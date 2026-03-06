#!/usr/bin/env python3
"""
Transform 3: Deduplicate shared modules across lab exercises.

Phase 1 — Reconcile shared/lib to match exercise interfaces:
    - debounce.v:    CLKS_TO_STABLE, i_bouncy/o_clean (exercise convention)
    - hex_to_7seg.v: {a,b,c,d,e,f,g} bit ordering (exercise convention)
    - Update associated testbenches

Phase 2 — Replace compatible dependency copies with symlinks:
    For each .v file in labs/ that has the same port interface as the
    reconciled shared/lib version, replace it with a relative symlink.
    Primary-target exercises (where the student BUILDS the module) are
    preserved as local files. This means:
    - Makefiles don't change (filename stays the same)
    - Zips remain self-contained (Python follows symlinks when zipping)
    - git tracks symlinks natively on Linux/macOS/WSL2

Modules with incompatible interfaces (day09 debounce, uart_tx/rx, etc.)
are skipped and reported for future reconciliation.

Usage:
    python3 transforms/t3_dedup_shared_modules.py            # preview
    python3 transforms/t3_dedup_shared_modules.py --apply     # execute

After applying:
    git add -A
    git commit -m "refactor: deduplicate shared modules via symlinks to shared/lib"
"""

import argparse
import filecmp
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SHARED_LIB = REPO / "shared" / "lib"
LABS = REPO / "labs"

# ─── Phase 1: Reconciled shared/lib content ───────────────────────
# These are the canonical versions, combining shared/lib documentation
# quality with exercise-tested implementations.

RECONCILED = {}

RECONCILED["debounce.v"] = """\
// =============================================================================
// debounce.v — Counter-based Button Debouncer (parameterized)
// Accelerated HDL for Digital System Design · UCF · shared/lib
// =============================================================================
// Description:
//   Eliminates switch bounce by requiring the input to be stable for
//   CLKS_TO_STABLE consecutive clock cycles before accepting a new value.
//   Includes a built-in 2-FF synchronizer for async inputs.
//
// Parameters:
//   CLKS_TO_STABLE  Number of stable cycles required (default 250000 = 10ms @ 25MHz)
//
// Ports:
//   i_clk     Clock input (25 MHz on Go Board)
//   i_bouncy  Raw (bouncy) switch input — may be asynchronous
//   o_clean   Debounced output (follows input only after stable)
//
// Introduced: Day 5
// =============================================================================
module debounce #(
    parameter CLKS_TO_STABLE = 250_000
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
    reg r_sync_0, r_sync_1;

    always @(posedge i_clk) begin
        // 2-FF synchronizer
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;

        // Debounce logic
        if (r_sync_1 != o_clean) begin
            r_count <= r_count + 1;
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;
                r_count <= 0;
            end
        end else begin
            r_count <= 0;
        end
    end

endmodule
"""

RECONCILED["hex_to_7seg.v"] = """\
// =============================================================================
// hex_to_7seg.v — Hexadecimal to 7-Segment Decoder
// Accelerated HDL for Digital System Design · UCF · shared/lib
// =============================================================================
// Description:
//   Maps a 4-bit hexadecimal value (0x0-0xF) to the 7 segment enable signals
//   for the Nandland Go Board's common-anode displays.
//   Segment encoding: o_seg[6:0] = {a, b, c, d, e, f, g}
//   ACTIVE LOW: o_seg bit = 0 means segment is ON.
//
// Ports:
//   i_hex   [3:0]  4-bit hex digit input
//   o_seg   [6:0]  {a,b,c,d,e,f,g} active-low segment outputs
//
// Introduced: Day 2
// =============================================================================
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {a,b,c,d,e,f,g} active low
);
    always @(*) begin
        case (i_hex)
            4'h0: o_seg = 7'b0000001;  4'h1: o_seg = 7'b1001111;
            4'h2: o_seg = 7'b0010010;  4'h3: o_seg = 7'b0000110;
            4'h4: o_seg = 7'b1001100;  4'h5: o_seg = 7'b0100100;
            4'h6: o_seg = 7'b0100000;  4'h7: o_seg = 7'b0001111;
            4'h8: o_seg = 7'b0000000;  4'h9: o_seg = 7'b0000100;
            4'hA: o_seg = 7'b0001000;  4'hB: o_seg = 7'b1100000;
            4'hC: o_seg = 7'b0110001;  4'hD: o_seg = 7'b1000010;
            4'hE: o_seg = 7'b0110000;  4'hF: o_seg = 7'b0111000;
        endcase
    end
endmodule
"""

RECONCILED["tb_debounce.v"] = """\
// =============================================================================
// tb_debounce.v — Self-checking testbench for debounce module
// Accelerated HDL for Digital System Design · UCF · shared/lib
// =============================================================================
`timescale 1ns/1ps
module tb_debounce;
    parameter CLKS_TO_STABLE = 20;    // Small for fast simulation
    parameter CLK_PERIOD     = 40;    // 25 MHz

    reg  i_clk    = 0;
    reg  i_bouncy = 0;
    wire o_clean;

    debounce #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) dut (
        .i_clk    (i_clk),
        .i_bouncy (i_bouncy),
        .o_clean  (o_clean)
    );

    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    integer pass_count = 0, fail_count = 0;

    task check;
        input expected;
        input [80*8-1:0] name;
        begin
            #1;
            if (o_clean !== expected) begin
                $display("FAIL: %0s — expected %b got %b", name, expected, o_clean);
                fail_count = fail_count + 1;
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) @(posedge i_clk);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce);

        i_bouncy = 0;
        wait_cycles(5);

        // Test 1: Stable press (hold > CLKS_TO_STABLE cycles)
        i_bouncy = 1;
        wait_cycles(CLKS_TO_STABLE + 5);
        check(1, "stable press");

        // Test 2: Glitch (pulse shorter than CLKS_TO_STABLE)
        i_bouncy = 0;
        wait_cycles(CLKS_TO_STABLE / 2);
        i_bouncy = 1;
        wait_cycles(2);
        check(1, "glitch rejected");

        // Test 3: Clean release
        i_bouncy = 0;
        wait_cycles(CLKS_TO_STABLE + 5);
        check(0, "stable release");

        // Test 4: Bounce storm
        repeat (8) begin
            i_bouncy = ~i_bouncy;
            wait_cycles(CLKS_TO_STABLE / 3);
        end
        i_bouncy = 0;
        wait_cycles(CLKS_TO_STABLE + 5);
        check(0, "bounce storm resolved");

        $display("\\n=== tb_debounce: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
"""

RECONCILED["tb_hex_to_7seg.v"] = """\
// =============================================================================
// tb_hex_to_7seg.v — Self-checking testbench for hex_to_7seg
// Accelerated HDL for Digital System Design · UCF · shared/lib
// =============================================================================
`timescale 1ns/1ps
module tb_hex_to_7seg;
    reg  [3:0] hex;
    wire [6:0] seg;

    hex_to_7seg dut (.i_hex(hex), .o_seg(seg));

    integer pass_count = 0, fail_count = 0;

    // Expected values: {a,b,c,d,e,f,g} active-low
    task check_seg;
        input [6:0] expected;
        input [3:0] digit;
        begin
            #1;
            if (seg !== expected) begin
                $display("FAIL: hex=%0h expected seg=%7b got=%7b", digit, expected, seg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: hex=%0h seg=%7b", digit, seg);
                pass_count = pass_count + 1;
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_hex_to_7seg);

        for (i = 0; i < 16; i = i + 1) begin
            hex = i[3:0];
            case (i[3:0])
                4'h0: check_seg(7'b0000001, 4'h0);
                4'h1: check_seg(7'b1001111, 4'h1);
                4'h2: check_seg(7'b0010010, 4'h2);
                4'h3: check_seg(7'b0000110, 4'h3);
                4'h4: check_seg(7'b1001100, 4'h4);
                4'h5: check_seg(7'b0100100, 4'h5);
                4'h6: check_seg(7'b0100000, 4'h6);
                4'h7: check_seg(7'b0001111, 4'h7);
                4'h8: check_seg(7'b0000000, 4'h8);
                4'h9: check_seg(7'b0000100, 4'h9);
                4'hA: check_seg(7'b0001000, 4'hA);
                4'hB: check_seg(7'b1100000, 4'hB);
                4'hC: check_seg(7'b0110001, 4'hC);
                4'hD: check_seg(7'b1000010, 4'hD);
                4'hE: check_seg(7'b0110000, 4'hE);
                4'hF: check_seg(7'b0111000, 4'hF);
            endcase
        end

        $display("\\n=== tb_hex_to_7seg: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
"""

# ─── Modules to deduplicate ───────────────────────────────────────
# (filename, list of exercises where this is the PRIMARY target — don't replace starters there)
PRIMARY_EXERCISES = {
    "debounce.v": [
        "ex1_debounce_module",   # Day 5: student builds debounce
        "ex2_debounce_testbench", # Day 6: student tests debounce
        "ex2_generate_debounce",  # Day 8: student parameterizes debounce
    ],
    "hex_to_7seg.v": [
        "ex4_7seg_decoder",       # Day 2: student builds hex_to_7seg
        "ex4_file_driven_testing", # Day 6: student tests hex_to_7seg
    ],
}

# Modules that only need dedup (no interface reconciliation needed)
PASSTHROUGH_MODULES = ["counter_mod_n.v", "lfsr_8bit.v", "baud_gen.v",
                       "uart_tx.v", "uart_rx.v", "edge_detect.v", "heartbeat.v"]


def relative_symlink(target, link_path):
    """Create a relative symlink from link_path → target."""
    rel = os.path.relpath(target, link_path.parent)
    if link_path.exists() or link_path.is_symlink():
        link_path.unlink()
    link_path.symlink_to(rel)


def is_primary_exercise(filepath, module_name):
    """Check if this file is in a primary-target exercise (don't replace)."""
    primaries = PRIMARY_EXERCISES.get(module_name, [])
    parts = filepath.parts
    for ex_name in primaries:
        if ex_name in parts:
            return True
    return False


def check_port_compat(copy_path, lib_path):
    """Quick check that module port signature matches (safety net)."""
    try:
        copy_text = copy_path.read_text(encoding="utf-8")
        lib_text = lib_path.read_text(encoding="utf-8")
        # Extract module declaration line
        def get_ports(text):
            m = re.search(r'module\s+\w+[^;]*;', text, re.DOTALL)
            return m.group(0) if m else ""
        copy_ports = re.sub(r'//.*', '', get_ports(copy_text))
        lib_ports = re.sub(r'//.*', '', get_ports(lib_text))
        # Check that port names match
        copy_names = set(re.findall(r'\b(i_\w+|o_\w+)\b', copy_ports))
        lib_names = set(re.findall(r'\b(i_\w+|o_\w+)\b', lib_ports))
        return copy_names == lib_names
    except Exception:
        return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    dry_run = not args.apply

    if dry_run:
        print("╔══════════════════════════════════════════╗")
        print("║  Transform 3: PREVIEW (dry run)          ║")
        print("║  Add --apply to execute                  ║")
        print("╚══════════════════════════════════════════╝")
    else:
        print("╔══════════════════════════════════════════╗")
        print("║  Transform 3: Applying changes           ║")
        print("╚══════════════════════════════════════════╝")
    print()

    # ── Phase 1: Reconcile shared/lib ──────────────────────────────
    print("Phase 1: Reconcile shared/lib to exercise interfaces")
    for filename, content in RECONCILED.items():
        target = SHARED_LIB / filename
        if dry_run:
            print(f"  would write shared/lib/{filename}")
        else:
            target.write_text(content, encoding="utf-8")
            print(f"  wrote shared/lib/{filename}")

    # For dry-run port checking, temporarily compute what shared/lib would be
    tmp_lib = None
    if dry_run:
        tmp_lib = Path(tempfile.mkdtemp())
        for filename, content in RECONCILED.items():
            (tmp_lib / filename).write_text(content, encoding="utf-8")
        # Copy non-reconciled modules too
        for m in PASSTHROUGH_MODULES:
            src = SHARED_LIB / m
            if src.exists():
                shutil.copy2(src, tmp_lib / m)
        effective_lib = tmp_lib
    else:
        effective_lib = SHARED_LIB
    print()

    # ── Phase 2: Replace dependency copies with symlinks ───────────
    print("Phase 2: Replace dependency copies with symlinks")
    print("  (Only replaces copies where port interface matches shared/lib)")
    print()
    modules_to_check = list(RECONCILED.keys()) + PASSTHROUGH_MODULES
    # Exclude testbenches from replacement — they belong in exercises
    modules_to_check = [m for m in modules_to_check if not m.startswith("tb_")]

    replaced = 0
    skipped_primary = 0
    skipped_incompat = 0
    skipped_symlink = 0

    for module_name in modules_to_check:
        lib_file = SHARED_LIB / module_name
        eff_lib_file = effective_lib / module_name
        if not eff_lib_file.exists():
            continue

        # Find all copies in labs/ (exact filename match)
        for copy in sorted(LABS.rglob(module_name)):
            if copy.is_symlink():
                skipped_symlink += 1
                continue

            # Skip primary-target exercises entirely (both starter and solution)
            if is_primary_exercise(copy, module_name):
                skipped_primary += 1
                if dry_run:
                    print(f"  SKIP (primary): {copy.relative_to(REPO)}")
                continue

            # Safety: verify port interface compatibility
            if not check_port_compat(copy, eff_lib_file):
                skipped_incompat += 1
                if dry_run:
                    print(f"  SKIP (ports differ): {copy.relative_to(REPO)}")
                continue

            rel_link = os.path.relpath(lib_file, copy.parent)
            if dry_run:
                print(f"  symlink {copy.relative_to(REPO)} → {rel_link}")
            else:
                subprocess.run(["git", "rm", "--cached", str(copy)],
                               cwd=REPO, capture_output=True)
                copy.unlink()
                copy.symlink_to(rel_link)
                subprocess.run(["git", "add", str(copy)],
                               cwd=REPO, capture_output=True)
            replaced += 1

    if tmp_lib:
        shutil.rmtree(tmp_lib, ignore_errors=True)

    print(f"\n  Replaced: {replaced}  |  Skipped primary: {skipped_primary}"
          f"  |  Skipped incompatible: {skipped_incompat}  |  Already symlink: {skipped_symlink}")
    print()

    # ── Summary ────────────────────────────────────────────────────
    if skipped_incompat > 0:
        print("Note: Files skipped due to port incompatibility are in modules where")
        print("shared/lib has a different interface (e.g., day09 debounce uses i_switch")
        print("instead of i_bouncy, shared/lib uart_tx has o_done port). These need")
        print("separate interface reconciliation in a future pass.")
        print()

    if dry_run:
        print("This was a dry run. To apply:")
        print("  python3 transforms/t3_dedup_shared_modules.py --apply")
    else:
        print("=== Transform 3 Complete ===")
        print()
        print("Verify with:")
        print("  ls -la labs/week2_day07/ex2_pattern_detector/starter/debounce.v")
        print("  # should show symlink → ../../../../../../shared/lib/debounce.v")
        print()
        print("  readlink labs/week4_day15/module_library/debounce.v")
        print("  # should show path to shared/lib/debounce.v")
        print()
        print("Then commit:")
        print("  git add -A")
        print("  git commit -m 'refactor: deduplicate shared modules via symlinks to shared/lib'")


if __name__ == "__main__":
    main()
