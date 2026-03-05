#!/usr/bin/env python3
"""
prep_mkdocs.py — Assemble MkDocs source directory from repo content.

Usage:
    python3 scripts/prep_mkdocs.py          # prep only
    python3 scripts/prep_mkdocs.py --serve   # prep + mkdocs serve
    python3 scripts/prep_mkdocs.py --build   # prep + mkdocs build
"""

import json, os, re, shutil, subprocess, sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DOCS = REPO / "docs_src"
YOUTUBE_FILE = REPO / "youtube_ids.json"

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

def generate_day_page(day_num, dir_name, title, yt_ids):
    slides = get_slides(day_num, dir_name, yt_ids)
    wk = (day_num - 1) // 4 + 1
    dz = f"{day_num:02d}"
    lines = []
    lines.append(f"# Day {day_num}: {title}\n")
    lines.append(f"**Week {wk} \u00b7 Session {day_num} of 16**\n")

    # Nav buttons
    lines.append('<div class="day-nav-cards" markdown>\n')
    lines.append('[:material-clipboard-text: **Daily Plan**](plan.md){ .md-button }')
    lines.append('[:material-flask: **Lab Guide**](lab.md){ .md-button }')
    quiz_exists = (REPO / "lectures" / dir_name / f"day{dz}_quiz.md").exists()
    if quiz_exists:
        lines.append('[:material-help-circle: **Pre-Class Quiz**](quiz.md){ .md-button }')
    lines.append('\n</div>\n')

    # Videos section
    lines.append("## Pre-Class Video Segments\n")
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
                lines.append(f'!!! info "Video coming soon"')
                lines.append(f'    This segment has not been recorded yet.\n')
                lines.append(f'[:material-presentation: View Slides]({s["slide_path"]})'
                             f'{{ .md-button .md-button--primary target="_blank" }}\n')
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

    # Copy theme CSS referenced by slides
    theme_src = REPO / "lectures" / "theme"
    theme_dst = site / "lectures" / "theme"
    # Already copied by copytree above

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

    # Top-level pages
    for name, src in [
        ("index.md",      REPO / "docs" / "README.md"),
        ("syllabus.md",   REPO / "docs" / "course_syllabus.md"),
        ("curriculum.md", REPO / "docs" / "course_curriculum.md"),
        ("setup.md",      REPO / "docs" / "course_setup_guide.md"),
        ("project.md",    REPO / "projects" / "README.md"),
        ("library.md",    REPO / "shared" / "lib" / "README.md"),
        ("dev-status.md", REPO / "docs" / "course_dev_status.md"),
    ]:
        if src.exists(): symlink(src, DOCS / name)
    print(f"  Symlinked: 7 top-level pages")

    # Day pages
    for day_num, dir_name, title in DAYS:
        dz = f"{day_num:02d}"
        dd = DOCS / "days" / f"day{dz}"
        dd.mkdir(parents=True, exist_ok=True)

        # Generated index
        (dd / "index.md").write_text(generate_day_page(day_num, dir_name, title, yt_ids))

        # Symlinks
        plan = REPO / "docs" / f"day{dz}.md"
        if plan.exists(): symlink(plan, dd / "plan.md")

        quiz = REPO / "lectures" / dir_name / f"day{dz}_quiz.md"
        if quiz.exists(): symlink(quiz, dd / "quiz.md")

        lab = REPO / "labs" / dir_name / "README.md"
        if lab.exists(): symlink(lab, dd / "lab.md")

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
:root {
    --md-primary-fg-color: #000;
    --md-primary-bg-color: #FFC904;
    --md-accent-fg-color: #FFC904;
}
[data-md-color-scheme="slate"] {
    --md-primary-fg-color: #000;
    --md-primary-bg-color: #FFC904;
    --md-default-bg-color: #0d1117;
}
.md-header { background: #000 !important; }
.md-header__title { color: #FFC904 !important; font-weight: 700; }
.md-tabs { background: #1a1a1a !important; }
.video-container {
    position: relative; padding-bottom: 56.25%; height: 0;
    overflow: hidden; margin: 1em 0; border-radius: 8px;
    background: #111; box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
.video-container iframe {
    position: absolute; top: 0; left: 0;
    width: 100%; height: 100%; border: none; border-radius: 8px;
}
.day-nav-cards { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 1.5em; }
.day-nav-cards .md-button { font-size: 0.85em !important; }
.md-content h1 { border-bottom: 3px solid #FFC904; padding-bottom: 0.3em; }
.highlight pre { border-left: 3px solid #FFC904; }
"""

if __name__ == "__main__":
    main()