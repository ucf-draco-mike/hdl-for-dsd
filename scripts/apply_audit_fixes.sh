#!/usr/bin/env bash
# =============================================================================
# apply_audit_fixes.sh
# Accelerated HDL for Digital System Design — repository audit fix script
#
# Addresses all 21 findings from the 2026-03-04 audit report.
#
# Usage:
#   chmod +x scripts/apply_audit_fixes.sh
#   ./scripts/apply_audit_fixes.sh              # DRY RUN (default)
#   ./scripts/apply_audit_fixes.sh --apply      # APPLY changes
#
# Safe to run multiple times (idempotent).
# Run from the repository root.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
GITHUB_ORG="ucf-draco-mike"
GITHUB_REPO="hdl-for-dsd"
CLONE_URL="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}.git"

# ---------------------------------------------------------------------------
# Mode
# ---------------------------------------------------------------------------
DRY_RUN=true
if [[ "${1:-}" == "--apply" ]]; then
    DRY_RUN=false
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  APPLY MODE — changes will be written to disk          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
else
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  DRY RUN — no files will be changed                    ║"
    echo "║  Re-run with --apply to make changes                   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
fi
echo ""

FIXES=0
SKIPS=0
MANUAL=0

inc_fixes()  { FIXES=$((FIXES + 1)); }
inc_skips()  { SKIPS=$((SKIPS + 1)); }
inc_manual() { MANUAL=$((MANUAL + 1)); }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
fix_header() {
    local num="$1" severity="$2" desc="$3"
    echo "────────────────────────────────────────────────────────────"
    printf "  #%-2s [%s] %s\n" "$num" "$severity" "$desc"
    echo "────────────────────────────────────────────────────────────"
}

# Replace a literal string in a file.
# Uses perl -s for safe literal matching — no regex or delimiter issues.
do_sed() {
    local file="$1" pattern="$2" replacement="$3"
    if [[ ! -f "$file" ]]; then
        echo "  SKIP: file $file not found"
        inc_skips; return 0
    fi
    if ! grep -qF -- "$pattern" "$file" 2>/dev/null; then
        echo "  SKIP: pattern not found in $file (already fixed?)"
        inc_skips; return 0
    fi
    if $DRY_RUN; then
        echo "  WOULD: sed in $file"
        echo "    - «${pattern:0:90}»"
        echo "    + «${replacement:0:90}»"
    else
        perl -i -spe '
            BEGIN { $re = quotemeta($pat); }
            s/$re/$rep/g;
        ' -- -pat="$pattern" -rep="$replacement" "$file"
        echo "  FIXED: $file"
    fi
    inc_fixes
}

do_rename() {
    local src="$1" dst="$2"
    if [[ -e "$dst" ]]; then
        echo "  SKIP: $dst already exists"
        inc_skips; return 0
    fi
    if [[ ! -e "$src" ]]; then
        echo "  SKIP: $src not found"
        inc_skips; return 0
    fi
    if $DRY_RUN; then
        echo "  WOULD: mv $src -> $dst"
    else
        mv "$src" "$dst"
        echo "  RENAMED: $src -> $dst"
    fi
    inc_fixes
}

do_delete() {
    local target="$1"
    if [[ ! -e "$target" ]]; then
        echo "  SKIP: $target not found"
        inc_skips; return 0
    fi
    if $DRY_RUN; then
        echo "  WOULD: rm -rf $target"
    else
        rm -rf "$target"
        echo "  DELETED: $target"
    fi
    inc_fixes
}

do_write_new() {
    local file="$1"
    shift
    # remaining args joined as content
    local content="$*"
    if [[ -e "$file" ]]; then
        echo "  SKIP: $file already exists"
        inc_skips; return 0
    fi
    if $DRY_RUN; then
        echo "  WOULD: create $file ($(echo "$content" | wc -l) lines)"
    else
        printf '%s\n' "$content" > "$file"
        echo "  CREATED: $file"
    fi
    inc_fixes
}

do_rewrite_if() {
    local file="$1" marker="$2"
    shift 2
    local content="$*"
    if [[ ! -f "$file" ]]; then
        echo "  SKIP: $file not found"
        inc_skips; return 0
    fi
    if ! grep -qF -- "$marker" "$file" 2>/dev/null; then
        echo "  SKIP: marker not found in $file (already fixed?)"
        inc_skips; return 0
    fi
    if $DRY_RUN; then
        echo "  WOULD: rewrite $file"
    else
        printf '%s\n' "$content" > "$file"
        echo "  REWROTE: $file"
    fi
    inc_fixes
}

flag_manual() {
    echo "  ⚠ MANUAL: $1"
    inc_manual
}

# ═══════════════════════════════════════════════════════════════════
# CRITICAL FIXES
# ═══════════════════════════════════════════════════════════════════

fix_header 1 "CRITICAL" "Clone URL is a placeholder"
do_sed README.md \
    'git clone https://github.com/<org>/hdl-course.git' \
    "git clone ${CLONE_URL}"
do_sed README.md \
    'cd hdl-course && nix develop' \
    "cd ${GITHUB_REPO} && nix develop"
do_sed README.md \
    'cd hdl-course' \
    "cd ${GITHUB_REPO}"
echo ""

# ---------------------------------------------------------------------------
fix_header 2 "CRITICAL" "Directory paths in README don't match actual layout"
do_sed README.md \
    'week1/day01/ through week1_day04/' \
    'week1_day01/ through week1_day04/'
do_sed README.md \
    'week2/day05/ through week2_day08/' \
    'week2_day05/ through week2_day08/'
do_sed README.md \
    'week3/day09/ through week3_day12/' \
    'week3_day09/ through week3_day12/'
do_sed README.md \
    'week4/day13/ through week4_day16/' \
    'week4_day13/ through week4_day16/'
do_sed README.md \
    'cd labs/week1/day01' \
    'cd labs/week1_day01'
do_sed README.md \
    'week1/ through week4/   ← slide decks (reveal.js HTML)' \
    'week1_day01/ … week4_day16/ ← slide decks (reveal.js HTML)'
echo ""

# ---------------------------------------------------------------------------
fix_header 3 "CRITICAL" "Day 10 — Lecture/lab vs. doc plan content mismatch"
flag_manual "Day 10 doc plan (docs/day10.md) describes 'Numerical Architectures & Design Trade-offs'"
flag_manual "  but lectures (d10_s1..s4) and labs (ex1..ex4) cover Timing/PLL/CDC."
flag_manual "  OPTIONS:"
flag_manual "    A) Update docs/day10.md title+SLOs to match existing timing/PLL/CDC content"
flag_manual "    B) Create new lecture slides + labs for numerical architectures"
flag_manual "    C) Split into two half-days (timing + numerical)"
flag_manual "  This requires an instructional design decision — cannot be auto-fixed."
echo ""

# ---------------------------------------------------------------------------
fix_header 4 "CRITICAL" "shared/scripts/Makefile.template does not exist"
do_sed README.md \
    'scripts/Makefile.template ← build automation template' \
    '.gtkwaverc              ← GTKWave display defaults'
echo ""

# ---------------------------------------------------------------------------
fix_header 5 "CRITICAL" "Week 1 Makefiles need renaming to standard 'Makefile'"
do_rename labs/week1_day01/w1d1_Makefile  labs/week1_day01/Makefile
do_rename labs/week1_day02/w1d2_Makefile  labs/week1_day02/Makefile
do_rename labs/week1_day03/w1d3_Makefile  labs/week1_day03/Makefile
do_rename labs/week1_day04/w1d4_Makefile  labs/week1_day04/Makefile
echo ""

# ---------------------------------------------------------------------------
fix_header 6 "CRITICAL" "No .gitignore — .DS_Store files committed"
read -r -d '' GITIGNORE_CONTENT << 'GEOF' || true
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Build artifacts (iCE40 flow)
*.vvp
*.vcd
*.json
*.asc
*.bin
*.blif
*.log

# Editor / IDE
*.swp
*.swo
*~
.vscode/
.idea/

# Nix
result
.direnv/

# Python
__pycache__/
*.pyc
GEOF
do_write_new .gitignore "$GITIGNORE_CONTENT"

if $DRY_RUN; then
    count=$(find . -name '.DS_Store' | wc -l)
    echo "  WOULD: remove ${count} .DS_Store files"
else
    find . -name '.DS_Store' -delete
    echo "  REMOVED: all .DS_Store files"
fi
inc_fixes
echo ""


# ═══════════════════════════════════════════════════════════════════
# HIGH SEVERITY FIXES
# ═══════════════════════════════════════════════════════════════════

fix_header 7 "HIGH" "Root README weekly arc is pre-v2.1"
do_sed README.md \
    '| **2** | Sequential Design & Verification | Verified module library |' \
    '| **2** | Sequential Design, Verification & AI-Assisted Testing | Verified module library + first AI-generated TB |'
do_sed README.md \
    '| **3** | Interfaces, Memory & Communication | "HELLO" on the PC terminal |' \
    '| **3** | Memory, Communication & Numerical Architectures | "HELLO" on the PC terminal + numerical module on FPGA |'
do_sed README.md \
    '| **4** | SystemVerilog Primer & Final Project | Complete demonstrated system |' \
    '| **4** | Advanced Design, Verification & Final Project | Complete demonstrated system with PPA report |'
do_sed README.md  'hdl-course/' 'hdl-for-dsd/'
do_sed docs/README.md  'hdl-course/' 'hdl-for-dsd/'
echo ""

# ---------------------------------------------------------------------------
fix_header 8 "HIGH" "course_dev_status.md — all filenames are stale"

read -r -d '' DEVSTATUS << 'DSEOF' || true
# Development Status

Last updated: 2026-03-04

## Content Inventory

### Core Documentation
| File | Status | Notes |
|---|---|---|
| `README.md` | ✅ Complete | Course overview, structure, quick start |
| `docs/course_curriculum.md` | ✅ Complete | 16-session map, video guide, grading |
| `docs/course_syllabus.md` | ✅ Complete | Student-facing syllabus |
| `docs/course_setup_guide.md` | ✅ Complete | Multi-platform install (Linux/macOS/WSL2) |
| `docs/course_video_scaffold.md` | ✅ Complete | 56-segment production guide |
| `docs/course_dev_status.md` | ✅ Complete | This file |

### Daily Plans (All 16 Complete)
| Day | File | Status |
|---|---|---|
| 1 | `docs/day01.md` | ✅ Full |
| 2 | `docs/day02.md` | ✅ Full |
| 3 | `docs/day03.md` | ✅ Full |
| 4 | `docs/day04.md` | ✅ Full |
| 5 | `docs/day05.md` | ✅ Full |
| 6 | `docs/day06.md` | ✅ Full |
| 7 | `docs/day07.md` | ✅ Full |
| 8 | `docs/day08.md` | ✅ Full |
| 9 | `docs/day09.md` | ✅ Full |
| 10 | `docs/day10.md` | ✅ Full |
| 11 | `docs/day11.md` | ✅ Full |
| 12 | `docs/day12.md` | ✅ Full |
| 13 | `docs/day13.md` | ✅ Full |
| 14 | `docs/day14.md` | ✅ Full |
| 15 | `docs/day15.md` | ✅ Full |
| 16 | `docs/day16.md` | ✅ Full |

**Note:** Filenames assume Fix #12 (normalize daily plan names) has been applied.

### Lecture Slides (Days 1-14: reveal.js HTML)
| Day | Dir | Segments | Readme | Quiz |
|---|---|---|---|---|
| 1 | `lectures/week1_day01/` | 4 slides | ✅ | ✅ |
| 2 | `lectures/week1_day02/` | 4 slides | ✅ | ✅ |
| 3 | `lectures/week1_day03/` | 4 slides | ✅ | ✅ |
| 4 | `lectures/week1_day04/` | 4 slides | ✅ | ✅ |
| 5 | `lectures/week2_day05/` | 4 slides | ✅ | ✅ |
| 6 | `lectures/week2_day06/` | 4 slides | ✅ | ✅ |
| 7 | `lectures/week2_day07/` | 4 slides | ✅ | ✅ |
| 8 | `lectures/week2_day08/` | 4 slides | ✅ | ✅ |
| 9 | `lectures/week3_day09/` | 4 slides | ✅ | ✅ |
| 10 | `lectures/week3_day10/` | 4 slides | ✅ | ✅ |
| 11 | `lectures/week3_day11/` | 4 slides | ✅ | ✅ |
| 12 | `lectures/week3_day12/` | 4 slides | ✅ | ✅ |
| 13 | `lectures/week4_day13/` | 4 slides | ✅ | ✅ |
| 14 | `lectures/week4_day14/` | 4 slides | ✅ | ✅ |
| 15 | `lectures/week4_day15/` | briefing only | ✅ | - |
| 16 | `lectures/week4_day16/` | retro only | ✅ | - |

### Lab Scaffolding
| Week | Days | Status |
|---|---|---|
| Week 1 | Days 1-4 | ✅ Starter + solution Verilog, Makefiles, lab guides |
| Week 2 | Days 5-8 | ✅ Starter + solution Verilog, Makefiles, READMEs |
| Week 3 | Days 9-12 | ✅ Starter + solution Verilog, per-exercise Makefiles, READMEs |
| Week 4 | Days 13-16 | ✅ SV exercises, project templates, demo materials |

### Shared Resources
| Resource | Status |
|---|---|
| `shared/pcf/go_board.pcf` | ✅ Complete pin constraint file |
| `shared/lib/` | ✅ 5 design modules + 5 testbenches |
| `shared/.gtkwaverc` | ✅ GTKWave display defaults |

### Projects
| Resource | Status |
|---|---|
| `projects/README.md` | ✅ Project options, rubric, requirements |

### Remaining Work
| Item | Priority | Notes |
|---|---|---|
| Day 10 content alignment | 🔴 High | Doc plan vs. lecture/lab topic mismatch (see audit) |
| Video recording | 🔶 Medium | 56 segments scripted, not yet recorded |
| Lab structure normalization | 🔶 Medium | Three different org patterns across weeks |
DSEOF

do_rewrite_if docs/course_dev_status.md \
    'day05_counters_shift_registers_debouncing.md' \
    "$DEVSTATUS"
echo ""

# ---------------------------------------------------------------------------
fix_header 9 "HIGH" "docs/README.md repo tree uses stale filenames"
if grep -qF 'curriculum_v2_1.md' docs/README.md 2>/dev/null; then
    if $DRY_RUN; then
        echo "  WOULD: replace entire repo structure tree in docs/README.md"
        inc_fixes
    else
        # Write a Python helper to do the multiline replacement safely
        python3 << 'PYEOF'
import re

with open("docs/README.md", "r") as f:
    content = f.read()

new_tree = """## Repository Structure

```
hdl-for-dsd/
├── README.md                    ← top-level overview & quick start
├── flake.nix                    ← Nix dev environment (all tools, all platforms)
├── .envrc                       ← optional direnv auto-activation
├── docs/
│   ├── README.md                ← you are here
│   ├── course_curriculum.md     ← full 16-day curriculum & session map
│   ├── course_syllabus.md       ← student-facing syllabus
│   ├── course_setup_guide.md    ← toolchain installation instructions
│   ├── course_video_scaffold.md ← lecture production guide
│   ├── course_dev_status.md     ← development status tracker
│   └── day01.md … day16.md      ← daily session plans (instructor guides)
│
├── lectures/                    ← pre-class video lecture materials
│   ├── theme/ucf-hdl.css        ← UCF-branded reveal.js theme
│   └── week1_day01/ … week4_day16/
│       ├── d##_s#_topic.html    ← reveal.js slide decks
│       ├── day##_quiz.md        ← pre-class quiz
│       ├── day##_readme.md      ← segment guide
│       ├── code/                ← live-code examples
│       └── diagrams/            ← SVGs & Mermaid sources
│
├── labs/                        ← in-class lab materials & starter code
│   └── week1_day01/ … week4_day16/
│       ├── README.md            ← lab guide
│       ├── Makefile             ← build targets (sim, synth, prog)
│       ├── go_board.pcf         ← pin constraints
│       ├── starter/             ← student starting point
│       └── solutions/           ← reference solutions
│
├── projects/                    ← final project specs & rubric
│
├── shared/
│   ├── pcf/go_board.pcf         ← canonical pin constraint file
│   ├── lib/                     ← reusable module library
│   └── .gtkwaverc               ← GTKWave display defaults
│
├── scripts/                     ← maintenance & migration utilities
│
└── assets/img/                  ← logos, board photos, etc.
```"""

content = re.sub(
    r"## Repository Structure\n\n```\n.*?```",
    new_tree,
    content,
    count=1,
    flags=re.DOTALL,
)

with open("docs/README.md", "w") as f:
    f.write(content)
PYEOF
        echo "  FIXED: docs/README.md repo tree"
        inc_fixes
    fi
else
    echo "  SKIP: stale tree marker not found (already fixed?)"
    inc_skips
fi
echo ""

# ---------------------------------------------------------------------------
fix_header 10 "HIGH" "Lecture file naming refs in docs/README"
# These were inside the old tree — may already be gone after #9
do_sed docs/README.md 'seg1_hdl_not_software.html'        'd01_s1_hdl_not_software.html'
do_sed docs/README.md 'seg2_synthesis_vs_simulation.html'  'd01_s2_synthesis_vs_simulation.html'
do_sed docs/README.md 'seg3_anatomy_of_a_module.html'      'd01_s3_anatomy_of_a_module.html'
do_sed docs/README.md 'seg4_digital_logic_refresher.html'  'd01_s4_digital_logic_refresher.html'
echo ""

# ---------------------------------------------------------------------------
fix_header 11 "HIGH" "docs/README Getting Started path is wrong"
do_sed docs/README.md \
    'lectures/week1_day01_welcome_to_hardware_thinking/' \
    'lectures/week1_day01/'
echo ""


# ═══════════════════════════════════════════════════════════════════
# MEDIUM SEVERITY FIXES
# ═══════════════════════════════════════════════════════════════════

fix_header 12 "MEDIUM" "Normalize daily plan filenames to dayNN.md"
do_rename docs/week1_day04_plan.md   docs/day04.md
do_rename docs/week2_day06_plan.md   docs/day06.md
do_rename docs/week3_day09_plan.md   docs/day09.md
do_rename docs/week3_day11_plan.md   docs/day11.md
do_rename docs/week3_day12_plan.md   docs/day12.md
do_rename docs/week4_day14_plan.md   docs/day14.md
do_rename docs/week4_day16_plan.md   docs/day16.md
echo ""

# ---------------------------------------------------------------------------
fix_header 13 "MEDIUM" "Normalize Week 1 lab docs to README.md"
do_rename labs/week1_day01/w1d1_lab_guide.md  labs/week1_day01/README.md
do_rename labs/week1_day02/w1d2_lab_guide.md  labs/week1_day02/README.md
do_rename labs/week1_day03/w1d3_lab_guide.md  labs/week1_day03/README.md
do_rename labs/week1_day04/w1d4_lab_guide.md  labs/week1_day04/README.md
echo ""

# ---------------------------------------------------------------------------
fix_header 14 "MEDIUM" "Lab structure uses three organizational patterns"
flag_manual "Week 1: flat starter/ + solutions/ dirs, prefixed filenames"
flag_manual "Week 2: per-exercise dirs with starter/ + solution/, root Makefile"
flag_manual "Weeks 3-4: per-exercise dirs with per-exercise Makefiles"
flag_manual "Recommend standardizing post-semester — too invasive for now."
echo ""

# ---------------------------------------------------------------------------
fix_header 15 "MEDIUM" "Normalize lecture readme naming for Days 15-16"
do_rename lectures/week4_day15/d15_readme.md  lectures/week4_day15/day15_readme.md
do_rename lectures/week4_day16/d16_readme.md  lectures/week4_day16/day16_readme.md
echo ""

# ---------------------------------------------------------------------------
fix_header 16 "MEDIUM" "Title mismatches between lecture readmes and doc plans"
flag_manual "Day 4:  lecture='Sequential Logic Fundamentals' vs doc='Sequential Logic -- Flip-Flops, Clocks & Counters'"
flag_manual "Day 6:  lecture='Testbenches & Sim-Driven Development' vs doc='Testbenches, Simulation & AI-Assisted Verification'"
flag_manual "Day 10: lecture='Timing, Clocking & Constraints' vs doc='Numerical Architectures & Design Trade-offs' (see #3)"
flag_manual "Day 11: lecture='UART Transmitter' vs doc='UART TX: Your First Communication Interface'"
flag_manual "Day 14: lecture='SystemVerilog for Verification' vs doc='Verification Techniques, AI-Driven Testing & PPA Analysis'"
echo ""


# ═══════════════════════════════════════════════════════════════════
# LOW SEVERITY FIXES
# ═══════════════════════════════════════════════════════════════════

fix_header 17 "LOW" "Remove orphan empty directories"
do_delete labs/week3
do_delete labs/week4
do_delete lectures/week2
do_delete lectures/week3
do_delete lectures/week4
echo ""

# ---------------------------------------------------------------------------
fix_header 18 "LOW" "PCF file duplication"
flag_manual "go_board.pcf duplicated 16x across lab dirs (all identical to shared/pcf/)."
flag_manual "Keeping per-lab copies is safest for student usability — no auto-fix."
echo ""

# ---------------------------------------------------------------------------
fix_header 19 "LOW" "License inconsistency in README"
do_sed README.md \
    'Course materials © UCF ECE. Verilog source code released under MIT License for educational use.' \
    'All materials released under the MIT License. See [LICENSE](LICENSE) for details.'
echo ""

# ---------------------------------------------------------------------------
fix_header 20 "LOW" "Syllabus project timeline says Days 14-15"
do_sed docs/course_syllabus.md \
    'before full build time begins on Days 14–15' \
    'before full build time begins on Day 15'
echo ""

# ---------------------------------------------------------------------------
fix_header 21 "LOW" "Add missing files to root README tree"
do_sed README.md \
    'day*_*.md                ← detailed daily session plans (instructor guides)' \
    'course_dev_status.md     ← development status tracker
│   └── day01.md … day16.md      ← daily session plans (instructor guides)'
echo ""


# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  AUDIT FIX SUMMARY"
echo "═══════════════════════════════════════════════════════════════"
printf "  Automated fixes applied/would apply : %d\n" "$FIXES"
printf "  Skipped (already fixed or missing)  : %d\n" "$SKIPS"
printf "  Manual action items flagged         : %d\n" "$MANUAL"
echo ""

if $DRY_RUN; then
    echo "  This was a DRY RUN. To apply changes:"
    echo "    ./scripts/apply_audit_fixes.sh --apply"
    echo ""
    echo "  Recommended workflow:"
    echo "    1. git checkout -b audit-fixes"
    echo "    2. ./scripts/apply_audit_fixes.sh --apply"
    echo "    3. git add -A && git diff --cached --stat"
    echo "    4. git commit -m 'fix: apply repository audit fixes (21 findings)'"
    echo "    5. Address the MANUAL items listed above"
    echo "    6. git push origin audit-fixes"
fi
echo ""
