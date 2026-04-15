#!/usr/bin/env bash
# =============================================================================
# inject_fit_to_slide.sh
# Accelerated HDL for Digital System Design — harden the fit-to-window
# feature on every reveal.js slide deck under lectures/week*/d*.html.
#
# Two jobs (both idempotent):
#   1. Inject <script src="../theme/fit-to-slide.js"></script> after the
#      reveal.js notes plugin <script> tag (a common anchor present in
#      every deck, independent of Reveal.initialize form).
#   2. Normalize any broken theme-CSS references from the wrong depth
#      (../../theme/ucf-hdl.css) to the correct depth (../theme/...).
#      Without this, both the theme AND the fit-mode CSS 404 on the
#      deployed site, and the JS has nothing to style.
#
# Path note: lecture decks live at lectures/week*/d*.html, so the theme
# directory is one level up (../theme/), NOT two (../../theme/).
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
INJECT='<script src="../theme/fit-to-slide.js"></script>'
MARKER='theme/fit-to-slide.js'
BAD_CSS='../../theme/ucf-hdl.css'
GOOD_CSS='../theme/ucf-hdl.css'

FIXES=0
SKIPS_ANCHOR=0
SKIPS_ALREADY=0
CSS_FIXES=0

shopt -s nullglob
for file in lectures/week*/d*.html; do
    # 1. CSS path normalization (first, independent of anchor).
    if grep -qF -- "$BAD_CSS" "$file"; then
        if $DRY_RUN; then
            echo "  WOULD FIX CSS PATH   : $file"
        else
            # Literal substitution — no regex metachar surprises.
            perl -i -spe 'BEGIN { $q = quotemeta($b); } s/$q/$g/g;' \
                -- -b="$BAD_CSS" -g="$GOOD_CSS" "$file"
            echo "  FIXED CSS PATH       : $file"
        fi
        CSS_FIXES=$((CSS_FIXES + 1))
    fi

    # 2. fit-to-slide.js injection.
    if ! grep -qF -- "$ANCHOR" "$file"; then
        echo "  SKIP (no anchor)     : $file"
        SKIPS_ANCHOR=$((SKIPS_ANCHOR + 1))
        continue
    fi
    if grep -qF -- "$MARKER" "$file"; then
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
echo "  CSS paths fixed         : $CSS_FIXES"
echo "  injected / would inject : $FIXES"
echo "  skipped (anchor missing): $SKIPS_ANCHOR"
echo "  skipped (already done)  : $SKIPS_ALREADY"
if $DRY_RUN && [[ $FIXES -gt 0 || $CSS_FIXES -gt 0 ]]; then
    echo ""
    echo "Re-run with --apply to write the changes."
fi
