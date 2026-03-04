# Day 3: Procedural Combinational Logic

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File | Slides |
|---|---------|----------|------|--------|
| 1 | The `always @(*)` Block | ~12 min | `d03_s1_always_star_block.html` | 6 |
| 2 | `if/else` and `case` | ~15 min | `d03_s2_if_else_and_case.html` | 7 |
| 3 | The Latch Problem | ~12 min | `d03_s3_the_latch_problem.html` | 6 |
| 4 | Blocking vs. Nonblocking | ~6 min | `d03_s4_blocking_vs_nonblocking.html` | 7 |

## Code Examples

| File | Description | Synthesizable? |
|------|-------------|----------------|
| `code/day03_ex01_latch_demo.v` | Intentional latch — see Yosys warnings | Yes (with warnings) |
| `code/day03_ex02_latch_fixed.v` | Fixed version using default assignment | Yes (clean) |
| `code/day03_ex03_alu_4bit.v` | 4-bit ALU with case statement | Yes |

## Diagrams

| File | Used In | Description |
|------|---------|-------------|
| `diagrams/d03_latch_vs_comb.svg` | Seg 3 | Latch vs combinational side-by-side comparison |

## Pre-Class Quiz

See `day03_quiz.md` — 4 questions. Also embedded at end of Segment 4.

## Directory Structure

```
day03_procedural_combinational_logic/
├── day03_readme.md
├── day03_quiz.md
├── d03_s1_always_star_block.html
├── d03_s2_if_else_and_case.html
├── d03_s3_the_latch_problem.html
├── d03_s4_blocking_vs_nonblocking.html
├── code/
│   ├── day03_ex01_latch_demo.v
│   ├── day03_ex02_latch_fixed.v
│   └── day03_ex03_alu_4bit.v
└── diagrams/
    └── d03_latch_vs_comb.svg
```
