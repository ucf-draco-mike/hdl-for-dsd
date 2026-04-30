# Day 9 Lab: Memory — RAM, ROM & Block RAM

## Overview
Today you'll work with on-chip memory: ROM for lookup tables and pattern
storage, RAM for read/write data, and the iCE40's block RAM (EBR) resources.
You'll learn to initialize memory from `.hex` files and write testbenches that
verify memory operations with proper handling of synchronous read latency.

## Prerequisites
- Completed Day 8 lab (hierarchical design)
- Pre-class video on ROM, RAM, and iCE40 memory resources watched

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | ROM Pattern Sequencer | 30 min | 9.1, 9.5, 9.6 |
| 2 | Synchronous RAM — Write/Read | 30 min | 9.2, 9.3, 9.4 |
| 3 | Initialized RAM with `$readmemh` | 25 min | 9.2, 9.6 |
| 4 | Dual-Display Pattern Player (stretch) | 20 min | 9.5, 9.6 |
| 5 | Register File (stretch) | 20 min | 9.2 |

### Ex 1 — ROM Pattern Sequencer

- **Earn the flag:** `cd ex1_rom_sequencer/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex4-lfsr-generic-e51428a33715` (Day 8 Exercise 4's flag).

### Ex 2 — Sync RAM

- **Earn the flag:** `cd ex2_sync_ram/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

### Ex 3 — Initialized RAM

- **Earn the flag:** `cd ex3_initialized_ram/starter && make test`. Save the printed flag for Exercise 4's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

### Ex 4 — Dual Display

- **Earn the flag:** `cd ex4_dual_display/starter && make test`. Save the printed flag for Exercise 5's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 3>`

### Ex 5 — Register File

- **Earn the flag:** `cd ex5_register_file/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 10 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 4>`

## Key Concepts
- `case`-based ROM vs. array + `$readmemh` ROM
- Async read → LUT inference. Sync read → block RAM inference
- Single-port synchronous RAM with read-before-write behavior
- iCE40 HX1K: 16 EBR blocks × 4 Kbit = 64 Kbit total block RAM
- One-cycle read latency is the #1 source of memory bugs

## Deliverables
- [ ] ROM pattern sequencer displaying on LEDs and 7-seg (Ex 1)
- [ ] RAM write/read verified with self-checking testbench (Ex 2)
- [ ] Initialized RAM with `.hex` file verified (Ex 3)
- [ ] `make stat` output showing block RAM inference for Ex 2

## Build Commands Quick Reference

```bash
# ── from labs/week3_day09/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
