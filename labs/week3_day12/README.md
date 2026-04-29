# Day 12 Lab: UART RX, SPI & IP Integration

## Overview
Build the UART receiver with 16× oversampling, create a loopback test, and
explore SPI master design or IP integration.

## Prerequisites
- Working UART TX from Day 11
- Pre-class video on UART RX oversampling and SPI

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer. **Note:** Today only Exercise 2 (loopback) is in the CTF chain — Exercise 1 (UART RX) and Exercise 3 (SPI master) ship plaintext. Exercise 2's optional unlock uses Day 11 Exercise 3's flag, *not* Day 12 Exercise 1's.

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | UART RX Module + Testbench | 40 min | 12.1, 12.2 |
| 2 | UART Loopback on Hardware | 25 min | 12.3 |
| 3 | SPI Master Module | 30 min | 12.4, 12.5 |
| 4 | UART-Controlled LED Pattern | 15 min | 12.3 |
| 5 | UART-to-SPI Bridge (Stretch) | 15 min | 12.4, 12.5 |

### Ex 1 — UART RX

- **Note:** This exercise isn't in the CTF chain — its reference solution ships unencrypted in `solution/`, so there's no `make test` flag to capture for it. Continue using the previous chained exercise's flag (Day 11 Exercise 3 — the flag from that exercise's `make test`) to unlock Exercise 2's reference.

### Ex 2 — Loopback

- **Earn the flag:** `cd ex2_loopback/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 13 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex3-hardware-verify-94791dea7600` (Day 11 Exercise 3's flag — Day 12 Exercise 1 isn't in the chain, so the previous chained flag comes from Day 11).

### Ex 3 — SPI Master

- **Note:** This exercise isn't in the CTF chain — its reference solution ships unencrypted in `solution/`, so there's no `make test` flag to capture for it. Continue using Exercise 2's flag (the flag from that exercise's `make test`) to unlock Day 13 Exercise 1's reference.

## Deliverables
1. UART RX with all test bytes passing in simulation
2. **Loopback working on hardware** — type on PC, see echo (crown jewel!)
3. SPI master verified in simulation

## Build Commands Quick Reference

```bash
# ── from labs/week3_day12/exN_*/starter/ ──
make test                            # run published testbench → flag on pass (Exercise 2 only)
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
