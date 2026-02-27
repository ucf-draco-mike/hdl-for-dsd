# Day 15: Final Project Build Day

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 15 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 15.1:** Integrate multiple previously developed and tested modules into a complete system, resolving interface mismatches and signal-width conflicts during integration.
2. **SLO 15.2:** Apply a systematic top-down integration strategy: stub modules first, integrate one module at a time, and verify incrementally rather than connecting everything at once.
3. **SLO 15.3:** Synthesize a complete multi-module design, interpret the Yosys resource report, and confirm timing closure with nextpnr.
4. **SLO 15.4:** Debug integration issues using a combination of simulation (GTKWave), synthesis warnings, and hardware observation (LED indicators and UART printf-style debugging).
5. **SLO 15.5:** Demonstrate a minimum viable version of the final project on hardware, even if stretch features are incomplete.

---

## Session Structure

This is a structured work session, not a traditional lecture. The class time is divided into:

| Time | Activity |
|---|---|
| 0:00–0:15 | Integration strategy briefing |
| 0:15–0:45 | Individual check-ins (Mike circulates) |
| 0:45–2:00 | Independent build time with on-call support |
| 2:00–2:15 | Status round and tomorrow prep |
| 2:15–2:30 | Buffer / overflow debugging |

---

## Opening Briefing: Integration Strategy (15 min)

### The Integration Trap

The #1 failure mode on project day: **Big Bang Integration** — writing all the modules, connecting them all at once, and hoping it works. It never works. You get a wall of errors, no idea which module is broken, and no path forward.

### Incremental Integration Checklist

Follow this order. Do not skip steps.

**Step 1: Verify your module library (should be done already)**

Every module you plan to reuse should pass its testbench. If you modified a module for the project, re-run its testbench.

```bash
# Quick smoke test of all modules
for tb in tb_debounce tb_uart_tx tb_uart_rx tb_hex_to_7seg tb_counter_mod_n; do
    iverilog -g2012 -o sim.vvp ${tb}.v ${tb%.tb_*}.sv *.sv 2>&1 | head -5
    vvp sim.vvp | tail -3
    echo "---"
done
```

**Step 2: Create a skeleton top module**

Write the top module with all ports but stub internal connections:

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

    // Heartbeat — proves the FPGA is configured and running
    logic [23:0] heartbeat;
    always_ff @(posedge i_clk) heartbeat <= heartbeat + 1;
    assign o_led4 = ~heartbeat[23];

    // Stub all other outputs
    assign o_led1 = 1'b1;  // off (active low)
    assign o_led2 = 1'b1;
    assign o_led3 = 1'b1;
    assign o_uart_tx = 1'b1;  // idle high
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = 7'b1111111;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = 7'b1111111;

endmodule
```

**Synthesize and program this immediately.** Verify the heartbeat LED blinks. This proves your toolchain, PCF, and FPGA are all working before you add complexity.

**Step 3: Add one module at a time**

For each module:
1. Instantiate it in the top module
2. Connect its inputs to real signals (or switches for manual testing)
3. Connect its outputs to LEDs or 7-seg for visibility
4. Synthesize and program
5. Verify the module works on hardware
6. Only then add the next module

**Example progression for a UART echo project:**
1. Skeleton + heartbeat ✓
2. Add debounce + button-driven LED → verify buttons work
3. Add UART TX + button sends 'A' → verify in terminal
4. Add UART RX + display received byte on 7-seg → verify receive
5. Connect RX output to TX input → verify loopback
6. Add command parser FSM → verify command recognition
7. Add any project-specific features

**Step 4: UART printf debugging**

When hardware doesn't behave as expected and you can't simulate the exact scenario, use UART TX as a debug port:

```systemverilog
// Debug: send state value over UART when button pressed
always_ff @(posedge i_clk) begin
    if (w_debug_btn_press && !w_tx_busy) begin
        debug_tx_valid <= 1'b1;
        debug_tx_data  <= {4'h0, state};  // send current state as a byte
    end else begin
        debug_tx_valid <= 1'b0;
    end
end
```

This is the FPGA equivalent of `printf` debugging. It's crude but effective.

---

## Individual Check-Ins (30 min)

Mike visits each student for a 3–5 minute status check:

### Check-In Template

1. **Current status:** What's working? What's not?
2. **Block diagram review:** Walk through the design. Are all modules identified?
3. **Critical path:** What's the hardest remaining task? Can it be simplified?
4. **Scope check:** Will you finish a demonstrable version by tomorrow? If not, what's the minimum viable demo?
5. **Immediate blockers:** Anything you're stuck on right now?

### Common Issues and Quick Fixes

| Problem | Quick Fix |
|---|---|
| Module port widths don't match | Check `$clog2` calculations; use explicit width parameters |
| Signal driven by two sources | Check for accidental double-assignment; use `logic` to catch |
| Synthesis error: "Net is not found" | Check instance port names; `.i_clk(i_clk)` not `.clk(i_clk)` |
| Timing failure | Check resource usage; simplify critical path; consider pipeline |
| UART sends garbage | Check baud rate parameter matches terminal; verify MSB/LSB order |
| Debounce not working | Check `CLKS_TO_STABLE` parameter matches clock frequency |
| FSM stuck in one state | Check transition conditions; add debug LED showing state bits |
| Memory contents wrong | Check `$readmemh` file path; verify file format |
| 7-seg shows wrong digit | Check segment polarity (active low on Go Board) |
| "Design does not fit" | Check resource usage in `stat`; reduce memory or logic |

---

## Final Project Options (Reference)

Students selected their project on Day 12. This is a reference list:

### Option A: UART Command Parser (Moderate)

A PC-controlled system. The FPGA receives single-character commands over UART and responds:

- **LED control:** 'R'/'G'/'B'/'W' commands set LED patterns
- **Counter display:** 'C' command displays a counter value on 7-seg; '+'/'-' increment/decrement
- **Status query:** '?' command sends the current state back to the PC via UART
- **Echo mode:** 'E' toggles echo on/off
- **Help:** 'H' sends a help string listing all commands

**Modules needed:** `debounce`, `uart_tx`, `uart_rx`, `hex_to_7seg`, command parser FSM (new), string sender (new or adapted from Day 11 Exercise 3)

**Minimum viable:** LED control + echo work via UART

### Option B: Digital Clock / Timer (Moderate)

A clock or countdown timer displayed on the 7-segment displays:

- **Stopwatch mode:** Start/stop/reset via buttons; displays seconds on 7-seg
- **Countdown timer:** Preset a time, count down, trigger alarm (LED/buzzer pattern) at zero
- **UART display:** Periodically sends the time to PC terminal in human-readable format
- **Lap timer:** Button press records the current time and sends it via UART

**Modules needed:** `debounce`, `counter_mod_n`, `hex_to_7seg`, `uart_tx`, BCD counter (new), time formatter (new), mode FSM (new)

**Minimum viable:** Stopwatch with start/stop/reset on 7-seg displays

### Option C: Pattern Generator / Sequencer (Moderate)

A programmable LED pattern sequencer with UART-based programming:

- **Playback:** Steps through patterns stored in RAM at adjustable speed
- **Record:** Button-press sequences are recorded into RAM
- **UART programming:** PC sends pattern data to load into RAM
- **Multiple sequences:** Switch between stored pattern banks

**Modules needed:** `debounce`, `uart_tx`, `uart_rx`, `ram_sp`, `hex_to_7seg`, sequencer FSM (new), UART-to-RAM loader (new)

**Minimum viable:** Plays back pre-loaded patterns; speed adjustable via buttons

### Option D: SPI Sensor Interface (Challenging)

Interface with an external SPI sensor (e.g., accelerometer, temperature sensor) via the PMOD connector:

- **SPI master:** Reads sensor data at configurable rate
- **Display:** Current reading on 7-seg displays
- **UART logging:** Streams readings to PC for graphing
- **Threshold alert:** LED triggers when reading exceeds a threshold

**Modules needed:** `debounce`, `spi_master`, `uart_tx`, `hex_to_7seg`, sensor controller FSM (new), threshold comparator (new)

**Minimum viable:** SPI reads sensor data and displays on 7-seg

### Option E: VGA Pattern Display (Challenging)

Generate VGA output displaying text or patterns:

- **VGA timing generator:** 640×480 @ 60 Hz (requires 25.175 MHz pixel clock — 25 MHz is close enough)
- **Character display:** ROM-based font, display a message on screen
- **UART input:** Received characters appear on the VGA display
- **Color control:** Foreground/background color selection via buttons

**Modules needed:** VGA timing generator (new), character ROM, frame buffer RAM, `uart_rx`, text position controller (new)

**Minimum viable:** Static text message displayed on VGA monitor

### Option F: Simple Processor (Very Challenging)

A minimal 8-bit processor executing instructions from ROM:

- **ALU:** 8-bit with add, sub, and, or, xor operations
- **Register file:** 4 or 8 general-purpose registers
- **Instruction ROM:** Loaded from `.hex` file
- **Program counter + FSM:** Fetch-decode-execute cycle
- **I/O:** LED and 7-seg output mapped to memory addresses

**Modules needed:** ALU, register file, instruction ROM, PC, decode FSM (all new or heavily adapted), `hex_to_7seg`

**Minimum viable:** Fetches and executes ADD/SUB/LOAD instructions; result visible on LEDs

---

## Status Round (15 min)

At 2:00, each student gives a 30-second status update to the class:

1. "My project is [name]. Right now [module X] works. I'm currently working on [module Y]. My biggest risk is [Z]. I expect to have [minimum viable demo] ready for tomorrow."

This serves three purposes:
- **Accountability:** Public commitment to a specific plan
- **Peer learning:** Students hear how others approach integration problems
- **Early warning:** Mike identifies students who need extra support before tomorrow

---

## Tomorrow: Demo Day Preparation

### Demo Format (Day 16)

- **Duration:** 5–7 minutes per student
- **Structure:**
  1. Brief description: What does your project do? (30 sec)
  2. Live hardware demo: Show it working on the Go Board (2 min)
  3. Architecture walk-through: Show your block diagram, explain the design decisions (1–2 min)
  4. Verification: Show your testbench output and/or assertions (1 min)
  5. Reflection: What worked well? What would you do differently? What did you learn? (1 min)
  6. Q&A (remaining time)

### Evaluation Criteria

| Category | Weight | Description |
|---|---|---|
| **Functionality** | 30% | Does the design work as described? Hardware demo. |
| **Design quality** | 25% | Clean architecture, appropriate use of FSMs/modules/parameters, reasonable resource usage |
| **Verification** | 20% | Testbench quality, assertions, coverage awareness, self-checking |
| **Integration** | 15% | Clean top module, proper signal connections, no hacks |
| **Presentation** | 10% | Clear explanation, honest reflection, good use of time |

### What to Prepare Tonight

1. **Finish the minimum viable demo.** Something must work on hardware.
2. **Prepare your block diagram** — clean version for presentation (hand-drawn is fine if it's clear)
3. **Run your testbenches one final time** — make sure they pass
4. **Synthesize and check timing** — know your resource usage and Fmax
5. **Prepare a 1-minute reflection** — what surprised you? What's the most interesting thing you learned?

---

## Instructor Notes

- **This session is 90% individual work time.** Resist the urge to lecture. The opening briefing should be exactly 15 minutes — students need build time, not more content.
- **The check-ins are the most important thing you do today.** 3–5 minutes per student to catch scope problems, identify blockers, and adjust expectations. Students who are behind need a clear minimum viable target. Students who are ahead can be pushed toward stretch goals.
- **Scope management is critical.** Many students will be behind where they hoped. Your job is to help them define a demonstrable subset: "If you can get UART echo working with one command ('H' prints 'Hello'), that's a solid demo. The full command parser is stretch."
- **Common late-stage panics:**
  - "It works in simulation but not on hardware" → Check pin mappings, debounce, and clock frequency parameters. Add debug LEDs.
  - "I can't fit it" → Check `stat` output. Are they using too much memory? Too many LUTs? Often caused by synthesis inferring unexpected logic.
  - "Timing fails" → Usually fine at 25 MHz. If not, check for extremely long combinational paths (e.g., very wide multipliers or deep priority encoders).
  - "I haven't started" → Help them identify the simplest possible demo and pair them with a nearby student for moral support.
- **The status round** at the end is deliberately public. Peer pressure is a powerful motivator. It also lets you identify which students need a check-in email tonight.
- **Don't solve students' bugs for them.** Guide them to the debugging technique (simulation, assertion, LED indicator, UART debug) and let them find the bug themselves. The debugging skill is as important as the design skill.
