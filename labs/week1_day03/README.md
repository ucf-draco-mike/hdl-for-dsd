# Day 3 Lab: Procedural Combinational Logic

> **Week 1, Session 3** · Accelerated HDL for Digital System Design · UCF ECE

## Overview

| | |
|---|---|
| **Duration** | ~2 hours |
| **Prerequisites** | Pre-class video (45 min): `always @(*)`, if/else, case, latch inference, blocking assignment |
| **Deliverable** | Mini-ALU with result on 7-segment, opcode selected by buttons |
| **Tools** | Yosys (critical for latch warnings!), nextpnr, iverilog |

## Learning Objectives

| SLO | Description |
|-----|-------------|
| 3.1 | Write `always @(*)` blocks for combinational logic |
| 3.2 | Implement decision structures (`if/else`, `case`, `casez`) and understand the hardware they imply |
| 3.3 | Identify and fix unintentional latch inference |
| 3.4 | Apply blocking assignment correctly in combinational blocks |
| 3.5 | Design a 4-bit ALU with procedural combinational logic |
| 3.6 | Use Yosys to detect latches in synthesized netlists |

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

### Exercise 1: Latch Hunting (20 min) ⚠️ MOST IMPORTANT
Find and fix intentional latch bugs. Run `make ex1_synth` and read every Yosys warning. Fix each bug in `starter/w1d3_ex1_latch_bugs.v`. Bug 3 is a trick question — explain why!

- **Earn the flag:** `cd ex1_latch_bugs/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex5-top-adder-display-46654043b4dc` (Day 2 Exercise 5's flag).

### Exercise 2: Priority Encoder (20 min)
Implement using `if/else` in `starter/w1d3_ex2_priority_encoder.v`. Compare with the provided `casez` alternative. Program and verify on board with `make ex2`.

- **Earn the flag:** `cd ex2_priority_encoder/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

### Exercise 3: 4-Bit ALU (35 min)
Four operations: ADD, SUB, AND, OR. Fill in `starter/w1d3_ex3_alu_4bit.v`. Fill in the verification matrix on paper before programming. Wire to board with `make ex3`.

- **Earn the flag:** `cd ex3_alu/starter && make test`. Save the printed flag for Exercise 4's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

### Exercise 4: BCD-to-7-Seg Decoder (20 min)
Case-based decoder with error display. Compare readability with Day 2's nested conditional.

- **Earn the flag:** `cd ex4_bcd_7seg/starter && make test`. Save the printed flag for Exercise 5's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 3>`

### Exercise 5 — Stretch: ALU + 7-Seg Integration (25 min)
Full system: ALU result displayed on 7-seg, flags on LEDs.

- **Earn the flag:** `cd ex5_top_alu_display/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 4 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 4>`

## Deliverable Checklist

- [ ] Exercise 1: All latch warnings eliminated; Bug 3 explained
- [ ] Exercise 2: Priority encoder correct on board
- [ ] Exercise 3: ALU passes all verification matrix entries
- [ ] Exercise 4: BCD decoder shows 0-9, 'E' for 10-15
- [ ] At minimum: Exercise 3 (ALU) working on board

## Quick Reference

```bash
# ── from labs/week1_day03/ ──
make ex1_synth # Check for latch warnings
make ex2
make ex3
make ex4
make ex5
make clean

# ── from labs/week1_day03/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
