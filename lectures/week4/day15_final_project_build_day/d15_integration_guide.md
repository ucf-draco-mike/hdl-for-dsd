# Integration Guide — Final Project Build Day
## Day 15 Student Reference Handout

---

## Incremental Integration Checklist

Follow this order. **Do not skip steps.**

### Step 1: Verify Module Library

Every module you plan to reuse must pass its testbench. If you modified a module, re-run its tests.

```bash
# Quick smoke test
for f in tb_*.v tb_*.sv; do
    echo "=== $f ==="
    iverilog -g2012 -o sim.vvp $f $(echo $f | sed 's/tb_//') 2>&1 | head -5
    vvp sim.vvp | tail -5
    echo "---"
done
```

### Step 2: Skeleton Top Module

Write the top module with all Go Board ports but **stub** all internal connections:

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

    // ---- Heartbeat: proves FPGA is configured ----
    logic [23:0] heartbeat;
    always_ff @(posedge i_clk) heartbeat <= heartbeat + 1;
    assign o_led4 = ~heartbeat[23];   // blinks ~1.5 Hz

    // ---- Stub all other outputs ----
    assign o_led1 = 1'b1;
    assign o_led2 = 1'b1;
    assign o_led3 = 1'b1;
    assign o_uart_tx = 1'b1;          // idle high
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = 7'b1111111;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = 7'b1111111;

endmodule
```

**Synthesize and program this IMMEDIATELY.** Heartbeat blinks? Great — your toolchain works.

### Step 3: Add One Module at a Time

For each module:

1. Instantiate in top module
2. Connect inputs (switches, UART RX, or test constants)
3. Connect outputs (LEDs, 7-seg, UART TX) for visibility
4. Synthesize and program
5. Verify on hardware
6. **Only then** add the next module

**Example progression (UART echo project):**

| Step | Add | Verify |
|------|-----|--------|
| 1 | Skeleton + heartbeat | LED4 blinks |
| 2 | Debounce + button → LED | Buttons toggle LEDs cleanly |
| 3 | UART TX + button sends 'A' | Character appears in terminal |
| 4 | UART RX + display on 7-seg | Typed character shows on display |
| 5 | Connect RX → TX (loopback) | Echo works |
| 6 | Command parser FSM | Commands recognized |
| 7 | Full feature integration | Done! |

### Step 4: UART Printf Debugging

When something works in simulation but not on hardware:

```systemverilog
// Send a debug byte when a condition occurs
always_ff @(posedge i_clk) begin
    if (debug_trigger && !uart_busy) begin
        uart_data  <= 8'h41 + {4'b0, state};  // 'A' + state offset
        uart_valid <= 1'b1;
    end else
        uart_valid <= 1'b0;
end
```

Watch the terminal for state codes. This is real industry debugging.

---

## Common Issues & Fixes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Nothing happens after programming | Wrong PCF / pin mismatch | Double-check go_board.pcf pin names |
| LEDs always on or off | Active-low confusion | Go Board LEDs: `0`=on, `1`=off |
| UART shows garbage | Baud rate mismatch | Verify CLK_FREQ parameter matches actual clock |
| Works sometimes, fails randomly | Missing debounce or synchronizer | Add debounce on buttons, 2-FF sync on async inputs |
| Synthesis: "can't fit" | Unexpected logic inference | Check for accidental multiplication or huge muxes |
| Timing fail at 25 MHz | Long combinational path | Pipeline the critical path (Day 10 technique) |

---

## Demo Prep Checklist (for tomorrow)

- [ ] Core functionality works on hardware
- [ ] Block diagram prepared (hand-drawn OK)
- [ ] At least one testbench with pass/fail output
- [ ] Know your resource usage (LUTs, FFs, EBRs)
- [ ] 1-minute reflection prepared: challenges, surprises, learnings
