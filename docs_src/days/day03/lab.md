# Day 3 Lab: Procedural Combinational Logic

!!! abstract "Starter Code"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day03/day03_all_starter.zip){ .md-button .md-button--primary }

    Individual exercise downloads and file links are below each exercise.


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

!!! code "Exercise 1 — Code"
    [:material-download: Starter .zip](../../downloads/day03/ex1_latch_bugs_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day03/ex1_latch_bugs_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex1_latch_bugs/starter/Makefile){ target=_blank } [:material-github: `ex1_latch_bugs.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex1_latch_bugs/starter/ex1_latch_bugs.v){ target=_blank } [:material-github: `tb_latch_bugs.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex1_latch_bugs/starter/tb_latch_bugs.v){ target=_blank }


Find and fix intentional latch bugs. Run `make ex1_synth` and read every Yosys warning. Fix each bug in `starter/w1d3_ex1_latch_bugs.v`. Bug 3 is a trick question — explain why!

### Exercise 2: Priority Encoder (20 min)

!!! code "Exercise 2 — Code"
    [:material-download: Starter .zip](../../downloads/day03/ex2_priority_encoder_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day03/ex2_priority_encoder_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex2_priority_encoder/starter/Makefile){ target=_blank } [:material-github: `ex2_priority_encoder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex2_priority_encoder/starter/ex2_priority_encoder.v){ target=_blank } [:material-github: `ex2_top_encoder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex2_priority_encoder/starter/ex2_top_encoder.v){ target=_blank } [:material-github: `tb_priority_encoder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex2_priority_encoder/starter/tb_priority_encoder.v){ target=_blank }


Implement using `if/else` in `starter/w1d3_ex2_priority_encoder.v`. Compare with the provided `casez` alternative. Program and verify on board with `make ex2`.

### Exercise 3: 4-Bit ALU (35 min)

!!! code "Exercise 3 — Code"
    [:material-download: Starter .zip](../../downloads/day03/ex3_alu_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day03/ex3_alu_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex3_alu/starter/Makefile){ target=_blank } [:material-github: `ex3_alu_4bit.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex3_alu/starter/ex3_alu_4bit.v){ target=_blank } [:material-github: `ex3_top_alu.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex3_alu/starter/ex3_top_alu.v){ target=_blank } [:material-github: `tb_alu_4bit.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex3_alu/starter/tb_alu_4bit.v){ target=_blank }


Four operations: ADD, SUB, AND, OR. Fill in `starter/w1d3_ex3_alu_4bit.v`. Fill in the verification matrix on paper before programming. Wire to board with `make ex3`.

### Exercise 4: BCD-to-7-Seg Decoder (20 min)

!!! code "Exercise 4 — Code"
    [:material-download: Starter .zip](../../downloads/day03/ex4_bcd_7seg_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day03/ex4_bcd_7seg_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex4_bcd_7seg/starter/Makefile){ target=_blank } [:material-github: `ex4_bcd_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex4_bcd_7seg/starter/ex4_bcd_to_7seg.v){ target=_blank } [:material-github: `ex4_top_bcd.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex4_bcd_7seg/starter/ex4_top_bcd.v){ target=_blank }


Case-based decoder with error display. Compare readability with Day 2's nested conditional.

### Exercise 5 — Stretch: ALU + 7-Seg Integration (25 min)

!!! code "Exercise 5 — Code"
    [:material-download: Starter .zip](../../downloads/day03/ex5_top_alu_display_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day03/ex5_top_alu_display_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex5_top_alu_display/starter/Makefile){ target=_blank } [:material-github: `ex3_alu_4bit.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex5_top_alu_display/starter/ex3_alu_4bit.v){ target=_blank } [:material-github: `ex4_bcd_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex5_top_alu_display/starter/ex4_bcd_to_7seg.v){ target=_blank } [:material-github: `ex5_top_alu_display.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day03/ex5_top_alu_display/starter/ex5_top_alu_display.v){ target=_blank }


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
