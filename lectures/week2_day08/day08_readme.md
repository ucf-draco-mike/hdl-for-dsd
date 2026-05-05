# Day 8: Hierarchy, Parameters & Generate

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Module Hierarchy Deep Dive | ~12 min | `d08_s1_module_hierarchy.html` |
| 2 | Parameters & Parameterization | ~15 min | `d08_s2_parameters_parameterization.html` |
| 3 | Generate Blocks | ~12 min | `d08_s3_generate_blocks.html` |
| 4 | Design for Reuse | ~6 min | `d08_s4_design_for_reuse.html` |

## Code Examples

Runnable lecture-deck demos live under
[`lecture_examples/week2_day08/`](../../lecture_examples/week2_day08/). Each
example is its own `make sim` / `make stat` / `make prog` directory.

| Slide cue | Example dir | Top file(s) | Demo |
|-----------|-------------|-------------|------|
| `d08_s1` | `d08_s1_ex1/` | `day08_ex01_button_handler.v`, `sync_2ff.v`, `debounce.v`, `edge_detect.v`, `tb_button_handler.v` | Build a hierarchical design (sync → debounce → edge) |
| `d08_s2` | `d08_s2_ex2/` | `day08_ex02_counter.v`, `top_with_three_counters.v`, `tb_top_with_three_counters.v` | One module, three instances at WIDTH=4 / 8 / 16 |
| `d08_s3` | `d08_s3_ex3/` | `day08_ex03_parallel_debounce.v`, `debounce.v`, `tb_parallel_debounce.v` | Generate-based scaling: `make stat N=4 / 8 / 16` |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d08_hierarchy_tree.svg` | Module hierarchy tree with levels, parameterization annotations |
| `diagrams/d08_generate_concept.svg` | generate-for: one source → N hardware copies at elaboration |

## Key Concepts
- Hierarchy for complexity management, descriptive naming
- `parameter` (configurable) vs. `localparam` (internal/derived)
- `$clog2()` for automatic width sizing
- `generate for` — hardware replication at elaboration time
- `generate if` — conditional hardware inclusion
- Module reuse checklist: parameterized, tested, documented

## Week 2 Recap

Your module library after Week 2 (~10 tested, reusable modules):
`hex_to_7seg`, `debounce`, `counter_mod_n`, `edge_detector`, `synchronizer`,
`shift_reg_piso`, `fsm_template`, `pattern_detector`, `button_handler`,
`parallel_debounce`

These are the building blocks for Week 3 (UART, SPI, memory).

## Directory Structure

```
lectures/week2_day08/
├── d08_s1_module_hierarchy.html
├── d08_s2_parameters_parameterization.html
├── d08_s3_generate_blocks.html
├── d08_s4_design_for_reuse.html
├── diagrams/
│   ├── d08_hierarchy_tree.svg
│   └── d08_generate_concept.svg
├── day08_quiz.md
└── day08_readme.md

lecture_examples/week2_day08/
├── Makefile                    # day-level dispatcher (ex1/ex2/ex3)
├── go_board.pcf
├── d08_s1_ex1/                 # button_handler hierarchy demo (s1)
│   ├── day08_ex01_button_handler.v
│   ├── sync_2ff.v
│   ├── debounce.v
│   ├── edge_detect.v
│   ├── tb_button_handler.v
│   └── Makefile
├── d08_s2_ex2/                 # parameterized counter triple (s2)
│   ├── day08_ex02_counter.v
│   ├── top_with_three_counters.v
│   ├── tb_top_with_three_counters.v
│   └── Makefile
└── d08_s3_ex3/                 # generate-N parallel debouncer (s3)
    ├── day08_ex03_parallel_debounce.v
    ├── debounce.v
    ├── tb_parallel_debounce.v
    └── Makefile
```
