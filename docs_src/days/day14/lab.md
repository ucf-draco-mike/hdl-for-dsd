# Day 14 Lab: Verification Techniques, AI-Driven Testing & PPA Analysis

!!! abstract "Starter Code"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day14/day14_all_starter.zip){ .md-button .md-button--primary }

    Individual exercise downloads and file links are below each exercise.


## Overview
The capstone verification session — all four cross-cutting threads converge.
You'll add assertions to existing designs, implement a constraint-based UART
parity extension, generate AI-driven testbenches for your project, and produce
a structured PPA analysis.

## Prerequisites
- Pre-class videos on assertions, AI verification workflows, PPA methodology, and coverage
- Working UART TX (SV version from Day 13 or Verilog from Day 11)
- Working FSM from Day 7 or Day 13
- Final project module (at least the interface defined) for Exercise 3

## Toolchain Notes
- Immediate assertions: supported by `iverilog -g2012`
- Concurrent assertions: NOT supported by Icarus (write as documentation only)
- Covergroups: NOT supported by Icarus (manual analysis in Exercise 4)

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Assertion-Enhanced UART TX | 25 min | 14.1 |
| 2 | Constraint-Based UART Parity Extension | 20 min | 14.2, 14.4 |
| 3 | AI Constraint-Based TB for Project Module | 25 min | 14.3, 14.6 |
| 4 | PPA Analysis Exercise | 25 min | 14.4, 14.5 |
| 5 | Project Work Time | 15 min | — |

> **Instructor note:** Exercise 2 has an escape valve — those behind on their
> final project may skip it and use the time for Exercises 3–4. Parity can be
> completed as homework.

## Deliverables

1. **Assertion-enhanced UART TX** with 7 assertions + bug injection demo
2. **Parity-parameterized UART TX** with PPA comparison (PARITY_EN=0 vs 1)
3. **AI constraint-based TB** with: constraint spec + raw AI output + corrected TB + coverage analysis
4. **PPA analysis report** — comparison table with real data + 2 analysis paragraphs

## Supplementary Material

The following exercises from the original Day 14 build are available as supplementary
content for those who finish early or want additional practice:

- `supplementary/fsm_assertions/` — Add transition and output assertions to the traffic light FSM
- `supplementary/coverage_worksheet/` — Manual functional coverage analysis for the ALU

## Shared Resources
- `go_board.pcf` — Pin constraint file
- Reuse modules from `shared/lib/` for PPA analysis targets


---

## :material-download: Exercise Code

### Ex 1 — Uart Assertions

[:material-download: Starter .zip](../../downloads/day14/ex1_uart_assertions_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day14/ex1_uart_assertions_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex1_uart_assertions/starter/Makefile){ target=_blank }
- :material-chip: [`uart_tx_asserted.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex1_uart_assertions/starter/uart_tx_asserted.sv){ target=_blank }

### Ex 2 — Uart Parity

[:material-download: Starter .zip](../../downloads/day14/ex2_uart_parity_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day14/ex2_uart_parity_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex2_uart_parity/starter/Makefile){ target=_blank }
- :material-chip: [`tb_uart_tx_parity.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex2_uart_parity/starter/tb_uart_tx_parity.sv){ target=_blank }
- :material-chip: [`uart_tx_parity.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex2_uart_parity/starter/uart_tx_parity.sv){ target=_blank }

### Ex 3 — Ai Constraint Tb

[:material-download: Starter .zip](../../downloads/day14/ex3_ai_constraint_tb_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day14/ex3_ai_constraint_tb_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex3_ai_constraint_tb/starter/Makefile){ target=_blank }
- :material-text: [`README.md`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex3_ai_constraint_tb/starter/README.md){ target=_blank }
- :material-chip: [`tb_uart_tx_ai.sv`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex3_ai_constraint_tb/starter/tb_uart_tx_ai.sv){ target=_blank }

### Ex 4 — Ppa Analysis

[:material-download: Starter .zip](../../downloads/day14/ex4_ppa_analysis_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day14/ex4_ppa_analysis_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex4_ppa_analysis/starter/Makefile){ target=_blank }
- :material-text: [`ppa_exercise.md`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week4_day14/ex4_ppa_analysis/starter/ppa_exercise.md){ target=_blank }
