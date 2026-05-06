# Day 3: Procedural Combinational Logic

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File | Slides |
|---|---------|----------|------|--------|
| 1 | The `always @(*)` Block | ~12 min | `d03_s1_always_star_block.html` | 6 |
| 2 | `if/else` and `case` | ~15 min | `d03_s2_if_else_and_case.html` | 7 |
| 3 | The Latch Problem | ~12 min | `d03_s3_the_latch_problem.html` | 6 |
| 4 | Combinational Capstone — Extending the ALU | ~10 min | `d03_s4_combinational_capstone.html` | 8 |

## Code Examples

Live-demo runnable code lives under `lecture_examples/week1_day03/` (mirrors
the per-segment slide layout). Each subdirectory ships its own `Makefile`
(`make sim`, `make stat`, `make prog`).

| File | Demo dir | Description | Synthesizable? |
|------|----------|-------------|----------------|
| `day03_ex01_latch_demo.v` | `d03_s3_ex2/` | Intentional latch — see Yosys warnings | Yes (with warnings) |
| `day03_ex02_latch_fixed.v` | `d03_s3_ex3/` | Fixed version using default + complete `case` | Yes (clean) |
| `day03_ex03_alu_4bit.v` | `d03_s2_ex1/` | 4-bit ALU with `case` statement (introduced in s2) | Yes |
| `day03_ex04_mux_assign.v` | `d03_s1_ex1/` | 4:1 mux written with `assign` (nested ternary) | Yes |
| `day03_ex05_mux_always.v` | `d03_s1_ex1/` | 4:1 mux written with `always @(*)` + `case` (same hardware as ex04) | Yes |
| `alu_4bit.v` | `d03_s4_ex5/` | Baseline ALU mirrored from `d03_s2_ex1/` for the s4 capstone stat-compare (`make stat-baseline`) | Yes |
| `alu_4bit_ext.v` | `d03_s4_ex5/` | Extended ALU (+ XOR + variable shift) — exercises operator costs and case-default safety (`make stat-ext`) | Yes |

The blocking-vs-nonblocking shift register, formerly mirrored in
`lecture_examples/week1_day03/d03_s4_ex5/`, now lives canonically in
`lecture_examples/week1_day04/d04_s2_ex1/` — see day 4.

## Diagrams

| File | Used In | Description |
|------|---------|-------------|
| `diagrams/d03_latch_vs_comb.svg` | Seg 3 | Latch vs combinational side-by-side comparison |

The blocking-vs-nonblocking execution-model and gate-representation diagrams
have moved to `lectures/week1_day04/diagrams/` since D4 Seg 2 is now the
canonical home for that material.

## Pre-Class Quiz

See `day03_quiz.md` — 4 questions. Also embedded at end of Segment 4.

## Directory Structure

```
lectures/week1_day03/
├── day03_readme.md
├── day03_quiz.md
├── d03_s1_always_star_block.html
├── d03_s2_if_else_and_case.html
├── d03_s3_the_latch_problem.html
├── d03_s4_combinational_capstone.html
└── diagrams/
    └── d03_latch_vs_comb.svg

lecture_examples/week1_day03/
├── Makefile                    # day-level dispatcher (ex1..ex5)
├── go_board.pcf
├── d03_s1_ex1/                 # `assign` vs `always @(*)` — same hardware
│   ├── day03_ex04_mux_assign.v
│   ├── day03_ex05_mux_always.v
│   ├── tb_mux.v
│   └── Makefile
├── d03_s2_ex1/                 # 4-bit ALU with `case`
│   ├── day03_ex03_alu_4bit.v
│   ├── tb_alu_4bit.v
│   └── Makefile
├── d03_s3_ex2/                 # latch demo (intentional bugs)
│   ├── day03_ex01_latch_demo.v
│   ├── tb_latch_demo.v
│   └── Makefile
├── d03_s3_ex3/                 # latch fixed (default + complete case)
│   ├── day03_ex02_latch_fixed.v
│   ├── tb_latch_fixed.v
│   └── Makefile
└── d03_s4_ex5/                 # combinational capstone: baseline vs extended ALU
    ├── alu_4bit.v              # baseline (ADD/SUB/AND/OR) — `make stat-baseline`
    ├── alu_4bit_ext.v          # extended (+ XOR + variable SHL) — `make stat-ext`
    ├── tb_alu_4bit_ext.v
    └── Makefile
```
