# Day 13 Lab: SystemVerilog for Design

!!! abstract "Starter Code & Notebooks"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day13/day13_all_starter.zip){ .md-button .md-button--primary }

    [:material-notebook: Open Lab Notebook](http://localhost:8888/lab/tree/notebooks/labs/lab_day13.ipynb){ .md-button target=_blank }
    [:material-github: Notebook on GitHub](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/notebooks/labs/lab_day13.ipynb){ .md-button target=_blank }

    Individual exercise downloads are linked below each exercise.
    Full file listing: [Code & Notebooks Reference](code.md)


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


---

## :material-download: Exercise Code

### Ex 1 — Alu Refactor

[:material-download: Starter .zip](../../downloads/day13/ex1_alu_refactor_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day13/ex1_alu_refactor_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day13/ex1_alu_refactor/starter/Makefile){ target=_blank }
- :material-chip: [`alu_sv.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day13/ex1_alu_refactor/starter/alu_sv.sv){ target=_blank }

### Ex 2 — Fsm Refactor

[:material-download: Starter .zip](../../downloads/day13/ex2_fsm_refactor_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day13/ex2_fsm_refactor_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day13/ex2_fsm_refactor/starter/Makefile){ target=_blank }
- :material-chip: [`traffic_light_sv.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day13/ex2_fsm_refactor/starter/traffic_light_sv.sv){ target=_blank }

### Ex 3 — Uart Refactor

[:material-download: Starter .zip](../../downloads/day13/ex3_uart_refactor_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day13/ex3_uart_refactor_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day13/ex3_uart_refactor/starter/Makefile){ target=_blank }
- :material-chip: [`uart_tx_sv.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day13/ex3_uart_refactor/starter/uart_tx_sv.sv){ target=_blank }
