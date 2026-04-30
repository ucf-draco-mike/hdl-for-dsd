# Day 11 Lab: UART Transmitter

## Overview
Build and verify a complete UART TX module, then send "HELLO" from the
Go Board to your PC terminal.

## Prerequisites
- Pre-class video on UART protocol and TX architecture
- Working debounce module from Day 5
- Working hex_to_7seg from Day 2

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../week1_day01/README.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Baud Rate Generator | 15 min | 11.2 |
| 2 | UART TX Module + Testbench | 40 min | 11.3, 11.4 |
| 3 | Hardware Verification | 25 min | 11.5 |
| 4 | Multi-Character Sender | 20 min | 11.3, 11.5 |
| 5 | Parity Support (Stretch) | 15 min | 11.3 |

### Ex 1 — Baud Rate Generator

- **Earn the flag:** `cd ex1_baud_gen/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex3-fixed-point-9d0f6eb0df21` (Day 10 Exercise 3's flag — Day 10's last chained exercise).

### Ex 2 — UART TX Module

- **Earn the flag:** `cd ex2_uart_tx/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 1>`

### Ex 3 — Hardware Verification

- **Earn the flag:** `cd ex3_hardware_verify/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 12 Exercise 2 (Day 12 Exercise 1 is not in the chain).
- **(Optional) Peek at the reference:** `make unlock FLAG=<flag from Exercise 2>`

## Deliverables
1. Baud generator verified in simulation
2. UART TX with self-checking protocol-aware testbench (all tests pass)
3. "HELLO" received on PC terminal emulator

## Terminal Setup
| Platform | Command |
|----------|---------|
| Linux | `screen /dev/ttyUSB0 115200` |
| macOS | `screen /dev/cu.usbserial-* 115200` |
| Windows | PuTTY → COMx, 115200, 8N1 |

## Build Commands Quick Reference

```bash
# ── from labs/week3_day11/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```
