# Day 14 Lab: Verification Techniques, AI-Driven Testing & PPA Analysis

## Overview
The capstone verification session — all four cross-cutting threads converge.
You'll add assertions to existing designs, implement a constraint-based UART
parity extension, generate AI-driven testbenches for your project, and produce
a structured PPA analysis.

## Prerequisites
- Pre-class videos on assertions, AI verification workflows, PPA methodology, and coverage
- Working UART TX (SV version from Day 13 or Verilog from Day 11)
- Working FSM from Day 7 or Day 13
- Final project module (at least the interface defined) for Exercise 3

## Toolchain Notes
- Immediate assertions: supported by `iverilog -g2012`
- Concurrent assertions: NOT supported by Icarus (write as documentation only)
- Covergroups: NOT supported by Icarus (manual analysis in Exercise 4)

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer. **Note:** Today only Exercises 1 and 2 are in the CTF chain — Exercises 3 (AI constraint TB) and 4 (PPA analysis) ship plaintext.

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Assertion-Enhanced UART TX | 25 min | 14.1 |
| 2 | Constraint-Based UART Parity Extension | 20 min | 14.2, 14.4 |
| 3 | AI Constraint-Based TB for Project Module | 25 min | 14.3, 14.6 |
| 4 | PPA Analysis Exercise | 25 min | 14.4, 14.5 |
| 5 | Project Work Time | 15 min | — |

### Ex 1 — UART Assertions

- **Earn the flag:** `cd ex1_uart_assertions/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex3-uart-refactor-763b6584598e` (Day 13 Exercise 3's flag).

### Ex 2 — UART Parity

- **Earn the flag:** `cd ex2_uart_parity/starter && make test`. This is the last chained exercise of the course — keep the flag as the final completion proof.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

### Ex 3 — AI Constraint TB

- **Note:** This exercise isn't in the CTF chain — its reference solution ships unencrypted in `solution/`, so there's no `make test` flag to capture for it. Capstones (Days 15–16) are ungated, so Exercise 2's flag is the final chained marker.

### Ex 4 — PPA Analysis

- **Note:** This exercise isn't in the CTF chain — its reference solution ships unencrypted in `solution/`, so there's no `make test` flag to capture for it. Capstones (Days 15–16) are ungated, so Exercise 2's flag is the final chained marker.

> **Instructor note:** Exercise 2 has an escape valve — those behind on their
> final project may skip it and use the time for Exercises 3–4. Parity can be
> completed as homework.

## Deliverables

1. **Assertion-enhanced UART TX** with 7 assertions + bug injection demo
2. **Parity-parameterized UART TX** with PPA comparison (PARITY_EN=0 vs 1)
3. **AI constraint-based TB** with: constraint spec + raw AI output + corrected TB + coverage analysis
4. **PPA analysis report** — comparison table with real data + 2 analysis paragraphs

## Supplementary Material

The following exercises from the original Day 14 build are available as supplementary
content for those who finish early or want additional practice:

- `supplementary/fsm_assertions/` — Add transition and output assertions to the traffic light FSM
- `supplementary/coverage_worksheet/` — Manual functional coverage analysis for the ALU

## Shared Resources
- `go_board.pcf` — Pin constraint file
- Reuse modules from `shared/lib/` for PPA analysis targets

## Build Commands Quick Reference

```bash
# ── from labs/week4_day14/exN_*/starter/ ──
make test                            # run published testbench → flag on pass (Exercises 1 & 2 only)
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
