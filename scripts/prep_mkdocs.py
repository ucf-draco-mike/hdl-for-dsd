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
    deliverables = {d[0]: d[2] for d in DAYS}  # not used yet but useful
    lines = []
    lines.append(f"---\ntitle: \"Day {day_num}: {title}\"\n---\n")
    lines.append(f"# Day {day_num}: {title}\n")
    lines.append(f'<p class="subtitle">Week {wk} · Session {day_num} of 16</p>\n')

    # Nav cards
    quiz_exists = (REPO / "lectures" / dir_name / f"day{dz}_quiz.md").exists()
    lines.append('<div class="card-grid card-grid--3" markdown>\n')
    lines.append(f'<div class="nav-card" markdown>\n:material-clipboard-text:{{ .card-icon }}\n\n**Daily Plan**\n\nSession timeline & instructor notes\n\n[:octicons-arrow-right-16: View plan](plan.md)\n</div>\n')
    lines.append(f'<div class="nav-card" markdown>\n:material-flask:{{ .card-icon }}\n\n**Lab Guide**\n\n{len(slides)} exercises · hands-on\n\n[:octicons-arrow-right-16: View lab](lab.md)\n</div>\n')
    if quiz_exists:
        lines.append(f'<div class="nav-card" markdown>\n:material-help-circle:{{ .card-icon }}\n\n**Pre-Class Quiz**\n\nSelf-check questions\n\n[:octicons-arrow-right-16: Take quiz](quiz.md)\n</div>\n')
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
    return "\n".join(lines)


WEEK_META = [
    (1, "Verilog Foundations & Combinational Design", "#1565C0"),
    (2, "Sequential Design, Verification & AI Testing", "#7B1FA2"),
    (3, "Memory, Communication & Numerical Architectures", "#E65100"),
    (4, "Advanced Design, Verification & Final Project", "#2E7D32"),
]

def generate_homepage():
    """Generate a visually rich landing page."""
    lines = []
    lines.append("---\nhide:\n  - toc\ntitle: Course Overview\n---\n")

    # Hero
    lines.append("# Accelerated HDL for Digital System Design\n")
    lines.append('<p class="subtitle">UCF · College of Engineering & Computer Science · Department of ECE</p>\n')
    lines.append("A 4-week intensive course in Verilog and digital system design. "
                 "Open-source toolchain, real FPGA hardware, AI-assisted verification.\n")

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

    # Cross-cutting threads
    lines.append("## Cross-Cutting Threads\n")
    lines.append('<div class="card-grid card-grid--4">\n')
    for emoji, name, days_str, color in [
        ("🤖", "AI-Assisted Verification", "D6 → D8 → D12 → D14 → D16", "#7B1FA2"),
        ("📊", "PPA Analysis", "D3 → D8 → D10 → D12 → D14", "#2E7D32"),
        ("⚙️", "Constraint-Based Design", "D3 → D7 → D8 → D10 → D14", "#E65100"),
        ("🔧", "AI Tool Literacy", "D6 → D12 → D14 → D16", "#1565C0"),
    ]:
        lines.append(f'<div class="thread-card" style="border-color: {color};">\n'
                     f'<div class="thread-icon">{emoji}</div>\n'
                     f'<div class="thread-name" style="color: {color};">{name}</div>\n'
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
            lines.append(f'<a class="day-card" href="days/day{dz}/">\n'
                         f'<div class="day-num" style="color:{wk_color}">DAY {dz}</div>\n'
                         f'<div class="day-title">{day_title}</div>\n'
                         f'</a>\n')
        lines.append('</div>\n</div>\n')

    # What makes this course different
    lines.append("## What Makes This Course Different\n")
    lines.append('<div class="card-grid card-grid--2">\n')
    for title, desc in [
        ("Hands-on from Day 1", "Real hardware, real toolchain, every session."),
        ("AI-Assisted Verification", "Students learn to prompt, evaluate, and correct AI-generated testbenches."),
        ("PPA Awareness", "Resource analysis via <code>yosys stat</code> becomes a habit, not a one-off exercise."),
        ("Open-Source Everything", "No license servers, no vendor lock-in — students keep the tools forever."),
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
    # index.md: generated rich landing page (README stays for GitHub)
    (DOCS / "index.md").write_text(generate_homepage(), encoding="utf-8")

    for name, src in [
        ("syllabus.md",   REPO / "docs" / "course_syllabus.md"),
        ("curriculum.md", REPO / "docs" / "course_curriculum.md"),
        ("setup.md",      REPO / "docs" / "course_setup_guide.md"),
        ("project.md",    REPO / "projects" / "README.md"),
        ("library.md",    REPO / "shared" / "lib" / "README.md"),
        ("dev-status.md", REPO / "docs" / "course_dev_status.md"),
    ]:
        if src.exists(): symlink(src, DOCS / name)
    print(f"  Created: 7 top-level pages (6 symlinks + index.md patched)")

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
"""

if __name__ == "__main__":
    main()