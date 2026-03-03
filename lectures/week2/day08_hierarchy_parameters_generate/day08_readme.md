# Day 8: Hierarchy, Parameters & Generate

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Module Hierarchy Deep Dive | ~12 min | `d08_s1_module_hierarchy.html` |
| 2 | Parameters & Parameterization | ~15 min | `d08_s2_parameters_parameterization.html` |
| 3 | Generate Blocks | ~12 min | `d08_s3_generate_blocks.html` |
| 4 | Design for Reuse | ~6 min | `d08_s4_design_for_reuse.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day08_ex01_parallel_debounce.v` | Generate-based N-button input pipeline (debounce + edge detect) |
| `code/day08_ex02_param_alu.v` | Parameterized N-bit ALU with self-checking testbench at WIDTH=4 and 8 |

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
`shift_reg_piso`, `fsm_template`, `pattern_detector`, `parallel_debounce`, `param_alu`

These are the building blocks for Week 3 (UART, SPI, memory).

## Directory Structure

```
day08_hierarchy_parameters_generate/
├── d08_s1_module_hierarchy.html
├── d08_s2_parameters_parameterization.html
├── d08_s3_generate_blocks.html
├── d08_s4_design_for_reuse.html
├── code/
│   ├── day08_ex01_parallel_debounce.v
│   └── day08_ex02_param_alu.v
├── diagrams/
│   ├── d08_hierarchy_tree.svg
│   └── d08_generate_concept.svg
├── day08_quiz.md
└── day08_readme.md
```
