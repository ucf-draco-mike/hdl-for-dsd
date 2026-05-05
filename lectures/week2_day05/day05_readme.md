# Day 5: Counters, Shift Registers & Debouncing

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Counter Variations | ~10 min | `d05_s1_counter_variations.html` |
| 2 | Shift Registers | ~12 min | `d05_s2_shift_registers.html` |
| 3 | Metastability & Synchronizers | ~12 min | `d05_s3_metastability_synchronizers.html` |
| 4 | Button Debouncing | ~11 min | `d05_s4_button_debouncing.html` |

## Code Examples

Code lives under `lecture_examples/week2_day05/d05_sN_exN/` (one folder per
segment). Each folder has its own `Makefile` exposing `sim`, `wave`, `stat`,
`synth`, and `prog` targets.

| Folder | Files | Description |
|--------|-------|-------------|
| `d05_s1_ex1/` | `day05_ex01_counter_mod_n.v`, `tb_counter_mod_n.v` | Parameterized modulo-N counter with `$clog2`-sized state, enable, and 1-cycle wrap pulse. |
| `d05_s2_ex2/` | `day05_ex02_shift_reg_sipo.v` (live demo), `day05_ex02_shift_reg_piso.v` (PISO companion), TBs for both | Serial-In Parallel-Out shift register (UART RX core) plus the Parallel-In Serial-Out variant covered in the "We Do" segment. |
| `d05_s3_ex3/` | `day05_ex03_synchronizer.v`, `tb_synchronizer.v` | 2-FF metastability synchronizer with TB exercising rising/falling latency and glitch rejection. |
| `d05_s4_ex4/` | `day05_ex04_debounce.v`, `day05_ex04_top.v`, `tb_debounce.v` | Pure counter-based debouncer plus a Go Board top wrapper that composes the full input pipeline (sync → debounce → edge → 4-bit press counter). |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d05_synchronizer.svg` | 2-FF synchronizer schematic with metastability annotation |
| `diagrams/d05_bounce_waveform.svg` | Button bounce → debounced output waveform comparison |

## Key Concepts
- Counter variations: modulo-N, up/down, loadable
- Shift register types: SISO, SIPO, PISO, PIPO
- Metastability, setup/hold, and 2-FF synchronizers
- Counter-based debouncing, edge detection
- Input pipeline: sync → debounce → edge detect

## Directory Structure

Lecture material (slides, diagrams, quiz) lives under `lectures/week2_day05/`.
Hands-on code examples live in a parallel tree under
`lecture_examples/week2_day05/`.

```
lectures/week2_day05/
├── d05_s1_counter_variations.html
├── d05_s2_shift_registers.html
├── d05_s3_metastability_synchronizers.html
├── d05_s4_button_debouncing.html
├── diagrams/
│   ├── d05_synchronizer.svg
│   └── d05_bounce_waveform.svg
├── day05_quiz.md
└── day05_readme.md

lecture_examples/week2_day05/
├── Makefile                  # day-level dispatcher: ex1, ex2, ex3, ex4
├── go_board.pcf              # shared PCF for Nandland Go Board
├── d05_s1_ex1/
│   ├── Makefile
│   ├── day05_ex01_counter_mod_n.v
│   └── tb_counter_mod_n.v
├── d05_s2_ex2/
│   ├── Makefile
│   ├── day05_ex02_shift_reg_sipo.v   # primary, used in live demo
│   ├── day05_ex02_shift_reg_piso.v   # PISO companion ("We Do" content)
│   ├── tb_shift_reg_sipo.v
│   └── tb_shift_reg_piso.v
├── d05_s3_ex3/
│   ├── Makefile
│   ├── day05_ex03_synchronizer.v
│   └── tb_synchronizer.v
└── d05_s4_ex4/
    ├── Makefile
    ├── day05_ex04_debounce.v        # pure debounce stage
    ├── day05_ex04_top.v             # Go Board pipeline (sync+deb+edge+ctr)
    └── tb_debounce.v
```
