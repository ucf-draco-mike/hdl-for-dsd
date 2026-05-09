# Day 4: Sequential Logic Fundamentals

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File | Slides |
|---|---------|----------|------|--------|
| 1 | Clocks and Edge-Triggered Behavior | ~12 min | `d04_s1_clocks_and_edges.html` | 7 |
| 2 | Nonblocking Assignment | ~15 min | `d04_s2_nonblocking_assignment.html` | 6 |
| 3 | Flip-Flops With Reset and Enable | ~10 min | `d04_s3_flip_flop_variants.html` | 5 |
| 4 | Counters and Clock Division | ~13 min | `d04_s4_counters_and_clock_division.html` | 8 |

## Code Examples

Runnable lecture examples live under `lecture_examples/week1_day04/`. Each
example is a self-contained subdirectory with its own `Makefile`
(`make sim`, `make wave`, `make stat`, `make prog`).

| Example dir | File(s) | Demo cue | Synthesizable? |
|-------------|---------|----------|----------------|
| `lecture_examples/week1_day04/d04_s2_ex1/` | `shift_blocking.v`, `shift_nonblocking.v`, `tb_shift_register_demo.v` | `d04_s2` (canonical home for blocking-vs-nonblocking demo) | Sim only |
| `lecture_examples/week1_day04/d04_s3_ex2/` | `day04_ex01_d_flip_flop.v`, `day04_ex01b_reg_4bit_rst_en.v`, `tb_d_flip_flop.v`, `tb_reg_4bit_rst_en.v` | `d04_s1`, `d04_s3` | Yes |
| `lecture_examples/week1_day04/d04_s4_ex3/` | `day04_ex02_led_blinker.v`, `tb_led_blinker.v` | `d04_s4` | Yes |
| `lecture_examples/week1_day04/d04_s1_ex4/` | `day04_ex03_led_blink_rates.v`, `tb_led_blink_rates.v` | `d04_s1` (four-LED multi-rate live demo) | Yes |

## Diagrams

| File | Used In | Description |
|------|---------|-------------|
| `diagrams/d04_pipeline_blocking.svg` | Seg 2 | Blocking vs nonblocking pipeline comparison |
| `diagrams/d04_blocking_vs_nonblocking.svg` | Seg 2 | Pointer-vs-snapshot execution model (simulator scheduling) |
| `diagrams/d04_gate_representation.svg` | Seg 2 | Combinational vs sequential hardware representation |

## Pre-Class Quiz

See `day04_quiz.md` — 4 questions. Also embedded at end of Segment 4.

## Directory Structure

```
lectures/week1_day04/
├── day04_readme.md
├── day04_quiz.md
├── d04_s1_clocks_and_edges.html
├── d04_s2_nonblocking_assignment.html
├── d04_s3_flip_flop_variants.html
├── d04_s4_counters_and_clock_division.html
└── diagrams/
    └── d04_pipeline_blocking.svg

lecture_examples/week1_day04/
├── Makefile                       # day-level dispatcher
├── go_board.pcf
├── d04_s2_ex1/                    # blocking vs nonblocking pipeline
│   ├── shift_blocking.v           # buggy version — synthesizes to 1 flop
│   ├── shift_nonblocking.v        # correct version — synthesizes to 3 flops
│   ├── tb_shift_register_demo.v
│   └── Makefile
├── d04_s3_ex2/                    # bare DFF (s1) + 4-bit reset/enable register (s3)
│   ├── day04_ex01_d_flip_flop.v
│   ├── day04_ex01b_reg_4bit_rst_en.v
│   ├── tb_d_flip_flop.v
│   ├── tb_reg_4bit_rst_en.v
│   └── Makefile
├── d04_s4_ex3/                    # 1 Hz LED blinker + bit-tap LEDs
│   ├── day04_ex02_led_blinker.v
│   ├── tb_led_blinker.v
│   └── Makefile
└── d04_s1_ex4/                    # four LEDs at 1/2/3/4 s rates (s1 live demo)
    ├── day04_ex03_led_blink_rates.v
    ├── tb_led_blink_rates.v
    └── Makefile
```
