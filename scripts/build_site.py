#!/usr/bin/env python3
"""
build_site.py — Generate the HDL Course Portal
================================================
Converts all markdown to styled HTML, generates navigation manifest,
and creates the main index.html landing page.

Run from repo root:  python3 scripts/build_site.py
Output:              site/
"""

import json
import os
import re
import shutil
import zipfile
from pathlib import Path

import markdown
from markdown.extensions.tables import TableExtension
from markdown.extensions.fenced_code import FencedCodeExtension
from markdown.extensions.codehilite import CodeHiliteExtension
from markdown.extensions.toc import TocExtension
from markdown.extensions.attr_list import AttrListExtension

REPO = Path(__file__).resolve().parent.parent
SITE = REPO / "site"
CONTENT = SITE / "content"

# ─── JupyterHub configuration ────────────────────────────────────
# Base URL for JupyterHub — set to your institution's hub.
# Notebook links assume the repo is cloned into the user's home dir
# as  ~/hdl-for-dsd/  (i.e., the default git clone path).
JUPYTER_HUB_BASE = os.environ.get(
    "HDL_JUPYTER_BASE",
    "/hub/user-redirect/lab/tree/hdl-for-dsd"
)
# GitHub raw base for direct file viewing (fallback when no hub)
GITHUB_RAW_BASE = "https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main"

# File extensions to include in code downloads
CODE_EXTENSIONS = {".v", ".sv", ".hex", ".pcf", ".md"}
# Extensions that get JupyterHub "open" links (text-editable files)
JUPYTER_EXTENSIONS = {".v", ".sv", ".hex", ".py", ".ipynb", ".md"}

# ─── Course metadata ───────────────────────────────────────────────

WEEKS = [
    {
        "num": 1, "title": "Verilog Foundations & Combinational Design",
        "dir_prefix": "week1",
        "days": [
            {"num": 1, "title": "Welcome to Hardware Thinking", "deliverable": "Buttons-to-LEDs on hardware"},
            {"num": 2, "title": "Combinational Building Blocks", "deliverable": "Hex-to-7-seg decoder on hardware"},
            {"num": 3, "title": "Procedural Combinational Logic", "deliverable": "ALU + synthesis comparison"},
            {"num": 4, "title": "Sequential Logic: FFs, Clocks & Counters", "deliverable": "LED blinker + counter on 7-seg"},
        ]
    },
    {
        "num": 2, "title": "Sequential Design, Verification & AI Testing",
        "dir_prefix": "week2",
        "days": [
            {"num": 5, "title": "Counters, Shift Registers & Debouncing", "deliverable": "Debounced LED chase pattern"},
            {"num": 6, "title": "Testbenches & AI-Assisted Verification", "deliverable": "Hand-written + AI testbenches"},
            {"num": 7, "title": "Finite State Machines", "deliverable": "Traffic light FSM with testbench"},
            {"num": 8, "title": "Hierarchy, Parameters & Generate", "deliverable": "Hierarchical design + PPA snapshot"},
        ]
    },
    {
        "num": 3, "title": "Memory, Communication & Numerical Architectures",
        "dir_prefix": "week3",
        "days": [
            {"num": 9, "title": "Memory: RAM, ROM & Block RAM", "deliverable": "ROM sequencer + RAM demo"},
            {"num": 10, "title": "Numerical Architectures & PPA", "deliverable": "Adder/multiplier PPA table"},
            {"num": 11, "title": "UART TX: Communication Interface", "deliverable": "'HELLO' on PC terminal"},
            {"num": 12, "title": "UART RX, SPI & Protocol Verification", "deliverable": "UART loopback + SPI master"},
        ]
    },
    {
        "num": 4, "title": "Advanced Design, Verification & Final Project",
        "dir_prefix": "week4",
        "days": [
            {"num": 13, "title": "SystemVerilog for Design", "deliverable": "SV refactored modules + PPA"},
            {"num": 14, "title": "Verification, AI Testing & PPA Analysis", "deliverable": "Assertions + parity + PPA report"},
            {"num": 15, "title": "Final Project: Build Day", "deliverable": "Working prototype + testbench"},
            {"num": 16, "title": "Final Project Demos & Course Wrap", "deliverable": "Live demo + presentation"},
        ]
    },
]

# ─── Slide segment titles (extracted from file naming) ─────────────

def get_slide_segments(day_num, youtube_ids=None):
    """Find reveal.js slide files for a day, return list of {file, title, segment, youtube_id}."""
    if youtube_ids is None:
        youtube_ids = {}
    for week in WEEKS:
        for day in week["days"]:
            if day["num"] == day_num:
                week_dir = f"{week['dir_prefix']}_day{day_num:02d}"
                slide_dir = REPO / "lectures" / week_dir
                if not slide_dir.exists():
                    return []
                slides = sorted(slide_dir.glob(f"d{day_num:02d}_s*.html"))
                results = []
                for s in slides:
                    name = s.stem  # e.g. d01_s1_hdl_not_software
                    parts = name.split("_", 2)
                    seg_num = int(parts[1][1]) if len(parts) >= 2 else 0
                    seg_key = f"d{day_num:02d}_s{seg_num}"

                    # Try to extract title from the HTML <title> tag
                    try:
                        html_text = s.read_text(encoding="utf-8")
                        title_match = re.search(r"<title>Day \d+\.\d+: ([^<—]+)", html_text)
                        if title_match:
                            title = title_match.group(1).strip()
                        else:
                            title = parts[2].replace("_", " ").title() if len(parts) >= 3 else name
                    except Exception:
                        title = parts[2].replace("_", " ").title() if len(parts) >= 3 else name

                    entry = {
                        "file": f"../lectures/{week_dir}/{s.name}",
                        "title": title,
                        "segment": seg_num,
                        "key": seg_key,
                    }
                    yt_id = youtube_ids.get(seg_key)
                    if yt_id:
                        entry["youtube_id"] = yt_id
                    results.append(entry)
                return results
    return []


# ─── Markdown converter ───────────────────────────────────────────

MD = markdown.Markdown(extensions=[
    TableExtension(),
    FencedCodeExtension(),
    CodeHiliteExtension(css_class="codehilite", guess_lang=False),
    TocExtension(permalink=False),
    AttrListExtension(),
    "md_in_html",
], output_format="html5")


def convert_md(md_path, title=None, css_path="../../css/content.css"):
    """Convert a markdown file to styled HTML page."""
    text = md_path.read_text(encoding="utf-8")
    MD.reset()
    body = MD.convert(text)

    if not title:
        # Try to extract from first H1
        m = re.search(r"<h1[^>]*>(.*?)</h1>", body)
        title = m.group(1) if m else md_path.stem.replace("_", " ").title()

    return CONTENT_TEMPLATE.format(title=title, body=body, css_path=css_path)


CONTENT_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} — HDL for DSD</title>
<link rel="stylesheet" href="{css_path}">
</head>
<body>
<article class="content-page">
{body}
</article>
</body>
</html>"""


# ─── Build steps ──────────────────────────────────────────────────

def build_content_css():
    """Write the shared content stylesheet."""
    css_dir = SITE / "css"
    css_dir.mkdir(parents=True, exist_ok=True)
    (css_dir / "content.css").write_text(CONTENT_CSS, encoding="utf-8")
    print(f"  Created: css/content.css")


def build_docs():
    """Convert docs/*.md → site/content/docs/*.html."""
    out = CONTENT / "docs"
    out.mkdir(parents=True, exist_ok=True)
    docs_dir = REPO / "docs"
    count = 0
    for md_file in sorted(docs_dir.glob("*.md")):
        if md_file.name == "README.md":
            out_name = "docs_overview.html"
        else:
            out_name = md_file.stem + ".html"
        html = convert_md(md_file)
        (out / out_name).write_text(html, encoding="utf-8")
        count += 1
    print(f"  Converted: {count} docs → content/docs/")


def build_quizzes():
    """Convert lecture quiz markdown → site/content/quizzes/*.html."""
    out = CONTENT / "quizzes"
    out.mkdir(parents=True, exist_ok=True)
    count = 0
    for quiz in sorted(REPO.glob("lectures/week*_day*/day*_quiz.md")):
        day_match = re.search(r"day(\d+)", quiz.stem)
        if day_match:
            day_num = int(day_match.group(1))
            html = convert_md(quiz, title=f"Day {day_num} Pre-Class Quiz")
            (out / f"day{day_num:02d}_quiz.html").write_text(html, encoding="utf-8")
            count += 1
    print(f"  Converted: {count} quizzes → content/quizzes/")


def build_labs():
    """Convert lab README.md files → site/content/labs/*.html."""
    out = CONTENT / "labs"
    out.mkdir(parents=True, exist_ok=True)
    count = 0
    for readme in sorted(REPO.glob("labs/week*_day*/README.md")):
        day_dir = readme.parent.name  # e.g. week1_day01
        day_match = re.search(r"day(\d+)", day_dir)
        if day_match:
            day_num = int(day_match.group(1))
            html = convert_md(readme, title=f"Day {day_num} Lab Guide")
            (out / f"day{day_num:02d}_lab.html").write_text(html, encoding="utf-8")
            count += 1

    # Also convert supplementary markdown in labs
    for md_file in REPO.glob("labs/**/ex*/starter/README.md"):
        rel = md_file.relative_to(REPO / "labs")
        out_name = str(rel).replace("/", "_").replace(".md", ".html")
        html = convert_md(md_file)
        (out / out_name).write_text(html, encoding="utf-8")
        count += 1

    print(f"  Converted: {count} lab files → content/labs/")


def build_misc():
    """Convert project README and other standalone docs."""
    out = CONTENT / "misc"
    out.mkdir(parents=True, exist_ok=True)

    # Projects
    proj = REPO / "projects" / "README.md"
    if proj.exists():
        html = convert_md(proj, title="Final Project")
        (out / "project.html").write_text(html, encoding="utf-8")

    # Shared lib README
    lib_readme = REPO / "shared" / "lib" / "README.md"
    if lib_readme.exists():
        html = convert_md(lib_readme, title="Module Library")
        (out / "library.html").write_text(html, encoding="utf-8")

    print(f"  Converted: misc docs → content/misc/")


def build_overview():
    """Generate the course overview HTML page."""
    out = CONTENT / "overview.html"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(OVERVIEW_HTML, encoding="utf-8")
    print(f"  Created: content/overview.html")


def build_lab_code_assets():
    """Scan labs/, create per-exercise zips, and return a manifest of code assets per day.

    Returns dict:  { day_num: { "exercises": [...], "all_zip": "path" } }
    Each exercise entry:
        { "name": "ex1_led_on", "label": "Ex 1 — LED On",
          "files": [ { "name": "ex1_led_on.v", "path": "labs/week1_day01/starter/ex1_led_on.v",
                        "jupyter_url": "...", "github_url": "..." } ],
          "zip": "downloads/day01/ex1_led_on_starter.zip",
          "has_solution": true,
          "solution_zip": "downloads/day01/ex1_led_on_solution.zip" }
    """
    dl_dir = SITE / "downloads"
    dl_dir.mkdir(parents=True, exist_ok=True)

    day_assets = {}  # day_num -> { exercises: [...], all_zip: ... }

    for week in WEEKS:
        for day in week["days"]:
            d = day["num"]
            dz = f"{d:02d}"
            week_dir_name = f"{week['dir_prefix']}_day{dz}"
            lab_dir = REPO / "labs" / week_dir_name

            if not lab_dir.exists():
                continue

            day_dl = dl_dir / f"day{dz}"
            day_dl.mkdir(parents=True, exist_ok=True)

            exercises = []
            all_files_for_day_zip = []

            # Detect structure: flat (week1) vs exercise-per-dir (week2+)
            has_exercise_dirs = any(lab_dir.glob("ex*"))

            if not has_exercise_dirs:
                # Week 1 flat structure: starter/ and solution/ at top level
                starter_dir = lab_dir / "starter"
                solution_dir = lab_dir / "solution"
                if starter_dir.is_dir():
                    grouped = _group_flat_exercises(starter_dir)
                    for ex_name, files in grouped.items():
                        label = _exercise_label(ex_name)
                        file_entries = []
                        for f in sorted(files):
                            rel = f.relative_to(REPO)
                            file_entries.append(_file_entry(f, rel))
                            all_files_for_day_zip.append(f)

                        # Create starter zip
                        zip_name = f"{ex_name}_starter.zip"
                        zip_path = day_dl / zip_name
                        _create_zip(zip_path, files, arcname_base=f"{ex_name}/starter")

                        # Check for solution
                        has_sol = False
                        sol_zip_rel = None
                        if solution_dir.is_dir():
                            sol_files = [solution_dir / f.name for f in files if (solution_dir / f.name).exists()]
                            if sol_files:
                                has_sol = True
                                sol_zip_name = f"{ex_name}_solution.zip"
                                sol_zip_path = day_dl / sol_zip_name
                                _create_zip(sol_zip_path, sol_files, arcname_base=f"{ex_name}/solution")
                                sol_zip_rel = f"downloads/day{dz}/{sol_zip_name}"

                        exercises.append({
                            "name": ex_name,
                            "label": label,
                            "files": file_entries,
                            "zip": f"downloads/day{dz}/{zip_name}",
                            "has_solution": has_sol,
                            "solution_zip": sol_zip_rel,
                        })
            else:
                # Week 2+ structure: ex*/ subdirectories
                for ex_dir in sorted(lab_dir.glob("ex*")):
                    if not ex_dir.is_dir():
                        continue
                    ex_name = ex_dir.name
                    label = _exercise_label(ex_name)
                    starter_dir = ex_dir / "starter"
                    solution_dir = ex_dir / "solution"

                    src_dir = starter_dir if starter_dir.is_dir() else ex_dir
                    files = sorted(f for f in src_dir.iterdir() if f.is_file() and f.name != ".DS_Store")
                    file_entries = []
                    for f in files:
                        rel = f.relative_to(REPO)
                        file_entries.append(_file_entry(f, rel))
                        all_files_for_day_zip.append(f)

                    # Create starter zip
                    zip_name = f"{ex_name}_starter.zip"
                    zip_path = day_dl / zip_name
                    _create_zip(zip_path, files, arcname_base=f"{ex_name}/starter")

                    # Solution zip
                    has_sol = solution_dir.is_dir() and any(solution_dir.iterdir())
                    sol_zip_rel = None
                    if has_sol:
                        sol_files = sorted(f for f in solution_dir.iterdir() if f.is_file() and f.name != ".DS_Store")
                        sol_zip_name = f"{ex_name}_solution.zip"
                        sol_zip_path = day_dl / sol_zip_name
                        _create_zip(sol_zip_path, sol_files, arcname_base=f"{ex_name}/solution")
                        sol_zip_rel = f"downloads/day{dz}/{sol_zip_name}"

                    exercises.append({
                        "name": ex_name,
                        "label": label,
                        "files": file_entries,
                        "zip": f"downloads/day{dz}/{zip_name}",
                        "has_solution": has_sol,
                        "solution_zip": sol_zip_rel,
                    })

            # Also include shared files (Makefile, pcf) as a "shared" entry
            shared_files = []
            for pattern in ["Makefile", "*.pcf"]:
                for f in lab_dir.glob(pattern):
                    if f.is_file():
                        shared_files.append(f)
                        all_files_for_day_zip.append(f)
            if shared_files:
                sf_entries = []
                for f in sorted(shared_files):
                    rel = f.relative_to(REPO)
                    sf_entries.append(_file_entry(f, rel))
                exercises.insert(0, {
                    "name": "_shared",
                    "label": "Shared Files (Makefile, PCF)",
                    "files": sf_entries,
                    "zip": None,
                    "has_solution": False,
                    "solution_zip": None,
                })

            # Create day-level "all starter code" zip
            all_zip_name = f"day{dz}_all_starter.zip"
            all_zip_path = day_dl / all_zip_name
            with zipfile.ZipFile(all_zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
                for f in all_files_for_day_zip:
                    try:
                        arcname = f"day{dz}_lab/{f.relative_to(lab_dir)}"
                    except ValueError:
                        arcname = f"day{dz}_lab/{f.name}"
                    zf.write(f, arcname)
            all_zip_rel = f"downloads/day{dz}/{all_zip_name}"

            day_assets[d] = {
                "exercises": exercises,
                "all_zip": all_zip_rel,
            }

    total_zips = sum(1 for _ in dl_dir.rglob("*.zip"))
    print(f"  Created: {total_zips} zip files → downloads/")
    return day_assets


def _group_flat_exercises(starter_dir):
    """Group files in a flat starter/ dir by exercise prefix (ex1_, ex2_, etc.)."""
    groups = {}
    for f in sorted(starter_dir.iterdir()):
        if not f.is_file() or f.name == ".DS_Store":
            continue
        m = re.match(r"(ex\d+)_", f.name)
        if m:
            key = m.group(1)
            # Use the full stem minus the leading exN_ for the group name
            group_name = f.stem
        else:
            key = "_misc"
            group_name = f.stem
        groups.setdefault(key, []).append(f)
    # Flatten into {ex_name: [files]} by picking the exercise prefix as name
    result = {}
    for key, files in groups.items():
        # Use the first file's stem as the exercise name
        if len(files) == 1:
            result[files[0].stem] = files
        else:
            # Group all files under the common prefix
            result[key + "_files"] = files
    return result


def _exercise_label(ex_name):
    """Convert ex1_alu_testbench → 'Ex 1 — ALU Testbench'."""
    m = re.match(r"ex(\d+)_(.*)", ex_name)
    if m:
        num = m.group(1)
        desc = m.group(2).replace("_", " ").title()
        return f"Ex {num} — {desc}"
    return ex_name.replace("_", " ").title()


def _file_entry(filepath, rel_path):
    """Create a file entry dict with URLs for JupyterHub and GitHub."""
    suffix = filepath.suffix.lower()
    entry = {
        "name": filepath.name,
        "path": str(rel_path),
        "github_url": f"{GITHUB_RAW_BASE}/{rel_path}",
        "ext": suffix,
    }
    if suffix in JUPYTER_EXTENSIONS or filepath.name == "Makefile":
        entry["jupyter_url"] = f"{JUPYTER_HUB_BASE}/{rel_path}"
    return entry


def _create_zip(zip_path, files, arcname_base=""):
    """Create a zip archive from a list of files."""
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for f in files:
            arcname = f"{arcname_base}/{f.name}" if arcname_base else f.name
            zf.write(f, arcname)


def build_manifest(code_assets=None):
    """Generate manifest.json with full navigation structure."""
    if code_assets is None:
        code_assets = {}
    # Load YouTube video IDs if available
    yt_path = REPO / "youtube_ids.json"
    youtube_ids = {}
    if yt_path.exists():
        raw = json.loads(yt_path.read_text(encoding="utf-8"))
        youtube_ids = {k: v for k, v in raw.items() if not k.startswith("_") and v}
        recorded = len(youtube_ids)
        total_segs = sum(1 for k, v in raw.items() if not k.startswith("_"))
        print(f"  YouTube IDs: {recorded}/{total_segs} segments have video links")

    manifest = {
        "course": {
            "title": "Accelerated HDL for Digital System Design",
            "institution": "UCF · College of Engineering & Computer Science",
            "version": "v2.1"
        },
        "jupyter_base": JUPYTER_HUB_BASE,
        "github_base": GITHUB_RAW_BASE,
        "docs": [
            {"id": "overview", "label": "Course Overview", "content": "content/overview.html"},
            {"id": "syllabus", "label": "Syllabus", "content": "content/docs/course_syllabus.html"},
            {"id": "curriculum", "label": "Curriculum Map", "content": "content/docs/course_curriculum.html"},
            {"id": "setup", "label": "Toolchain Setup", "content": "content/docs/course_setup_guide.html"},
            {"id": "project", "label": "Final Project", "content": "content/misc/project.html"},
            {"id": "library", "label": "Module Library", "content": "content/misc/library.html"},
        ],
        "weeks": []
    }

    for week in WEEKS:
        week_data = {
            "num": week["num"],
            "title": week["title"],
            "days": []
        }
        for day in week["days"]:
            d = day["num"]
            dz = f"{d:02d}"
            week_dir = f"{week['dir_prefix']}_day{dz}"

            slides = get_slide_segments(d, youtube_ids)

            day_data = {
                "num": d,
                "title": day["title"],
                "deliverable": day["deliverable"],
                "content": {
                    "plan": f"content/docs/day{dz}.html",
                    "lab": f"content/labs/day{dz}_lab.html",
                },
                "slides": slides,
            }
            # Only include quiz if the file was actually converted
            quiz_path = SITE / f"content/quizzes/day{dz}_quiz.html"
            if quiz_path.exists():
                day_data["content"]["quiz"] = f"content/quizzes/day{dz}_quiz.html"

            # Include code assets if available
            if d in code_assets:
                day_data["code_assets"] = code_assets[d]

            week_data["days"].append(day_data)
        manifest["weeks"].append(week_data)

    (SITE / "manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    print(f"  Created: manifest.json")
    return manifest


def build_index(manifest):
    """Generate the main index.html landing page with inlined manifest."""
    manifest_json = json.dumps(manifest, ensure_ascii=False)
    html = INDEX_HTML.replace("/*MANIFEST_JSON*/null", manifest_json)
    (SITE / "index.html").write_text(html, encoding="utf-8")
    print(f"  Created: index.html (manifest inlined, no fetch required)")


# ─── Templates ────────────────────────────────────────────────────

CONTENT_CSS = r"""
/* Content page styles — HDL for DSD Course Portal */
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&family=Libre+Franklin:wght@300;400;500;600;700;800&display=swap');

:root {
    --gold: #FFC904;
    --black: #1a1a1a;
    --gray-900: #2C2A29;
    --gray-600: #666;
    --gray-400: #999;
    --gray-200: #e0e0e0;
    --gray-100: #f4f4f2;
    --bg: #fdfcfa;
    --code-bg: #282c34;
    --border: #e5e5e0;
    --link: #1565C0;
}

* { box-sizing: border-box; }

body {
    margin: 0;
    padding: 0;
    font-family: 'Libre Franklin', 'Source Sans 3', 'Segoe UI', sans-serif;
    font-size: 15px;
    line-height: 1.7;
    color: var(--black);
    background: var(--bg);
}

.content-page {
    max-width: 820px;
    margin: 0 auto;
    padding: 28px 36px 60px;
}

h1 {
    font-size: 28px;
    font-weight: 300;
    letter-spacing: -0.02em;
    color: var(--black);
    margin: 0 0 6px;
    padding-bottom: 10px;
    border-bottom: 2px solid var(--gold);
}

h2 {
    font-size: 20px;
    font-weight: 700;
    color: var(--black);
    margin: 32px 0 12px;
    padding-bottom: 6px;
    border-bottom: 1px solid var(--gray-200);
}

h3 {
    font-size: 16px;
    font-weight: 700;
    color: var(--gray-900);
    margin: 24px 0 8px;
}

h4 { font-size: 14px; font-weight: 700; color: var(--gray-600); margin: 20px 0 6px; }

p { margin: 0 0 12px; }

a { color: var(--link); text-decoration: none; }
a:hover { text-decoration: underline; }

strong { font-weight: 700; color: var(--black); }
em { font-style: italic; }

ul, ol { padding-left: 24px; margin: 0 0 16px; }
li { margin-bottom: 4px; }

/* Tables */
table {
    width: 100%;
    border-collapse: collapse;
    margin: 16px 0;
    font-size: 14px;
}
th {
    text-align: left;
    padding: 10px 12px;
    font-weight: 700;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--gray-400);
    border-bottom: 2px solid var(--gray-200);
    background: var(--gray-100);
}
td {
    padding: 8px 12px;
    border-bottom: 1px solid #f0f0ec;
    vertical-align: top;
}
tr:last-child td { border-bottom: none; }

/* Code */
code {
    font-family: 'IBM Plex Mono', 'JetBrains Mono', 'Fira Code', monospace;
    font-size: 0.88em;
    background: #f0efeb;
    padding: 2px 6px;
    border-radius: 3px;
    color: #c7254e;
}

pre {
    background: var(--code-bg);
    border-radius: 8px;
    padding: 18px 20px;
    overflow-x: auto;
    margin: 12px 0 16px;
    border-left: 3px solid var(--gold);
}
pre code {
    background: none;
    color: #abb2bf;
    padding: 0;
    font-size: 13px;
    line-height: 1.55;
}

/* Details/summary */
details {
    background: var(--gray-100);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 12px 16px;
    margin: 8px 0;
}
details summary {
    cursor: pointer;
    font-weight: 600;
    color: var(--link);
    font-size: 14px;
}
details[open] summary { margin-bottom: 8px; }

/* Blockquotes */
blockquote {
    border-left: 3px solid var(--gold);
    margin: 16px 0;
    padding: 12px 20px;
    background: #fdfaf0;
    color: var(--gray-900);
    border-radius: 0 6px 6px 0;
}
blockquote p:last-child { margin-bottom: 0; }

/* Horizontal rules */
hr {
    border: none;
    height: 1px;
    background: var(--gray-200);
    margin: 32px 0;
}

/* Images */
img { max-width: 100%; height: auto; border-radius: 6px; }
"""

OVERVIEW_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Course Overview — HDL for DSD</title>
<link rel="stylesheet" href="../css/content.css">
<style>
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin: 24px 0 32px; }
.stat-card { padding: 18px; border-radius: 8px; border: 1px solid var(--border); background: #fff; }
.stat-card .value { font-size: 28px; font-weight: 800; color: var(--gold); font-family: 'IBM Plex Mono', monospace; }
.stat-card .label { font-size: 13px; font-weight: 600; color: var(--black); margin-top: 2px; }
.stat-card .sub { font-size: 11px; color: var(--gray-400); margin-top: 2px; }
.week-section { margin-bottom: 28px; }
.week-header { display: flex; align-items: center; gap: 12px; margin-bottom: 14px; }
.week-num { width: 36px; height: 36px; border-radius: 10px; background: var(--gold); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 16px; font-family: 'IBM Plex Mono', monospace; }
.day-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
.day-card { background: #fff; border: 1px solid var(--border); border-radius: 8px; padding: 14px; transition: border-color 0.15s; cursor: pointer; }
.day-card:hover { border-color: var(--gold); }
.day-card .day-num { font-size: 11px; font-weight: 700; color: var(--gold); font-family: 'IBM Plex Mono', monospace; margin-bottom: 4px; }
.day-card .day-title { font-size: 13px; font-weight: 600; color: var(--black); line-height: 1.3; margin-bottom: 8px; min-height: 36px; }
.day-card .day-del { font-size: 11px; color: var(--gray-400); border-top: 1px solid var(--gray-100); padding-top: 6px; }
.thread-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin: 16px 0; }
.thread-card { padding: 14px; border-radius: 8px; border: 1px solid; }
.thread-card .icon { font-size: 18px; margin-bottom: 4px; }
.thread-card .name { font-size: 13px; font-weight: 700; }
.thread-card .days { font-size: 10px; font-family: 'IBM Plex Mono', monospace; margin-top: 4px; opacity: 0.7; }
.diff-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 16px 0; }
.diff-card { padding: 14px 16px; background: var(--gray-100); border-radius: 8px; }
.diff-card strong { display: block; margin-bottom: 2px; }
.diff-card p { margin: 0; font-size: 13px; color: var(--gray-600); }
</style>
</head>
<body>
<article class="content-page">
<h1>Accelerated HDL for Digital System Design</h1>
<p style="color: var(--gray-400); font-size: 13px; margin-top: -4px;">UCF · College of Engineering & Computer Science · Department of ECE · v2.1</p>

<div class="stats-grid">
<div class="stat-card"><div class="value">16</div><div class="label">Sessions</div><div class="sub">4 weeks × 4 days</div></div>
<div class="stat-card"><div class="value">12.2h</div><div class="label">Video Content</div><div class="sub">56 segments</div></div>
<div class="stat-card"><div class="value">38+</div><div class="label">Lab Exercises</div><div class="sub">Hands-on every day</div></div>
<div class="stat-card"><div class="value">iCE40</div><div class="label">Platform</div><div class="sub">Nandland Go Board</div></div>
</div>

<p>A 4-week intensive course taking students from zero HDL experience to confidently designing, simulating, and implementing digital systems in Verilog on real FPGA hardware. Uses an entirely open-source toolchain (Yosys, nextpnr, Icarus Verilog) and integrates modern practices including AI-assisted verification and PPA analysis.</p>

<h2>Weekly Arc</h2>

<div class="week-section">
<div class="week-header"><div class="week-num">1</div><div><strong>Verilog Foundations &amp; Combinational Design</strong></div></div>
<div class="day-grid">
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:1},'*')"><div class="day-num">DAY 01</div><div class="day-title">Welcome to Hardware Thinking</div><div class="day-del">Buttons-to-LEDs on hardware</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:2},'*')"><div class="day-num">DAY 02</div><div class="day-title">Combinational Building Blocks</div><div class="day-del">Hex-to-7-seg decoder</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:3},'*')"><div class="day-num">DAY 03</div><div class="day-title">Procedural Combinational Logic</div><div class="day-del">ALU + synthesis comparison</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:4},'*')"><div class="day-num">DAY 04</div><div class="day-title">Sequential Logic: FFs & Counters</div><div class="day-del">LED blinker + counter on 7-seg</div></div>
</div>
</div>

<div class="week-section">
<div class="week-header"><div class="week-num">2</div><div><strong>Sequential Design, Verification &amp; AI Testing</strong></div></div>
<div class="day-grid">
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:5},'*')"><div class="day-num">DAY 05</div><div class="day-title">Counters, Shift Registers &amp; Debouncing</div><div class="day-del">Debounced LED chase</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:6},'*')"><div class="day-num">DAY 06</div><div class="day-title">Testbenches &amp; AI Verification</div><div class="day-del">Hand-written + AI testbenches</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:7},'*')"><div class="day-num">DAY 07</div><div class="day-title">Finite State Machines</div><div class="day-del">Traffic light FSM</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:8},'*')"><div class="day-num">DAY 08</div><div class="day-title">Hierarchy, Parameters &amp; Generate</div><div class="day-del">Hierarchical design + PPA</div></div>
</div>
</div>

<div class="week-section">
<div class="week-header"><div class="week-num">3</div><div><strong>Memory, Communication &amp; Numerical Architectures</strong></div></div>
<div class="day-grid">
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:9},'*')"><div class="day-num">DAY 09</div><div class="day-title">Memory: RAM, ROM &amp; Block RAM</div><div class="day-del">ROM sequencer + RAM demo</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:10},'*')"><div class="day-num">DAY 10</div><div class="day-title">Numerical Architectures &amp; PPA</div><div class="day-del">Adder/multiplier PPA table</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:11},'*')"><div class="day-num">DAY 11</div><div class="day-title">UART TX: Communication Interface</div><div class="day-del">"HELLO" on PC terminal</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:12},'*')"><div class="day-num">DAY 12</div><div class="day-title">UART RX, SPI &amp; Protocol Verification</div><div class="day-del">UART loopback + SPI master</div></div>
</div>
</div>

<div class="week-section">
<div class="week-header"><div class="week-num">4</div><div><strong>Advanced Design, Verification &amp; Final Project</strong></div></div>
<div class="day-grid">
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:13},'*')"><div class="day-num">DAY 13</div><div class="day-title">SystemVerilog for Design</div><div class="day-del">SV refactored modules</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:14},'*')"><div class="day-num">DAY 14</div><div class="day-title">Verification, AI Testing &amp; PPA</div><div class="day-del">Assertions + parity + PPA</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:15},'*')"><div class="day-num">DAY 15</div><div class="day-title">Final Project: Build Day</div><div class="day-del">Working prototype</div></div>
<div class="day-card" onclick="parent.postMessage({type:'nav',view:'day',id:16},'*')"><div class="day-num">DAY 16</div><div class="day-title">Demo Day &amp; Course Wrap</div><div class="day-del">Live demo + presentation</div></div>
</div>
</div>

<h2>Cross-Cutting Threads</h2>
<div class="thread-grid">
<div class="thread-card" style="border-color: #7B1FA2; background: #F3E5F515;"><div class="icon">🤖</div><div class="name" style="color:#7B1FA2;">AI-Assisted Verification</div><div class="days">D6 → D8 → D12 → D14 → D16</div></div>
<div class="thread-card" style="border-color: #2E7D32; background: #E8F5E915;"><div class="icon">📊</div><div class="name" style="color:#2E7D32;">PPA Analysis</div><div class="days">D3 → D8 → D10 → D12 → D14 → D16</div></div>
<div class="thread-card" style="border-color: #E65100; background: #FFF3E015;"><div class="icon">⚙️</div><div class="name" style="color:#E65100;">Constraint-Based Design</div><div class="days">D3 → D7 → D8 → D10 → D12 → D14</div></div>
<div class="thread-card" style="border-color: #1565C0; background: #E3F2FD15;"><div class="icon">🔧</div><div class="name" style="color:#1565C0;">AI Tool Literacy</div><div class="days">D6 → D12 → D14 → D16</div></div>
</div>

<h2>What Makes This Course Different</h2>
<div class="diff-grid">
<div class="diff-card"><strong>Hands-on from Day 1</strong><p>Real hardware, real toolchain, every session.</p></div>
<div class="diff-card"><strong>AI-Assisted Verification</strong><p>Prompt, evaluate, and correct AI-generated testbenches.</p></div>
<div class="diff-card"><strong>PPA Awareness</strong><p>Resource analysis via <code>yosys stat</code> becomes a habit.</p></div>
<div class="diff-card"><strong>Open-Source Everything</strong><p>No license servers, no vendor lock-in. Students keep the tools.</p></div>
</div>

</article>
</body>
</html>"""


# ─── Main index.html ──────────────────────────────────────────────

INDEX_HTML = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HDL for Digital System Design — UCF ECE</title>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&family=Libre+Franklin:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
/* ── Reset & Variables ── */
*{box-sizing:border-box;margin:0;padding:0}
:root{
    --gold:#FFC904;--black:#1a1a1a;--gray-900:#2c2a29;
    --gray-600:#666;--gray-400:#999;--gray-200:#e5e5e0;
    --gray-100:#f4f4f2;--bg:#fdfcfa;--border:#e5e5e0;
    --link:#1565C0;--sidebar-w:264px;--header-h:0px;
}
html,body{height:100%;font-family:'Libre Franklin','Segoe UI',sans-serif;background:var(--bg);color:var(--black)}
button{border:none;background:none;cursor:pointer;font:inherit;color:inherit}

/* ── Layout ── */
.shell{display:flex;height:100vh;overflow:hidden}

/* ── Sidebar ── */
.sidebar{width:var(--sidebar-w);background:#fafaf8;border-right:1px solid var(--border);display:flex;flex-direction:column;flex-shrink:0;overflow:hidden;transition:width .2s}
.sidebar.collapsed{width:48px}
.sidebar-header{padding:14px 14px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:10px;min-height:52px}
.sidebar-header .logo{display:flex;align-items:center;gap:8px;overflow:hidden;white-space:nowrap}
.sidebar-header .logo-icon{width:22px;height:22px;background:var(--gold);border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.sidebar-header .logo-text{font-family:'IBM Plex Mono',monospace;font-size:13px;font-weight:800;color:var(--black)}
.sidebar-header .logo-sub{font-size:10px;color:var(--gray-400)}
.sidebar.collapsed .logo-text,.sidebar.collapsed .logo-sub,.sidebar.collapsed .sidebar-nav{display:none}
.sidebar-toggle{margin-left:auto;padding:4px;color:var(--gray-400);flex-shrink:0;font-size:16px;line-height:1}
.sidebar-toggle:hover{color:var(--black)}

.sidebar-nav{flex:1;overflow-y:auto;padding:6px 0}
.nav-section-label{padding:6px 16px;font-size:10px;font-weight:700;color:var(--gray-400);letter-spacing:.1em;text-transform:uppercase}
.nav-item{display:flex;align-items:center;gap:8px;padding:7px 16px;font-size:13px;color:var(--gray-600);cursor:pointer;border-right:2px solid transparent;transition:all .1s}
.nav-item:hover{background:#efeee8;color:var(--black)}
.nav-item.active{color:var(--black);font-weight:600;background:#FFC90412;border-right-color:var(--gold)}
.nav-divider{height:1px;background:var(--border);margin:8px 16px}

.nav-week{display:flex;align-items:center;gap:4px;padding:8px 16px;font-size:11px;font-weight:700;color:var(--gray-400);letter-spacing:.05em;text-transform:uppercase;cursor:pointer;user-select:none}
.nav-week:hover{color:var(--gray-600)}
.nav-week .arrow{font-size:10px;transition:transform .15s;display:inline-block;width:12px}
.nav-week .arrow.open{transform:rotate(90deg)}

.nav-day{display:flex;align-items:center;gap:6px;padding:5px 16px 5px 28px;font-size:13px;color:#777;cursor:pointer;border-right:2px solid transparent;transition:all .1s}
.nav-day:hover{background:#efeee8;color:var(--black)}
.nav-day.active{color:var(--black);font-weight:600;background:#FFC90412;border-right-color:var(--gold)}
.nav-day .day-num{font-family:'IBM Plex Mono',monospace;font-size:10px;color:#bbb;width:18px;flex-shrink:0}
.nav-day .day-label{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}

/* ── Main content area ── */
.main{flex:1;display:flex;flex-direction:column;overflow:hidden}
.breadcrumb{padding:10px 24px;font-size:12px;color:var(--gray-400);border-bottom:1px solid var(--border);background:#fff;display:flex;align-items:center;gap:6px;flex-shrink:0}
.breadcrumb span.sep{color:#ddd}
.breadcrumb a{color:var(--gray-600);text-decoration:none}
.breadcrumb a:hover{color:var(--black)}

/* ── Day header with sub-tabs ── */
.day-header{padding:16px 24px 0;background:#fff;border-bottom:1px solid var(--border);flex-shrink:0}
.day-header h1{font-size:22px;font-weight:300;letter-spacing:-.01em;margin-bottom:2px}
.day-header .subtitle{font-size:13px;color:var(--gray-400);margin-bottom:14px}
.day-tabs{display:flex;gap:0}
.day-tab{display:flex;align-items:center;gap:6px;padding:10px 16px;font-size:13px;color:var(--gray-400);cursor:pointer;border-bottom:2px solid transparent;margin-bottom:-1px;transition:color .1s}
.day-tab:hover{color:var(--gray-600)}
.day-tab.active{color:var(--black);font-weight:600;border-bottom-color:var(--gold)}

/* ── Slide list (inside content area) ── */
.slide-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:20px 24px}
.slide-card{display:flex;align-items:center;gap:12px;padding:14px 16px;border:1px solid var(--border);border-radius:8px;cursor:pointer;transition:border-color .15s}
.slide-card:hover{border-color:var(--gold)}
.slide-card.has-video{border-left:3px solid #c00}
.slide-card .seg-thumb{flex-shrink:0;position:relative;width:40px;height:40px;display:flex;align-items:center;justify-content:center}
.slide-card .seg-num{width:30px;height:30px;border-radius:8px;background:var(--gray-100);display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;color:var(--gray-600);font-family:'IBM Plex Mono',monospace}
.slide-card .yt-thumb{width:40px;height:30px;border-radius:4px;object-fit:cover}
.slide-card .yt-play{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:#fff;font-size:14px;text-shadow:0 1px 3px rgba(0,0,0,.5)}
.slide-card .seg-info{flex:1;min-width:0}
.slide-card .seg-title{font-size:14px;font-weight:500;color:var(--black);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.slide-card .seg-meta{font-size:11px;color:var(--gray-400);margin-top:2px;display:flex;align-items:center;gap:4px}
.slide-card .yt-badge{background:#c00;color:#fff;font-size:9px;font-weight:700;padding:1px 5px;border-radius:3px;letter-spacing:.03em}
.slide-card .pending-badge{background:var(--gray-100);color:var(--gray-400);font-size:9px;font-weight:600;padding:1px 5px;border-radius:3px}
.slide-card .seg-actions{display:flex;flex-direction:column;gap:4px;flex-shrink:0}
.slide-card .open-btn{font-size:11px;color:var(--link);white-space:nowrap;text-decoration:none;padding:3px 8px;border-radius:4px;border:1px solid #1565C030;text-align:center}
.slide-card .open-btn:hover{background:#1565C010}

/* ── YouTube embed ── */
.yt-embed-container{padding:8px 24px 0 !important;display:flex;justify-content:center;background:#111 !important;border-bottom:none !important}
.yt-embed{width:100%;max-width:720px;aspect-ratio:16/9;border-radius:6px}

/* ── Iframe content ── */
.content-frame{flex:1;border:none;width:100%;background:#fff}

/* ── Slide preview with toolbar ── */
.slide-toolbar{display:flex;align-items:center;gap:10px;padding:8px 24px;background:#fff;border-bottom:1px solid var(--border);flex-shrink:0}
.slide-toolbar .slide-title{flex:1;font-size:13px;font-weight:600;color:var(--black)}
.slide-toolbar a{font-size:12px;color:var(--link);text-decoration:none;padding:4px 12px;border-radius:4px;border:1px solid #1565C030}
.slide-toolbar a:hover{background:#1565C010}

/* ── Code & Notebook panel ── */
.code-panel{flex:1;overflow-y:auto;background:#fdfcfa;padding:20px 24px}
.code-panel .code-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
.code-panel .code-header h3{font-size:16px;font-weight:700;color:var(--black);margin:0}
.code-panel .dl-all{font-size:12px;color:#fff;background:var(--link);padding:6px 14px;border-radius:6px;text-decoration:none;font-weight:600}
.code-panel .dl-all:hover{opacity:.9}
.code-panel .jupyter-banner{background:#F37626;color:#fff;border-radius:8px;padding:12px 16px;margin-bottom:18px;font-size:13px;display:flex;align-items:center;gap:10px}
.code-panel .jupyter-banner .jup-icon{font-size:20px}
.code-panel .jupyter-banner a{color:#fff;font-weight:700;text-decoration:underline}
.ex-section{margin-bottom:20px;border:1px solid var(--border);border-radius:8px;overflow:hidden}
.ex-section .ex-header{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;background:var(--gray-100);border-bottom:1px solid var(--border)}
.ex-section .ex-header .ex-title{font-size:14px;font-weight:600;color:var(--black)}
.ex-section .ex-header .ex-actions{display:flex;gap:6px}
.ex-section .ex-header .ex-btn{font-size:11px;padding:4px 10px;border-radius:4px;text-decoration:none;border:1px solid #1565C030;color:var(--link);white-space:nowrap}
.ex-section .ex-header .ex-btn:hover{background:#1565C010}
.ex-section .ex-header .ex-btn.zip{background:var(--link);color:#fff;border-color:var(--link)}
.ex-section .ex-header .ex-btn.zip:hover{opacity:.9}
.ex-section .ex-header .ex-btn.sol{background:#2E7D32;color:#fff;border-color:#2E7D32}
.ex-section .file-list{padding:0;margin:0;list-style:none}
.ex-section .file-item{display:flex;align-items:center;gap:10px;padding:8px 14px;border-bottom:1px solid #f0f0ec;font-size:13px}
.ex-section .file-item:last-child{border-bottom:none}
.ex-section .file-item .file-icon{font-size:14px;width:20px;text-align:center;flex-shrink:0}
.ex-section .file-item .file-name{flex:1;font-family:'IBM Plex Mono',monospace;font-size:12px;color:var(--black)}
.ex-section .file-item .file-links{display:flex;gap:6px}
.ex-section .file-item .file-link{font-size:11px;color:var(--link);text-decoration:none;padding:2px 8px;border-radius:3px;border:1px solid #1565C020}
.ex-section .file-item .file-link:hover{background:#1565C010}
.ex-section .file-item .file-link.jup{color:#E65100;border-color:#E6510030}
.ex-section .file-item .file-link.jup:hover{background:#E6510010}
</style>
</head>
<body>

<div class="shell">
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="logo">
                <div class="logo-icon">⚡</div>
                <div>
                    <div class="logo-text">HDL for DSD</div>
                    <div class="logo-sub">v2.1 · UCF ECE</div>
                </div>
            </div>
            <button class="sidebar-toggle" onclick="toggleSidebar()" title="Toggle sidebar">☰</button>
        </div>
        <div class="sidebar-nav" id="sidebarNav">
            <!-- Populated by JS from manifest -->
        </div>
    </div>

    <!-- Main -->
    <div class="main" id="mainArea">
        <div class="breadcrumb" id="breadcrumb">
            <a href="#" onclick="navigateTo('doc','overview');return false">Course</a>
        </div>
        <iframe class="content-frame" id="contentFrame" src="content/overview.html"></iframe>
    </div>
</div>

<script>
let manifest = /*MANIFEST_JSON*/null;
let currentView = { type: 'doc', id: 'overview' };
let expandedWeeks = { 1: true, 2: true, 3: true, 4: true };

// Build navigation immediately (manifest is inlined)
buildNav();

function buildNav() {
    const nav = document.getElementById('sidebarNav');
    let html = '<div class="nav-section-label">Course</div>';

    manifest.docs.forEach(d => {
        html += `<div class="nav-item${currentView.type==='doc'&&currentView.id===d.id?' active':''}" data-type="doc" data-id="${d.id}" onclick="navigateTo('doc','${d.id}')">${d.label}</div>`;
    });

    html += '<div class="nav-divider"></div>';

    manifest.weeks.forEach(w => {
        const open = expandedWeeks[w.num];
        html += `<div class="nav-week" onclick="toggleWeek(${w.num})"><span class="arrow${open?' open':''}">▶</span>Week ${w.num}: ${w.title}</div>`;
        if (open) {
            w.days.forEach(d => {
                const active = currentView.type==='day' && currentView.id===d.num;
                html += `<div class="nav-day${active?' active':''}" onclick="navigateTo('day',${d.num})"><span class="day-num">${String(d.num).padStart(2,'0')}</span><span class="day-label">${d.title}</span></div>`;
            });
        }
    });

    nav.innerHTML = html;
}

function toggleWeek(num) {
    expandedWeeks[num] = !expandedWeeks[num];
    buildNav();
}

function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('collapsed');
}

// ── Navigation ──

function navigateTo(type, id) {
    currentView = { type, id };
    buildNav();

    const main = document.getElementById('mainArea');
    const bc = document.getElementById('breadcrumb');

    if (type === 'doc') {
        const doc = manifest.docs.find(d => d.id === id);
        bc.innerHTML = `<a href="#" onclick="navigateTo('doc','overview');return false">Course</a><span class="sep">›</span>${doc ? doc.label : id}`;
        // Remove day header and slide toolbar if present
        clearDayUI();
        loadFrame(doc ? doc.content : '');
    }
    else if (type === 'day') {
        showDay(id);
    }
}

// Listen for navigation messages from iframed content (e.g., overview day cards)
window.addEventListener('message', function(e) {
    if (e.data && e.data.type === 'nav') {
        navigateTo(e.data.view, e.data.id);
    }
});

function clearDayUI() {
    const existing = document.querySelectorAll('.day-header, .slide-toolbar, .slide-grid-container, .yt-embed-container, .code-panel');
    existing.forEach(el => el.remove());
}

let currentDayTab = 'plan';
let currentDayNum = null;

function showDay(dayNum) {
    currentDayNum = dayNum;
    currentDayTab = 'plan';
    clearDayUI();

    // Find day data
    let weekData = null, dayData = null;
    for (const w of manifest.weeks) {
        for (const d of w.days) {
            if (d.num === dayNum) { weekData = w; dayData = d; break; }
        }
        if (dayData) break;
    }
    if (!dayData) return;

    const bc = document.getElementById('breadcrumb');
    bc.innerHTML = `<a href="#" onclick="navigateTo('doc','overview');return false">Course</a><span class="sep">›</span><a href="#" onclick="navigateTo('doc','overview');return false">Week ${weekData.num}</a><span class="sep">›</span>Day ${dayNum}: ${dayData.title}`;

    // Insert day header with tabs
    const header = document.createElement('div');
    header.className = 'day-header';
    header.innerHTML = `
        <h1>Day ${dayNum}: ${dayData.title}</h1>
        <div class="subtitle">Week ${weekData.num} · Session ${dayNum} of 16 · Deliverable: ${dayData.deliverable}</div>
        <div class="day-tabs" id="dayTabs">
            <div class="day-tab active" data-tab="plan" onclick="switchDayTab('plan')">📋 Daily Plan</div>
            <div class="day-tab" data-tab="videos" onclick="switchDayTab('videos')">▶ Videos (${dayData.slides.length})</div>
            ${dayData.content.quiz ? '<div class="day-tab" data-tab="quiz" onclick="switchDayTab(\'quiz\')">📝 Quiz</div>' : ''}
            <div class="day-tab" data-tab="lab" onclick="switchDayTab('lab')">🔬 Lab</div>
            ${dayData.code_assets ? '<div class="day-tab" data-tab="code" onclick="switchDayTab(\'code\')">💾 Code & Notebooks</div>' : ''}
        </div>
    `;

    const frame = document.getElementById('contentFrame');
    frame.parentNode.insertBefore(header, frame);

    // Load default tab
    loadDayContent(dayData, 'plan');
}

function switchDayTab(tab) {
    currentDayTab = tab;
    // Update tab UI
    document.querySelectorAll('.day-tab').forEach(t => {
        t.classList.toggle('active', t.dataset.tab === tab);
    });

    // Find day data
    let dayData = null;
    for (const w of manifest.weeks) {
        for (const d of w.days) {
            if (d.num === currentDayNum) { dayData = d; break; }
        }
        if (dayData) break;
    }
    if (dayData) loadDayContent(dayData, tab);
}

function loadDayContent(dayData, tab) {
    // Remove existing slide toolbar/grid/youtube embeds/code panels
    document.querySelectorAll('.slide-toolbar, .slide-grid-container, .yt-embed-container, .code-panel').forEach(el => el.remove());

    const frame = document.getElementById('contentFrame');

    if (tab === 'code' && dayData.code_assets) {
        frame.style.display = 'none';
        const container = document.createElement('div');
        container.className = 'code-panel';
        container.innerHTML = renderCodePanel(dayData);
        frame.parentNode.appendChild(container);
    } else if (tab === 'videos') {
        // Show slide grid instead of iframe
        frame.style.display = 'none';

        const container = document.createElement('div');
        container.className = 'slide-grid-container';
        container.style.cssText = 'flex:1;overflow-y:auto;background:#fdfcfa';

        if (dayData.slides.length === 0) {
            container.innerHTML = '<div style="padding:40px;text-align:center;color:#999">No video segments for this session.</div>';
        } else {
            let html = '<div class="slide-grid">';
            dayData.slides.forEach(s => {
                const hasVideo = !!s.youtube_id;
                const ytThumb = hasVideo ? `https://img.youtube.com/vi/${s.youtube_id}/mqdefault.jpg` : '';
                html += `<div class="slide-card${hasVideo ? ' has-video' : ''}" onclick="previewSlide('${s.file}', '${s.title.replace(/'/g,"\\'")}', '${s.youtube_id || ''}')">
                    <div class="seg-thumb">
                        ${hasVideo
                            ? `<img src="${ytThumb}" alt="" class="yt-thumb"><div class="yt-play">▶</div>`
                            : `<div class="seg-num">${s.segment}</div>`
                        }
                    </div>
                    <div class="seg-info">
                        <div class="seg-title">${s.title}</div>
                        <div class="seg-meta">
                            ${hasVideo
                                ? '<span class="yt-badge">YouTube</span> · '
                                : '<span class="pending-badge">Coming soon</span> · '
                            }
                            Slides
                        </div>
                    </div>
                    <div class="seg-actions">
                        ${hasVideo ? `<a class="open-btn" href="https://www.youtube.com/watch?v=${s.youtube_id}" target="_blank" onclick="event.stopPropagation()">↗ YouTube</a>` : ''}
                        <a class="open-btn" href="${s.file}" target="_blank" onclick="event.stopPropagation()">↗ Slides</a>
                    </div>
                </div>`;
            });
            html += '</div>';
            container.innerHTML = html;
        }

        frame.parentNode.appendChild(container);
    } else {
        // Remove slide grid if present
        frame.style.display = '';
        const contentUrl = dayData.content[tab];
        loadFrame(contentUrl);
    }
}

function previewSlide(url, title, youtubeId) {
    // Remove slide grid, show toolbar + content
    document.querySelectorAll('.slide-grid-container').forEach(el => el.remove());

    const frame = document.getElementById('contentFrame');
    frame.style.display = '';

    // Add toolbar above iframe
    const toolbar = document.createElement('div');
    toolbar.className = 'slide-toolbar';
    let toolbarHtml = `<span class="slide-title">📽 ${title}</span>`;
    toolbarHtml += `<a href="#" onclick="switchDayTab('videos');return false">← Back to segments</a>`;
    if (youtubeId) {
        toolbarHtml += `<a href="https://www.youtube.com/watch?v=${youtubeId}" target="_blank">↗ YouTube</a>`;
    }
    toolbarHtml += `<a href="${url}" target="_blank">↗ Slides</a>`;
    toolbar.innerHTML = toolbarHtml;
    frame.parentNode.insertBefore(toolbar, frame);

    if (youtubeId) {
        // Show YouTube embed above slides iframe
        const videoContainer = document.createElement('div');
        videoContainer.className = 'slide-toolbar yt-embed-container';
        videoContainer.innerHTML = `<iframe class="yt-embed" src="https://www.youtube.com/embed/${youtubeId}?rel=0" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`;
        frame.parentNode.insertBefore(videoContainer, frame);
    }

    loadFrame(url);
}

function loadFrame(url) {
    const frame = document.getElementById('contentFrame');
    if (url) {
        frame.src = url;
    } else {
        frame.src = 'about:blank';
    }
}

// ── Code & Notebooks panel ──

const FILE_ICONS = {'.v':'📄','.sv':'📄','.hex':'🔢','.pcf':'📌','.md':'📝','.py':'🐍','.ipynb':'📓'};
const MAKEFILE_ICON = '⚙️';

function renderCodePanel(dayData) {
    const ca = dayData.code_assets;
    if (!ca) return '<div style="padding:40px;text-align:center;color:#999">No code assets for this session.</div>';

    const jupBase = manifest.jupyter_base;
    let html = '';

    // Header with download-all button
    html += '<div class="code-header">';
    html += `<h3>Lab Code & Notebooks — Day ${dayData.num}</h3>`;
    if (ca.all_zip) {
        html += `<a class="dl-all" href="${ca.all_zip}" download>⬇ Download All Starter Code (.zip)</a>`;
    }
    html += '</div>';

    // JupyterHub banner
    html += `<div class="jupyter-banner">
        <span class="jup-icon">🪐</span>
        <span>Open files directly in <a href="${jupBase}" target="_blank">JupyterHub</a> — click the <strong>Open in Hub</strong> links below.
        Files assume the repo is cloned as <code style="background:rgba(255,255,255,.2);padding:1px 5px;border-radius:3px;font-size:12px">~/hdl-for-dsd/</code></span>
    </div>`;

    // Exercise sections
    ca.exercises.forEach(ex => {
        html += '<div class="ex-section">';
        html += '<div class="ex-header">';
        html += `<span class="ex-title">${ex.label}</span>`;
        html += '<span class="ex-actions">';
        if (ex.zip) {
            html += `<a class="ex-btn zip" href="${ex.zip}" download>⬇ Starter .zip</a>`;
        }
        if (ex.has_solution && ex.solution_zip) {
            html += `<a class="ex-btn sol" href="${ex.solution_zip}" download>✓ Solution .zip</a>`;
        }
        html += '</span></div>';

        // File listing
        html += '<ul class="file-list">';
        ex.files.forEach(f => {
            const icon = f.name === 'Makefile' ? MAKEFILE_ICON : (FILE_ICONS[f.ext] || '📄');
            html += '<li class="file-item">';
            html += `<span class="file-icon">${icon}</span>`;
            html += `<span class="file-name">${f.name}</span>`;
            html += '<span class="file-links">';
            html += `<a class="file-link" href="${f.github_url}" target="_blank">GitHub ↗</a>`;
            if (f.jupyter_url) {
                html += `<a class="file-link jup" href="${f.jupyter_url}" target="_blank">Open in Hub ↗</a>`;
            }
            html += '</span></li>';
        });
        html += '</ul></div>';
    });

    return html;
}
</script>
</body>
</html>"""


# ─── Main ─────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════╗")
    print("║  Building HDL Course Portal              ║")
    print("╚══════════════════════════════════════════╝")
    print()

    # Clean output
    if SITE.exists():
        shutil.rmtree(SITE)
    SITE.mkdir()
    CONTENT.mkdir()

    print("Phase 1: Content CSS")
    build_content_css()

    print("Phase 2: Convert documents")
    build_docs()

    print("Phase 3: Convert quizzes")
    build_quizzes()

    print("Phase 4: Convert lab guides")
    build_labs()

    print("Phase 5: Convert misc docs")
    build_misc()

    print("Phase 6: Generate overview")
    build_overview()

    print("Phase 7: Build lab code assets (zips + file manifest)")
    code_assets = build_lab_code_assets()

    print("Phase 8: Generate manifest")
    manifest = build_manifest(code_assets)

    print("Phase 9: Generate index.html")
    build_index(manifest)

    # Summary
    total = sum(1 for _ in SITE.rglob("*.html"))
    print()
    print(f"  Total HTML files: {total}")
    print(f"  Output: {SITE.relative_to(REPO)}/")
    print()
    print("  To preview (serve from repo root for slide embedding):")
    print("    python3 -m http.server 8000")
    print("    Open: http://localhost:8000/site/index.html")
    print()


if __name__ == "__main__":
    main()