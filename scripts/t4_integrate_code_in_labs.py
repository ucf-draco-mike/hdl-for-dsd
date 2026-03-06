#!/usr/bin/env python3
"""
Transform 4: Integrate code/download links directly into lab pages.

Changes prep_mkdocs.py so that lab.md is a generated file (not a symlink)
that includes:
  1. A download banner at the top (all-starter zip + notebook link)
  2. Per-exercise code callouts injected after each exercise heading
  3. For days without detailed exercise headings, a consolidated code
     section appended at the end

Also removes "Code & Notebooks" from the mkdocs.yml primary nav since
all links are now in the lab page. code.md is kept as a generated file
for full reference but moved to a less prominent position.

Usage:
    python3 transforms/t4_integrate_code_in_labs.py           # preview
    python3 transforms/t4_integrate_code_in_labs.py --apply   # execute

After applying:
    git add -A
    git commit -m "feat: integrate code download links directly into lab pages"
"""

import argparse
import re
import textwrap
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SCRIPT = REPO / "scripts" / "prep_mkdocs.py"
MKDOCS_YML = REPO / "mkdocs.yml"

# ─── New function to add to prep_mkdocs.py ────────────────────────

GENERATE_LAB_PAGE_FUNC = r'''

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
                f'    [:material-notebook: Open Lab Notebook]({nb_jup})'
                f'{{ .md-button target=_blank }}\n'
                f'    [:material-github: Notebook on GitHub]({nb_gh})'
                f'{{ .md-button target=_blank }}\n'
            )
        banner_lines.append(
            f'    Individual exercise downloads are linked below each exercise.\n'
            f'    Full file listing: [Code & Notebooks Reference](code.md)\n'
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
            # GitHub link to the starter directory
            for sf in ex.get("starter_files", []):
                gh = f"{GITHUB_RAW_BASE}/{sf.relative_to(REPO)}"
                parts.append(
                    f'[:material-github: `{sf.name}`]({gh}){{ target=_blank }}'
                )
                break  # just link first file as representative

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

'''


def patch_prep_mkdocs(dry_run=True):
    """Apply patches to scripts/prep_mkdocs.py."""
    content = SCRIPT.read_text(encoding="utf-8")
    patches_applied = []

    # ── Patch 1: Add generate_lab_page function ────────────────────
    # Insert before generate_homepage()
    marker = "def generate_homepage():"
    if "def generate_lab_page(" not in content:
        if marker in content:
            content = content.replace(marker, GENERATE_LAB_PAGE_FUNC + "\n" + marker)
            patches_applied.append("Added generate_lab_page() function")
        else:
            print(f"  ERROR: Could not find '{marker}' in prep_mkdocs.py")
            return False, []
    else:
        patches_applied.append("generate_lab_page() already exists (skipped)")

    # ── Patch 2: Change lab.md from symlink to generated ───────────
    old_lab_block = (
        '        lab = REPO / "labs" / dir_name / "README.md"\n'
        '        if lab.exists(): symlink(lab, dd / "lab.md")'
    )
    new_lab_block = (
        '        # Generate enriched lab page (with code links injected)\n'
        '        lab_md = generate_lab_page(day_num, dir_name, code_assets)\n'
        '        if lab_md:\n'
        '            (dd / "lab.md").write_text(lab_md, encoding="utf-8")\n'
        '        else:\n'
        '            lab = REPO / "labs" / dir_name / "README.md"\n'
        '            if lab.exists(): symlink(lab, dd / "lab.md")'
    )
    if old_lab_block in content:
        content = content.replace(old_lab_block, new_lab_block)
        patches_applied.append("Changed lab.md from symlink → generated (with code injection)")
    elif "generate_lab_page(day_num" in content:
        patches_applied.append("lab.md generation already patched (skipped)")
    else:
        print("  WARNING: Could not find lab symlink block to patch")
        print("  Looking for:")
        print(f"    {old_lab_block!r}")

    if not dry_run:
        SCRIPT.write_text(content, encoding="utf-8")

    return True, patches_applied


def patch_mkdocs_yml(dry_run=True):
    """Remove 'Code & Notebooks' from primary nav, keeping it accessible."""
    content = MKDOCS_YML.read_text(encoding="utf-8")
    patches = []

    # Remove "Code & Notebooks: days/dayNN/code.md" lines from nav
    # Keep the file generated — just not in primary nav
    lines = content.split("\n")
    new_lines = []
    removed = 0
    for line in lines:
        if re.match(r'\s+- Code & Notebooks: days/day\d+/code\.md', line):
            removed += 1
            continue
        new_lines.append(line)

    if removed > 0:
        patches.append(f"Removed {removed} 'Code & Notebooks' nav entries from mkdocs.yml")
        content = "\n".join(new_lines)
    else:
        patches.append("No 'Code & Notebooks' nav entries found (already removed)")

    if not dry_run:
        MKDOCS_YML.write_text(content, encoding="utf-8")

    return patches


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    dry_run = not args.apply

    if dry_run:
        print("╔══════════════════════════════════════════╗")
        print("║  Transform 4: PREVIEW (dry run)          ║")
        print("║  Add --apply to execute                  ║")
        print("╚══════════════════════════════════════════╝")
    else:
        print("╔══════════════════════════════════════════╗")
        print("║  Transform 4: Applying changes           ║")
        print("╚══════════════════════════════════════════╝")
    print()

    # ── Patch prep_mkdocs.py ───────────────────────────────────────
    print("Step 1: Patch scripts/prep_mkdocs.py")
    ok, patches = patch_prep_mkdocs(dry_run)
    for p in patches:
        print(f"  {p}")
    if not ok:
        print("  FAILED — aborting")
        return
    print()

    # ── Patch mkdocs.yml ───────────────────────────────────────────
    print("Step 2: Patch mkdocs.yml")
    patches = patch_mkdocs_yml(dry_run)
    for p in patches:
        print(f"  {p}")
    print()

    # ── Summary ────────────────────────────────────────────────────
    if dry_run:
        print("This was a dry run. To apply:")
        print("  python3 transforms/t4_integrate_code_in_labs.py --apply")
        print()
        print("After applying, test with:")
        print("  python3 scripts/prep_mkdocs.py")
        print("  # Inspect docs_src/days/day01/lab.md for injected code links")
        print("  # Inspect docs_src/days/day09/lab.md for appended code section")
    else:
        print("=== Transform 4 Complete ===")
        print()
        print("Verify with:")
        print("  python3 scripts/prep_mkdocs.py")
        print("  head -30 docs_src/days/day01/lab.md  # should have download banner")
        print("  grep -n 'code.*Exercise' docs_src/days/day06/lab.md  # inline callouts")
        print("  tail -30 docs_src/days/day09/lab.md   # appended code section")
        print()
        print("Then commit:")
        print("  git add -A")
        print("  git commit -m 'feat: integrate code download links directly into lab pages'")


if __name__ == "__main__":
    main()
