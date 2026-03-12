#!/usr/bin/env python3
"""fix_quiz_rendering.py — Convert quiz <details>/<summary> to MkDocs admonition syntax.

Problem:
    Quiz answers use raw <details><summary>Answer</summary> HTML tags.
    The md_in_html extension requires `markdown="1"` on each tag for markdown
    to render inside HTML blocks.  Without it, bold, lists, and code fences
    render as raw text on the MkDocs Material site.

Fix:
    Replace each <details><summary>Answer</summary> ... </details> block with
    the pymdownx.details admonition syntax:

        ??? success "Answer"
            (indented content)

    This uses the already-enabled pymdownx.details extension and renders
    natively with the Material theme — no extra attributes needed.

Source of truth:
    Quiz files live under lectures/weekW_dayDD/dayDD_quiz.md.
    The docs_src/days/dayDD/quiz.md files are symlinks created by prep_mkdocs.py.
    This script edits the SOURCE files (in lectures/).

Usage:
    python3 scripts/fix_quiz_rendering.py          # dry run
    python3 scripts/fix_quiz_rendering.py --apply   # apply changes
"""

import re
import sys
from pathlib import Path

# Resolve repo root: try script location first, then CWD
_script_parent = Path(__file__).resolve().parent.parent
if (_script_parent / "lectures").is_dir():
    REPO = _script_parent
elif (Path.cwd() / "lectures").is_dir():
    REPO = Path.cwd()
else:
    REPO = _script_parent  # fallback
DRY_RUN = "--apply" not in sys.argv


def convert_details_to_admonition(text: str) -> str:
    """Convert <details><summary>Answer</summary>...</details> to admonition syntax."""

    # Pattern matches <details><summary>Answer</summary> ... </details>
    # Handles optional whitespace, newlines, and varying content
    pattern = re.compile(
        r'<details>\s*<summary>\s*Answer\s*</summary>\s*\n'
        r'(.*?)'
        r'\n</details>',
        re.DOTALL
    )

    def replacer(m: re.Match) -> str:
        body = m.group(1).strip()
        if not body:
            return '??? success "Answer"\n    *(No answer provided)*'

        # Indent every line by 4 spaces for admonition body.
        # Special handling: fenced code blocks need their delimiters
        # and content indented uniformly.
        indented_lines = []
        for line in body.split("\n"):
            if line.strip():
                indented_lines.append(f"    {line}")
            else:
                indented_lines.append("")

        indented = "\n".join(indented_lines)
        return f'??? success "Answer"\n{indented}'

    return pattern.sub(replacer, text)


def main():
    if DRY_RUN:
        print("DRY RUN — pass --apply to write changes\n")

    quiz_files = sorted(REPO.glob("lectures/week*_day*/day*_quiz.md"))

    if not quiz_files:
        print("ERROR: No quiz files found under lectures/")
        sys.exit(1)

    total_conversions = 0

    for qf in quiz_files:
        original = qf.read_text(encoding="utf-8")

        # Count <details> blocks before conversion
        count = len(re.findall(r'<details>', original))
        if count == 0:
            print(f"  SKIP  {qf.relative_to(REPO)} (no <details> blocks)")
            continue

        converted = convert_details_to_admonition(original)

        # Verify no <details> remain
        remaining = len(re.findall(r'<details>', converted))
        if remaining > 0:
            print(f"  WARN  {qf.relative_to(REPO)}: {remaining} unconverted <details> blocks remain")

        if DRY_RUN:
            print(f"  WOULD FIX  {qf.relative_to(REPO)} ({count} answers)")
        else:
            qf.write_text(converted, encoding="utf-8")
            print(f"  FIXED  {qf.relative_to(REPO)} ({count} answers)")

        total_conversions += count

    print(f"\n{'Would convert' if DRY_RUN else 'Converted'} {total_conversions} answer blocks "
          f"across {len(quiz_files)} quiz files.")

    if DRY_RUN:
        print("\nRe-run with --apply to write changes.")


if __name__ == "__main__":
    main()
