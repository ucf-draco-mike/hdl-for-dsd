# Day 4: Sequential Logic Fundamentals

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Clocks and Edge-Triggered Behavior | ~12 min | `seg1_clocks_and_edges.html` |
| 2 | Nonblocking Assignment — Why It Matters | ~15 min | `seg2_nonblocking_assignment.html` |
| 3 | Flip-Flops With Reset and Enable | ~10 min | `seg3_flip_flop_variants.html` |
| 4 | Counters and Clock Division | ~13 min | `seg4_counters_and_clock_division.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/d_flip_flop.v` | D flip-flop with synchronous reset |
| `code/led_blinker.v` | Counter-based 1 Hz LED blinker (25 MHz → 1 Hz) |
| `code/shift_register_demo.v` | Side-by-side blocking vs. nonblocking shift registers |

## Key Concepts

- Clock edges define state transitions — `always @(posedge clk)`
- Nonblocking `<=` ensures all registers update simultaneously
- Blocking `=` in sequential blocks destroys pipeline behavior
- D-FF variants: basic, sync reset, async reset, with enable
- Counters as the fundamental sequential building block
- Clock division: count to target, toggle, reset

## Pre-Class Quiz

See `quiz.md` — 4 questions covering all 4 segments.
