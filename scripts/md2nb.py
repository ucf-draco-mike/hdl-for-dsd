#!/usr/bin/env python3
"""
md2nb.py — Convert HDL-for-DSD markdown labs & lectures to Jupyter notebooks.

Usage:
    python scripts/md2nb.py                      # convert everything
    python scripts/md2nb.py --labs                # labs only
    python scripts/md2nb.py --lectures            # lectures only
    python scripts/md2nb.py --day 5               # single day
    python scripts/md2nb.py --out notebooks/      # custom output root

The generated notebooks use a standard Python 3 kernel with:
  - %%writefile cells for Verilog source
  - ! shell commands for iverilog / vvp / yosys
  - Inline WaveDrom waveform rendering from VCD output

Design principle: content is IDENTICAL to the source markdown except for
the addition of executable cells and waveform rendering.  Re-running this
script overwrites previous output, keeping notebooks in sync with the repo.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys
import textwrap
from pathlib import Path
from typing import Optional

import nbformat
from nbformat.v4 import new_code_cell, new_markdown_cell, new_notebook

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
REPO_ROOT = Path(__file__).resolve().parent.parent
LABS_DIR = REPO_ROOT / "labs"
LECTURES_DIR = REPO_ROOT / "lectures"
DEFAULT_OUT = REPO_ROOT / "notebooks"

KERNEL_SPEC = {
    "display_name": "Python 3",
    "language": "python",
    "name": "python3",
}

# File extensions we inline as code
HDL_EXTS = {".v", ".sv", ".vh", ".svh"}
DATA_EXTS = {".hex", ".mem", ".dat"}
BUILD_EXTS = {".pcf"}

# ---------------------------------------------------------------------------
# Waveform helper — included once per notebook that has testbenches
# ---------------------------------------------------------------------------
WAVEDROM_HELPER = r'''
# --- WaveDrom / VCD rendering utilities (auto-generated — do not edit) ---
import json, re, subprocess
from IPython.display import HTML, display

def _vcd_to_wavedrom(vcd_path, max_cycles=80, signals=None):
    """
    Minimal VCD → WaveDrom JSON converter.
    Works for single-bit and multi-bit signals from iverilog output.
    """
    with open(vcd_path) as f:
        vcd = f.read()

    # Parse variable declarations
    var_map = {}  # id_code → (name, width)
    for m in re.finditer(
        r"\$var\s+\w+\s+(\d+)\s+(\S+)\s+(\S+)", vcd
    ):
        width, code, name = int(m.group(1)), m.group(2), m.group(3)
        if signals is None or name in signals:
            var_map[code] = (name, width)

    if not var_map:
        print(f"⚠  No matching signals in {vcd_path}")
        return None

    # Parse value changes
    changes = {}  # id_code → [(time, value), ...]
    current_time = 0
    for line in vcd.splitlines():
        line = line.strip()
        if line.startswith("#"):
            current_time = int(line[1:])
        elif line.startswith("b"):
            parts = line.split()
            if len(parts) == 2 and parts[1] in var_map:
                val = int(parts[0][1:], 2) if parts[0][1:] else 0
                changes.setdefault(parts[1], []).append((current_time, val))
        elif len(line) >= 2 and line[0] in "01xXzZ" and line[1:] in var_map:
            code = line[1:]
            val = {"0": 0, "1": 1, "x": "x", "X": "x", "z": "z", "Z": "z"}[line[0]]
            changes.setdefault(code, []).append((current_time, val))

    # Determine time step (smallest non-zero delta)
    all_times = sorted({t for ch in changes.values() for t, _ in ch})
    if len(all_times) < 2:
        return None
    deltas = [all_times[i+1] - all_times[i] for i in range(len(all_times)-1) if all_times[i+1] != all_times[i]]
    if not deltas:
        return None
    step = min(deltas)
    end_time = min(all_times[-1], step * max_cycles) if max_cycles else all_times[-1]
    sample_times = list(range(0, end_time + 1, step))[:max_cycles]

    # Build WaveDrom signal list
    wave_signals = []
    for code, (name, width) in sorted(var_map.items(), key=lambda x: x[1][0]):
        ch = sorted(changes.get(code, []))
        # Sample at each time point
        samples = []
        cur_val = 0
        ci = 0
        for t in sample_times:
            while ci < len(ch) and ch[ci][0] <= t:
                cur_val = ch[ci][1]
                ci += 1
            samples.append(cur_val)

        if width == 1:
            # Single-bit: WaveDrom wave string
            wave_str = ""
            for v in samples:
                if v == "x":
                    wave_str += "x"
                elif v == "z":
                    wave_str += "z"
                else:
                    wave_str += str(int(v))
            wave_signals.append({"name": name, "wave": wave_str})
        else:
            # Multi-bit: use '=' for data with labels
            wave_str = ""
            data = []
            prev = None
            for v in samples:
                if v == prev:
                    wave_str += "."
                else:
                    wave_str += "="
                    data.append(f"0x{v:X}" if isinstance(v, int) else str(v))
                    prev = v
            wave_signals.append({"name": name, "wave": wave_str, "data": data})

    return {"signal": wave_signals, "config": {"hscale": 1}}


def show_waves(vcd_path="dump.vcd", max_cycles=80, signals=None, width=900):
    """Render VCD waveforms inline using WaveDrom."""
    wd = _vcd_to_wavedrom(vcd_path, max_cycles=max_cycles, signals=signals)
    if wd is None:
        print("No waveform data to display.")
        return
    wd_json = json.dumps(wd)
    html = f"""
    <div id="wd_{id(wd):x}"></div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/wavedrom/3.5.0/wavedrom.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/wavedrom/3.5.0/skins/default.js"></script>
    <script>
    (function() {{
        var container = document.getElementById("wd_{id(wd):x}");
        container.innerHTML = '<div id="wd_tgt_{id(wd):x}"><script type="WaveDrom">' +
            JSON.stringify({wd_json}) + '</' + 'script></div>';
        WaveDrom.ProcessAll();
    }})();
    </script>
    """
    display(HTML(html))


def show_wavedrom(wave_dict, width=900):
    """Render a raw WaveDrom JSON dict inline."""
    wd_json = json.dumps(wave_dict)
    html = f"""
    <div id="wd_{id(wave_dict):x}"></div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/wavedrom/3.5.0/wavedrom.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/wavedrom/3.5.0/skins/default.js"></script>
    <script>
    (function() {{
        var container = document.getElementById("wd_{id(wave_dict):x}");
        container.innerHTML = '<div id="wd_tgt_{id(wave_dict):x}"><script type="WaveDrom">' +
            JSON.stringify({wd_json}) + '</' + 'script></div>';
        WaveDrom.ProcessAll();
    }})();
    </script>
    """
    display(HTML(html))

print("✓ WaveDrom helpers loaded — use show_waves('dump.vcd') after simulation")
'''.strip()

# ---------------------------------------------------------------------------
# Markdown parser helpers
# ---------------------------------------------------------------------------

def _split_md_sections(text: str) -> list[tuple[str, str]]:
    """
    Split markdown into (heading, body) tuples.
    The first tuple may have an empty heading (preamble).
    """
    parts: list[tuple[str, str]] = []
    lines = text.splitlines(keepends=True)
    current_heading = ""
    current_body: list[str] = []

    for line in lines:
        if re.match(r"^#{1,4}\s", line):
            # Flush previous section
            parts.append((current_heading, "".join(current_body)))
            current_heading = line.rstrip("\n")
            current_body = []
        else:
            current_body.append(line)

    parts.append((current_heading, "".join(current_body)))
    return parts


def _extract_code_fences(body: str) -> list[tuple[str, str, str]]:
    """
    Return list of (before, fence_content, lang) for each fenced code block.
    """
    pattern = re.compile(r"```(\w*)\n(.*?)```", re.DOTALL)
    results = []
    for m in pattern.finditer(body):
        results.append((body[: m.start()], m.group(2), m.group(1)))
    return results


def _find_file_refs(text: str, base_dir: Path) -> list[Path]:
    """Find referenced files like starter/foo.v or solution/bar.v."""
    refs = []
    for m in re.finditer(r'(?:starter|solution)/[\w./]+\.(?:v|sv|vh|svh|hex|mem|dat)', text):
        p = base_dir / m.group(0)
        if p.exists():
            refs.append(p)
    return refs


def _detect_exercise_files(ex_dir: Path) -> dict[str, list[Path]]:
    """
    For an exercise directory with starter/ and solution/ subdirs,
    return {"starter": [...], "solution": [...]} file lists.
    """
    result = {}
    for sub in ("starter", "solution"):
        d = ex_dir / sub
        if d.is_dir():
            files = sorted(
                p for p in d.iterdir()
                if p.suffix in HDL_EXTS | DATA_EXTS | BUILD_EXTS | {".v", ".sv"}
                and p.name != "Makefile"
            )
            result[sub] = files
    return result


# ---------------------------------------------------------------------------
# Notebook cell builders
# ---------------------------------------------------------------------------

def _md_cell(source: str) -> nbformat.NotebookNode:
    """Create a markdown cell, stripping trailing whitespace."""
    return new_markdown_cell(source.rstrip())


def _code_cell(source: str, lang: str = "python") -> nbformat.NotebookNode:
    """Create a code cell."""
    return new_code_cell(source.rstrip())


def _writefile_cell(filepath: str, content: str, lang_comment: str = "") -> nbformat.NotebookNode:
    """Create a %%writefile cell that writes HDL source to disk."""
    source = f"%%writefile {filepath}\n{content}"
    return new_code_cell(source.rstrip())


def _shell_cell(cmd: str, comment: str = "") -> nbformat.NotebookNode:
    """Create a shell command cell."""
    lines = []
    if comment:
        lines.append(f"# {comment}")
    lines.append(f"!{cmd}")
    return new_code_cell("\n".join(lines))


# ---------------------------------------------------------------------------
# Lab notebook builder
# ---------------------------------------------------------------------------

def _build_lab_notebook(day_dir: Path, day_num: int) -> nbformat.NotebookNode:
    """Build a notebook for a single lab day."""
    nb = new_notebook()
    nb.metadata["kernelspec"] = KERNEL_SPEC
    cells = nb["cells"]

    readme_path = day_dir / "README.md"
    if not readme_path.exists():
        print(f"  ⚠  No README.md in {day_dir}")
        return nb

    readme = readme_path.read_text()

    # Detect if this lab has testbenches → need wavedrom helper
    has_testbenches = any(day_dir.rglob("tb_*.v")) or any(day_dir.rglob("tb_*.sv"))

    # Setup cell
    cells.append(_code_cell(
        "import os, subprocess\n"
        'os.makedirs("build", exist_ok=True)'
    ))

    if has_testbenches:
        cells.append(_code_cell(WAVEDROM_HELPER))

    # Detect lab structure: flat (day01 style) vs exercise-dirs (day05+ style)
    exercise_dirs = sorted(
        d for d in day_dir.iterdir()
        if d.is_dir() and d.name.startswith("ex")
    )
    has_exercise_dirs = len(exercise_dirs) > 0
    has_flat_starters = (day_dir / "starter").is_dir()

    # Parse the README into sections
    sections = _split_md_sections(readme)

    # Two-pass approach: identify exercise boundaries, then emit with
    # deferred file injection (files appear AFTER all descriptive text
    # for that exercise, right before the next exercise or end-of-doc).
    #
    # Pass 1: tag each section with its exercise number
    tagged: list[tuple[int, str, str]] = []  # (ex_num, heading, body)
    current_ex = 0
    for heading, body in sections:
        ex_match = re.match(r"#{2,3}\s+(?:Exercise\s+)?(\d+)", heading)
        if ex_match:
            current_ex = int(ex_match.group(1))
        elif re.match(r"^#{1,2}\s", heading) and not re.match(r"^###", heading):
            # Non-exercise h1/h2 heading → end of exercise context
            current_ex = 0
        tagged.append((current_ex, heading, body))

    # Pass 2: emit cells, injecting exercise files at exercise transitions
    injected: set[int] = set()
    prev_ex = 0

    for i, (ex_num, heading, body) in enumerate(tagged):
        full_section = (heading + "\n" + body).strip()
        if not full_section:
            continue

        # If we're transitioning to a new exercise (or to a non-exercise
        # section after an exercise), inject files for the previous exercise
        if prev_ex > 0 and ex_num != prev_ex and prev_ex not in injected:
            _inject_exercise_files(
                cells, day_dir, prev_ex, injected,
                has_exercise_dirs, exercise_dirs, has_flat_starters
            )

        # Emit this section's markdown + code cells
        _emit_section_cells(cells, heading, body)
        prev_ex = ex_num

    # Inject files for the last exercise if not yet done
    if prev_ex > 0 and prev_ex not in injected:
        _inject_exercise_files(
            cells, day_dir, prev_ex, injected,
            has_exercise_dirs, exercise_dirs, has_flat_starters
        )

    # For overview-style READMEs that don't have inline exercise headings
    # but DO have exercise subdirectories, append sections for each exercise
    if has_exercise_dirs and not injected:
        cells.append(_md_cell("---\n## Exercise Files\n\n"
                              "The starter files for each exercise are below. "
                              "Edit the code, then run the simulation/build cells."))
        for ed in exercise_dirs:
            ex_match = re.match(r"ex(\d+)_?(.*)", ed.name)
            if not ex_match:
                continue
            ex_n = int(ex_match.group(1))
            ex_label = ex_match.group(2).replace("_", " ").title()
            _inject_exercise_files(
                cells, day_dir, ex_n, injected,
                has_exercise_dirs, exercise_dirs, has_flat_starters
            )

    return nb


def _emit_section_cells(cells: list, heading: str, body: str):
    """Emit markdown + code cells for one README section."""
    full_text = (heading + "\n" + body) if heading else body

    # Split around fenced code blocks
    fence_pattern = re.compile(r"(```\w*\n.*?```)", re.DOTALL)
    parts = fence_pattern.split(full_text)

    md_buffer = []

    for part in parts:
        fence_match = re.match(r"```(\w*)\n(.*?)```", part, re.DOTALL)
        if fence_match:
            # Flush accumulated markdown
            if md_buffer:
                combined = "".join(md_buffer).strip()
                if combined:
                    cells.append(_md_cell(combined))
                md_buffer = []

            lang = fence_match.group(1).lower()
            code = fence_match.group(2)

            if lang in ("bash", "sh", "shell", ""):
                # Join backslash-continued lines
                raw_lines = code.strip().splitlines()
                joined: list[str] = []
                accum = ""
                for rl in raw_lines:
                    stripped = rl.strip()
                    if stripped.endswith("\\"):
                        accum += stripped[:-1].rstrip() + " "
                    else:
                        accum += stripped
                        if accum:
                            joined.append(accum)
                        accum = ""
                if accum:
                    joined.append(accum)

                lines = [l for l in joined if l]
                is_toolchain = any(
                    cmd in " ".join(lines) for cmd in
                    ["make", "iverilog", "vvp", "gtkwave", "yosys",
                     "nextpnr", "icepack", "iceprog", "nix"]
                )
                if is_toolchain:
                    for line in lines:
                        if line.startswith("#"):
                            continue
                        # Replace gtkwave / make wave with inline waveform render
                        if ("gtkwave" in line and "--version" not in line) or \
                           re.match(r"make\s+wave\b", line):
                            cells.append(_code_cell(
                                "# Render waveforms inline (replaces GTKWave)\n"
                                "show_waves('dump.vcd')"
                            ))
                        else:
                            cells.append(_shell_cell(line))
                else:
                    md_buffer.append(part)
            elif lang in ("verilog", "systemverilog", "v", "sv"):
                md_buffer.append(part)
            else:
                md_buffer.append(part)
        else:
            md_buffer.append(part)

    # Flush remaining markdown
    if md_buffer:
        combined = "".join(md_buffer).strip()
        if combined:
            cells.append(_md_cell(combined))


def _inject_exercise_files(
    cells: list,
    day_dir: Path,
    ex_num: int,
    injected: set[int],
    has_exercise_dirs: bool,
    exercise_dirs: list[Path],
    has_flat_starters: bool,
):
    """Inject %%writefile cells for exercise starter files."""
    injected.add(ex_num)

    files_to_inject: list[tuple[str, str]] = []  # (display_name, content)

    if has_exercise_dirs:
        # Find exercise dir matching this number
        for ed in exercise_dirs:
            if ed.name.startswith(f"ex{ex_num}_") or ed.name == f"ex{ex_num}":
                starter_dir = ed / "starter"
                if starter_dir.is_dir():
                    for f in sorted(starter_dir.iterdir()):
                        if f.suffix in HDL_EXTS | DATA_EXTS and f.name != "Makefile":
                            files_to_inject.append((f.name, f.read_text()))
                    # Also grab the Makefile content for reference
                    mf = starter_dir / "Makefile"
                    if mf.exists():
                        files_to_inject.append(("Makefile", mf.read_text()))
                break

    elif has_flat_starters:
        # Flat structure: starter/ex{N}_*.v
        starter_dir = day_dir / "starter"
        pattern = re.compile(rf"ex{ex_num}_|w\d+d\d+_ex{ex_num}_", re.IGNORECASE)
        for f in sorted(starter_dir.iterdir()):
            if f.suffix in HDL_EXTS and pattern.search(f.name):
                files_to_inject.append((f.name, f.read_text()))

    if not files_to_inject:
        return

    cells.append(_md_cell(f"#### 📝 Exercise {ex_num} — Starter Files\n\n"
                          f"Edit the code below, then run the build cells."))

    for fname, content in files_to_inject:
        if Path(fname).suffix in HDL_EXTS:
            cells.append(_writefile_cell(fname, content))
        elif Path(fname).suffix in DATA_EXTS:
            cells.append(_writefile_cell(fname, content))
        elif fname == "Makefile":
            cells.append(_writefile_cell("Makefile", content))

    # Add simulation cell if there's a testbench among the files
    tb_files = [f for f, _ in files_to_inject if f.startswith("tb_")]
    src_files = [f for f, _ in files_to_inject
                 if f.endswith((".v", ".sv")) and not f.startswith("tb_") and f != "Makefile"]
    if tb_files and src_files:
        tb = tb_files[0]
        srcs = " ".join(src_files)
        cells.append(_shell_cell(
            f"iverilog -g2012 -Wall -o sim.vvp {tb} {srcs} && vvp sim.vvp",
            "Compile and simulate"
        ))
        cells.append(_code_cell("show_waves('dump.vcd')"))


# ---------------------------------------------------------------------------
# Lecture notebook builder
# ---------------------------------------------------------------------------

def _build_lecture_notebook(day_dir: Path, day_num: int) -> nbformat.NotebookNode:
    """Build a notebook for a single lecture day."""
    nb = new_notebook()
    nb.metadata["kernelspec"] = KERNEL_SPEC
    cells = nb["cells"]

    # Find the readme
    readme_candidates = [
        day_dir / f"day{day_num:02d}_readme.md",
        day_dir / "README.md",
    ]
    readme_path = None
    for rc in readme_candidates:
        if rc.exists():
            readme_path = rc
            break

    if readme_path is None:
        print(f"  ⚠  No readme in {day_dir}")
        return nb

    readme = readme_path.read_text()

    # Title cell
    sections = _split_md_sections(readme)
    for heading, body in sections:
        combined = (heading + "\n" + body).strip()
        if combined:
            cells.append(_md_cell(combined))

    # Inline code examples
    code_dir = day_dir / "code"
    if code_dir.is_dir():
        cells.append(_md_cell("---\n## Code Examples"))
        for f in sorted(code_dir.iterdir()):
            if f.suffix in HDL_EXTS:
                content = f.read_text()
                cells.append(_md_cell(f"### `{f.name}`"))
                cells.append(_md_cell(f"```verilog\n{content}```"))

    # Include quiz if present
    quiz_candidates = [
        day_dir / f"day{day_num:02d}_quiz.md",
        day_dir / "quiz.md",
    ]
    for qp in quiz_candidates:
        if qp.exists():
            cells.append(_md_cell("---\n## Pre-Class Self-Check Quiz"))
            quiz_text = qp.read_text()
            # Strip the top heading if it duplicates
            quiz_text = re.sub(r"^#[^\n]*\n(?:##[^\n]*\n)?", "", quiz_text, count=1)
            cells.append(_md_cell(quiz_text.strip()))
            break

    return nb


# ---------------------------------------------------------------------------
# Top-level orchestration
# ---------------------------------------------------------------------------

def _day_num_from_dir(d: Path) -> Optional[int]:
    """Extract day number from directory name like week1_day01."""
    m = re.search(r"day(\d+)", d.name)
    return int(m.group(1)) if m else None


def convert_labs(out_root: Path, day_filter: Optional[int] = None):
    """Convert all lab days (or a single day) to notebooks."""
    out_dir = out_root / "labs"
    out_dir.mkdir(parents=True, exist_ok=True)

    for day_dir in sorted(LABS_DIR.iterdir()):
        if not day_dir.is_dir() or not day_dir.name.startswith("week"):
            continue
        day_num = _day_num_from_dir(day_dir)
        if day_num is None:
            continue
        if day_filter is not None and day_num != day_filter:
            continue

        print(f"  Lab day {day_num:02d}: {day_dir.name}")
        nb = _build_lab_notebook(day_dir, day_num)
        out_path = out_dir / f"lab_day{day_num:02d}.ipynb"
        with open(out_path, "w") as f:
            nbformat.write(nb, f)
        print(f"    → {out_path.relative_to(REPO_ROOT)}")


def convert_lectures(out_root: Path, day_filter: Optional[int] = None):
    """Convert all lecture days (or a single day) to notebooks."""
    out_dir = out_root / "lectures"
    out_dir.mkdir(parents=True, exist_ok=True)

    for day_dir in sorted(LECTURES_DIR.iterdir()):
        if not day_dir.is_dir() or not day_dir.name.startswith("week"):
            continue
        day_num = _day_num_from_dir(day_dir)
        if day_num is None:
            continue
        if day_filter is not None and day_num != day_filter:
            continue

        print(f"  Lecture day {day_num:02d}: {day_dir.name}")
        nb = _build_lecture_notebook(day_dir, day_num)
        out_path = out_dir / f"lecture_day{day_num:02d}.ipynb"
        with open(out_path, "w") as f:
            nbformat.write(nb, f)
        print(f"    → {out_path.relative_to(REPO_ROOT)}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert HDL-for-DSD markdown to Jupyter notebooks"
    )
    parser.add_argument("--labs", action="store_true", help="Convert labs only")
    parser.add_argument("--lectures", action="store_true",
                        help="Convert lectures only")
    parser.add_argument("--day", type=int, default=None,
                        help="Convert a single day number")
    parser.add_argument("--out", type=str, default=str(DEFAULT_OUT),
                        help="Output directory root")
    args = parser.parse_args()

    out_root = Path(args.out)
    do_labs = not args.lectures  # do labs unless --lectures only
    do_lectures = not args.labs  # do lectures unless --labs only

    print(f"md2nb: converting HDL-for-DSD → {out_root.relative_to(REPO_ROOT)}/")
    print()

    if do_labs:
        print("Converting labs:")
        convert_labs(out_root, args.day)
        print()

    if do_lectures:
        print("Converting lectures:")
        convert_lectures(out_root, args.day)
        print()

    print("Done.")


if __name__ == "__main__":
    main()
