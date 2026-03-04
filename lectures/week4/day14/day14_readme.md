# Day 14: SystemVerilog for Verification

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Assertions — Executable Specifications | ~15 min | `d14_s1_assertions.html` |
| 2 | Concurrent Assertions | ~12 min | `d14_s2_concurrent_assertions.html` |
| 3 | Functional Coverage | ~12 min | `d14_s3_functional_coverage.html` |
| 4 | Interfaces & the Road to UVM | ~11 min | `d14_s4_interfaces_road_to_uvm.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day14_ex01_uart_tx_assertions.sv` | UART TX with 5 immediate assertions + concurrent assertion templates |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d14_verification_pyramid.svg` | Verification maturity scale: waveforms → assertions → UVM → formal |

## Key Concepts
- Immediate assertions: checked at a point in procedural code
- Concurrent assertions: multi-cycle sequence checking (`assert property`)
- `|->` overlapping, `|=>` non-overlapping implication
- `disable iff (reset)` to skip checks during reset
- `covergroup` / `coverpoint` / `bins` for functional coverage
- `interface` with `modport`: bundled connections, different views
- Verification maturity: waveforms → self-checking → assertions → coverage → UVM → formal
- Tool notes: immediate assertions in iverilog -g2012; concurrent/coverage need commercial tools

## Directory Structure

```
day14_systemverilog_for_verification/
├── d14_s1_assertions.html
├── d14_s2_concurrent_assertions.html
├── d14_s3_functional_coverage.html
├── d14_s4_interfaces_road_to_uvm.html
├── code/
│   └── day14_ex01_uart_tx_assertions.sv
├── diagrams/
│   └── d14_verification_pyramid.svg
├── day14_quiz.md
└── day14_readme.md
```
