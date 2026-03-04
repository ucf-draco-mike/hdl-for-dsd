# Day 14 Lab: SystemVerilog for Verification

## Overview
Add assertions and functional coverage to existing designs. Learn the
verification maturity scale from directed tests to coverage-driven workflows.

## Prerequisites
- Pre-class video on assertions, coverage, and interfaces
- Working UART TX (SV version from Day 13)
- Working FSM from Day 7 or Day 13

## Toolchain Notes
- Immediate assertions: supported by `iverilog -g2012`
- Concurrent assertions: NOT supported by Icarus (write as documentation)
- Covergroups: NOT supported by Icarus (manual analysis exercise)

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | UART TX Assertions | 30 min | 14.1, 14.6 |
| 2 | FSM Transition Assertions | 25 min | 14.1, 14.2, 14.6 |
| 3 | Coverage Analysis | 25 min | 14.3, 14.6 |
| 4 | Final Project Work | 30 min | — |
| 5 | Interface-Based TB (Stretch) | 15 min | 14.4 |

## Deliverables
1. UART TX with 7 assertions; clean pass + targeted bug-injection failures
2. FSM assertions catching illegal transitions
3. Coverage table (manual or tool-generated) with gaps identified
4. Core project module simulated with at least 3 assertions
