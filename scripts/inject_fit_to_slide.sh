#!/usr/bin/env bash
# =============================================================================
# inject_fit_to_slide.sh
# Accelerated HDL for Digital System Design — inject fit-to-slide.js into
# every reveal.js slide deck under lectures/week*/d*.html.
#
# Adds one <script> tag pointing to ../../theme/fit-to-slide.js, inserted
# immediately after the reveal.js notes plugin <script> tag (a common anchor
# present in every deck, independent of init-form variant).
#
# Usage:
#   chmod +x scripts/inject_fit_to_slide.sh
#   ./scripts/inject_fit_to_slide.sh           # DRY RUN (default)
#   ./scripts/inject_fit_to_slide.sh --apply   # APPLY
#
# Safe to re-run (idempotent — skips files that already have the injection).
# Run from the repository root.
# =============================================================================

set -euo pipefail

DRY_RUN=true
if [[ "${1:-}" == "--apply" ]]; then
    DRY_RUN=false
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  APPLY MODE — changes will be written to disk           ║"
    echo "╚══════════════════════════════════════════════════════════╝"
else
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  DRY RUN — no files will be changed                     ║"
    echo "║  Re-run with --apply to make changes                    ║"
    echo "╚══════════════════════════════════════════════════════════╝"
fi
echo ""

ANCHOR='<script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/plugin/notes/notes.min.js"></script>'
INJECT='<script src="../../theme/fit-to-slide.js"></script>'
MARKER='theme/fit-to-slide.js'

FIXES=0
SKIPS_ANCHOR=0
SKIPS_ALREADY=0

shopt -s nullglob
for file in lectures/week*/d*.html; do
    if ! grep -qF -- "$ANCHOR" "$file"; then
        echo "  SKIP (no anchor)     : $file"
        SKIPS_ANCHOR=$((SKIPS_ANCHOR + 1))
        continue
    fi
    if grep -qF -- "$MARKER" "$file"; then
        echo "  SKIP (already injected): $file"
        SKIPS_ALREADY=$((SKIPS_ALREADY + 1))
        continue
    fi
    if $DRY_RUN; then
        echo "  WOULD INJECT         : $file"
    else
        # Insert $INJECT on a new line after every occurrence of $ANCHOR.
        # perl -i with literal match (quotemeta) — no regex metachar surprises.
        perl -i -spe 'BEGIN { $q = quotemeta($a); } s/($q)/$1\n$inj/;' \
            -- -a="$ANCHOR" -inj="$INJECT" "$file"
        echo "  INJECTED             : $file"
    fi
    FIXES=$((FIXES + 1))
done

echo ""
echo "Summary:"
echo "  injected / would inject : $FIXES"
echo "  skipped (anchor missing): $SKIPS_ANCHOR"
echo "  skipped (already done)  : $SKIPS_ALREADY"
if $DRY_RUN && [[ $FIXES -gt 0 ]]; then
    echo ""
    echo "Re-run with --apply to write the changes."
fi
