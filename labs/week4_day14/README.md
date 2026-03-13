# Day 14 Lab: Verification Techniques, AI-Driven Testing & PPA Analysis

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
