#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# build_all.sh — One-shot build for the HDL for DSD course
# ═══════════════════════════════════════════════════════════════════
#
# Runs every generation step in the correct order:
#   1. Prep MkDocs source tree (docs_src/) with code pages & zips
#   2. Build the static site (build_site.py standalone portal)
#   3. Build the MkDocs site (_site/)
#
# Usage:
#   ./scripts/build_all.sh              # everything
#   ./scripts/build_all.sh --quick      # skip standalone site (build_site.py)
#   ./scripts/build_all.sh --serve      # build then serve MkDocs locally
#
# Requirements:
#   nix develop .#full   (or have mkdocs + markdown installed)
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
        --help|-h)
            echo "Usage: $0 [--quick|--serve|--help]"
            echo ""
            echo "  (default)    Run all build steps"
            echo "  --quick      Skip standalone site (build_site.py)"
            echo "  --serve      Build then serve MkDocs at localhost:8000"
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
check_cmd mkdocs

# ═══════════════════════════════════════════════════════════════════
# Phase 1: Prep MkDocs source (docs_src/, downloads/)
# ═══════════════════════════════════════════════════════════════════
step "Phase 1: Preparing MkDocs source tree"
python3 scripts/prep_mkdocs.py
ok "docs_src/ ready"

# ═══════════════════════════════════════════════════════════════════
# Phase 2: Standalone site (build_site.py) — skipped in --quick
# ═══════════════════════════════════════════════════════════════════
if [ "$MODE" = "full" ]; then
    step "Phase 2: Building standalone site (site/)"
    python3 scripts/build_site.py
    ok "site/ ready"
else
    step "Phase 2: Standalone site — skipped (--quick)"
fi

# ═══════════════════════════════════════════════════════════════════
# Phase 3: Build MkDocs site (_site/)
# ═══════════════════════════════════════════════════════════════════
step "Phase 3: Building MkDocs site"
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
ZIPS=$(find docs_src/downloads -name "*.zip" 2>/dev/null | wc -l)
HTML=$(find _site -name "*.html" 2>/dev/null | wc -l)
echo -e "  ${GREEN}Downloads:${NC}  ${ZIPS} zip files"
echo -e "  ${GREEN}Site:${NC}       ${HTML} HTML pages in _site/"
echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""

if $SERVE; then
    step "Serving MkDocs at http://127.0.0.1:8000"
    echo "  Press Ctrl+C to stop."
    mkdocs serve
fi
