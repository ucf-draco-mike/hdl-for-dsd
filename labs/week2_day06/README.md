# Day 6 Lab: Testbenches & Simulation-Driven Development

## Course: Accelerated HDL for Digital System Design — Week 2, Session 6

---

## Objectives

By the end of this lab, you will:
- Write a comprehensive self-checking testbench with automated pass/fail reporting
- Use `task` blocks to organize test stimulus and checking
- Apply file-driven testing with `$readmemh`
- Demonstrate exhaustive testing of a small combinational module

## Prerequisites

- Completed Days 1–5 labs (ALU from Day 3, debounce from Day 5)
- Watched Day 6 pre-class video (~50 min): testbench anatomy, self-checking patterns
- Copy your `alu_4bit.v` from Day 3 (or use the provided version)

## Key Rule: The Verification Contract

**From today forward, every lab deliverable must include:**
1. The design module(s)
2. A self-checking testbench with pass/fail output
3. A passing test report (terminal output screenshot)
4. Only after tests pass: the hardware demo

## Deliverables

| # | Exercise | Time | What to Submit |
|---|----------|------|----------------|
| 1 | ALU Testbench | 35 min | `tb_alu_4bit.v` — all tests pass + bug injection demo |
| 2 | Debounce Testbench | 25 min | `tb_debounce_thorough.v` — 4 scenarios pass |
| 3 | Counter Testbench | 20 min | `tb_counter.v` — rollover, reset, enable verified |
| 4 | File-Driven TB (stretch) | 15 min | `tb_hex_file.v` + `hex_vectors.hex` |
| 5 | Exhaustive Test (stretch) | 20 min | 1024 vectors, 0 failures |

**Primary deliverable:** Self-checking ALU testbench with automated pass/fail report.

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

---

## Exercise 1: Self-Checking ALU Testbench (35 min)

**SLOs: 6.1, 6.2, 6.3, 6.6**

### Part A: Create `tb_alu_4bit.v`

Use the starter file. Implement the `check_alu` task and complete the test vectors.

Requirements:
1. Clock generation (practice the pattern for sequential designs)
2. Waveform dump (`$dumpfile`/`$dumpvars`)
3. `check_alu` task: apply inputs, wait, compare result/carry/zero, report pass/fail
4. Final summary with total pass/fail counts

### Part B: Run and verify all tests pass

```bash
make ex1_sim          # from labs/week2_day06/
```

### Part C: Intentional bug injection

Change SUB to `a + b` in the ALU. Re-run the testbench. Confirm SUB tests fail.

- **Earn the flag:** `cd ex1_alu_testbench/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex4-lfsr-pattern-177caf99dffa` (Day 5 Exercise 4's flag).

---

## Exercise 2: Debounce Module Testbench (25 min)

**SLOs: 6.2, 6.6**

Write `tb_debounce_thorough.v` with four test scenarios:
1. **Clean press:** Input settles low, verify `o_clean` transitions after threshold
2. **Bounce rejection:** 6+ toggles within threshold window, verify single transition
3. **Glitch rejection:** Input low for less than threshold, verify no transition
4. **Clean release:** After stable press, verify release transition

- **Earn the flag:** `cd ex2_debounce_testbench/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

---

## Exercise 3: Counter Testbench (20 min)

**SLOs: 6.2, 6.3**

Write `tb_counter.v` for a simple 4-bit counter. Verify:
1. Reset sets count to 0
2. Counter increments each enabled clock
3. Rollover from F to 0
4. Enable=0 holds the count

- **Earn the flag:** `cd ex3_counter_testbench/starter && make test`. Save the printed flag for Exercise 4's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

---

## Exercise 4 (Stretch): File-Driven Testing (15 min)

**SLO: 6.4**

Use `$readmemh` to load test vectors from `hex_vectors.hex`. Verify the hex-to-7seg decoder against file-based expected outputs.

- **Earn the flag:** `cd ex4_file_driven_testing/starter && make test`. Save the printed flag for Exercise 5's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 3>`

---

## Exercise 5 (Stretch): Exhaustive Combinational Test (20 min)

**SLO: 6.2**

Test all 1024 ALU input combinations (4-bit a × 4-bit b × 2-bit opcode). Report: "Tested 1024 combinations, 0 failures."

- **Earn the flag:** `cd ex5_exhaustive_alu/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 7 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 4>`

---

## Build Commands Quick Reference

```bash
# ── from labs/week2_day06/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
