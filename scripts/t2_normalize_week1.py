#!/usr/bin/env python3
"""
Transform 2: Normalize Week 1 lab directories to per-exercise layout.

Converts the flat starter/solution structure used in Week 1 (days 1–4)
into the per-exercise directory structure used in Weeks 2–4:

    BEFORE:                         AFTER:
    labs/week1_day01/               labs/week1_day01/
    ├── Makefile (monolithic)       ├── Makefile (dispatcher)
    ├── README.md                   ├── README.md
    ├── go_board.pcf                ├── go_board.pcf
    ├── starter/                    ├── ex1_led_on/
    │   ├── ex1_led_on.v            │   ├── starter/
    │   └── ex2_buttons_to_leds.v   │   │   ├── Makefile
    └── solution/                   │   │   └── ex1_led_on.v
        ├── ex1_led_on.v            │   └── solution/
        └── ex2_buttons_to_leds.v   │       └── ex1_led_on.v
                                    ├── ex2_buttons_to_leds/
                                    │   ├── starter/  ...
                                    │   └── solution/ ...
                                    └── ...

Usage:
    python3 transforms/t2_normalize_week1.py           # preview (dry-run)
    python3 transforms/t2_normalize_week1.py --apply   # actually do it

After applying:
    git add -A
    git commit -m "refactor: normalize Week 1 labs to per-exercise directories"
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
LABS = REPO / "labs"

# ─── Exercise metadata ─────────────────────────────────────────────
# Extracted from the monolithic Makefiles.
# format: (exercise_dir_name, top_module, [starter_files], build_type, extra_deps)
#   build_type: "synth" | "sim" | "analysis"
#   extra_deps: files from other exercises needed in this exercise's starter dir

WEEK1 = {
    "week1_day01": [
        ("ex1_led_on",           "led_on",           ["ex1_led_on.v"],                         "synth", []),
        ("ex2_buttons_to_leds",  "buttons_to_leds",  ["ex2_buttons_to_leds.v"],                "synth", []),
        ("ex3_button_logic",     "button_logic",     ["ex3_button_logic.v"],                   "synth", []),
        ("ex4_active_low_clean", "active_low_clean",  ["ex4_active_low_clean.v"],              "synth", []),
        ("ex5_xor_pattern",      "xor_pattern",      ["ex5_xor_pattern.v"],                   "synth", []),
    ],
    "week1_day02": [
        ("ex1_vector_ops",        "vector_ops",        ["ex1_vector_ops.v"],                                                         "synth", []),
        ("ex2_mux_hierarchy",     "top_mux",           ["ex2_mux2to1.v", "ex2_mux4to1.v", "ex2_top_mux.v"],                          "synth", []),
        ("ex3_ripple_adder",      "top_adder",         ["ex3_full_adder.v", "ex3_ripple_adder_4bit.v", "ex3_top_adder.v"],            "synth", []),
        ("ex4_7seg_decoder",      "top_7seg",          ["ex4_hex_to_7seg.v", "ex4_top_7seg.v"],                                      "synth", []),
        ("ex5_top_adder_display", "top_adder_display", ["ex5_top_adder_display.v"],                                                  "synth",
            ["ex3_full_adder.v", "ex3_ripple_adder_4bit.v", "ex4_hex_to_7seg.v"]),
    ],
    "week1_day03": [
        ("ex1_latch_bugs",       "latch_bugs",        ["ex1_latch_bugs.v"],                                        "analysis", []),
        ("ex2_priority_encoder", "top_encoder",        ["ex2_priority_encoder.v", "ex2_top_encoder.v"],             "synth",    []),
        ("ex3_alu",              "top_alu",            ["ex3_alu_4bit.v", "ex3_top_alu.v"],                         "synth",    []),
        ("ex4_bcd_7seg",         "top_bcd",            ["ex4_bcd_to_7seg.v", "ex4_top_bcd.v"],                     "synth",    []),
        ("ex5_top_alu_display",  "top_alu_display",    ["ex5_top_alu_display.v"],                                  "synth",
            ["ex3_alu_4bit.v", "ex4_bcd_to_7seg.v"]),
    ],
    "week1_day04": [
        ("ex1_d_ff",             None,                 ["ex1_d_ff.v", "ex1_tb_d_ff.v"],                     "sim",  []),
        ("ex2_register",         None,                 ["ex2_register_4bit.v", "ex2_tb_register.v"],        "sim",  []),
        ("ex3_led_blinker",      "led_blinker",        ["ex3_led_blinker.v"],                               "synth", []),
        ("ex4_seg_counter",      "seg_counter",        ["ex4_seg_counter.v"],                               "synth", []),
        ("ex5_dual_blinker",     "dual_blinker",       ["ex5_dual_blinker.v"],                              "synth", []),
        ("ex6_updown_counter",   "updown_counter",     ["ex6_updown_counter.v"],                            "synth", []),
    ],
}


def generate_exercise_makefile(top, srcs, build_type, tb_file=None):
    """Generate a per-exercise Makefile matching the Week 2+ template."""
    lines = ["# Auto-generated Makefile"]

    # Detect testbench
    all_srcs = list(srcs)
    if tb_file is None:
        tb_candidates = [s for s in srcs if s.startswith("tb_") or "_tb_" in s]
        if tb_candidates:
            tb_file = tb_candidates[0]
    design_srcs = [s for s in all_srcs if s != tb_file]

    if top:
        lines.append(f"TOP      = {top}")
    lines.append(f"SRCS     = {' '.join(design_srcs)}")
    if tb_file:
        lines.append(f"TB       = {tb_file}")
    lines.append("PCF      = ../go_board.pcf")
    lines.append("DEVICE   = hx1k")
    lines.append("PACKAGE  = vq100")
    lines.append("IVFLAGS  = -g2012 -Wall")
    lines.append("")

    # sim target
    if tb_file:
        if build_type == "sim":
            lines.append("all: sim")
            lines.append("")
        lines.append("sim: $(TB) $(SRCS)")
        lines.append("\tiverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)")
        lines.append("\tvvp sim.vvp")
        lines.append("")
        lines.append("wave: sim")
        lines.append("\tgtkwave *.vcd &")
        lines.append("")

    # synth/prog targets
    if build_type in ("synth", "analysis") and top:
        if build_type == "analysis":
            lines.append("all: stat")
            lines.append("")
            lines.append("synth: $(SRCS)")
            lines.append(f'\tyosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP)"')
            lines.append("")
        else:
            lines.append("synth: $(SRCS)")
            lines.append(f'\tyosys -p "synth_ice40 -top $(TOP) -json $(TOP).json" $(SRCS)')
            lines.append("")
            lines.append("prog: synth")
            lines.append("\tnextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) "
                         "--json $(TOP).json --asc $(TOP).asc --freq 25")
            lines.append("\ticepack $(TOP).asc $(TOP).bin")
            lines.append("\ticeprog $(TOP).bin")
            lines.append("")

        lines.append("stat: $(SRCS)")
        lines.append(f'\tyosys -p "synth_ice40 -top $(TOP); stat" $(SRCS)')
        lines.append("")

    lines.append("clean:")
    lines.append("\trm -f *.json *.asc *.bin *.vvp *.vcd *.log")
    lines.append("")
    targets = ["sim", "wave", "synth", "prog", "stat", "clean", "all"]
    lines.append(f".PHONY: {' '.join(t for t in targets)}")
    lines.append("")

    return "\n".join(lines)


def generate_dispatcher_makefile(day_dir_name, exercises):
    """Generate a top-level Makefile that dispatches to per-exercise dirs."""
    lines = [
        f"# =============================================================================",
        f"# Makefile — {day_dir_name} (dispatcher)",
        f"# Delegates to per-exercise directories. Run from day directory.",
        f"# =============================================================================",
        "",
    ]

    targets = []
    for ex_dir, top, _srcs, btype, _deps in exercises:
        short = re.match(r"(ex\d+)", ex_dir).group(1)
        targets.append(short)
        if btype == "sim":
            lines.append(f"{short}:")
            lines.append(f"\t$(MAKE) -C {ex_dir}/starter sim")
        elif btype == "analysis":
            lines.append(f"{short}:")
            lines.append(f"\t$(MAKE) -C {ex_dir}/starter synth")
        else:
            lines.append(f"{short}:")
            lines.append(f"\t$(MAKE) -C {ex_dir}/starter prog")
        lines.append("")

    lines.append("clean:")
    for ex_dir, *_ in exercises:
        lines.append(f"\t$(MAKE) -C {ex_dir}/starter clean")
    lines.append("")

    lines.append(f".PHONY: {' '.join(targets)} clean")
    lines.append("")
    return "\n".join(lines)


def plan_moves(day_dir_name, exercises, dry_run=True):
    """Plan all file operations for one day. Returns list of (action, src, dst) tuples."""
    lab_dir = LABS / day_dir_name
    starter = lab_dir / "starter"
    solution = lab_dir / "solution"
    ops = []

    for ex_dir_name, top, src_files, btype, extra_deps in exercises:
        ex_dir = lab_dir / ex_dir_name
        ex_starter = ex_dir / "starter"
        ex_solution = ex_dir / "solution"

        ops.append(("mkdir", ex_starter, None))
        ops.append(("mkdir", ex_solution, None))

        # Move starter files
        for fname in src_files:
            src = starter / fname
            dst = ex_starter / fname
            if src.exists():
                ops.append(("git_mv", src, dst))
            else:
                print(f"  WARNING: expected starter file missing: {src}")

        # Copy extra deps (files from other exercises)
        for fname in extra_deps:
            src = starter / fname
            dst = ex_starter / fname
            if src.exists():
                ops.append(("copy", src, dst))
            elif (solution / fname).exists():
                ops.append(("copy", solution / fname, dst))
            else:
                print(f"  WARNING: dependency missing: {fname} for {ex_dir_name}")

        # Move solution files
        for fname in src_files:
            src = solution / fname
            dst = ex_solution / fname
            if src.exists():
                ops.append(("git_mv", src, dst))

        # Copy extra deps into solution too
        for fname in extra_deps:
            src = solution / fname
            dst = ex_solution / fname
            if src.exists():
                ops.append(("copy", src, dst))
            elif (starter / fname).exists():
                ops.append(("copy", starter / fname, dst))

        # Determine tb_file for Makefile generation
        tb_file = None
        for f in src_files:
            if f.startswith("tb_") or "_tb_" in f:
                tb_file = f
                break
        all_src_names = list(src_files) + list(extra_deps)
        mkfile_content = generate_exercise_makefile(top, all_src_names, btype, tb_file)
        ops.append(("write", ex_starter / "Makefile", mkfile_content))

    # Generate dispatcher Makefile (replaces old monolithic one)
    dispatcher = generate_dispatcher_makefile(day_dir_name, exercises)
    ops.append(("write", lab_dir / "Makefile", dispatcher))

    # Remove now-empty starter/ and solution/ dirs
    ops.append(("rmdir", starter, None))
    ops.append(("rmdir", solution, None))

    return ops


def execute_ops(ops, dry_run=True):
    """Execute planned operations.

    Critical: reorder so copies happen before git_mv's,
    since copies may reference files that git_mv will move.
    """
    # Phase 1: mkdir
    # Phase 2: copy (dependencies from original locations — must happen before git mv)
    # Phase 3: git_mv
    # Phase 4: write (new Makefiles)
    # Phase 5: rmdir
    phase_order = {"mkdir": 0, "copy": 1, "git_mv": 2, "write": 3, "rmdir": 4}
    sorted_ops = sorted(ops, key=lambda o: phase_order.get(o[0], 99))

    for action, src, dst in sorted_ops:
        if action == "mkdir":
            if dry_run:
                print(f"  mkdir -p {src}")
            else:
                src.mkdir(parents=True, exist_ok=True)

        elif action == "git_mv":
            if dry_run:
                print(f"  git mv {src.relative_to(REPO)} → {dst.relative_to(REPO)}")
            else:
                dst.parent.mkdir(parents=True, exist_ok=True)
                subprocess.run(["git", "mv", str(src), str(dst)],
                               cwd=REPO, check=True, capture_output=True)

        elif action == "copy":
            if dry_run:
                print(f"  cp {src.relative_to(REPO)} → {dst.relative_to(REPO)}")
            else:
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)

        elif action == "write":
            if dry_run:
                print(f"  write {src.relative_to(REPO)} ({len(dst)} bytes)")
            else:
                src.parent.mkdir(parents=True, exist_ok=True)
                src.write_text(dst, encoding="utf-8")

        elif action == "rmdir":
            if dry_run:
                print(f"  rmdir {src.relative_to(REPO)} (if empty)")
            else:
                # Only remove if empty (git mv should have moved everything)
                if src.exists():
                    remaining = list(src.iterdir())
                    if remaining:
                        print(f"  WARNING: {src} not empty, {len(remaining)} files remain:")
                        for f in remaining:
                            print(f"    {f.name}")
                    else:
                        src.rmdir()


def main():
    parser = argparse.ArgumentParser(description="Normalize Week 1 labs to per-exercise layout")
    parser.add_argument("--apply", action="store_true", help="Actually perform the restructuring")
    args = parser.parse_args()

    dry_run = not args.apply
    if dry_run:
        print("╔══════════════════════════════════════════╗")
        print("║  Transform 2: PREVIEW (dry run)          ║")
        print("║  Add --apply to execute                  ║")
        print("╚══════════════════════════════════════════╝")
    else:
        print("╔══════════════════════════════════════════╗")
        print("║  Transform 2: Applying changes           ║")
        print("╚══════════════════════════════════════════╝")
    print()

    total_ops = 0
    for day_dir_name, exercises in WEEK1.items():
        print(f"=== {day_dir_name} ({len(exercises)} exercises) ===")
        ops = plan_moves(day_dir_name, exercises, dry_run)
        execute_ops(ops, dry_run)
        total_ops += len(ops)
        print()

    print(f"Total operations: {total_ops}")
    print()

    if dry_run:
        print("This was a dry run. To apply:")
        print("  python3 transforms/t2_normalize_week1.py --apply")
    else:
        print("=== Transform 2 Complete ===")
        print()
        print("Verify with:")
        print("  ls labs/week1_day01/  # should show ex*/ dirs, no starter/solution/")
        print("  cat labs/week1_day01/ex1_led_on/starter/Makefile")
        print("  cat labs/week1_day01/Makefile  # dispatcher")
        print()
        print("Then commit:")
        print("  git add -A")
        print("  git commit -m 'refactor: normalize Week 1 labs to per-exercise directories'")


if __name__ == "__main__":
    main()
