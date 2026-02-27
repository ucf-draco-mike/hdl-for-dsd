# Day 15: Integration Strategy Guide

## The #1 Rule: No Big Bang Integration

Writing all modules, connecting them all at once, and hoping it works → **it never works.**
You get a wall of errors, no idea which module is broken, and no path forward.

---

## Step-by-Step Integration Checklist

### Step 1: Verify Your Module Library

Every module you plan to reuse must pass its testbench. If you modified a module, re-run tests.

```bash
# Quick smoke test
for tb in tb_*.sv; do
    echo "--- Testing: $tb ---"
    iverilog -g2012 -o sim.vvp $tb *.sv 2>&1 | head -5
    vvp sim.vvp | tail -3
done
```

### Step 2: Create a Skeleton Top Module

All ports declared, all outputs stubbed, heartbeat LED proving the FPGA runs:

```systemverilog
module top_project (
    input  logic i_clk,
    input  logic i_switch1, i_switch2, i_switch3, i_switch4,
    input  logic i_uart_rx,
    output logic o_uart_tx,
    output logic o_led1, o_led2, o_led3, o_led4,
    output logic o_segment1_a, o_segment1_b, o_segment1_c,
    output logic o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output logic o_segment2_a, o_segment2_b, o_segment2_c,
    output logic o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);
    // Heartbeat — proves FPGA is configured
    logic [23:0] heartbeat;
    always_ff @(posedge i_clk) heartbeat <= heartbeat + 1;
    assign o_led4 = ~heartbeat[23];

    // Stub all other outputs
    assign o_led1 = 1'b1;  assign o_led2 = 1'b1;  assign o_led3 = 1'b1;
    assign o_uart_tx = 1'b1;  // idle high
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = 7'b1111111;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = 7'b1111111;
endmodule
```

**Synthesize and program this FIRST.** Verify heartbeat blinks. Then add modules one at a time.

### Step 3: Add One Module at a Time

For each module:
1. Instantiate it
2. Connect inputs to real signals (or switches for manual testing)
3. Connect outputs to LEDs or 7-seg for visibility
4. Synthesize and program
5. Verify on hardware
6. **Only then** add the next module

### Step 4: UART Printf Debugging

When hardware misbehaves and simulation doesn't reproduce it:

```systemverilog
// Send internal state over UART when debug button pressed
always_ff @(posedge i_clk) begin
    if (w_debug_press && !w_tx_busy) begin
        debug_valid <= 1'b1;
        debug_data  <= {4'h0, state};  // current state as ASCII-ish byte
    end else
        debug_valid <= 1'b0;
end
```

---

## Common Integration Issues — Quick Fixes

| Problem | Fix |
|---|---|
| Port widths don't match | Check `$clog2` calculations; use explicit width parameters |
| Signal driven by two sources | Check for double-assignment; `logic` type catches this |
| "Net is not found" | Check instance port names: `.i_clk(i_clk)` not `.clk(i_clk)` |
| Timing failure | Simplify critical path; check resource usage |
| UART sends garbage | Check baud rate parameter matches terminal (115200) |
| Debounce not working | Check `CLKS_TO_STABLE` matches clock frequency (25 MHz) |
| FSM stuck in one state | Check transition conditions; add debug LED showing state bits |
| Memory contents wrong | Check `$readmemh` file path; verify hex file format |
| 7-seg shows wrong digit | Segments are active LOW on Go Board |
| "Design does not fit" | Check `yosys stat`; reduce memory or logic |

---

## Minimum Viable Demo Targets

If you're behind schedule, aim for the minimum viable version:

| Project | Minimum Viable Demo |
|---|---|
| UART Command Parser | LED control + echo via UART |
| Digital Clock/Timer | Stopwatch with start/stop/reset on 7-seg |
| Pattern Sequencer | Play pre-loaded patterns; speed via buttons |
| SPI Sensor | Read sensor, display on 7-seg |
| VGA Display | Static text on VGA monitor |
| Simple Processor | Fetch + execute ADD/LOAD, result on LEDs |

**Something must work on hardware by tomorrow.**
