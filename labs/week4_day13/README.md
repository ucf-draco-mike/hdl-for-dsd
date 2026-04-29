# Day 13 Lab: SystemVerilog for Design

## Overview
Refactor existing Verilog modules into SystemVerilog using `logic`,
`always_ff`, `always_comb`, `enum`, and `struct`. Compare behavior
and synthesis results.

## Prerequisites
- Pre-class video on SystemVerilog design constructs
- Working ALU, traffic light FSM, and UART TX from prior labs

## Toolchain Notes
- Simulation: `iverilog -g2012` (limited SV support)
- Synthesis: `yosys read_verilog -sv`
- Linting: `verilator --lint-only -Wall` (if installed)

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | ALU Refactor | 25 min | 13.1, 13.2, 13.6 |
| 2 | FSM Refactor | 25 min | 13.2, 13.3, 13.6 |
| 3 | UART TX Refactor | 30 min | 13.1–13.4 |
| 4 | Final Project Design | 30 min | — |
| 5 | Package (Stretch) | 15 min | 13.5 |

### Ex 1 — ALU Refactor

- **Earn the flag:** `cd ex1_alu_refactor/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex2-loopback-fd4d0f924767` (Day 12 Exercise 2's flag).

### Ex 2 — FSM Refactor

- **Earn the flag:** `cd ex2_fsm_refactor/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

### Ex 3 — UART TX Refactor

- **Earn the flag:** `cd ex3_uart_refactor/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 14 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

## Deliverables
1. SV-refactored ALU passing all original tests
2. SV-refactored FSM with enum states and .name() debug output
3. SV-refactored UART TX with struct-based signal grouping
4. Final project block diagram and module inventory

## Build Commands Quick Reference

```bash
# ── from labs/week4_day13/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
