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

Every Verilog code block in the four pre-class decks is paired with an RTL
block diagram. Signals share a consistent palette across all diagrams:
clk → blue, reset → red, noisy/raw → orange, clean/output → green,
count/internal → purple, carry → pink, parameters → gold. The same colors
are applied inline in the code blocks so a signal can be traced from
source to silhouette.

| File | Description |
|------|-------------|
| `diagrams/d08_hierarchy_tree.svg` | Module hierarchy tree (Level 0/1/2) with per-block colors |
| `diagrams/d08_generate_concept.svg` | generate-for: one source → N hardware copies at elaboration |
| `diagrams/d08_button_handler_rtl.svg` | s1 I-Do — button_handler wraps a debounce submodule |
| `diagrams/d08_bad_hierarchy_rtl.svg` | s1 You-Do — anonymous-chain anti-pattern |
| `diagrams/d08_param_counter_rtl.svg` | s2 I-Do — parameterized counter (WIDTH/MAX_VAL) |
| `diagrams/d08_param_debounce_rtl.svg` | s2 We-Do — debounce with `localparam` + `$clog2` |
| `diagrams/d08_fifo_rtl.svg` | s2 You-Do — FIFO (hardcoded & parameterized share the picture) |
| `diagrams/d08_button_array_rtl.svg` | s3 I-Do — `generate for` unrolls N debouncers |
| `diagrams/d08_generate_if_rtl.svg` | s3 We-Do — `generate if` selects between 2-FF sync vs pass-through |
| `diagrams/d08_ripple_adder_rtl.svg` | s3 You-Do — N-bit ripple-carry adder via `generate for` |
| `diagrams/d08_reusable_debounce_rtl.svg` | s4 I-Do — datasheet header alongside black-box RTL |
| `diagrams/d08_before_after_rtl.svg` | s4 — "works for me" (grey pins) vs reusable (colored pins) |

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
│   ├── d08_generate_concept.svg
│   ├── d08_button_handler_rtl.svg
│   ├── d08_bad_hierarchy_rtl.svg
│   ├── d08_param_counter_rtl.svg
│   ├── d08_param_debounce_rtl.svg
│   ├── d08_fifo_rtl.svg
│   ├── d08_button_array_rtl.svg
│   ├── d08_generate_if_rtl.svg
│   ├── d08_ripple_adder_rtl.svg
│   ├── d08_reusable_debounce_rtl.svg
│   └── d08_before_after_rtl.svg
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
