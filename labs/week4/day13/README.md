# Day 13 Lab: SystemVerilog for Design

## Overview
Refactor existing Verilog modules into SystemVerilog using `logic`,
`always_ff`, `always_comb`, `enum`, and `struct`. Compare behavior
and synthesis results.

## Prerequisites
- Pre-class video on SystemVerilog design constructs
- Working ALU, traffic light FSM, and UART TX from prior labs

## Toolchain Notes
- Simulation: `iverilog -g2012` (limited SV support)
- Synthesis: `yosys read_verilog -sv`
- Linting: `verilator --lint-only -Wall` (if installed)

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | ALU Refactor | 25 min | 13.1, 13.2, 13.6 |
| 2 | FSM Refactor | 25 min | 13.2, 13.3, 13.6 |
| 3 | UART TX Refactor | 30 min | 13.1–13.4 |
| 4 | Final Project Design | 30 min | — |
| 5 | Package (Stretch) | 15 min | 13.5 |

## Deliverables
1. SV-refactored ALU passing all original tests
2. SV-refactored FSM with enum states and .name() debug output
3. SV-refactored UART TX with struct-based signal grouping
4. Final project block diagram and module inventory
