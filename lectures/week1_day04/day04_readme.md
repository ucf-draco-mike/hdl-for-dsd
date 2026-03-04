# Day 4: Sequential Logic Fundamentals

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File | Slides |
|---|---------|----------|------|--------|
| 1 | Clocks and Edge-Triggered Behavior | ~12 min | `d04_s1_clocks_and_edges.html` | 6 |
| 2 | Nonblocking Assignment | ~15 min | `d04_s2_nonblocking_assignment.html` | 6 |
| 3 | Flip-Flops With Reset and Enable | ~10 min | `d04_s3_flip_flop_variants.html` | 5 |
| 4 | Counters and Clock Division | ~13 min | `d04_s4_counters_and_clock_division.html` | 8 |

## Code Examples

| File | Description | Synthesizable? |
|------|-------------|----------------|
| `code/day04_ex01_d_flip_flop.v` | D flip-flop with sync reset and enable | Yes |
| `code/day04_ex02_led_blinker.v` | Counter-based 1 Hz LED blinker | Yes |
| `code/day04_ex03_shift_register_demo.v` | Side-by-side blocking vs nonblocking | Sim only |

## Diagrams

| File | Used In | Description |
|------|---------|-------------|
| `diagrams/d04_pipeline_blocking.svg` | Seg 2 | Blocking vs nonblocking pipeline comparison |

## Pre-Class Quiz

See `day04_quiz.md` — 4 questions. Also embedded at end of Segment 4.

## Directory Structure

```
week1_day04/
├── day04_readme.md
├── day04_quiz.md
├── d04_s1_clocks_and_edges.html
├── d04_s2_nonblocking_assignment.html
├── d04_s3_flip_flop_variants.html
├── d04_s4_counters_and_clock_division.html
├── code/
│   ├── day04_ex01_d_flip_flop.v
│   ├── day04_ex02_led_blinker.v
│   └── day04_ex03_shift_register_demo.v
└── diagrams/
    └── d04_pipeline_blocking.svg
```
