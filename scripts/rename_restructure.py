#!/usr/bin/env python3
"""
rename_structure.py — Rename repo directories and files to week#_day#_activity# convention.

Usage:
    python3 scripts/rename_structure.py                  # dry-run (default)
    python3 scripts/rename_structure.py --execute        # perform renames
    python3 scripts/rename_structure.py --execute --git  # use 'git mv' instead of os.rename

Run from repo root.
"""

import os
import re
import sys
import shutil
import subprocess
import argparse
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

REPO_ROOT = Path(os.environ.get("REPO_ROOT", ".")).resolve()

def day_to_week(day: int) -> int:
    """Map day number (1-16) to week number (1-4)."""
    return (day - 1) // 4 + 1

# ---------------------------------------------------------------------------
# Rename rules — each returns a list of (old_path, new_path) relative to root
# ---------------------------------------------------------------------------

def plan_renames_docs(root: Path) -> list[tuple[Path, Path]]:
    """Rename docs/dayNN_*.md → docs/weekW_dayDD_plan.md
       Rename course-level docs → docs/course_*.md
    """
    ops = []
    docs = root / "docs"
    if not docs.is_dir():
        return ops

    # Daily plans: dayNN_anything.md → weekW_dayDD_plan.md
    for f in sorted(docs.glob("day[0-9][0-9]_*.md")):
        m = re.match(r"day(\d{2})_(.+)\.md$", f.name)
        if m:
            day = int(m.group(1))
            week = day_to_week(day)
            new_name = f"week{week}_day{day:02d}_plan.md"
            ops.append((f, docs / new_name))

    # Course-level docs
    course_level = {
        "course_curriculum.md":            "course_curriculum.md",
        "course_syllabus.md":              "course_syllabus.md",
        "course_setup_guide.md":           "course_setup_guide.md",
        "course_video_scaffold.md": "course_video_scaffold.md",
        "course_dev_status.md":    "course_dev_status.md",
    }
    for old_name, new_name in course_level.items():
        old = docs / old_name
        if old.exists():
            ops.append((old, docs / new_name))

    return ops


def plan_renames_labs(root: Path) -> list[tuple[Path, Path]]:
    """Flatten labs/weekN/dayNN/ → labs/weekW_dayDD/"""
    ops = []
    labs = root / "labs"
    if not labs.is_dir():
        return ops

    for week_dir in sorted(labs.glob("week[0-9]*")):
        if not week_dir.is_dir():
            continue
        for day_dir in sorted(week_dir.glob("day[0-9][0-9]*")):
            if not day_dir.is_dir():
                continue
            m = re.match(r"day(\d{2})", day_dir.name)
            if m:
                day = int(m.group(1))
                week = day_to_week(day)
                new_dir = labs / f"week{week}_day{day:02d}"
                ops.append((day_dir, new_dir))

    return ops


def plan_renames_lectures(root: Path) -> list[tuple[Path, Path]]:
    """Restructure lectures/weekN/ → lectures/weekW_dayDD/
    
    Handles two layouts:
      A) lectures/weekN/dayNN_topic/  → lectures/weekW_dayDD/
      B) lectures/weekN/ (flat, segments only) → split by day numbering
    """
    ops = []
    lectures = root / "lectures"
    if not lectures.is_dir():
        return ops

    for week_dir in sorted(lectures.glob("week[0-9]*")):
        if not week_dir.is_dir() or week_dir.name == "theme":
            continue

        # Check for day subdirectories first (Layout A)
        day_subdirs = sorted(week_dir.glob("day[0-9][0-9]*"))
        if day_subdirs:
            for day_dir in day_subdirs:
                m = re.match(r"day(\d{2})", day_dir.name)
                if m:
                    day = int(m.group(1))
                    week = day_to_week(day)
                    new_dir = lectures / f"week{week}_day{day:02d}"
                    ops.append((day_dir, new_dir))
        else:
            # Layout B: flat segment files in weekN/
            # Infer week number from directory name
            wm = re.match(r"week(\d+)", week_dir.name)
            if wm:
                week_num = int(wm.group(1))
                new_dir = lectures / f"week{week_num}_slides"
                ops.append((week_dir, new_dir))

    return ops


def plan_renames_scripts(root: Path) -> list[tuple[Path, Path]]:
    """Rename scripts/generate_weekN.py → scripts/weekN_generate_slides.py"""
    ops = []
    scripts = root / "scripts"
    if not scripts.is_dir():
        return ops

    for f in sorted(scripts.glob("generate_week[0-9]*.py")):
        m = re.match(r"generate_week(\d+)\.py$", f.name)
        if m:
            week = int(m.group(1))
            new_name = f"week{week}_generate_slides.py"
            ops.append((f, scripts / new_name))

    return ops


# ---------------------------------------------------------------------------
# Execution engine
# ---------------------------------------------------------------------------

def execute_rename(old: Path, new: Path, use_git: bool, dry_run: bool) -> str:
    """Perform a single rename. Returns a log line."""
    rel_old = old.relative_to(REPO_ROOT)
    rel_new = new.relative_to(REPO_ROOT)
    tag = "[DRY-RUN] " if dry_run else ""

    if old == new:
        return f"  SKIP (identical): {rel_old}"

    if new.exists():
        return f"  ** CONFLICT: {rel_new} already exists — skipping {rel_old}"

    line = f"  {tag}{rel_old}  →  {rel_new}"

    if not dry_run:
        new.parent.mkdir(parents=True, exist_ok=True)
        if use_git:
            subprocess.run(["git", "mv", str(old), str(new)],
                           cwd=REPO_ROOT, check=True)
        else:
            if old.is_dir():
                shutil.move(str(old), str(new))
            else:
                old.rename(new)

    return line


def cleanup_empty_dirs(root: Path, dry_run: bool):
    """Remove directories left empty after flattening."""
    for dirpath in sorted(root.rglob("*"), reverse=True):
        if dirpath.is_dir() and not any(dirpath.iterdir()):
            rel = dirpath.relative_to(REPO_ROOT)
            tag = "[DRY-RUN] " if dry_run else ""
            print(f"  {tag}REMOVE empty: {rel}")
            if not dry_run:
                dirpath.rmdir()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Rename HDL course repo to week#_day# convention")
    parser.add_argument("--execute", action="store_true",
                        help="Actually perform renames (default is dry-run)")
    parser.add_argument("--git", action="store_true",
                        help="Use 'git mv' for renames (preserves history)")
    args = parser.parse_args()
    dry_run = not args.execute

    if dry_run:
        print("=" * 60)
        print("  DRY RUN — no changes will be made")
        print("  Re-run with --execute to apply (add --git for git mv)")
        print("=" * 60)

    all_ops = []

    print("\n[1/4] Docs — daily plans + course-level docs")
    ops = plan_renames_docs(REPO_ROOT)
    all_ops.extend(ops)
    for old, new in ops:
        print(execute_rename(old, new, args.git, dry_run))

    print("\n[2/4] Labs — flatten week/day nesting")
    ops = plan_renames_labs(REPO_ROOT)
    all_ops.extend(ops)
    for old, new in ops:
        print(execute_rename(old, new, args.git, dry_run))

    print("\n[3/4] Lectures — restructure to weekW_dayDD")
    ops = plan_renames_lectures(REPO_ROOT)
    all_ops.extend(ops)
    for old, new in ops:
        print(execute_rename(old, new, args.git, dry_run))

    print("\n[4/4] Scripts — prefix-first naming")
    ops = plan_renames_scripts(REPO_ROOT)
    all_ops.extend(ops)
    for old, new in ops:
        print(execute_rename(old, new, args.git, dry_run))

    # Clean up empty parent directories
    if not dry_run:
        print("\n[cleanup] Removing empty directories...")
        for subdir in ["labs", "lectures"]:
            cleanup_empty_dirs(REPO_ROOT / subdir, dry_run)

    # Write the mapping file for Script 2
    mapping_file = REPO_ROOT / "scripts" / ".rename_mapping.json"
    import json
    mapping = {str(o.relative_to(REPO_ROOT)): str(n.relative_to(REPO_ROOT))
               for o, n in all_ops if o != n}
    if not dry_run:
        mapping_file.parent.mkdir(parents=True, exist_ok=True)
        with open(mapping_file, "w") as f:
            json.dump(mapping, f, indent=2)
        print(f"\n  Wrote rename mapping → {mapping_file.relative_to(REPO_ROOT)}")
    else:
        print(f"\n  Would write {len(mapping)} entries to {mapping_file.relative_to(REPO_ROOT)}")

    print(f"\nTotal operations: {len(all_ops)}")


if __name__ == "__main__":
    main()