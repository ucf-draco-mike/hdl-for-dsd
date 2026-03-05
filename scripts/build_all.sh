#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# build_all.sh — One-shot build for the HDL for DSD course
# ═══════════════════════════════════════════════════════════════════
#
# Runs every generation step in the correct order:
#   1. Convert lab markdown → Jupyter notebooks (jupytext)
#   2. Prep MkDocs source tree (docs_src/) with code pages & zips
#   3. Build the static site (build_site.py standalone portal)
#   4. Build the MkDocs site (_site/)
#
# Usage:
#   ./scripts/build_all.sh              # everything
#   ./scripts/build_all.sh --quick      # skip standalone site (build_site.py)
#   ./scripts/build_all.sh --serve      # build then serve MkDocs locally
#   ./scripts/build_all.sh --notebooks  # only regenerate notebooks
#
# Requirements:
#   nix develop .#full   (or have jupytext, mkdocs, markdown installed)
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail
cd "$(dirname "$0")/.."
REPO=$(pwd)

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

step() { echo -e "\n${CYAN}${BOLD}▶ $1${NC}"; }
ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
fail() { echo -e "${RED}  ✗ $1${NC}"; exit 1; }

MODE="full"
SERVE=false
for arg in "$@"; do
    case "$arg" in
        --quick)     MODE="quick" ;;
        --serve)     SERVE=true ;;
        --notebooks) MODE="notebooks" ;;
        --help|-h)
            echo "Usage: $0 [--quick|--serve|--notebooks|--help]"
            echo ""
            echo "  (default)    Run all build steps"
            echo "  --quick      Skip standalone site (build_site.py)"
            echo "  --serve      Build then serve MkDocs at localhost:8000"
            echo "  --notebooks  Only regenerate .ipynb files from lab markdown"
            exit 0
            ;;
    esac
done

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║  HDL for DSD — Full Build                       ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Preflight checks ──
step "Checking tools"

check_cmd() {
    if command -v "$1" &>/dev/null; then
        ok "$1 found"
    else
        fail "$1 not found — run 'nix develop .#full' first"
    fi
}

check_cmd python3
check_cmd jupytext

if [ "$MODE" != "notebooks" ]; then
    check_cmd mkdocs
fi

# ═══════════════════════════════════════════════════════════════════
# Phase 1: Convert lab markdown → Jupyter notebooks
# ═══════════════════════════════════════════════════════════════════
step "Phase 1: Generating Jupyter notebooks from lab markdown"

NB_COUNT=0
NB_SKIP=0

for readme in labs/week*_day*/README.md; do
    lab_dir=$(dirname "$readme")
    day_dir=$(basename "$lab_dir")
    nb_out="${lab_dir}/${day_dir}_lab.ipynb"

    # Only regenerate if markdown is newer than notebook
    if [ -f "$nb_out" ] && [ "$nb_out" -nt "$readme" ]; then
        NB_SKIP=$((NB_SKIP + 1))
        continue
    fi

    jupytext --to notebook --output "$nb_out" "$readme" 2>/dev/null
    NB_COUNT=$((NB_COUNT + 1))
done

# Also convert exercise-level READMEs that have substantive content
for readme in labs/**/ex*/starter/README.md; do
    [ -f "$readme" ] || continue
    ex_dir=$(dirname "$readme")
    ex_name=$(basename "$(dirname "$ex_dir")")
    nb_out="${ex_dir}/${ex_name}_guide.ipynb"

    if [ -f "$nb_out" ] && [ "$nb_out" -nt "$readme" ]; then
        NB_SKIP=$((NB_SKIP + 1))
        continue
    fi

    jupytext --to notebook --output "$nb_out" "$readme" 2>/dev/null
    NB_COUNT=$((NB_COUNT + 1))
done

ok "Generated ${NB_COUNT} notebooks (${NB_SKIP} up-to-date, skipped)"

if [ "$MODE" = "notebooks" ]; then
    echo ""
    echo -e "${GREEN}${BOLD}  Done. Notebooks regenerated.${NC}"
    exit 0
fi

# ═══════════════════════════════════════════════════════════════════
# Phase 2: Prep MkDocs source (docs_src/, downloads/)
# ═══════════════════════════════════════════════════════════════════
step "Phase 2: Preparing MkDocs source tree"
python3 scripts/prep_mkdocs.py
ok "docs_src/ ready"

# ═══════════════════════════════════════════════════════════════════
# Phase 3: Standalone site (build_site.py) — skipped in --quick
# ═══════════════════════════════════════════════════════════════════
if [ "$MODE" = "full" ]; then
    step "Phase 3: Building standalone site (site/)"
    python3 scripts/build_site.py
    ok "site/ ready"
else
    step "Phase 3: Standalone site — skipped (--quick)"
fi

# ═══════════════════════════════════════════════════════════════════
# Phase 4: Build MkDocs site (_site/)
# ═══════════════════════════════════════════════════════════════════
step "Phase 4: Building MkDocs site"
mkdocs build --site-dir _site 2>&1 | tail -5

# Post-build: copy slides and downloads into _site/
cp -r lectures _site/lectures 2>/dev/null && ok "Copied lectures → _site/lectures/"
cp -r docs_src/downloads _site/downloads 2>/dev/null && ok "Copied downloads → _site/downloads/"

ok "_site/ ready"

# ═══════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
NB_TOTAL=$(find labs -name "*.ipynb" 2>/dev/null | wc -l)
ZIPS=$(find docs_src/downloads -name "*.zip" 2>/dev/null | wc -l)
HTML=$(find _site -name "*.html" 2>/dev/null | wc -l)
echo -e "  ${GREEN}Notebooks:${NC}  ${NB_TOTAL} .ipynb files in labs/"
echo -e "  ${GREEN}Downloads:${NC}  ${ZIPS} zip files"
echo -e "  ${GREEN}Site:${NC}       ${HTML} HTML pages in _site/"
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""

if $SERVE; then
    step "Serving MkDocs at http://127.0.0.1:8000"
    echo "  Press Ctrl+C to stop."
    mkdocs serve
fi
