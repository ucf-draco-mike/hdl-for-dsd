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

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

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

The testbench simulates bouncy press/release sequences. Run it from
the day directory:

```bash
make ex1_sim
```

### Part C: Verify in GTKWave

1. Count transitions on `clean` — should be exactly 2 (one press, one release)
2. Measure delay from input stabilization to clean output transition
3. Change `CLKS_TO_STABLE` to 5 — does bounce sneak through? Why?

- **Earn the flag:** `cd ex1_debounce_module/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex6-updown-counter-e594878da536` (Day 4 Exercise 6's flag).

---

## Exercise 2: Shift Register LED Chase (25 min)

**SLOs: 5.2, 5.5**

Build a "Knight Rider" / Cylon LED pattern using a shift register with direction control.

Use `starter/led_chase.v` — the clock divider and debounce instantiations are provided. You implement the bounce-back shift logic.

```bash
make ex2          # build + program (run from labs/week2_day05/)
```

**Tasks:**
1. Implement the chase logic (shift with direction reversal at walls)
2. Verify the light sweeps back and forth
3. Verify debounced switch2 controls direction cleanly
4. Experiment with tick rate — make it faster, slower

**Extension:** Make the pattern 2 bits wide (two adjacent LEDs lit).

- **Earn the flag:** `cd ex2_led_chase/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

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
make ex3          # build + program (run from labs/week2_day05/)
```

- **Earn the flag:** `cd ex3_button_counter/starter && make test`. Save the printed flag for Exercise 4's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

---

## Exercise 4 (Stretch): LFSR Pattern Generator (20 min)

**SLO: 5.6**

Build `lfsr_8bit.v` — an 8-bit Linear Feedback Shift Register with maximal-length taps.

Use `starter/lfsr_8bit.v`. Create a top module that:
- Clocks the LFSR at ~4 Hz using a tick
- Displays lower 4 bits on 7-seg, upper 4 on LEDs
- Uses a button to pause/resume

**Simulation:** Write a testbench verifying 255-cycle period (returns to seed after exactly 255 enables).

- **Earn the flag:** `cd ex4_lfsr_pattern/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 6 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 3>`

---

## Exercise 5 (Stretch): Shift Register Debounce (20 min)

**SLOs: 5.2, 5.4**

Implement `debounce_shift.v` — an alternative architecture that samples the input into an N-bit shift register at a slow rate. If all N bits agree, the input is stable.

**Comparison task:** Which approach (counter vs. shift register) uses more resources? Which responds faster? Which is easier to tune?

- **Note:** This exercise isn't in the CTF chain — it's a paper/comparison stretch with no `starter/` directory under `labs/week2_day05/`, so there's no `make test` flag to capture for it. Keep using Exercise 4's flag (the flag from that exercise's `make test`) to unlock Day 6 Exercise 1's reference.

---

## Build Commands Quick Reference

```bash
# ── from labs/week2_day05/ ──
make ex1                             # build/sim ex1 (debounce module)
make ex2                             # build + program ex2 (led chase)
make ex3                             # build + program ex3 (button counter)
make ex4                             # build + program ex4 (LFSR, stretch)
make exN_sim                         # simulate exercise N
make exN_wave                        # open GTKWave for exercise N
make exN_stat                        # resource usage for exercise N
make clean                           # remove build artifacts

# ── from labs/week2_day05/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
