# Day 3 Lab: Procedural Combinational Logic

> **Week 1, Session 3** · Accelerated HDL for Digital System Design · UCF ECE

## Overview

| | |
|---|---|
| **Duration** | ~2 hours |
| **Prerequisites** | Pre-class video (45 min): `always @(*)`, if/else, case, latch inference, blocking assignment |
| **Deliverable** | Mini-ALU with result on 7-segment, opcode selected by buttons |
| **Tools** | Yosys (critical for latch warnings!), nextpnr, iverilog |

## Learning Objectives

| SLO | Description |
|-----|-------------|
| 3.1 | Write `always @(*)` blocks for combinational logic |
| 3.2 | Implement decision structures (`if/else`, `case`, `casez`) and understand the hardware they imply |
| 3.3 | Identify and fix unintentional latch inference |
| 3.4 | Apply blocking assignment correctly in combinational blocks |
| 3.5 | Design a 4-bit ALU with procedural combinational logic |
| 3.6 | Use Yosys to detect latches in synthesized netlists |

## Exercises

### Exercise 1: Latch Hunting (20 min) ⚠️ MOST IMPORTANT
Find and fix intentional latch bugs. Run `make ex1_synth` and read every Yosys warning. Fix each bug in `starter/w1d3_ex1_latch_bugs.v`. Bug 3 is a trick question — explain why!

### Exercise 2: Priority Encoder (20 min)
Implement using `if/else` in `starter/w1d3_ex2_priority_encoder.v`. Compare with the provided `casez` alternative. Program and verify on board with `make ex2`.

### Exercise 3: 4-Bit ALU (35 min)
Four operations: ADD, SUB, AND, OR. Fill in `starter/w1d3_ex3_alu_4bit.v`. Fill in the verification matrix on paper before programming. Wire to board with `make ex3`.

### Exercise 4: BCD-to-7-Seg Decoder (20 min)
Case-based decoder with error display. Compare readability with Day 2's nested conditional.

### Exercise 5 — Stretch: ALU + 7-Seg Integration (25 min)
Full system: ALU result displayed on 7-seg, flags on LEDs.

## Deliverable Checklist

- [ ] Exercise 1: All latch warnings eliminated; Bug 3 explained
- [ ] Exercise 2: Priority encoder correct on board
- [ ] Exercise 3: ALU passes all verification matrix entries
- [ ] Exercise 4: BCD decoder shows 0-9, 'E' for 10-15
- [ ] At minimum: Exercise 3 (ALU) working on board

## Quick Reference

```
make ex1_synth    # Check for latch warnings
make ex2          make ex3          make ex4          make ex5
make clean
```
