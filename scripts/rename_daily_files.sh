#!/usr/bin/env bash
# =============================================================================
# rename_daily_files.sh
# Accelerated HDL for Digital System Design — filename standardization
#
# Policy: daily plan files and lecture directories use dayNN only.
#         The topic title lives inside the file/directory, not in the name.
#
# Run from the repository root:
#   chmod +x rename_daily_files.sh
#   ./rename_daily_files.sh          # dry-run (shows what would happen)
#   ./rename_daily_files.sh --apply  # execute using git mv / git rm
#
# Requires git — uses `git mv` / `git rm` to preserve history.
# =============================================================================

set -euo pipefail

DRY_RUN=true
if [[ "${1:-}" == "--apply" ]]; then
    DRY_RUN=false
fi

ERRORS=0

do_mv() {
    local src="$1"
    local dst="$2"
    if [[ "$src" == "$dst" ]]; then return; fi
    if [[ ! -e "$src" ]]; then
        echo "  [SKIP — not found] $src"
        return
    fi
    if [[ -e "$dst" ]]; then
        echo "  [CONFLICT — destination exists] $dst"
        ERRORS=$((ERRORS + 1))
        return
    fi
    if $DRY_RUN; then
        echo "  [dry-run] git mv  $src  →  $dst"
    else
        git mv "$src" "$dst"
        echo "  [renamed]  $src  →  $dst"
    fi
}

do_rm() {
    local src="$1"
    if [[ ! -e "$src" ]]; then
        echo "  [SKIP — not found] $src"
        return
    fi
    if $DRY_RUN; then
        echo "  [dry-run] git rm  $src"
    else
        git rm "$src"
        echo "  [deleted]  $src"
    fi
}

echo "================================================================="
echo "HDL Course — filename standardization"
$DRY_RUN && echo "MODE: DRY RUN (pass --apply to execute)" \
         || echo "MODE: APPLYING RENAMES"
echo "================================================================="

# -----------------------------------------------------------------------------
# 1. docs/ — daily instructor plan files
#    dayNN_topic_slug.md  →  dayNN.md
#
#    Day 10 special case:
#      KEEP:   day10_numerical_architectures_ppa.md
#              (combined timing + numerical; source-of-truth per curriculum.md,
#               syllabus.md, and video_lecture_scaffold.md)
#      DELETE: day10_timing_clocking_constraints.md
#              (timing-only; content diverged from source docs — to be rebuilt)
# -----------------------------------------------------------------------------
echo ""
echo "--- docs/ daily plan files ---"

do_mv "docs/day01_welcome_to_hardware_thinking.md"              "docs/day01.md"
do_mv "docs/day02_combinational_building_blocks.md"             "docs/day02.md"
do_mv "docs/day03_procedural_combinational_logic.md"            "docs/day03.md"
do_mv "docs/day04_sequential_logic_fundamentals.md"             "docs/day04.md"
do_mv "docs/day05_counters_shift_registers_debouncing.md"       "docs/day05.md"
do_mv "docs/day06_testbenches_simulation_driven_development.md" "docs/day06.md"
do_mv "docs/day07_finite_state_machines.md"                     "docs/day07.md"
do_mv "docs/day08_hierarchy_parameters_generate.md"             "docs/day08.md"
do_mv "docs/day09_memory_ram_rom_block_ram.md"                  "docs/day09.md"

# Day 10: keep combined timing+numerical; remove timing-only divergence
do_mv "docs/day10_numerical_architectures_ppa.md"               "docs/day10.md"
do_rm "docs/day10_timing_clocking_constraints.md"

do_mv "docs/day11_uart_transmitter.md"                          "docs/day11.md"
do_mv "docs/day12_uart_rx_spi_ip_integration.md"                "docs/day12.md"
do_mv "docs/day13_systemverilog_for_design.md"                  "docs/day13.md"
do_mv "docs/day14_systemverilog_for_verification.md"            "docs/day14.md"
do_mv "docs/day15_final_project_build_day.md"                   "docs/day15.md"
do_mv "docs/day16_demos_reflection_next_steps.md"               "docs/day16.md"

# -----------------------------------------------------------------------------
# 2. lectures/ — per-day subdirectories
#    lectures/weekN/dayNN_topic_slug/  →  lectures/weekN/dayNN/
#
#    Note: lectures/week3/day10_timing_clocking_constraints/ holds the
#    generated timing-only slides. The directory is RENAMED (not deleted)
#    so existing slides remain accessible during the Day 10 rebuild.
# -----------------------------------------------------------------------------
echo ""
echo "--- lectures/ weekly subdirectories ---"

# Week 1
do_mv "lectures/week1_day01_welcome_to_hardware_thinking"          "lectures/week1_day01"
do_mv "lectures/week1_day02_combinational_building_blocks"         "lectures/week1_day02"
do_mv "lectures/week1_day03_procedural_combinational_logic"        "lectures/week1_day03"
do_mv "lectures/week1_day04_sequential_logic_fundamentals"         "lectures/week1_day04"

# Week 2
do_mv "lectures/week2_day05_counters_shift_registers_debouncing"   "lectures/week2_day05"
do_mv "lectures/week2_day06_testbenches_simulation_driven_development" \
                                                                    "lectures/week2_day06"
do_mv "lectures/week2_day07_finite_state_machines"                 "lectures/week2_day07"
do_mv "lectures/week2_day08_hierarchy_parameters_generate"         "lectures/week2_day08"

# Week 3
do_mv "lectures/week3_day09_memory_ram_rom_block_ram"              "lectures/week3_day09"
do_mv "lectures/week3_day10_timing_clocking_constraints"           "lectures/week3_day10"
do_mv "lectures/week3_day11_uart_transmitter"                      "lectures/week3_day11"
do_mv "lectures/week3_day12_uart_rx_spi_ip_integration"            "lectures/week3_day12"

# Week 4
do_mv "lectures/week4_day13_systemverilog_for_design"              "lectures/week4_day13"
do_mv "lectures/week4_day14_systemverilog_for_verification"        "lectures/week4_day14"
do_mv "lectures/week4_day15_final_project_build_day"               "lectures/week4_day15"
do_mv "lectures/week4_day16_demos_reflection_next_steps"           "lectures/week4_day16"

# -----------------------------------------------------------------------------
# 3. labs/ — already use dayNN/ format; no renames needed
# -----------------------------------------------------------------------------
echo ""
echo "--- labs/ ---"
echo "  [OK] labs/weekN/dayNN/ already follows dayNN convention — no renames."

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "================================================================="
if [[ $ERRORS -gt 0 ]]; then
    echo "COMPLETED WITH $ERRORS CONFLICT(S) — review above before retrying."
else
    $DRY_RUN \
        && echo "Dry run complete. Run with --apply to execute." \
        || echo "All renames applied successfully."
fi
echo ""
echo "Post-rename checklist:"
echo "  1. ls docs/day*.md               — should be week1_day01.md through week4_day16.md only"
echo "  2. ls lectures/week3_day10/      — timing-only slides; flagged for rebuild"
echo "  3. Commit docs/course_dev_status.md (provided separately)"
echo "  4. Update README.md and docs/README.md directory tree listings"
echo "  5. When Day 10 rebuild complete: replace lectures/week3_day10/ contents"
echo "  6. git commit -m 'refactor: standardize daily filenames to dayNN convention'"
echo "================================================================="
