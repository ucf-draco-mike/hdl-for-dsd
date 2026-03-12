#!/usr/bin/env python3
"""merge_code_into_labs.py — Patch prep_mkdocs.py to embed file links in lab pages.

Problem:
    Each day has a separate code.md page with per-exercise file links
    (GitHub, JupyterLab) that duplicates the download buttons already
    in the lab guide. Students have to click away from the lab context
    to find individual file links.

Fix:
    1. Expand per-exercise code admonitions in lab.md to include all
       individual file links (not just the first representative file).
    2. Replace the "Full file listing: Code & Notebooks Reference" link
       with the notebook links directly in the lab banner.
    3. Simplify the day index "Notebooks & Code" card to just "Notebooks"
       (pointing to lab/lecture notebooks only).
    4. Keep code.md as a generated page (some users may still want it)
       but remove it from the prominent nav card.

This script describes the three targeted edits to prep_mkdocs.py.
Apply with a text editor or sed — the edits are small and surgical.

Usage:
    python3 scripts/merge_code_into_labs.py    # prints the diff description
"""

EDITS = """
═══════════════════════════════════════════════════════════════════
EDIT 1: Expand per-exercise file links in generate_lab_page()
═══════════════════════════════════════════════════════════════════

In scripts/prep_mkdocs.py, function generate_lab_page(), around line 502-508,
the current code only links the FIRST starter file per exercise:

  CURRENT (lines ~502-508):
  │  for sf in ex.get("starter_files", []):
  │      gh = f"{GITHUB_RAW_BASE}/{sf.relative_to(REPO)}"
  │      parts.append(
  │          f'[:material-github: `{sf.name}`]({gh}){{ target=_blank }}'
  │      )
  │      break  # just link first file as representative

  REPLACE WITH:
  │  for sf in ex.get("starter_files", []):
  │      gh = f"{GITHUB_RAW_BASE}/{sf.relative_to(REPO)}"
  │      parts.append(
  │          f'[:material-github: `{sf.name}`]({gh}){{ target=_blank }}'
  │      )
  │      # Link Jupyter for editable files
  │      if sf.suffix.lower() in JUPYTER_EXTENSIONS or sf.name == "Makefile":
  │          jup = f"{JUPYTER_LAB_BASE}/{sf.relative_to(REPO)}"
  │          parts.append(
  │              f'[:material-notebook: Jupyter]({jup}){{ target=_blank }}'
  │          )

═══════════════════════════════════════════════════════════════════
EDIT 2: Remove "Code & Notebooks Reference" link from lab banner
═══════════════════════════════════════════════════════════════════

In generate_lab_page(), around line 475-478, the banner includes a link to code.md:

  CURRENT (lines ~475-478):
  │  banner_lines.append(
  │      f'    Individual exercise downloads are linked below each exercise.\\n'
  │      f'    Full file listing: [Code & Notebooks Reference](code.md)\\n'
  │  )

  REPLACE WITH:
  │  banner_lines.append(
  │      f'    Individual exercise downloads and file links are below each exercise.\\n'
  │  )

═══════════════════════════════════════════════════════════════════
EDIT 3: Simplify day index "Notebooks & Code" card
═══════════════════════════════════════════════════════════════════

In generate_day_page(), the 4th nav card currently says "Notebooks & Code"
and links to code.md. Change it to "Notebooks" and remove the code.md link.

Find (around lines 110-114 in the card builder):
  │  **Notebooks & Code**
  │
  │  Lab notebook · lecture notebook · [code ref](code.md)

Replace with:
  │  **Notebooks**
  │
  │  Lab notebook · lecture notebook

The rest of the card (JupyterLab links to .ipynb files) stays the same.

═══════════════════════════════════════════════════════════════════
SUMMARY
═══════════════════════════════════════════════════════════════════

After these 3 edits:
  • Lab pages show all file links per exercise (GitHub + Jupyter)
  • The code.md link is removed from prominent navigation
  • code.md still generates (for anyone who wants a full listing)
  • Students stay in the lab context when they need files
"""

if __name__ == "__main__":
    print(EDITS)
