# Day 4: Sequential Logic — Flip-Flops, Clocks & Counters

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 4 of 16

---

## Student Learning Objectives

1. **SLO 4.1:** Design edge-triggered sequential circuits using `always @(posedge clk)` and nonblocking assignment (`<=`).
2. **SLO 4.2:** Implement D flip-flops with synchronous/asynchronous reset and enable.
3. **SLO 4.3:** Build counters and clock dividers to generate timing from the 25 MHz Go Board clock.
4. **SLO 4.4:** Apply RTL thinking: every `<=` is a flip-flop, every `=` in `always @(*)` is combinational.
5. **SLO 4.5:** Verify sequential designs in simulation (Icarus + GTKWave) before programming hardware.

---

## Pre-Class Video (~50 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Clocks & edge-triggered logic: `always @(posedge clk)` | 12 min | `video/day04_seg1_clocks_edges.mp4` |
| 2 | Nonblocking assignment deep dive: `<=` vs `=` in sequential blocks | 15 min | `video/day04_seg2_nonblocking_deep_dive.mp4` |
| 3 | FF variants: with enable, with load, with synchronous/asynchronous reset | 10 min | `video/day04_seg3_ff_variants.mp4` |
| 4 | Counters & clock dividers: counting cycles to generate slower events | 13 min | `video/day04_seg4_counters_dividers.mp4` |

**Key concepts:**
- `always @(posedge clk)` creates edge-triggered flip-flops — this is how hardware gains memory
- `<=` (nonblocking) in sequential blocks: all right-hand sides evaluated first, then all left-hand sides updated simultaneously
- `=` (blocking) in sequential blocks causes subtle ordering bugs — avoid it
- RTL mental model: count the `<=` assignments to know how many flip-flops you're creating

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up Q&A: combinational vs sequential, pre-class questions | 5 min |
| 0:05 | Mini-lecture: FF variations, counters, clock divider concept, live demo | 30 min |
| 0:35 | Lab Exercise 1: D flip-flop | 15 min |
| 0:50 | Lab Exercise 2: Loadable register | 15 min |
| 1:05 | Lab Exercise 3: Free-running counters | 15 min |
| 1:20 | Break | 5 min |
| 1:25 | Lab Exercise 4: LED blinker — clock divider | 20 min |
| 1:45 | Lab Exercise 5: Dual-speed blinker | 10 min |
| 1:55 | Lab Exercise 6 (Stretch): Up/down counter on 7-seg | 15 min |
| 2:10 | Debrief: RTL thinking discussion, common bugs | 10 min |
| 2:20 | Week 1 recap + Preview Day 5 | 10 min |

---

## In-Class Mini-Lecture (30 min)

### FF Variations (10 min)
- Basic D-FF: `always @(posedge clk) q <= d;` — that's it, one line, one flip-flop
- With synchronous reset: `if (reset) q <= 0; else q <= d;`
- With asynchronous reset: `always @(posedge clk or posedge reset)` — when to use which?
- With enable: `if (en) q <= d;` — what happens when `en` is low? (Holds value — implicit feedback)
- With load: separate `load` and `d` signals for register-file style behavior

### Counter as Canonical Sequential Block (10 min)
- Up counter: `count <= count + 1;`
- Modulo-N: `if (count == N-1) count <= 0; else count <= count + 1;`
- Terminal count output: `assign tc = (count == N-1);` — useful for chaining
- Rollover: what happens at the maximum value for the declared width?

### Clock Divider Concept (5 min)
- 25 MHz ÷ 25,000,000 = 1 Hz — counting to a big number to create a slow event
- The toggle pattern: use a counter to generate a slower enable pulse, toggle an output
- The math: `HALF_PERIOD = clk_freq / (2 * desired_freq)`

### Live Demo (5 min)
- Build a visible LED blinker from the 25 MHz clock — ~10 lines of code
- Simulate first (with small counter values), then synthesize with real values
- "If it doesn't blink in simulation, it won't blink on hardware"

---

## Lab Exercises

### Exercise 1: D Flip-Flop (15 min)

**Objective (SLO 4.1, 4.5):** Implement the fundamental sequential element and verify it in simulation before hardware.

**Tasks:**
1. Create `dff.v` with `input clk, d, reset` and `output reg q`.
2. Implement with synchronous reset: on `posedge clk`, if `reset` then `q <= 0`, else `q <= d`.
3. Write a basic testbench (`dff_tb.v`):
   - Generate a clock: `always #5 clk = ~clk;` (10 time-unit period)
   - Apply reset, then toggle `d` at various times
   - Dump waveforms with `$dumpfile` / `$dumpvars`
4. Run with Icarus: `iverilog -o dff_tb dff.v dff_tb.v && vvp dff_tb`
5. Open waveform in GTKWave. Verify `q` changes only on rising clock edges and `d` is captured correctly.
6. Synthesize and test on the Go Board: button → D input, LED → Q output. Observe the "sampling" behavior.

**Checkpoint:** Waveform shows correct edge-triggered behavior. LED on hardware reflects button state only at clock edges.

---

### Exercise 2: 4-Bit Loadable Register (15 min)

**Objective (SLO 4.2):** Build a register with synchronous reset and parallel load — a workhorse building block.

**Tasks:**
1. Create `register.v` with `input clk, reset, load, input [3:0] d, output reg [3:0] q`.
2. Priority: reset (highest) → load → hold.
3. Simulate: load a pattern, verify it holds. Assert reset, verify it clears. Load a new pattern.
4. Synthesize and test: use buttons for load/data, display `q` on LEDs or 7-seg.

**Checkpoint:** Register loads, holds, and resets correctly in both simulation and hardware.

---

### Exercise 3: Free-Running Counters (15 min)

**Objective (SLO 4.3, 4.4):** Build counters of different widths and observe rollover behavior.

**Tasks:**
1. Create counters at three widths: 8-bit, 16-bit, and 24-bit.
2. Simulate all three. Observe:
   - 8-bit: rolls over at 255 → 0 (visible in waveform)
   - 16-bit and 24-bit: rollover happens, but at much larger values
3. Connect the upper bits of different counters to LEDs on the Go Board. Which counter's LEDs change visibly? (The 24-bit counter's upper bits change slowly enough to see.)
4. **RTL thinking exercise:** How many flip-flops does each counter use? (Answer: exactly the width.) Verify with `yosys stat`.

**Checkpoint:** All three counters simulate correctly. Student can predict flip-flop count before checking `yosys stat`.

---

### Exercise 4: LED Blinker — Clock Divider (20 min)

**Objective (SLO 4.3, 4.5):** The canonical first sequential project — make an LED blink at a human-visible rate.

**Tasks:**
1. Create `blinker.v`: a counter that counts from 0 to a threshold, then toggles an LED output.
2. **Parameterize the threshold:** `parameter HALF_PERIOD = 12_500_000;` (0.5 seconds at 25 MHz, giving 1 Hz blink).
3. **Simulate first** with a small threshold (e.g., `HALF_PERIOD = 5`) to verify the toggle logic without waiting millions of cycles.
4. Synthesize with the real threshold. Program the Go Board.
5. Verify: LED blinks at approximately 1 Hz (one second on, one second off).

**Checkpoint:** LED blinks at visible ~1 Hz rate on hardware. Simulation waveform confirms toggle behavior.

---

### Exercise 5: Dual-Speed Blinker (10 min)

**Objective (SLO 4.3):** Instantiate multiple independent sequential modules.

**Tasks:**
1. Create a top module that instantiates two blinker modules with different `HALF_PERIOD` values.
2. LED 0: blinks at ~1 Hz. LED 1: blinks at ~4 Hz.
3. Observe: the two LEDs blink independently — they are separate hardware, running concurrently.

**Checkpoint:** Two LEDs blinking at visibly different rates on the Go Board.

---

### Exercise 6 (Stretch): Up/Down Counter on 7-Seg (15 min)

**Objective (SLO 4.2, 4.3):** Integrate sequential logic with the Day 2 hex display.

**Tasks:**
1. Build a 4-bit counter with a debounced button for up-count and another for down-count. (For now, a simple FF synchronizer is sufficient — full debouncer comes Day 5.)
2. Display the count on the 7-segment display using the `hex_to_7seg` module from Day 2.
3. Counter wraps: 0→F on down, F→0 on up.

---

## Deliverable

LED blinker at visible rate (~1 Hz) + counter value displayed on 7-seg (Exercise 4 required; Exercise 6 if completed).

**Submit:** Blinker source file, testbench with waveform dump, and top module.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — D flip-flop | 4.1, 4.5 | Core |
| 2 — Loadable register | 4.2 | Core |
| 3 — Free-running counters | 4.3, 4.4 | Core |
| 4 — LED blinker | 4.3, 4.5 | Core — graded deliverable |
| 5 — Dual-speed blinker | 4.3 | Core |
| 6 — Up/down counter on 7-seg | 4.2, 4.3 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> Day 4 is your first day with sequential logic and clocked designs. The mental model shifts from "circuits settle instantly" to "things happen on clock edges."

- **Using `=` instead of `<=` in `always @(posedge clk)`?** This is the single most common sequential logic bug. `=` (blocking) evaluates top-to-bottom like software. `<=` (non-blocking) updates all registers simultaneously at the clock edge — which is what real flip-flops do. If your multi-register design behaves strangely, check this first.
- **Clock signal stays X in simulation?** The clock generator pattern `always #5 clk = ~clk;` requires initialization: `reg clk = 0;`. Without the initializer, `clk` starts as X, and `~X` is still X. Your simulation will hang.
- **Blinker simulates in microseconds but takes seconds on hardware?** Simulation is event-driven — it skips idle time between clock edges. The real clock runs at 25 MHz, so counting to 12,500,000 takes 0.5 real seconds. This isn't a bug.
- **Counter hits max and... nothing happens?** Hardware wraps silently. An 8-bit counter at 255 goes to 0 on the next increment. There's no exception, no error — just rollover. If you need to detect overflow, you must build that logic yourself.
- **`$dumpfile` giving a syntax error?** It must go inside an `initial` block, not at module scope. Use this pattern: `initial begin $dumpfile("dump.vcd"); $dumpvars(0, tb_name); end`
- **Feeling shaky on `=` vs `<=` or combinational vs sequential?** That's normal at this point. These concepts solidify with practice over Week 2. But if you're confused, ask now — these fundamentals must be solid before you move on.
---

## Preview: Day 5

Counters, shift registers, and debouncing — the building blocks you'll need for every design going forward. You'll build a reusable debouncer module, learn about metastability (and why it's terrifying), and create an LED chase pattern controlled by buttons. Watch the Day 5 video (~45 min).
