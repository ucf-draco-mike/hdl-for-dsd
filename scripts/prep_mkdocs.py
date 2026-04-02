#!/usr/bin/env python3
"""
prep_mkdocs.py — Assemble MkDocs source directory from repo content.

Usage:
    python3 scripts/prep_mkdocs.py          # prep only
    python3 scripts/prep_mkdocs.py --serve   # prep + mkdocs serve
    python3 scripts/prep_mkdocs.py --build   # prep + mkdocs build
"""

import json, os, re, shutil, subprocess, sys, zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DOCS = REPO / "docs_src"
YOUTUBE_FILE = REPO / "youtube_ids.json"

# ─── JupyterLab configuration ─────────────────────────────────────
# Base URL for JupyterLab file links.
# Default assumes `jupyter lab` is launched from the repo root,
# so file paths are relative to the working directory.
# Override with HDL_JUPYTER_BASE for institutional JupyterHub deployments.
JUPYTER_LAB_BASE = os.environ.get(
    "HDL_JUPYTER_BASE",
    "http://localhost:8888/lab/tree"
)
GITHUB_RAW_BASE = "https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main"
JUPYTER_EXTENSIONS = {".v", ".sv", ".hex", ".py", ".ipynb", ".md"}

DAYS = [
    (1,  "week1_day01", "Welcome to Hardware Thinking"),
    (2,  "week1_day02", "Combinational Building Blocks"),
    (3,  "week1_day03", "Procedural Combinational Logic"),
    (4,  "week1_day04", "Sequential Logic: FFs, Clocks & Counters"),
    (5,  "week2_day05", "Counters, Shift Registers & Debouncing"),
    (6,  "week2_day06", "Testbenches & AI-Assisted Verification"),
    (7,  "week2_day07", "Finite State Machines"),
    (8,  "week2_day08", "Hierarchy, Parameters & Generate"),
    (9,  "week3_day09", "Memory: RAM, ROM & Block RAM"),
    (10, "week3_day10", "Numerical Architectures & PPA"),
    (11, "week3_day11", "UART TX: Communication Interface"),
    (12, "week3_day12", "UART RX, SPI & Protocol Verification"),
    (13, "week4_day13", "SystemVerilog for Design"),
    (14, "week4_day14", "Verification, AI Testing & PPA Analysis"),
    (15, "week4_day15", "Final Project: Build Day"),
    (16, "week4_day16", "Final Project Demos & Course Wrap"),
]

def symlink(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() or dst.is_symlink():
        dst.unlink()
    dst.symlink_to(os.path.relpath(src, dst.parent))

def load_youtube_ids():
    if YOUTUBE_FILE.exists():
        raw = json.loads(YOUTUBE_FILE.read_text())
        return {k: v for k, v in raw.items() if not k.startswith("_") and v}
    return {}

def get_slides(day_num, dir_name, yt_ids):
    slide_dir = REPO / "lectures" / dir_name
    if not slide_dir.exists():
        return []
    results = []
    for s in sorted(slide_dir.glob(f"d{day_num:02d}_s*.html")):
        parts = s.stem.split("_", 2)
        seg = int(parts[1][1]) if len(parts) >= 2 else 0
        key = f"d{day_num:02d}_s{seg}"
        try:
            html = s.read_text(encoding="utf-8")
            m = re.search(r"<title>Day \d+\.\d+: ([^<\u2014]+)", html)
            title = m.group(1).strip() if m else parts[2].replace("_", " ").title()
        except Exception:
            title = parts[2].replace("_", " ").title() if len(parts) >= 3 else s.stem
        results.append({
            "seg": seg, "title": title, "key": key,
            "slide_path": f"../../lectures/{dir_name}/{s.name}",
            "yt_id": yt_ids.get(key),
        })
    return results

def generate_day_page(day_num, dir_name, title, yt_ids, code_assets=None):
    slides = get_slides(day_num, dir_name, yt_ids)
    wk = (day_num - 1) // 4 + 1
    dz = f"{day_num:02d}"
    deliverables = {d[0]: d[2] for d in DAYS}  # not used yet but useful
    lines = []
    lines.append(f"---\ntitle: \"Day {day_num}: {title}\"\n---\n")
    lines.append(f"# Day {day_num}: {title}\n")
    lines.append(f'<p class="subtitle">Week {wk} · Session {day_num} of 16</p>\n')

    # Cross-cutting thread badges
    day_threads = threads_for_day(day_num)
    if day_threads:
        badges = " ".join(
            f'<span class="thread-pill" style="border-color:{color}; color:{color}">'
            f'{emoji} {name}</span>'
            for emoji, name, color in day_threads
        )
        lines.append(f'<div class="day-thread-bar">{badges}</div>\n')

    # Nav cards — add code card if assets exist
    quiz_exists = (REPO / "lectures" / dir_name / f"day{dz}_quiz.md").exists()
    has_code = code_assets and day_num in code_assets
    lab_nb_chk = (REPO / "notebooks" / "labs" / f"lab_day{dz}.ipynb").exists()
    lec_nb_chk = (REPO / "notebooks" / "lectures" / f"lecture_day{dz}.ipynb").exists()
    has_notebooks = lab_nb_chk or lec_nb_chk
    n_cards = 2 + (1 if quiz_exists else 0) + (1 if has_notebooks else 0)
    grid_class = "card-grid--4" if n_cards == 4 else "card-grid--3"
    lines.append(f'<div class="card-grid {grid_class}" markdown>\n')
    lines.append(f'<div class="nav-card" markdown>\n:material-clipboard-text:{{ .card-icon }}\n\n**Daily Plan**\n\nSession timeline & instructor notes\n\n[:octicons-arrow-right-16: View plan](plan.md)\n</div>\n')
    lines.append(f'<div class="nav-card" markdown>\n:material-flask:{{ .card-icon }}\n\n**Lab Guide**\n\n{len(slides)} exercises · hands-on\n\n[:octicons-arrow-right-16: View lab](lab.md)\n</div>\n')
    if quiz_exists:
        lines.append(f'<div class="nav-card" markdown>\n:material-help-circle:{{ .card-icon }}\n\n**Pre-Class Quiz**\n\nSelf-check questions\n\n[:octicons-arrow-right-16: Take quiz](quiz.md)\n</div>\n')
    # Notebooks card — lab + lecture .ipynb
    if has_notebooks:
        nb_desc_parts = []
        if lab_nb_chk:
            nb_desc_parts.append("Lab notebook")
        if lec_nb_chk:
            nb_desc_parts.append("lecture notebook")
        nb_desc = " · ".join(nb_desc_parts)
        lines.append(f'<div class="nav-card" markdown>\n'
                     f':material-notebook:{{ .card-icon }}\n\n'
                     f'**Notebooks**\n\n'
                     f'{nb_desc}\n\n')
        if lab_nb_chk:
            nb_gh = f"{GITHUB_RAW_BASE}/notebooks/labs/lab_day{dz}.ipynb"
            lines.append(f'[:material-notebook: Lab Notebook]({nb_gh}){{ target=_blank }}\n')
        if lec_nb_chk:
            nb_gh = f"{GITHUB_RAW_BASE}/notebooks/lectures/lecture_day{dz}.ipynb"
            lines.append(f'[:material-notebook-outline: Lecture Notebook]({nb_gh}){{ target=_blank }}\n')
        lines.append(f'</div>\n')
    lines.append('</div>\n')

    # Videos section
    lines.append("## :material-play-circle: Pre-Class Video Segments\n")
    if not slides:
        lines.append("*No recorded lecture segments for this session.*\n")
    else:
        yt_count = sum(1 for s in slides if s["yt_id"])
        if yt_count > 0:
            lines.append(f"*{yt_count} of {len(slides)} segments recorded.*\n")

        for s in slides:
            lines.append(f'### Segment {s["seg"]}: {s["title"]}\n')
            if s["yt_id"]:
                lines.append(f'<div class="video-container">')
                lines.append(f'<iframe src="https://www.youtube.com/embed/{s["yt_id"]}?rel=0" '
                             f'frameborder="0" allowfullscreen loading="lazy"></iframe>')
                lines.append(f'</div>\n')
                lines.append(f'[:material-youtube: Watch on YouTube](https://www.youtube.com/watch?v={s["yt_id"]})'
                             f'{{ .md-button target="_blank" }} '
                             f'[:material-presentation: View Slides]({s["slide_path"]})'
                             f'{{ .md-button .md-button--primary target="_blank" }}\n')
            else:
                lines.append(f'!!! info "Video coming soon"\n    This segment has not been recorded yet.\n')
                lines.append(f'[:material-presentation: View Slides]({s["slide_path"]})'
                             f'{{ .md-button .md-button--primary target="_blank" }}\n')

    # Lecture examples section
    lec_code_dir = REPO / "lectures" / dir_name / "code"
    if lec_code_dir.exists():
        code_files = sorted(lec_code_dir.glob("*.*"))
        code_files = [f for f in code_files if f.suffix in {".v", ".sv", ".mem", ".hex"}]
        if code_files:
            lines.append("## :material-code-braces: Lecture Code Examples\n")
            lines.append("Code shown during the pre-class video. Use these as reference ")
            lines.append("when working on the lab exercises.\n")
            for f in code_files:
                rel = f.relative_to(REPO)
                gh = f"{GITHUB_RAW_BASE}/{rel}"
                icon = ":material-chip:" if f.suffix in {".v", ".sv"} else ":material-file:"
                # Derive a human-readable label
                label = f.stem.replace(f"day{dz}_", "").replace("_", " ").title()
                lines.append(f"- {icon} **{label}** — [`{f.name}`]({gh}){{ target=_blank }}")
            lines.append("")

    return "\n".join(lines)


# ─── Lab code asset discovery ────────────────────────────────────

def discover_lab_code():
    """Scan labs/ and return code asset metadata per day.

    Returns: { day_num: { "exercises": [...], "shared_files": [...] } }
    """
    day_assets = {}

    for day_num, dir_name, title in DAYS:
        lab_dir = REPO / "labs" / dir_name
        if not lab_dir.exists():
            continue

        exercises = []
        shared_files = []

        # Collect shared files (top-level Makefile, pcf)
        for pattern in ["Makefile", "*.pcf"]:
            for f in lab_dir.glob(pattern):
                if f.is_file():
                    shared_files.append(f)

        has_exercise_dirs = any(lab_dir.glob("ex*"))

        if not has_exercise_dirs:
            # Week 1 flat layout: starter/ and solution/
            starter_dir = lab_dir / "starter"
            solution_dir = lab_dir / "solution"
            if starter_dir.is_dir():
                grouped = _group_flat_exercises(starter_dir)
                for ex_name, files in grouped.items():
                    has_sol = solution_dir.is_dir() and all(
                        (solution_dir / f.name).exists() for f in files
                    )
                    sol_files = [solution_dir / f.name for f in files] if has_sol else []
                    exercises.append({
                        "name": ex_name,
                        "label": _exercise_label(ex_name),
                        "starter_files": sorted(files, key=lambda f: f.name),
                        "solution_files": sorted(sol_files, key=lambda f: f.name),
                    })
        else:
            for ex_dir in sorted(lab_dir.glob("ex*")):
                if not ex_dir.is_dir():
                    continue
                starter_dir = ex_dir / "starter"
                solution_dir = ex_dir / "solution"
                src_dir = starter_dir if starter_dir.is_dir() else ex_dir
                files = sorted(
                    (f for f in src_dir.iterdir() if f.is_file() and f.name != ".DS_Store"),
                    key=lambda f: f.name,
                )
                has_sol = solution_dir.is_dir() and any(solution_dir.iterdir())
                sol_files = sorted(
                    (f for f in solution_dir.iterdir() if f.is_file() and f.name != ".DS_Store"),
                    key=lambda f: f.name,
                ) if has_sol else []

                exercises.append({
                    "name": ex_dir.name,
                    "label": _exercise_label(ex_dir.name),
                    "starter_files": files,
                    "solution_files": sol_files,
                })

        if exercises or shared_files:
            day_assets[day_num] = {
                "exercises": exercises,
                "shared_files": shared_files,
                "lab_dir": lab_dir,
            }

    return day_assets


def build_lab_zips(code_assets):
    """Create zip archives in docs_src/downloads/ for MkDocs to pick up.

    Returns updated code_assets with zip relative paths added.
    """
    dl_dir = DOCS / "downloads"
    dl_dir.mkdir(parents=True, exist_ok=True)

    for day_num, assets in code_assets.items():
        dz = f"{day_num:02d}"
        day_dl = dl_dir / f"day{dz}"
        day_dl.mkdir(parents=True, exist_ok=True)
        lab_dir = assets["lab_dir"]

        all_files = list(assets["shared_files"])

        for ex in assets["exercises"]:
            # Starter zip
            zip_name = f"{ex['name']}_starter.zip"
            zip_path = day_dl / zip_name
            with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
                for f in ex["starter_files"]:
                    zf.write(f, f"{ex['name']}/starter/{f.name}")
            ex["starter_zip"] = f"../../downloads/day{dz}/{zip_name}"

            # Solution zip
            if ex["solution_files"]:
                sol_zip_name = f"{ex['name']}_solution.zip"
                sol_zip_path = day_dl / sol_zip_name
                with zipfile.ZipFile(sol_zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
                    for f in ex["solution_files"]:
                        zf.write(f, f"{ex['name']}/solution/{f.name}")
                ex["solution_zip"] = f"../../downloads/day{dz}/{sol_zip_name}"
            else:
                ex["solution_zip"] = None

            all_files.extend(ex["starter_files"])

        # Day-level all-starter zip
        all_zip_name = f"day{dz}_all_starter.zip"
        all_zip_path = day_dl / all_zip_name
        with zipfile.ZipFile(all_zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for f in all_files:
                try:
                    arcname = f"day{dz}_lab/{f.relative_to(lab_dir)}"
                except ValueError:
                    arcname = f"day{dz}_lab/{f.name}"
                zf.write(f, arcname)
        assets["all_zip"] = f"../../downloads/day{dz}/{all_zip_name}"

    total = sum(1 for _ in dl_dir.rglob("*.zip"))
    print(f"  Created: {total} zip files → docs_src/downloads/")
    return code_assets


def generate_code_page(day_num, code_assets):
    """Generate a code.md page for a given day with download links and JupyterLab links."""
    if day_num not in code_assets:
        return None

    assets = code_assets[day_num]
    dz = f"{day_num:02d}"
    lines = []
    lines.append(f"---\ntitle: \"Day {day_num} — Code & Notebooks\"\n---\n")
    lines.append(f"# :material-download-circle: Day {day_num} — Code & Notebooks\n")

    # Download-all button
    if assets.get("all_zip"):
        lines.append(f'[:material-folder-download: Download All Starter Code (.zip)]({assets["all_zip"]})'
                     f'{{ .md-button .md-button--primary }}\n')

    # JupyterLab banner
    lines.append(f'!!! tip "Open files in JupyterLab"\n'
                 f'    Click the **:material-notebook: Open in Jupyter** links below to open files '
                 f'directly in your local JupyterLab instance.\n'
                 f'    Start JupyterLab from the repo root: `cd hdl-for-dsd && jupyter lab`\n')

    # Lab notebook (.ipynb generated from README by jupytext)
    lab_dir = assets["lab_dir"]
    nb_name = f"{lab_dir.name}_lab.ipynb"
    nb_path = lab_dir / nb_name
    if nb_path.exists():
        nb_rel = nb_path.relative_to(REPO)
        nb_gh = f"{GITHUB_RAW_BASE}/{nb_rel}"
        nb_jup = f"{JUPYTER_LAB_BASE}/{nb_rel}"
        lines.append("## :material-notebook: Lab Notebook\n")
        lines.append(f"The full lab guide is also available as a Jupyter notebook "
                     f"(auto-generated from the lab markdown via `jupytext`).\n")
        lines.append(f'[:material-notebook: Open `{nb_name}` in Hub]({nb_jup})'
                     f'{{ .md-button .md-button--primary target=_blank }} '
                     f'[:material-github: View on GitHub]({nb_gh})'
                     f'{{ .md-button target=_blank }}\n')

    # Shared files
    if assets["shared_files"]:
        lines.append("## Shared Files\n")
        lines.append("These files are shared across all exercises for this day.\n")
        lines.append("| File | Links |")
        lines.append("|------|-------|")
        for f in sorted(assets["shared_files"], key=lambda f: f.name):
            rel = f.relative_to(REPO)
            gh = f"{GITHUB_RAW_BASE}/{rel}"
            links = f"[:material-github: GitHub]({gh}){{ target=_blank }}"
            if f.suffix.lower() in JUPYTER_EXTENSIONS or f.name == "Makefile":
                jup = f"{JUPYTER_LAB_BASE}/{rel}"
                links += f" · [:material-notebook: Open in Jupyter]({jup}){{ target=_blank }}"
            icon = _file_icon_md(f)
            lines.append(f"| {icon} `{f.name}` | {links} |")
        lines.append("")

    # Per-exercise sections
    for ex in assets["exercises"]:
        lines.append(f"## {ex['label']}\n")

        # Zip download buttons
        btns = f'[:material-download: Starter .zip]({ex["starter_zip"]}){{ .md-button }}'
        if ex.get("solution_zip"):
            btns += f' [:material-check-circle: Solution .zip]({ex["solution_zip"]}){{ .md-button }}'
        lines.append(btns + "\n")

        # File table
        lines.append("| File | Links |")
        lines.append("|------|-------|")
        for f in ex["starter_files"]:
            rel = f.relative_to(REPO)
            gh = f"{GITHUB_RAW_BASE}/{rel}"
            links = f"[:material-github: GitHub]({gh}){{ target=_blank }}"
            if f.suffix.lower() in JUPYTER_EXTENSIONS or f.name == "Makefile":
                jup = f"{JUPYTER_LAB_BASE}/{rel}"
                links += f" · [:material-notebook: Open in Jupyter]({jup}){{ target=_blank }}"
            icon = _file_icon_md(f)
            lines.append(f"| {icon} `{f.name}` | {links} |")
        lines.append("")

    return "\n".join(lines)


def _group_flat_exercises(starter_dir):
    """Group files in a flat starter/ dir by exercise prefix (ex1_, ex2_, etc.)."""
    groups = {}
    for f in sorted(starter_dir.iterdir()):
        if not f.is_file() or f.name == ".DS_Store":
            continue
        m = re.match(r"(ex\d+)_", f.name)
        key = m.group(1) if m else "_misc"
        groups.setdefault(key, []).append(f)
    result = {}
    for key, files in groups.items():
        if len(files) == 1:
            result[files[0].stem] = files
        else:
            result[key + "_files"] = files
    return result


def _exercise_label(ex_name):
    """Convert ex1_alu_testbench → 'Ex 1 — ALU Testbench'."""
    m = re.match(r"ex(\d+)_(.*)", ex_name)
    if m:
        return f"Ex {m.group(1)} — {m.group(2).replace('_', ' ').title()}"
    return ex_name.replace("_", " ").title()


FILE_ICONS = {".v": ":material-chip:", ".sv": ":material-chip:",
              ".hex": ":material-hexadecimal:", ".pcf": ":material-pin:",
              ".md": ":material-text:", ".py": ":material-language-python:",
              ".ipynb": ":material-notebook:"}

def _file_icon_md(f):
    if f.name == "Makefile":
        return ":material-cog:"
    return FILE_ICONS.get(f.suffix.lower(), ":material-file:")


WEEK_META = [
    (1, "Verilog Foundations & Combinational Design", "#1565C0"),
    (2, "Sequential Design, Verification & AI Testing", "#7B1FA2"),
    (3, "Memory, Communication & Numerical Architectures", "#E65100"),
    (4, "Advanced Design, Verification & Final Project", "#2E7D32"),
]

# Cross-cutting threads: (emoji, short_name, color, set_of_day_numbers)
THREADS = [
    ("🤖", "AI Verification", "#7B1FA2", {6, 8, 12, 14, 16}),
    ("📊", "PPA Analysis",    "#2E7D32", {3, 8, 10, 12, 14}),
    ("⚙️", "Constraints",     "#E65100", {3, 7, 8, 10, 14}),
    ("🔧", "AI Literacy",     "#1565C0", {6, 12, 14, 16}),
]

def threads_for_day(day_num):
    """Return list of (emoji, name, color) for threads active on a given day."""
    return [(e, n, c) for e, n, c, days in THREADS if day_num in days]



def generate_lab_page(day_num, dir_name, code_assets):
    """Generate an enriched lab.md by reading the lab README and injecting code links.

    For days with per-exercise headings (days 1-8), injects a compact code
    admonition after each exercise heading. For days without (9+), appends
    a consolidated code section at the end.

    Returns None if no README exists.
    """
    lab_readme = REPO / "labs" / dir_name / "README.md"
    if not lab_readme.exists():
        return None

    dz = f"{day_num:02d}"
    content = lab_readme.read_text(encoding="utf-8")
    has_code = day_num in code_assets
    assets = code_assets.get(day_num, {})

    # ── Build download banner ──────────────────────────────────────
    banner_lines = []

    if has_code and assets.get("all_zip"):
        banner_lines.append(
            f'!!! abstract "Starter Code & Notebooks"\n'
            f'    [:material-folder-download: Download All Starter Code (.zip)]'
            f'({assets["all_zip"]}){{ .md-button .md-button--primary }}\n'
        )
        # Notebook link
        nb_path = REPO / "notebooks" / "labs" / f"lab_day{dz}.ipynb"
        if nb_path.exists():
            nb_rel = nb_path.relative_to(REPO)
            nb_jup = f"{JUPYTER_LAB_BASE}/{nb_rel}"
            nb_gh = f"{GITHUB_RAW_BASE}/{nb_rel}"
            banner_lines.append(
                f'    [:material-notebook: Open in JupyterLab]({nb_jup})'
                f'{{ .md-button target=_blank }}\n'
                f'    [:material-download: Download .ipynb](../../notebooks/labs/lab_day{dz}.ipynb)'
                f'{{ .md-button target=_blank }}\n'
                f'    [:material-github: View on GitHub]({nb_gh})'
                f'{{ .md-button target=_blank }}\n'
            )
        banner_lines.append(
            f'    Individual exercise downloads and file links are below each exercise.\n'
        )

    banner = "\n".join(banner_lines)

    # ── Build per-exercise admonitions ─────────────────────────────
    ex_admonitions = {}  # exercise_number -> admonition string
    if has_code:
        for ex in assets.get("exercises", []):
            m = re.match(r"ex(\d+)", ex["name"])
            if not m:
                continue
            ex_num = int(m.group(1))

            parts = []
            if ex.get("starter_zip"):
                parts.append(
                    f'[:material-download: Starter .zip]({ex["starter_zip"]})'
                    f'{{ .md-button }}'
                )
            if ex.get("solution_zip"):
                parts.append(
                    f'[:material-check-circle: Solution .zip]({ex["solution_zip"]})'
                    f'{{ .md-button }}'
                )
            # GitHub + Jupyter links for all starter files
            for sf in ex.get("starter_files", []):
                gh = f"{GITHUB_RAW_BASE}/{sf.relative_to(REPO)}"
                parts.append(
                    f'[:material-github: `{sf.name}`]({gh}){{ target=_blank }}'
                )
                if sf.suffix.lower() in JUPYTER_EXTENSIONS or sf.name == "Makefile":
                    jup = f"{JUPYTER_LAB_BASE}/{sf.relative_to(REPO)}"
                    parts.append(
                        f'[:material-notebook: Jupyter]({jup}){{ target=_blank }}'
                    )

            if parts:
                btns = " ".join(parts)
                ex_admonitions[ex_num] = (
                    f'\n!!! code "Exercise {ex_num} — Code"\n'
                    f'    {btns}\n\n'
                )

    # ── Inject into content ────────────────────────────────────────
    lines = content.split("\n")
    output = []
    banner_inserted = False
    exercises_found = 0

    # Pattern: ## Exercise N or ### Exercise N (with various suffixes)
    ex_heading_re = re.compile(
        r'^(#{2,3})\s+Exercise\s+(\d+)\b', re.IGNORECASE
    )

    for i, line in enumerate(lines):
        output.append(line)

        # Insert banner after first heading
        if not banner_inserted and line.startswith("# ") and banner:
            output.append("")
            output.append(banner)
            banner_inserted = True
            continue

        # Check for exercise heading
        m = ex_heading_re.match(line)
        if m:
            ex_num = int(m.group(2))
            exercises_found += 1
            if ex_num in ex_admonitions:
                output.append(ex_admonitions[ex_num])

    # If banner wasn't inserted (no H1), prepend it
    if not banner_inserted and banner:
        output.insert(0, banner + "\n")

    # For days without exercise headings, append consolidated code section
    if exercises_found <= 1 and has_code and assets.get("exercises"):
        output.append("\n---\n")
        output.append("## :material-download: Exercise Code\n")
        for ex in assets["exercises"]:
            output.append(f"### {ex['label']}\n")
            parts = []
            if ex.get("starter_zip"):
                parts.append(
                    f'[:material-download: Starter .zip]({ex["starter_zip"]})'
                    f'{{ .md-button }}'
                )
            if ex.get("solution_zip"):
                parts.append(
                    f'[:material-check-circle: Solution .zip]({ex["solution_zip"]})'
                    f'{{ .md-button }}'
                )
            if parts:
                output.append(" ".join(parts) + "\n")

            # File list
            for sf in ex.get("starter_files", []):
                rel = sf.relative_to(REPO)
                gh = f"{GITHUB_RAW_BASE}/{rel}"
                icon = _file_icon_md(sf)
                output.append(f"- {icon} [`{sf.name}`]({gh}){{ target=_blank }}")
            output.append("")

    return "\n".join(output)


def generate_homepage():
    """Generate a visually rich landing page."""
    lines = []
    lines.append("---\nhide:\n  - toc\ntitle: Course Overview\n---\n")

    # Hero
    lines.append("# Accelerated HDL for Digital System Design\n")
    lines.append('<p class="subtitle">UCF · College of Engineering & Computer Science · Department of ECE</p>\n')
    lines.append("A 4-week intensive course in Verilog and digital system design. "
                 "Open-source toolchain, real FPGA hardware, AI-assisted verification.\n")

    # Quick-start nav cards (TLDR row)
    lines.append('<div class="card-grid card-grid--3" markdown>\n')
    lines.append('<div class="nav-card" markdown>\n'
                 ':material-rocket-launch:{ .card-icon }\n\n'
                 '**New here?**\n\n'
                 'Set up your environment and get ready for Day 1.\n\n'
                 '[:octicons-arrow-right-16: Get Started](getting-started.md)\n'
                 '</div>\n')
    lines.append('<div class="nav-card" markdown>\n'
                 ':material-sitemap:{ .card-icon }\n\n'
                 '**How this site works**\n\n'
                 'Understand the page layout, repo structure, and daily workflow.\n\n'
                 '[:octicons-arrow-right-16: Site Guide](site-guide.md)\n'
                 '</div>\n')
    lines.append('<div class="nav-card" markdown>\n'
                 ':material-tools:{ .card-icon }\n\n'
                 '**Setup details**\n\n'
                 'Full platform-specific instructions and troubleshooting.\n\n'
                 '[:octicons-arrow-right-16: Toolchain Setup](setup.md)\n'
                 '</div>\n')
    lines.append('</div>\n')

    # Stat cards
    lines.append('<div class="stat-grid" markdown>\n')
    for val, label, sub in [
        ("16", "Sessions", "4 weeks × 4 days"),
        ("12.2h", "Video Content", "56 segments"),
        ("38+", "Lab Exercises", "Hands-on every day"),
        ("iCE40", "FPGA Platform", "Nandland Go Board"),
    ]:
        lines.append(f'<div class="stat-card">\n<div class="stat-value">{val}</div>\n'
                     f'<div class="stat-label">{label}</div>\n'
                     f'<div class="stat-sub">{sub}</div>\n</div>\n')
    lines.append('</div>\n')

    # Cross-cutting threads (derived from THREADS constant)
    # Full display names for the homepage cards
    _thread_full_names = {
        "AI Verification": "AI-Assisted Verification",
        "PPA Analysis":    "PPA Analysis",
        "Constraints":     "Constraint-Based Design",
        "AI Literacy":     "AI Tool Literacy",
    }
    lines.append("## Cross-Cutting Threads\n")
    lines.append('<div class="card-grid card-grid--4">\n')
    for idx, (emoji, short_name, color, day_set) in enumerate(THREADS):
        full_name = _thread_full_names.get(short_name, short_name)
        days_str = " → ".join(f"D{d}" for d in sorted(day_set))
        tid = short_name.lower().replace(" ", "-")
        lines.append(f'<div class="thread-card thread-filter" data-thread="{tid}" '
                     f'style="border-color: {color}; cursor: pointer;" tabindex="0">\n'
                     f'<div class="thread-icon">{emoji}</div>\n'
                     f'<div class="thread-name" style="color: {color};">{full_name}</div>\n'
                     f'<div class="thread-days">{days_str}</div>\n</div>\n')
    lines.append('</div>\n')

    # Weekly arc with day cards
    lines.append("## Weekly Arc\n")
    for wk_num, wk_title, wk_color in WEEK_META:
        lines.append(f'<div class="week-section">\n'
                     f'<div class="week-header">\n'
                     f'<span class="week-num" style="background:{wk_color}">{wk_num}</span>\n'
                     f'<span class="week-title">{wk_title}</span>\n'
                     f'</div>\n')
        lines.append('<div class="card-grid card-grid--4">\n')
        for day_num, dir_name, day_title in DAYS:
            if (day_num - 1) // 4 + 1 != wk_num:
                continue
            dz = f"{day_num:02d}"
            day_threads = threads_for_day(day_num)
            thread_ids = " ".join(
                n.lower().replace(" ", "-") for _, n, _ in day_threads
            )
            thread_icons = ""
            if day_threads:
                badges = " ".join(
                    f'<span class="thread-badge" title="{name}" style="color:{color}">{emoji}</span>'
                    for emoji, name, color in day_threads
                )
                thread_icons = f'<div class="day-threads">{badges}</div>\n'
            data_attr = f' data-threads="{thread_ids}"' if thread_ids else ""
            lines.append(f'<a class="day-card"{data_attr} href="days/day{dz}/">\n'
                         f'<div class="day-num" style="color:{wk_color}">DAY {dz}</div>\n'
                         f'<div class="day-title">{day_title}</div>\n'
                         f'{thread_icons}'
                         f'</a>\n')
        lines.append('</div>\n</div>\n')

    # What makes this course different
    lines.append("## What Makes This Course Different\n")
    lines.append('<div class="card-grid card-grid--2">\n')
    for title, desc in [
        ("Hands-on from Day 1", "Real hardware, real toolchain, every session."),
        ("AI-Assisted Verification", "Learn to prompt, evaluate, and correct AI-generated testbenches."),
        ("PPA Awareness", "Resource analysis via <code>yosys stat</code> becomes a habit, not a one-off exercise."),
        ("Open-Source Everything", "No license servers, no vendor lock-in — you keep the tools forever."),
    ]:
        lines.append(f'<div class="feature-card">\n'
                     f'<strong>{title}</strong>\n'
                     f'<p>{desc}</p>\n</div>\n')
    lines.append('</div>\n')

    # Quick reference
    lines.append("## Toolchain Quick Reference\n")
    lines.append("```bash\n"
                 "# Simulation (Icarus Verilog + GTKWave)\n"
                 "iverilog -o sim.vvp -g2012 tb_module.v module.v\n"
                 "vvp sim.vvp\n"
                 "gtkwave dump.vcd\n\n"
                 "# Synthesis & Programming (iCE40 open-source flow)\n"
                 "yosys -p \"synth_ice40 -top top_module -json top.json\" top.v\n"
                 "nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json top.json --asc top.asc\n"
                 "icepack top.asc top.bin\n"
                 "iceprog top.bin\n"
                 "```\n")

    # Thread filter script — click a cross-cutting thread card to
    # highlight its days in the Weekly Arc. Click again to clear.
    lines.append("""
<script>
document.addEventListener('DOMContentLoaded', function() {
  var active = null;
  document.querySelectorAll('.thread-filter').forEach(function(card) {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      var tid = this.dataset.thread;
      var cards = document.querySelectorAll('a.day-card');

      // Toggle off if same thread clicked again
      if (active === tid) {
        active = null;
        cards.forEach(function(c) { c.classList.remove('day-highlight', 'day-dim'); });
        document.querySelectorAll('.thread-filter').forEach(function(t) {
          t.classList.remove('thread-active');
        });
        return;
      }

      active = tid;
      document.querySelectorAll('.thread-filter').forEach(function(t) {
        t.classList.toggle('thread-active', t.dataset.thread === tid);
      });
      cards.forEach(function(c) {
        var threads = (c.dataset.threads || '').split(' ');
        if (threads.indexOf(tid) >= 0) {
          c.classList.add('day-highlight');
          c.classList.remove('day-dim');
        } else {
          c.classList.add('day-dim');
          c.classList.remove('day-highlight');
        }
      });
    });
  });
});
</script>
""")

    return "\n".join(lines)

def post_build():
    """Copy non-markdown assets (slides, theme CSS) into _site/ for deployment."""
    site = REPO / "_site"
    if not site.exists():
        print("  WARNING: _site/ not found — run mkdocs build first")
        return

    # Copy reveal.js slide decks
    lectures_src = REPO / "lectures"
    lectures_dst = site / "lectures"
    if lectures_src.exists():
        if lectures_dst.exists():
            shutil.rmtree(lectures_dst)
        shutil.copytree(lectures_src, lectures_dst)
        slide_count = sum(1 for _ in lectures_dst.rglob("*.html"))
        print(f"  Copied: {slide_count} slide files → _site/lectures/")

    # Copy download zips (built by build_lab_zips into docs_src/downloads/)
    dl_src = DOCS / "downloads"
    dl_dst = site / "downloads"
    if dl_src.exists():
        if dl_dst.exists():
            shutil.rmtree(dl_dst)
        shutil.copytree(dl_src, dl_dst)
        zip_count = sum(1 for _ in dl_dst.rglob("*.zip"))
        print(f"  Copied: {zip_count} zip files → _site/downloads/")

    # Copy theme CSS referenced by slides
    theme_src = REPO / "lectures" / "theme"
    theme_dst = site / "lectures" / "theme"
    # Already copied by copytree above


    # Copy notebooks (lab + lecture)
    nb_src = REPO / "notebooks"
    nb_dst = site / "notebooks"
    if nb_src.exists():
        if nb_dst.exists():
            shutil.rmtree(nb_dst)
        shutil.copytree(nb_src, nb_dst)
        nb_count = sum(1 for _ in nb_dst.rglob("*.ipynb"))
        print(f"  Copied: {nb_count} notebooks → _site/notebooks/")

    print(f"  Post-build complete. Site ready for deployment.")



def main():
    print("\u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557")
    print("\u2551  Preparing MkDocs source                 \u2551")
    print("\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d")

    if DOCS.exists():
        shutil.rmtree(DOCS)
    DOCS.mkdir()

    yt_ids = load_youtube_ids()
    print(f"  YouTube: {len(yt_ids)} video IDs loaded")

    # Discover lab code assets and build zips
    code_assets = discover_lab_code()
    print(f"  Lab code: {len(code_assets)} days with code assets")
    code_assets = build_lab_zips(code_assets)

    # Top-level pages
    # index.md: generated rich landing page (README stays for GitHub)
    (DOCS / "index.md").write_text(generate_homepage(), encoding="utf-8")

    for name, src in [
        ("syllabus.md",        REPO / "docs" / "course_syllabus.md"),
        ("curriculum.md",      REPO / "docs" / "course_curriculum.md"),
        ("setup.md",           REPO / "docs" / "course_setup_guide.md"),
        ("project.md",         REPO / "projects" / "README.md"),
        ("library.md",         REPO / "shared" / "lib" / "README.md"),
        ("dev-status.md",      REPO / "docs" / "course_dev_status.md"),
        ("getting-started.md", REPO / "docs" / "getting_started.md"),
        ("site-guide.md",      REPO / "docs" / "site_guide.md"),
        ("barcelona-schedule.md", REPO / "docs" / "barcelona_schedule.md"),
        ("barcelona-project.md",  REPO / "docs" / "barcelona_project.md"),
    ]:
        if src.exists(): symlink(src, DOCS / name)
    print(f"  Created: top-level pages (symlinks + index.md generated)")

    # Day pages
    for day_num, dir_name, title in DAYS:
        dz = f"{day_num:02d}"
        dd = DOCS / "days" / f"day{dz}"
        dd.mkdir(parents=True, exist_ok=True)

        # Generated index (now with code_assets for nav card)
        (dd / "index.md").write_text(
            generate_day_page(day_num, dir_name, title, yt_ids, code_assets))

        # Symlinks
        plan = REPO / "docs" / f"day{dz}.md"
        if plan.exists(): symlink(plan, dd / "plan.md")

        quiz = REPO / "lectures" / dir_name / f"day{dz}_quiz.md"
        if quiz.exists(): symlink(quiz, dd / "quiz.md")

        # Generate enriched lab page (with code links injected)
        lab_md = generate_lab_page(day_num, dir_name, code_assets)
        if lab_md:
            (dd / "lab.md").write_text(lab_md, encoding="utf-8")
        else:
            lab = REPO / "labs" / dir_name / "README.md"
            if lab.exists(): symlink(lab, dd / "lab.md")

        # Generated code page
        code_md = generate_code_page(day_num, code_assets)
        if code_md:
            (dd / "code.md").write_text(code_md, encoding="utf-8")

    print(f"  Generated: 16 day sections")

    # Overrides
    ov = DOCS / "overrides"
    ov.mkdir(exist_ok=True)
    (ov / "extra.css").write_text(EXTRA_CSS)
    print(f"  Created: overrides/extra.css")

    total = sum(1 for _ in DOCS.rglob("*") if _.is_file() or _.is_symlink())
    print(f"  Total: {total} files in docs_src/\n")

    if "--serve" in sys.argv:
        subprocess.run(["mkdocs", "serve"], cwd=REPO)
    elif "--build" in sys.argv:
        subprocess.run(["mkdocs", "build"], cwd=REPO)
        post_build()
        print("  Output: _site/")

EXTRA_CSS = """\
/* ═══ UCF Branding ═══ */
:root {
    --md-primary-fg-color: #000;
    --md-primary-bg-color: #FFC904;
    --md-accent-fg-color: #FFC904;
    --ucf-gold: #FFC904;
    --ucf-black: #000;
}
[data-md-color-scheme="slate"] {
    --md-primary-fg-color: #000;
    --md-primary-bg-color: #FFC904;
    --md-default-bg-color: #0d1117;
    --card-bg: #161b22;
    --card-border: #30363d;
    --card-hover: #FFC90420;
    --text-muted: #8b949e;
    --text-secondary: #c9d1d9;
}
[data-md-color-scheme="default"] {
    --card-bg: #fff;
    --card-border: #e5e5e0;
    --card-hover: #FFC90415;
    --text-muted: #666;
    --text-secondary: #333;
}
.md-header { background: var(--ucf-black) !important; }
.md-header__title { color: var(--ucf-gold) !important; font-weight: 700; }
.md-tabs { background: #1a1a1a !important; }

/* ═══ Typography ═══ */
.md-content h1 {
    border-bottom: 3px solid var(--ucf-gold);
    padding-bottom: 0.3em;
}
.subtitle {
    color: var(--text-muted) !important;
    font-size: 0.9em;
    margin-top: -0.5em;
    margin-bottom: 1em;
}
.highlight pre { border-left: 3px solid var(--ucf-gold); }

/* ═══ Card Grid System ═══ */
.card-grid {
    display: grid;
    gap: 12px;
    margin: 1em 0 1.5em;
}
.card-grid--2 { grid-template-columns: repeat(2, 1fr); }
.card-grid--3 { grid-template-columns: repeat(3, 1fr); }
.card-grid--4 { grid-template-columns: repeat(4, 1fr); }
@media (max-width: 768px) {
    .card-grid--3, .card-grid--4 { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 480px) {
    .card-grid--2, .card-grid--3, .card-grid--4 { grid-template-columns: 1fr; }
}

/* ═══ Stat Cards (Homepage) ═══ */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 14px;
    margin: 1.5em 0 2em;
}
@media (max-width: 768px) { .stat-grid { grid-template-columns: repeat(2, 1fr); } }
.stat-card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 10px;
    padding: 20px 18px;
    text-align: left;
}
.stat-value {
    font-size: 2em;
    font-weight: 800;
    color: var(--ucf-gold);
    font-family: 'JetBrains Mono', 'IBM Plex Mono', monospace;
    line-height: 1.1;
}
.stat-label {
    font-size: 0.9em;
    font-weight: 600;
    color: var(--text-secondary);
    margin-top: 4px;
}
.stat-sub {
    font-size: 0.75em;
    color: var(--text-muted);
    margin-top: 2px;
}

/* ═══ Thread Cards ═══ */
.thread-card {
    border: 1px solid;
    border-radius: 10px;
    padding: 16px;
    background: var(--card-bg);
}
.thread-icon { font-size: 1.5em; margin-bottom: 4px; }
.thread-name { font-size: 0.9em; font-weight: 700; }
.thread-days {
    font-size: 0.7em;
    font-family: 'JetBrains Mono', monospace;
    color: var(--text-muted);
    margin-top: 6px;
}

/* ═══ Week Section + Day Cards ═══ */
.week-section { margin-bottom: 1.8em; }
.week-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}
.week-num {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 10px;
    color: #fff;
    font-weight: 800;
    font-size: 1.1em;
    font-family: 'JetBrains Mono', monospace;
    flex-shrink: 0;
}
.week-title { font-weight: 600; font-size: 1em; }

a.day-card {
    display: block;
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 10px;
    padding: 16px;
    text-decoration: none !important;
    color: inherit !important;
    transition: border-color 0.15s, box-shadow 0.15s;
}
a.day-card:hover {
    border-color: var(--ucf-gold);
    box-shadow: 0 2px 12px rgba(255, 201, 4, 0.12);
}
.day-num {
    font-size: 0.72em;
    font-weight: 700;
    font-family: 'JetBrains Mono', monospace;
    margin-bottom: 6px;
    letter-spacing: 0.03em;
}
.day-title {
    font-size: 0.88em;
    font-weight: 600;
    color: var(--text-secondary);
    line-height: 1.35;
    min-height: 2.7em;
}

/* ═══ Feature Cards ═══ */
.feature-card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 10px;
    padding: 18px 20px;
}
.feature-card strong {
    display: block;
    font-size: 0.95em;
    margin-bottom: 4px;
}
.feature-card p {
    font-size: 0.85em;
    color: var(--text-muted);
    margin: 0;
    line-height: 1.5;
}

/* ═══ Day Page Nav Cards ═══ */
.nav-card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 10px;
    padding: 20px;
    text-align: center;
}
.nav-card .card-icon {
    font-size: 1.8em;
    display: block;
    margin-bottom: 6px;
}
.nav-card strong { font-size: 1em; }
.nav-card p { font-size: 0.82em; color: var(--text-muted); margin: 4px 0 10px; }
.nav-card a { font-size: 0.85em; }

/* ═══ YouTube Embed ═══ */
.video-container {
    position: relative;
    padding-bottom: 56.25%;
    height: 0;
    overflow: hidden;
    margin: 1em 0;
    border-radius: 8px;
    background: #111;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
.video-container iframe {
    position: absolute;
    top: 0; left: 0;
    width: 100%; height: 100%;
    border: none;
    border-radius: 8px;
}

/* ═══ Cross-Cutting Thread Badges (Day Cards on Homepage) ═══ */
.day-threads {
    margin-top: 8px;
    display: flex;
    gap: 4px;
    flex-wrap: wrap;
}
.thread-badge {
    font-size: 0.85em;
    line-height: 1;
    cursor: default;
}

/* ═══ Cross-Cutting Thread Pills (Day Landing Pages) ═══ */
.day-thread-bar {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin: -0.3em 0 1.2em;
}
.thread-pill {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-size: 0.72em;
    font-weight: 600;
    padding: 3px 10px;
    border: 1.5px solid;
    border-radius: 20px;
    background: transparent;
    white-space: nowrap;
}

/* ═══ Thread Filter Interaction (Homepage) ═══ */
.thread-filter {
    transition: transform 0.15s, box-shadow 0.15s;
    user-select: none;
}
.thread-filter:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
.thread-active {
    box-shadow: 0 0 0 2.5px var(--ucf-gold), 0 4px 12px rgba(255,201,4,0.25);
    transform: translateY(-2px);
}
a.day-card.day-highlight {
    border-color: var(--ucf-gold) !important;
    box-shadow: 0 0 0 2px var(--ucf-gold), 0 4px 16px rgba(255,201,4,0.18);
    transform: translateY(-2px);
    transition: all 0.2s ease;
}
a.day-card.day-dim {
    opacity: 0.3;
    transition: opacity 0.2s ease, transform 0.2s ease;
}
"""

if __name__ == "__main__":
    main()