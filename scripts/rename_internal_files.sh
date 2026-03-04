#!/usr/bin/env bash
# =============================================================================
# rename_internal_files.sh
# Accelerated HDL for Digital System Design — internal file standardization
#
# Companion to rename_daily_files.sh (which handles top-level directories).
# This script handles files *inside* lecture and lab directories.
#
# Transformations applied:
#   lectures/weekN/dayNN/
#     d##_s#_topic.html         →  s#_topic.html       (strip day prefix from segments)
#     day##_ex##_name.v         →  ex##_name.v          (strip day prefix from code)
#     d##_name.svg              →  name.svg             (strip day prefix from diagrams)
#     d##_name.mmd              →  name.mmd             (strip day prefix from diagrams)
#     d##_name.json             →  name.json            (wavedrom sources)
#     day##_readme.md           →  README.md
#     d##_readme.md             →  README.md
#     day##_quiz.md             →  quiz.md
#
#   labs/weekN/dayNN/
#     w#d##_Makefile            →  Makefile
#     w#d##_lab_guide.md        →  README.md
#     starter/w#d##_ex*         →  starter/ex*          (strip w#d## from starter files)
#     solutions/w#d##_ex*       →  solutions/ex*        (strip w#d## from solution files)
#
# Notes:
#   - Run AFTER rename_daily_files.sh (directories must be dayNN/ not dayNN_topic/)
#   - Build artifacts in labs/*/build/ are generated and git-ignored; not touched.
#   - HTML <title> tags and internal references are content — not changed by this script.
#     Run fix_internal_refs.sh (provided separately) to update cross-file references.
#
# Usage:
#   chmod +x rename_internal_files.sh
#   ./rename_internal_files.sh           # dry-run
#   ./rename_internal_files.sh --apply   # execute with git mv
# =============================================================================

set -euo pipefail

DRY_RUN=true
[[ "${1:-}" == "--apply" ]] && DRY_RUN=false

RENAMED=0
SKIPPED=0
ERRORS=0

do_mv() {
    local src="$1" dst="$2"
    [[ "$src" == "$dst" ]] && return
    if [[ ! -e "$src" ]]; then
        echo "  [SKIP not found] $src"
        SKIPPED=$((SKIPPED+1))
        return
    fi
    if [[ -e "$dst" ]]; then
        echo "  [CONFLICT]       $dst already exists"
        ERRORS=$((ERRORS+1))
        return
    fi
    if $DRY_RUN; then
        echo "  [dry-run] $src  →  $(basename "$dst")"
    else
        git mv "$src" "$dst"
        echo "  [renamed] $src  →  $(basename "$dst")"
    fi
    RENAMED=$((RENAMED+1))
}

banner() { echo ""; echo "=== $1 ==="; }

# ---------------------------------------------------------------------------
# Helper: strip a leading d##_ or day##_ prefix from a basename
# Returns the stripped name on stdout; empty string if no prefix matched
# ---------------------------------------------------------------------------
strip_day_prefix() {
    local base="$1"
    # Matches d01_ through d16_
    if [[ "$base" =~ ^d[0-9]{2}_(.*) ]]; then
        echo "${BASH_REMATCH[1]}"
    # Matches day01_ through day16_
    elif [[ "$base" =~ ^day[0-9]{2}_(.*) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# Helper: strip a leading w#d##_ or w##d##_ lab prefix (e.g., w1d1_, w2d12_)
# ---------------------------------------------------------------------------
strip_lab_prefix() {
    local base="$1"
    if [[ "$base" =~ ^w[0-9]d[0-9]{1,2}_(.*) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

# ===========================================================================
# SECTION 1: Lecture HTML segment files
#   lectures/weekN/dayNN/d##_s#_topic.html  →  s#_topic.html
# ===========================================================================
banner "Lecture HTML segments (d##_s#_*.html → s#_*.html)"

while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    stripped=$(strip_day_prefix "$base")
    if [[ -n "$stripped" ]]; then
        do_mv "$f" "$dir/$stripped"
    fi
done < <(find lectures -name "d[0-9][0-9]_s[0-9]_*.html" -print0 2>/dev/null)

# ===========================================================================
# SECTION 2: Lecture code files
#   lectures/weekN/dayNN/code/day##_ex##_*.v  →  ex##_*.v
# ===========================================================================
banner "Lecture code files (day##_ex##_*.v → ex##_*.v)"

while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    stripped=$(strip_day_prefix "$base")
    if [[ -n "$stripped" ]]; then
        do_mv "$f" "$dir/$stripped"
    fi
done < <(find lectures -path "*/code/day[0-9][0-9]_*.v" -print0 2>/dev/null)

# ===========================================================================
# SECTION 3: Lecture diagram files
#   lectures/weekN/dayNN/diagrams/d##_*.svg|mmd|json  →  name.svg|mmd|json
# ===========================================================================
banner "Lecture diagram files (d##_*.svg/mmd/json → name.*)"

while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    stripped=$(strip_day_prefix "$base")
    if [[ -n "$stripped" ]]; then
        do_mv "$f" "$dir/$stripped"
    fi
done < <(find lectures -path "*/diagrams/d[0-9][0-9]_*" \
         \( -name "*.svg" -o -name "*.mmd" -o -name "*.json" \) -print0 2>/dev/null)

# ===========================================================================
# SECTION 4: Lecture support documents
#   day##_readme.md / d##_readme.md  →  README.md
#   day##_quiz.md                    →  quiz.md
# ===========================================================================
banner "Lecture support docs (day##_readme.md → README.md, day##_quiz.md → quiz.md)"

# READMEs — two prefix styles
while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    do_mv "$f" "$dir/README.md"
done < <(find lectures \
         \( -name "day[0-9][0-9]_readme.md" -o -name "d[0-9][0-9]_readme.md" \) \
         -print0 2>/dev/null)

# Quizzes
while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    do_mv "$f" "$dir/quiz.md"
done < <(find lectures -name "day[0-9][0-9]_quiz.md" -print0 2>/dev/null)

# ===========================================================================
# SECTION 5: Lab directories with topic slugs
#   labs/weekN/dayNN_topic_slug/  →  labs/weekN/dayNN/
#   (SKIP if dayNN/ already exists — handled by rename_daily_files.sh)
# ===========================================================================
banner "Lab directories — topic slug removal (if not already clean)"

for week in labs/week1 labs/week2 labs/week3 labs/week4; do
    [[ -d "$week" ]] || continue
    for src_dir in "$week"/day[0-9][0-9]_*/; do
        [[ -d "$src_dir" ]] || continue
        base=$(basename "$src_dir")
        # Extract just dayNN prefix
        day_prefix="${base%%_*}"   # e.g., week1_day01
        dst_dir="$week/$day_prefix"
        do_mv "$src_dir" "$dst_dir"
    done
done

# ===========================================================================
# SECTION 6: Lab Makefiles
#   labs/weekN/dayNN/w#d##_Makefile  →  Makefile
# ===========================================================================
banner "Lab Makefiles (w#d##_Makefile → Makefile)"

while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    do_mv "$f" "$dir/Makefile"
done < <(find labs -name "w[0-9]d[0-9]*_Makefile" -print0 2>/dev/null)

# ===========================================================================
# SECTION 7: Lab guides
#   labs/weekN/dayNN/w#d##_lab_guide.md  →  README.md
# ===========================================================================
banner "Lab guides (w#d##_lab_guide.md → README.md)"

while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    do_mv "$f" "$dir/README.md"
done < <(find labs -name "w[0-9]d[0-9]*_lab_guide.md" -print0 2>/dev/null)

# ===========================================================================
# SECTION 8: Lab starter/solution files with w#d##_ prefix
#   labs/.../starter/w#d##_ex*.v  →  ex*.v
#   labs/.../solutions/w#d##_ex*.v  →  ex*.v
# ===========================================================================
banner "Lab starter/solution files (w#d##_ex*.v → ex*.v)"

while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    stripped=$(strip_lab_prefix "$base")
    if [[ -n "$stripped" ]]; then
        do_mv "$f" "$dir/$stripped"
    fi
done < <(find labs \( -path "*/starter/w[0-9]d[0-9]*_*" \
                   -o -path "*/solutions/w[0-9]d[0-9]*_*" \) \
         -type f -print0 2>/dev/null)

# ===========================================================================
# Summary
# ===========================================================================
echo ""
echo "================================================================="
echo "Summary: $RENAMED rename(s) | $SKIPPED skipped | $ERRORS conflict(s)"
if [[ $ERRORS -gt 0 ]]; then
    echo "ACTION REQUIRED: $ERRORS conflict(s) above need manual resolution."
fi
$DRY_RUN \
    && echo "DRY RUN — rerun with --apply to execute." \
    || echo "Done. Review changes with: git diff --cached --name-status"
echo ""
echo "Post-rename checklist:"
echo "  1. Update README.md file-reference tables in each lecture dayNN/"
echo "  2. Check HTML <title> tags still accurately describe the segment (content, not filename)"
echo "  3. Run: grep -r 'd[0-9][0-9]_s[0-9]' lectures/ to catch any remaining old refs"
echo "  4. Run: grep -r 'day[0-9][0-9]_ex' lectures/ to catch old code refs"
echo "  5. Run: grep -r 'w[0-9]d[0-9]' labs/ to catch remaining lab prefix refs in Makefiles"
echo "  6. git commit -m 'refactor: strip day/lab prefixes from internal lecture and lab files'"
echo "================================================================="
