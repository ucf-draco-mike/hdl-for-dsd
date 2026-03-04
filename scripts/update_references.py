#!/usr/bin/env python3
"""
update_references.py — Update internal file/path references after renaming.

Reads the mapping file produced by rename_structure.py and rewrites references
in all text files throughout the repo. Does NOT modify document titles (# headings).

Usage:
    python3 scripts/update_references.py                # dry-run (default)
    python3 scripts/update_references.py --execute       # apply changes

Run from repo root, AFTER rename_structure.py --execute.
"""

import os
import re
import sys
import json
import argparse
from pathlib import Path

REPO_ROOT = Path(os.environ.get("REPO_ROOT", ".")).resolve()
MAPPING_FILE = REPO_ROOT / "scripts" / ".rename_mapping.json"

# File extensions to process for reference updates
TEXT_EXTENSIONS = {
    ".md", ".py", ".v", ".sv", ".vh", ".svh",
    ".html", ".css", ".json", ".yaml", ".yml",
    ".sh", ".bash", ".tcl", ".pcf", ".txt",
    ""  # Makefile, README with no extension
}

# Filenames to always process regardless of extension
ALWAYS_PROCESS = {"Makefile", "Makefile.template", "README", ".gitignore"}


def load_mapping() -> dict[str, str]:
    """Load the old→new path mapping from JSON."""
    if not MAPPING_FILE.exists():
        print(f"ERROR: Mapping file not found: {MAPPING_FILE}")
        print("       Run rename_structure.py --execute first.")
        sys.exit(1)

    with open(MAPPING_FILE) as f:
        return json.load(f)


def build_replacement_patterns(mapping: dict[str, str]) -> list[tuple[re.Pattern, str, str]]:
    """Build regex patterns for all reference variants we need to catch.

    For each old→new mapping, generate patterns for:
      - Full relative paths (docs/day01_welcome... → docs/week1_day01_plan)
      - Basename only (week1_day01.md → week1_day01_plan.md)
      - Directory references (labs/week1/day01 → labs/week1_day01)
      - Path fragments in strings, links, includes
    """
    patterns = []

    for old_path, new_path in mapping.items():
        old_p = Path(old_path)
        new_p = Path(new_path)

        # --- Full relative path (with and without extension) ---
        old_str = old_path.replace("\\", "/")
        new_str = new_path.replace("\\", "/")

        # Exact path reference (e.g., in markdown links, Python strings)
        pattern = re.compile(re.escape(old_str))
        patterns.append((pattern, new_str, f"full path: {old_str}"))

        # Without extension (for references like `docs/day01_welcome...`)
        old_no_ext = str(old_p.with_suffix("")).replace("\\", "/")
        new_no_ext = str(new_p.with_suffix("")).replace("\\", "/")
        if old_no_ext != old_str:
            pattern = re.compile(re.escape(old_no_ext) + r"(?![\w/])")
            patterns.append((pattern, new_no_ext, f"no-ext path: {old_no_ext}"))

        # --- Basename references ---
        old_base = old_p.name
        new_base = new_p.name
        if old_base != new_base:
            # Match basename but not as substring of longer word
            pattern = re.compile(r"(?<![/\w])" + re.escape(old_base) + r"(?![\w])")
            patterns.append((pattern, new_base, f"basename: {old_base}"))

            # Basename without extension
            old_stem = old_p.stem
            new_stem = new_p.stem
            if old_stem != new_stem and len(old_stem) > 5:  # skip very short stems
                pattern = re.compile(r"(?<![/\w])" + re.escape(old_stem) + r"(?![\w])")
                patterns.append((pattern, new_stem, f"stem: {old_stem}"))

        # --- Directory path components (for nested→flat) ---
        # e.g., "week1/day01" → "week1_day01"
        if old_p.is_dir() or not old_p.suffix:
            old_dir = old_str.rstrip("/")
            new_dir = new_str.rstrip("/")
            if old_dir != new_dir:
                pattern = re.compile(re.escape(old_dir) + r"(?=[/\s\"'\)]|$)")
                patterns.append((pattern, new_dir, f"dir ref: {old_dir}"))

    # --- Script-name specific patterns ---
    # generate_weekN.py → weekN_generate_slides.py
    for w in range(1, 5):
        old_script = f"generate_week{w}.py"
        new_script = f"week{w}_generate_slides.py"
        pattern = re.compile(re.escape(old_script))
        patterns.append((pattern, new_script, f"script: {old_script}"))

        # Without .py
        pattern = re.compile(re.escape(f"generate_week{w}") + r"(?![\w])")
        patterns.append((pattern, f"week{w}_generate_slides", f"script stem: generate_week{w}"))

    # Deduplicate: prefer longer patterns (more specific) first
    seen = set()
    unique = []
    for pat, repl, desc in sorted(patterns, key=lambda x: -len(x[0].pattern)):
        key = (pat.pattern, repl)
        if key not in seen:
            seen.add(key)
            unique.append((pat, repl, desc))

    return unique


def is_title_line(line: str) -> bool:
    """Returns True if this line is a markdown heading — do NOT modify."""
    return bool(re.match(r"^\s*#{1,6}\s", line))


def is_yaml_title(line: str, prev_line: str) -> bool:
    """Returns True if this line is a YAML title field."""
    return bool(re.match(r"^\s*title\s*:", line, re.IGNORECASE))


def should_process(filepath: Path) -> bool:
    """Determine if a file should have its references updated."""
    if filepath.name in ALWAYS_PROCESS:
        return True
    if filepath.suffix.lower() in TEXT_EXTENSIONS:
        return True
    return False


def update_file(filepath: Path, patterns: list, dry_run: bool) -> list[str]:
    """Update references in a single file. Returns list of change descriptions."""
    changes = []
    rel = filepath.relative_to(REPO_ROOT)

    try:
        with open(filepath, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
    except (IOError, UnicodeDecodeError):
        return changes

    new_lines = []
    modified = False
    prev_line = ""

    for lineno, line in enumerate(lines, 1):
        original = line

        # Skip markdown headings and YAML titles entirely
        if is_title_line(line) or is_yaml_title(line, prev_line):
            new_lines.append(line)
            prev_line = line
            continue

        # Apply all replacement patterns
        for pattern, replacement, desc in patterns:
            line, count = pattern.subn(replacement, line)
            if count > 0:
                changes.append(f"  L{lineno}: [{desc}] {count}× in {rel}")

        if line != original:
            modified = True
        new_lines.append(line)
        prev_line = original

    if modified and not dry_run:
        with open(filepath, "w", encoding="utf-8") as f:
            f.writelines(new_lines)

    return changes


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Update internal references after repo rename")
    parser.add_argument("--execute", action="store_true",
                        help="Apply changes (default is dry-run)")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Show every line-level change")
    args = parser.parse_args()
    dry_run = not args.execute

    if dry_run:
        print("=" * 60)
        print("  DRY RUN — no files will be modified")
        print("  Re-run with --execute to apply changes")
        print("=" * 60)

    mapping = load_mapping()
    print(f"\nLoaded {len(mapping)} rename mappings from {MAPPING_FILE.name}")

    patterns = build_replacement_patterns(mapping)
    print(f"Built {len(patterns)} replacement patterns\n")

    # Walk all text files in repo
    total_changes = 0
    files_modified = 0

    for filepath in sorted(REPO_ROOT.rglob("*")):
        # Skip .git directory
        if ".git" in filepath.parts:
            continue
        if not filepath.is_file():
            continue
        if not should_process(filepath):
            continue

        changes = update_file(filepath, patterns, dry_run)
        if changes:
            files_modified += 1
            total_changes += len(changes)
            rel = filepath.relative_to(REPO_ROOT)
            tag = "[DRY-RUN] " if dry_run else ""
            print(f"{tag}Modified: {rel}  ({len(changes)} replacements)")
            if args.verbose:
                for c in changes:
                    print(c)

    print(f"\n{'=' * 60}")
    print(f"  Files modified:    {files_modified}")
    print(f"  Total replacements: {total_changes}")
    if dry_run:
        print(f"  (no changes written — use --execute to apply)")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()