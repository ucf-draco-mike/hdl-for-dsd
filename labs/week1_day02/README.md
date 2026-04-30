# Day 2 Lab: Combinational Building Blocks

> **Week 1, Session 2** · Accelerated HDL for Digital System Design · UCF ECE

## Overview

| | |
|---|---|
| **Duration** | ~2 hours |
| **Prerequisites** | Pre-class video (45 min): data types, vectors, operators, continuous assignment |
| **Deliverable** | 7-segment display showing button states as hex digit, programmed on board |
| **Tools** | Yosys, nextpnr-ice40, icepack, iceprog |

## Learning Objectives

| SLO | Description |
|-----|-------------|
| 2.1 | Declare and manipulate vectors using bit selection, concatenation, and replication |
| 2.2 | Apply bitwise, arithmetic, and reduction operators correctly |
| 2.3 | Build multiplexers using the conditional operator |
| 2.4 | Compose modules hierarchically using named port connections |
| 2.5 | Design a hex-to-7-segment decoder targeting the Go Board display |
| 2.6 | Use properly sized literals to avoid width mismatch warnings |

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

### Exercise 1: Vector Operations Warm-Up (20 min)
Reduction operators on a 4-bit vector → LED display. Fill in `starter/w1d2_ex1_vector_ops.v`.

- **Earn the flag:** `cd ex1_vector_ops/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex5-xor-pattern-8a24f2740644` (Day 1 Exercise 5's flag).

### Exercise 2: 2:1 → 4:1 Multiplexer (25 min)
Build a 4:1 mux from three 2:1 mux instances. Fill in `starter/w1d2_ex2_mux4to1.v` and `starter/w1d2_ex2_top_mux.v`. Use `make ex2_show` to visualize the netlist in Yosys.

- **Earn the flag:** `cd ex2_mux_hierarchy/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

### Exercise 3: 4-Bit Ripple-Carry Adder (25 min)
Chain four `full_adder` modules. Fill in `starter/w1d2_ex3_ripple_adder_4bit.v` and `starter/w1d2_ex3_top_adder.v`.

- **Earn the flag:** `cd ex3_ripple_adder/starter && make test`. Save the printed flag for Exercise 4's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

### Exercise 4: Hex-to-7-Segment Decoder (30 min)
Complete the nested conditional decoder in `starter/w1d2_ex4_hex_to_7seg.v`. Wire up the top module. Cycle through all 16 button combinations and verify each hex digit displays correctly.

- **Earn the flag:** `cd ex4_7seg_decoder/starter && make test`. Save the printed flag for Exercise 5's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 3>`

### Exercise 5 — Stretch: Adder + Display Integration (20 min)
Combine the adder and decoder into a single design that displays the sum on 7-seg.

- **Earn the flag:** `cd ex5_top_adder_display/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 3 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 4>`

## Deliverable Checklist

- [ ] Exercise 1: LEDs respond correctly to reduction operations
- [ ] Exercise 2: 4:1 mux works on board
- [ ] Exercise 3: Adder shows correct sums on LEDs
- [ ] Exercise 4: All 16 hex digits display on 7-segment
- [ ] At minimum: Exercise 4 (hex display) programmed and working

## Quick Reference

```bash
# ── from labs/week1_day02/ ──
make ex1
make ex2
make ex3
make ex4
make ex5
make ex2_show
make clean

# ── from labs/week1_day02/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
