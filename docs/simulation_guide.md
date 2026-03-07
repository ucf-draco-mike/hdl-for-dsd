# Simulation & Verification Guide

> **Accelerated HDL for Digital System Design · Dr. Mike Borowczak · Electrical & Computer Engineering · CECS · UCF**

This guide covers the simulation and verification workflow used throughout the course.  It complements the synthesis flow documented in `course_setup_guide.md`.

---

## Why Simulate?

Synthesis produces hardware.  Simulation produces confidence.

Every design in this course follows a **simulate-first** workflow: verify functional correctness in simulation before programming the FPGA.  This mirrors industry practice for both ASIC and FPGA design — the only difference is which netlist you simulate against.

| Phase | What you're simulating | Tool |
|-------|------------------------|------|
| **Behavioral (RTL)** | Your Verilog source as-written | Icarus Verilog |
| **Post-synthesis (FPGA)** | Yosys gate-level netlist (LUT/FF) | Icarus Verilog |
| **Post-synthesis (ASIC)** | Generic/technology gate-level netlist | Icarus Verilog (or commercial) |

In this course we primarily use behavioral simulation.  Post-synthesis simulation is introduced in Week 4 for advanced verification.

---

## Quick Reference

```bash
# Enter course environment
cd hdl-for-dsd && nix develop

# Run a testbench
cd labs/week1_day02/ex3_ripple_adder/starter
make sim        # compile + run → prints PASS/FAIL

# View waveforms
make wave       # opens GTKWave with the VCD dump

# Synthesis stats (for comparison)
make stat       # shows LUT/FF utilization
```

---

## Testbench Anatomy

Every testbench in this course follows a consistent structure:

```verilog
`timescale 1ns / 1ps

module tb_my_module;
    // 1. DUT port signals
    reg  [3:0] a, b;
    wire [3:0] result;

    // 2. Instantiate the Design Under Test
    my_module dut (
        .i_a(a), .i_b(b), .o_result(result)
    );

    // 3. Pass/fail counters
    integer pass_count = 0, fail_count = 0;

    // 4. Stimulus + checking
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_my_module);

        a = 4'd3; b = 4'd5; #1;
        if (result === 4'd8) begin
            $display("PASS: 3+5=8");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: 3+5 got %0d", result);
            fail_count = fail_count + 1;
        end

        // 5. Summary
        $display("=== %0d passed, %0d failed ===",
                 pass_count, fail_count);
        $finish;
    end
endmodule
```

### Key conventions

- **`timescale 1ns/1ps`** — consistent across all TBs.
- **`$dumpfile` / `$dumpvars`** — always emit VCD for GTKWave debugging.
- **Self-checking** — every TB prints PASS/FAIL and a final summary.  No manual waveform inspection required to determine correctness.
- **`===` not `==`** — the identity operator catches X/Z values that `==` would silently accept.

---

## Testbench Patterns by Design Type

### Combinational (Days 1–3)

For purely combinational modules, stimulus is applied and checked after a small propagation delay (`#1`).  No clock is needed.

```verilog
// Exhaustive: test all input combinations
for (i = 0; i < 16; i = i + 1) begin
    input_signal = i[3:0];
    #1;  // let combinational logic settle
    // check output
end
```

**When to use exhaustive testing:**  If the input space is small enough (≤ 2^10 = 1024 vectors), test every combination.  A 4-bit ALU with 2 operands + 2-bit opcode has 2^10 = 1024 vectors — easily exhaustive.

### Sequential (Days 4+)

Sequential designs require a clock and usually a reset.  Outputs are sampled after the active clock edge plus a small delay.

```verilog
parameter CLK_PERIOD = 40;  // 25 MHz Go Board clock
reg clk = 0;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    rst = 1;
    repeat (2) @(posedge clk);  // hold reset 2 cycles
    rst = 0;

    // Apply stimulus, sample after clock edge
    @(posedge clk); #1;
    // check outputs
end
```

### FSM (Days 7–8)

State machines need carefully sequenced inputs and state verification.  Check both outputs and, when accessible, internal state:

```verilog
// Walk through state transitions
@(posedge clk); #1;
// Should be in STATE_GREEN
if (dut.r_state === 2'b00) ...

// Apply transition trigger
sensor = 1;
repeat (TIMEOUT) @(posedge clk);
// Should have transitioned to STATE_YELLOW
```

### File-Driven (Day 6)

For large test vector sets, use `$readmemh` / `$readmemb` to load stimulus from files:

```verilog
reg [7:0] test_vectors [0:255];
initial $readmemh("test_data.hex", test_vectors);
```

---

## ASIC vs. FPGA: Dual-Target Simulation

This course uses the same Verilog source for both FPGA implementation (iCE40 HX1K) and conceptual ASIC design.  The testbenches are written to be technology-neutral, but there are important differences to understand:

### Behavioral simulation (what we mostly do)

The DUT is your RTL source code.  Combinational logic has zero delay; sequential logic updates on clock edges.  This is identical for ASIC and FPGA — you're simulating your *design intent*.

### Post-synthesis FPGA simulation

After Yosys synthesizes your design into iCE40 primitives, you can simulate the gate-level netlist:

```bash
# Generate gate-level Verilog from Yosys
yosys -p "synth_ice40 -top my_module; write_verilog -noattr gate_level.v" my_module.v

# Simulate with the iCE40 cell library
iverilog -g2012 -o sim.vvp tb_my_module.v gate_level.v \
    $(yosys-config --datdir)/ice40/cells_sim.v

vvp sim.vvp
```

### Post-synthesis ASIC simulation (conceptual)

For an ASIC flow you would target a standard-cell library instead of iCE40 LUTs:

```bash
# (Conceptual — uses generic gates)
yosys -p "synth -top my_module; write_verilog -noattr gate_level.v" my_module.v
iverilog -g2012 -DGATE_LEVEL -o sim.vvp tb_my_module.v gate_level.v
```

### Handling timing differences

Gate-level netlists introduce propagation delays that don't exist in behavioral simulation.  Use conditional compilation to adjust your testbench:

```verilog
`ifdef GATE_LEVEL
    parameter PROP_DELAY = 5;  // ns — adjust for your technology
`else
    parameter PROP_DELAY = 1;  // behavioral: just avoid delta-cycle issues
`endif

// After changing inputs:
#PROP_DELAY;
// Now check outputs
```

The `tb_utils.vh` include file in `shared/lib/` documents this pattern.

---

## Shared Testbench Utilities

The file `shared/lib/tb_utils.vh` provides reusable infrastructure:

| Utility | Purpose |
|---------|---------|
| `check_eq(width, actual, expected, label)` | Assert equality with formatted PASS/FAIL |
| `check_eq_1(actual, expected, label)` | Single-bit convenience wrapper |
| `tb_summary(name)` | Print final pass/fail summary |

Include it with:

```verilog
`include "tb_utils.vh"
```

And compile with the include path:

```bash
iverilog -g2012 -I../../shared/lib -o sim.vvp tb_my_module.v my_module.v
```

---

## GTKWave Tips

- **Zoom to fit**: press `Ctrl+Shift+F` after loading a VCD.
- **Add signals**: drag from the signal list, or use `Edit → Insert Comment` to group signals.
- **Save layout**: `File → Write Save File` to keep your signal arrangement for next time.
- **Color signals**: right-click a signal → `Color` to visually group related signals.
- **Analog display**: for multi-bit buses, right-click → `Data Format → Analog → Step` to see value changes as a waveform.

---

## Testbench Coverage Map

Every lab exercise in the course includes or references a testbench.  Here is the full coverage:

| Day | Exercise | TB File | Pattern |
|-----|----------|---------|---------|
| 1 | Ex 3: button_logic | `tb_button_logic.v` | Exhaustive combinational |
| 2 | Ex 2: mux_hierarchy | `tb_mux.v` | Exhaustive (2:1) + directed (4:1) |
| 2 | Ex 3: ripple_adder | `tb_adder.v` | Exhaustive (FA) + sampled (4-bit) |
| 2 | Ex 4: 7seg_decoder | `tb_hex_to_7seg.v` | Exhaustive (16 values) |
| 3 | Ex 1: latch_bugs | `tb_latch_bugs.v` | Latch detection (X-check) |
| 3 | Ex 2: priority_encoder | `tb_priority_encoder.v` | Exhaustive (16 inputs) |
| 3 | Ex 3: alu | `tb_alu_4bit.v` | Sampled per opcode |
| 4 | Ex 1: d_ff | `ex1_tb_d_ff.v` | Reset + capture sequence |
| 4 | Ex 2: register | `ex2_tb_register.v` | Load/hold/reset |
| 4 | Ex 3: led_blinker | `tb_led_blinker.v` | Toggle count over N cycles |
| 5 | Ex 1: debounce | `tb_debounce.v` | Bounce stimulus + clean output |
| 6 | Ex 1–5 | Multiple | Systematic TB development (student-written) |
| 7 | Ex 1–2 | FSM TBs | State transition verification |
| 8 | Ex 1 | `tb_counter_mod_n.v` | Parameterized rollover |
| 9 | Ex 1–5 | Memory TBs | Read/write/address verification |
| 10 | Ex 2–3 | Arithmetic TBs | Multiplier + fixed-point checks |
| 11 | Ex 1–2 | UART TX TBs | Baud timing + serial decode |
| 12 | Ex 1, 3 | UART RX + SPI TBs | Protocol verification |
| 13 | Ex 1–2 | SV refactor TBs | SystemVerilog typed interfaces |
| 14 | Ex 1–3 | Assertion + AI TBs | SVA + constraint-random |

---

## Workflow Summary

For every exercise:

1. **Read** the exercise spec and understand the expected behavior.
2. **Simulate** — run `make sim` to verify your design against the provided testbench.
3. **Debug** — if tests fail, run `make wave` and inspect waveforms in GTKWave.
4. **Synthesize** — run `make prog` to build and program the FPGA.
5. **Verify on hardware** — confirm physical behavior matches simulation.

If simulation passes but hardware fails, the problem is almost always a timing or pin-mapping issue — not a logic error.  Trust your testbench.
