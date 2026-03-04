# Day 5 Lab: Counters, Shift Registers & Debouncing

## Course: Accelerated HDL for Digital System Design — Week 2, Session 5

---

## Objectives

By the end of this lab, you will:
- Build a reusable, parameterized debounce module with built-in 2-FF synchronizer
- Construct a shift-register-based LED chase pattern on the Go Board
- Prove that debouncing works by building a reliable button counter
- (Stretch) Build an LFSR pseudo-random pattern generator

## Prerequisites

- Completed Week 1 labs (combinational + sequential fundamentals)
- Watched Day 5 pre-class video (~45 min): counters, shift registers, metastability
- `hex_to_7seg.v` from Day 2 (provided in `starter/`)

## Deliverables

| # | Exercise | Time | What to Submit |
|---|----------|------|----------------|
| 1 | Debounce Module | 30 min | `debounce.v` + `tb_debounce.v` + GTKWave screenshot |
| 2 | LED Chase | 25 min | `led_chase.v` working on Go Board |
| 3 | Button Counter | 25 min | `button_counter.v` — clean count + erratic count comparison |
| 4 | LFSR (stretch) | 20 min | `lfsr_8bit.v` + testbench verifying 255-cycle period |
| 5 | Shift Debounce (stretch) | 20 min | `debounce_shift.v` + comparison analysis |

**Primary deliverable:** Debounced button-controlled LED chase pattern on the Go Board.

---

## Exercise 1: Debounce Module — Build and Simulate (30 min)

**SLOs: 5.3, 5.4**

### Part A: Build `debounce.v`

Create the counter-based debounce module from the pre-class video. Requirements:
- Built-in 2-FF synchronizer (input can be fully asynchronous)
- Parameterized `CLKS_TO_STABLE` (default 250,000 = ~10 ms at 25 MHz)
- When synchronized input differs from clean output, count up
- If count reaches threshold, accept the new value
- If input bounces back before threshold, reset counter

Use the starter file in `starter/debounce.v` — fill in the `YOUR CODE HERE` sections.

### Part B: Simulate with `tb_debounce.v`

The testbench simulates bouncy press/release sequences. Run it:

```bash
make sim TB=tb_debounce.v SRCS="debounce.v"
```

### Part C: Verify in GTKWave

1. Count transitions on `clean` — should be exactly 2 (one press, one release)
2. Measure delay from input stabilization to clean output transition
3. Change `CLKS_TO_STABLE` to 5 — does bounce sneak through? Why?

---

## Exercise 2: Shift Register LED Chase (25 min)

**SLOs: 5.2, 5.5**

Build a "Knight Rider" / Cylon LED pattern using a shift register with direction control.

Use `starter/led_chase.v` — the clock divider and debounce instantiations are provided. You implement the bounce-back shift logic.

```bash
make PROJECT=led_chase TOP=led_chase SRCS="led_chase.v debounce.v"
make prog PROJECT=led_chase
```

**Tasks:**
1. Implement the chase logic (shift with direction reversal at walls)
2. Verify the light sweeps back and forth
3. Verify debounced switch2 controls direction cleanly
4. Experiment with tick rate — make it faster, slower

**Extension:** Make the pattern 2 bits wide (two adjacent LEDs lit).

---

## Exercise 3: Debounced Button Counter (25 min)

**SLOs: 5.4, 5.5**

The definitive test: prove debouncing works by building a press counter.

Use `starter/button_counter.v` — provided complete (this is the reference integration).

### The Test Protocol

1. **With debounce:** Press button 16 times slowly. Display should count 0→1→2→...→F→0 cleanly.
2. **Without debounce:** Modify to bypass debounce (use direct sync only). Repeat. Record the erratic count.
3. **Record:** "With debounce: 16 presses → count reached 0 (wrapped). Without: 16 presses → count reached [X]."

```bash
make PROJECT=button_counter TOP=button_counter \
     SRCS="button_counter.v debounce.v hex_to_7seg.v"
make prog PROJECT=button_counter
```

---

## Exercise 4 (Stretch): LFSR Pattern Generator (20 min)

**SLO: 5.6**

Build `lfsr_8bit.v` — an 8-bit Linear Feedback Shift Register with maximal-length taps.

Use `starter/lfsr_8bit.v`. Create a top module that:
- Clocks the LFSR at ~4 Hz using a tick
- Displays lower 4 bits on 7-seg, upper 4 on LEDs
- Uses a button to pause/resume

**Simulation:** Write a testbench verifying 255-cycle period (returns to seed after exactly 255 enables).

---

## Exercise 5 (Stretch): Shift Register Debounce (20 min)

**SLOs: 5.2, 5.4**

Implement `debounce_shift.v` — an alternative architecture that samples the input into an N-bit shift register at a slow rate. If all N bits agree, the input is stable.

**Comparison task:** Which approach (counter vs. shift register) uses more resources? Which responds faster? Which is easier to tune?

---

## Build Commands Quick Reference

```bash
make sim TB=tb_debounce.v SRCS="debounce.v"         # Simulate
make wave                                              # Open GTKWave
make PROJECT=led_chase SRCS="led_chase.v debounce.v"  # Synthesize
make prog PROJECT=led_chase                            # Program board
make stat PROJECT=led_chase SRCS="led_chase.v debounce.v"  # Resources
```
