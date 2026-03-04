# Day 10 Lab: Numerical Architectures & Design Trade-offs

## Overview
Today you'll compare adder and multiplier architectures, implement a sequential
multiplier, work with fixed-point arithmetic, and produce your first structured
PPA comparison table. These are the same analysis habits you'll use in the
final project report.

## Prerequisites
- Completed Day 9 lab (memory)
- Pre-class videos on timing essentials, numerical architectures, and PPA watched
- Reuse your `hex_to_7seg.v` from Day 2 and `full_adder.v` from Day 2

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Adder Architecture Comparison | 30 min | 10.1, 10.4 |
| 2 | Shift-and-Add Multiplier | 30 min | 10.2, 10.4 |
| 3 | Fixed-Point Arithmetic | 20 min | 10.3 |
| 4 | Timing Constraint Exercise | 10 min | 10.5 |
| 5 | PLL & CDC (Stretch) | 15 min | 10.5 |

## Deliverables
1. **Adder/multiplier PPA comparison table** with real data (LUTs, FFs, Fmax)
2. **Working shift-and-add multiplier** on FPGA with testbench
3. **Fixed-point demo** showing correct Q4.4 multiplication result on 7-seg

## PPA Comparison Table Template

| Module | Configuration | LUTs | FFs | Fmax (MHz) | Notes |
|--------|---------------|------|-----|------------|-------|
| Adder | Ripple-carry, 8-bit | | | | Manual chain |
| Adder | Ripple-carry, 16-bit | | | | Manual chain |
| Adder | Behavioral `+`, 8-bit | | | | Tool-chosen |
| Adder | Behavioral `+`, 16-bit | | | | Tool-chosen |
| Multiplier | Combinational `*`, 8-bit | | | | 1 cycle |
| Multiplier | Shift-and-add, 8-bit | | | | 8 cycles |

## Shared Resources
- `go_board.pcf` — Pin constraint file
- Reuse your `hex_to_7seg.v` and `full_adder.v` from previous labs
