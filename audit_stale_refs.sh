#!/usr/bin/env bash
# =============================================================================
# audit_stale_refs.sh
# Accelerated HDL for Digital System Design — stale reference audit
#
# Run AFTER both rename scripts have been applied.
# Scans all tracked text files for references that still use old naming patterns.
# Outputs a prioritized list of files requiring content edits.
#
# Usage:
#   chmod +x audit_stale_refs.sh
#   ./audit_stale_refs.sh              # report to stdout
#   ./audit_stale_refs.sh > refs.txt   # save report
# =============================================================================

set -euo pipefail

HITS=0

report() {
    local label="$1" pattern="$2"
    shift 2
    local dirs=("$@")
    local results
    results=$(grep -rn --include="*.md" --include="*.html" \
                        --include="*.v" --include="*.sv" \
                        --include="*.sh" --include="*.json" \
                        -E "$pattern" "${dirs[@]}" 2>/dev/null || true)
    if [[ -n "$results" ]]; then
        echo ""
        echo "--- $label ---"
        echo "$results"
        HITS=$((HITS + $(echo "$results" | wc -l)))
    fi
}

echo "================================================================="
echo "Stale Reference Audit — run after rename scripts applied"
echo "Timestamp: $(date)"
echo "================================================================="

# 1. Old lecture directory names inside markdown/HTML
report "Old lecture dir slugs (dayNN_topic) in docs/README/lectures" \
    'day[0-9]{2}_[a-z]' docs lectures README.md

# 2. Old lab directory slugs
report "Old lab dir slugs (dayNN_topic) in labs/docs" \
    'day0[0-9]_[a-z]|day1[0-6]_[a-z]' labs docs

# 3. HTML segment files with d##_ prefix in links or titles
report "Old segment filename pattern (d##_s#_) in HTML/markdown" \
    'd[0-9]{2}_s[0-9]_' lectures docs

# 4. Old code file pattern (day##_ex) in Makefiles or markdown
report "Old code file prefix (day##_ex) in any file" \
    'day[0-9]{2}_ex' lectures labs docs

# 5. Old diagram file pattern (d##_) in HTML src attributes or markdown
report "Old diagram prefix (d##_) in img/src references" \
    '"d[0-9]{2}_|'\''d[0-9]{2}_' lectures docs

# 6. Old lab file prefixes (w#d#_) in Makefiles or markdown
report "Old lab file prefix (w#d##_) in any file" \
    'w[0-9]d[0-9]{1,2}_' labs docs lectures

# 7. Old total hours claim (12.2) anywhere
report "Stale video duration claim (12.2 hours)" \
    '12\.2' docs README.md

# 8. Old final project span (Days 14-16)
report "Old final project span (Days 14–16 or Days 14-16)" \
    'Days 14.16|spanning Days 14' docs README.md

# 9. Old DEVELOPMENT_STATUS filenames
report "Old verbose daily plan names in DEVELOPMENT_STATUS" \
    'day0[0-9]_welcome|day0[0-9]_combinational|day0[0-9]_procedural' docs

echo ""
echo "================================================================="
if [[ $HITS -eq 0 ]]; then
    echo "CLEAN — no stale references detected."
else
    echo "TOTAL: $HITS stale reference(s) found across the repository."
    echo "Edit each file listed above to update the references."
fi
echo "================================================================="
