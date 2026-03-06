#!/usr/bin/env python3
"""
Transform 5: Surface notebooks as first-class delivery and bridge lecture code.

Combined T5 + T6 from the analysis:

1. Deploy notebooks to the site (pages.yml + post_build)
2. Replace "Code & Notebooks" index card with a "Notebooks" card
   linking lab + lecture .ipynb downloads
3. Add "Lecture Examples" section to day index pages showing
   the code files from lectures/weekN_dayNN/code/
4. Add direct .ipynb download link to lab page banners

Usage:
    python3 transforms/t5_surface_notebooks.py           # preview
    python3 transforms/t5_surface_notebooks.py --apply   # execute
"""

import argparse
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SCRIPT = REPO / "scripts" / "prep_mkdocs.py"
PAGES_YML = REPO / ".github" / "workflows" / "pages.yml"


def patch_pages_yml(dry_run):
    """Add notebook copy step to CI pipeline."""
    content = PAGES_YML.read_text(encoding="utf-8")
    patches = []

    # Add notebooks copy after lectures copy
    marker = "      - name: Copy slides into site\n        run: cp -r lectures _site/lectures"
    new_block = (
        "      - name: Copy slides into site\n"
        "        run: cp -r lectures _site/lectures\n"
        "\n"
        "      - name: Copy notebooks into site\n"
        "        run: cp -r notebooks _site/notebooks"
    )

    if "Copy notebooks into site" not in content:
        if marker in content:
            content = content.replace(marker, new_block)
            patches.append("Added 'Copy notebooks into site' step to pages.yml")
        else:
            patches.append("WARNING: Could not find lectures copy marker in pages.yml")
    else:
        patches.append("Notebooks copy step already exists (skipped)")

    if not dry_run:
        PAGES_YML.write_text(content, encoding="utf-8")
    return patches


def patch_post_build(content):
    """Add notebooks copy to post_build() function."""

    nb_copy_block = '''
    # Copy notebooks (lab + lecture)
    nb_src = REPO / "notebooks"
    nb_dst = site / "notebooks"
    if nb_src.exists():
        if nb_dst.exists():
            shutil.rmtree(nb_dst)
        shutil.copytree(nb_src, nb_dst)
        nb_count = sum(1 for _ in nb_dst.rglob("*.ipynb"))
        print(f"  Copied: {nb_count} notebooks → _site/notebooks/")
'''

    marker = '    print(f"  Post-build complete. Site ready for deployment.")'
    if "nb_dst = site" not in content:
        if marker in content:
            content = content.replace(marker, nb_copy_block + "\n" + marker)
            return content, "Added notebooks copy to post_build()"
        else:
            return content, "WARNING: Could not find post_build marker"
    return content, "Notebooks copy in post_build already exists (skipped)"


def patch_generate_day_page(content):
    """Replace 'Code & Notebooks' card with 'Notebooks' card + add lecture examples section."""
    patches = []

    # ── Replace the Code & Notebooks card ──────────────────────────
    old_card = (
        '    if has_code:\n'
        '        lines.append(f\'<div class="nav-card" markdown>\\n'
        ':material-download-circle:{{ .card-icon }}\\n\\n'
        '**Code & Notebooks**\\n\\n'
        'Starter code, zips & Jupyter links\\n\\n'
        '[:octicons-arrow-right-16: View code](code.md)\\n'
        '</div>\\n\')'
    )

    new_card = (
        '    # Notebooks card — lab + lecture .ipynb\n'
        '    if has_notebooks:\n'
        '        nb_desc_parts = []\n'
        '        if lab_nb_chk:\n'
        '            nb_desc_parts.append("Lab notebook")\n'
        '        if lec_nb_chk:\n'
        '            nb_desc_parts.append("lecture notebook")\n'
        '        if has_code:\n'
        '            nb_desc_parts.append("[code ref](code.md)")\n'
        '        nb_desc = " · ".join(nb_desc_parts)\n'
        '        lines.append(f\'<div class="nav-card" markdown>\\n\'\n'
        '                     f\':material-notebook:{{ .card-icon }}\\n\\n\'\n'
        '                     f\'**Notebooks & Code**\\n\\n\'\n'
        '                     f\'{nb_desc}\\n\\n\')\n'
        '        if lab_nb_chk:\n'
        '            nb_gh = f"{GITHUB_RAW_BASE}/notebooks/labs/lab_day{dz}.ipynb"\n'
        '            lines.append(f\'[:material-notebook: Lab Notebook]({nb_gh}){{ target=_blank }}\\n\')\n'
        '        if lec_nb_chk:\n'
        '            nb_gh = f"{GITHUB_RAW_BASE}/notebooks/lectures/lecture_day{dz}.ipynb"\n'
        '            lines.append(f\'[:material-notebook-outline: Lecture Notebook]({nb_gh}){{ target=_blank }}\\n\')\n'
        '        lines.append(f\'</div>\\n\')'
    )

    if old_card in content:
        content = content.replace(old_card, new_card)
        patches.append("Replaced 'Code & Notebooks' card with 'Notebooks & Code' card")
    else:
        patches.append("WARNING: Could not find Code & Notebooks card to replace")

    # ── Fix card count to account for notebooks ─────────────────────
    # Compute has_notebooks BEFORE n_cards, then use it
    old_count = "    n_cards = 3 + (1 if has_code else 0)"
    new_count = (
        '    lab_nb_chk = (REPO / "notebooks" / "labs" / f"lab_day{dz}.ipynb").exists()\n'
        '    lec_nb_chk = (REPO / "notebooks" / "lectures" / f"lecture_day{dz}.ipynb").exists()\n'
        '    has_notebooks = lab_nb_chk or lec_nb_chk\n'
        '    n_cards = 2 + (1 if quiz_exists else 0) + (1 if has_notebooks else 0)'
    )
    if old_count in content:
        content = content.replace(old_count, new_count)
        patches.append("Fixed nav card count with has_notebooks pre-computation")

    # ── Add lecture examples section ───────────────────────────────
    # Insert after the videos section (before the return statement)
    return_marker = '    return "\\n".join(lines)\n\n\n# ─── Lab code asset discovery'
    lecture_code_section = '''
    # Lecture examples section
    lec_code_dir = REPO / "lectures" / dir_name / "code"
    if lec_code_dir.exists():
        code_files = sorted(lec_code_dir.glob("*.*"))
        code_files = [f for f in code_files if f.suffix in {".v", ".sv", ".mem", ".hex"}]
        if code_files:
            lines.append("## :material-code-braces: Lecture Code Examples\\n")
            lines.append("Code shown during the pre-class video. Use these as reference ")
            lines.append("when working on the lab exercises.\\n")
            for f in code_files:
                rel = f.relative_to(REPO)
                gh = f"{GITHUB_RAW_BASE}/{rel}"
                icon = ":material-chip:" if f.suffix in {".v", ".sv"} else ":material-file:"
                # Derive a human-readable label
                label = f.stem.replace(f"day{dz}_", "").replace("_", " ").title()
                lines.append(f"- {icon} **{label}** — [`{f.name}`]({gh}){{ target=_blank }}")
            lines.append("")

'''

    if "Lecture Code Examples" not in content:
        if return_marker in content:
            content = content.replace(return_marker, lecture_code_section + return_marker)
            patches.append("Added 'Lecture Code Examples' section to day index")
        else:
            patches.append("WARNING: Could not find return marker for lecture code injection")
    else:
        patches.append("Lecture code section already exists (skipped)")

    return content, patches


def patch_lab_banner(content):
    """Add direct .ipynb download link to lab page banner."""

    # Match the exact lines in generate_lab_page
    old_marker = "f'    [:material-notebook: Open Lab Notebook]({nb_jup})'"
    new_replacement = "f'    [:material-notebook: Open in JupyterLab]({nb_jup})'"

    old_gh_line = "f'    [:material-github: Notebook on GitHub]({nb_gh})'"
    new_gh_lines = (
        "f'    [:material-download: Download .ipynb](../../notebooks/labs/lab_day{dz}.ipynb)'\n"
        "                f'{{ .md-button target=_blank }}\\n'\n"
        "                f'    [:material-github: View on GitHub]({nb_gh})'"
    )

    if old_marker in content and old_gh_line in content:
        content = content.replace(old_marker, new_replacement)
        content = content.replace(old_gh_line, new_gh_lines)
        return content, "Updated lab banner with 3-link notebook row (JupyterLab / Download / GitHub)"
    else:
        return content, "WARNING: Could not find lab notebook block to patch"


def patch_prep_mkdocs(dry_run):
    """Apply all patches to prep_mkdocs.py."""
    content = SCRIPT.read_text(encoding="utf-8")
    all_patches = []

    # Patch 1: post_build
    content, msg = patch_post_build(content)
    all_patches.append(msg)

    # Patch 2: generate_day_page (card + lecture code)
    content, patches = patch_generate_day_page(content)
    all_patches.extend(patches)

    # Patch 3: generate_lab_page banner
    content, msg = patch_lab_banner(content)
    all_patches.append(msg)

    if not dry_run:
        SCRIPT.write_text(content, encoding="utf-8")

    return all_patches


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    dry_run = not args.apply

    label = "PREVIEW (dry run)" if dry_run else "Applying changes"
    print(f"╔══════════════════════════════════════════╗")
    print(f"║  Transform 5: {label:<27s}║")
    print(f"╚══════════════════════════════════════════╝")
    print()

    # ── Step 1: Patch pages.yml ────────────────────────────────────
    print("Step 1: Patch .github/workflows/pages.yml")
    for p in patch_pages_yml(dry_run):
        print(f"  {p}")
    print()

    # ── Step 2: Patch prep_mkdocs.py ───────────────────────────────
    print("Step 2: Patch scripts/prep_mkdocs.py")
    for p in patch_prep_mkdocs(dry_run):
        print(f"  {p}")
    print()

    if dry_run:
        print("This was a dry run. To apply:")
        print("  python3 transforms/t5_surface_notebooks.py --apply")
        print()
        print("After applying, test with:")
        print("  python3 scripts/prep_mkdocs.py")
        print("  head -20 docs_src/days/day06/index.md    # Notebooks card")
        print("  grep 'Lecture Code' docs_src/days/day06/index.md")
        print("  grep 'Download .ipynb' docs_src/days/day06/lab.md")
    else:
        print("=== Transform 5 Complete ===")
        print()
        print("Verify with:")
        print("  python3 scripts/prep_mkdocs.py")
        print("  grep 'Notebooks' docs_src/days/day06/index.md")
        print("  grep 'Lecture Code' docs_src/days/day06/index.md")
        print("  grep 'Download .ipynb' docs_src/days/day06/lab.md")
        print()
        print("Then commit:")
        print("  git add -A")
        print("  git commit -m 'feat: surface notebooks + lecture code in day pages'")


if __name__ == "__main__":
    main()
