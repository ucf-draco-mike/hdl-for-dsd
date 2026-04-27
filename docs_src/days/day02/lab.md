# Day 2 Lab: Combinational Building Blocks

!!! abstract "Starter Code"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day02/day02_all_starter.zip){ .md-button .md-button--primary }

    Individual exercise downloads and file links are below each exercise.


> **Week 1, Session 2** · Accelerated HDL for Digital System Design · UCF ECE

## Overview

| | |
|---|---|
| **Duration** | ~2 hours |
| **Prerequisites** | Pre-class video (45 min): data types, vectors, operators, continuous assignment |
| **Deliverable** | 7-segment display showing button states as hex digit, programmed on board |
| **Tools** | Yosys, nextpnr-ice40, icepack, iceprog |

## Learning Objectives

| SLO | Description |
|-----|-------------|
| 2.1 | Declare and manipulate vectors using bit selection, concatenation, and replication |
| 2.2 | Apply bitwise, arithmetic, and reduction operators correctly |
| 2.3 | Build multiplexers using the conditional operator |
| 2.4 | Compose modules hierarchically using named port connections |
| 2.5 | Design a hex-to-7-segment decoder targeting the Go Board display |
| 2.6 | Use properly sized literals to avoid width mismatch warnings |

## Exercises

### Exercise 1: Vector Operations Warm-Up (20 min)

!!! code "Exercise 1 — Code"
    [:material-download: Starter .zip](../../downloads/day02/ex1_vector_ops_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day02/ex1_vector_ops_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex1_vector_ops/starter/Makefile){ target=_blank } [:material-github: `ex1_vector_ops.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex1_vector_ops/starter/ex1_vector_ops.v){ target=_blank }


Reduction operators on a 4-bit vector → LED display. Fill in `starter/w1d2_ex1_vector_ops.v`.

### Exercise 2: 2:1 → 4:1 Multiplexer (25 min)

!!! code "Exercise 2 — Code"
    [:material-download: Starter .zip](../../downloads/day02/ex2_mux_hierarchy_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day02/ex2_mux_hierarchy_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex2_mux_hierarchy/starter/Makefile){ target=_blank } [:material-github: `ex2_mux2to1.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex2_mux_hierarchy/starter/ex2_mux2to1.v){ target=_blank } [:material-github: `ex2_mux4to1.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex2_mux_hierarchy/starter/ex2_mux4to1.v){ target=_blank } [:material-github: `ex2_top_mux.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex2_mux_hierarchy/starter/ex2_top_mux.v){ target=_blank } [:material-github: `tb_mux.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex2_mux_hierarchy/starter/tb_mux.v){ target=_blank }


Build a 4:1 mux from three 2:1 mux instances. Fill in `starter/w1d2_ex2_mux4to1.v` and `starter/w1d2_ex2_top_mux.v`. Use `make ex2_show` to visualize the netlist in Yosys.

### Exercise 3: 4-Bit Ripple-Carry Adder (25 min)

!!! code "Exercise 3 — Code"
    [:material-download: Starter .zip](../../downloads/day02/ex3_ripple_adder_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day02/ex3_ripple_adder_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex3_ripple_adder/starter/Makefile){ target=_blank } [:material-github: `ex3_full_adder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex3_ripple_adder/starter/ex3_full_adder.v){ target=_blank } [:material-github: `ex3_ripple_adder_4bit.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex3_ripple_adder/starter/ex3_ripple_adder_4bit.v){ target=_blank } [:material-github: `ex3_top_adder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex3_ripple_adder/starter/ex3_top_adder.v){ target=_blank } [:material-github: `tb_adder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex3_ripple_adder/starter/tb_adder.v){ target=_blank }


Chain four `full_adder` modules. Fill in `starter/w1d2_ex3_ripple_adder_4bit.v` and `starter/w1d2_ex3_top_adder.v`.

### Exercise 4: Hex-to-7-Segment Decoder (30 min)

!!! code "Exercise 4 — Code"
    [:material-download: Starter .zip](../../downloads/day02/ex4_7seg_decoder_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day02/ex4_7seg_decoder_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex4_7seg_decoder/starter/Makefile){ target=_blank } [:material-github: `ex4_hex_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex4_7seg_decoder/starter/ex4_hex_to_7seg.v){ target=_blank } [:material-github: `ex4_top_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex4_7seg_decoder/starter/ex4_top_7seg.v){ target=_blank } [:material-github: `tb_hex_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex4_7seg_decoder/starter/tb_hex_to_7seg.v){ target=_blank }


Complete the nested conditional decoder in `starter/w1d2_ex4_hex_to_7seg.v`. Wire up the top module. Cycle through all 16 button combinations and verify each hex digit displays correctly.

### Exercise 5 — Stretch: Adder + Display Integration (20 min)

!!! code "Exercise 5 — Code"
    [:material-download: Starter .zip](../../downloads/day02/ex5_top_adder_display_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day02/ex5_top_adder_display_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex5_top_adder_display/starter/Makefile){ target=_blank } [:material-github: `ex3_full_adder.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex5_top_adder_display/starter/ex3_full_adder.v){ target=_blank } [:material-github: `ex3_ripple_adder_4bit.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex5_top_adder_display/starter/ex3_ripple_adder_4bit.v){ target=_blank } [:material-github: `ex4_hex_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex5_top_adder_display/starter/ex4_hex_to_7seg.v){ target=_blank } [:material-github: `ex5_top_adder_display.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day02/ex5_top_adder_display/starter/ex5_top_adder_display.v){ target=_blank }


Combine the adder and decoder into a single design that displays the sum on 7-seg.

## Deliverable Checklist

- [ ] Exercise 1: LEDs respond correctly to reduction operations
- [ ] Exercise 2: 4:1 mux works on board
- [ ] Exercise 3: Adder shows correct sums on LEDs
- [ ] Exercise 4: All 16 hex digits display on 7-segment
- [ ] At minimum: Exercise 4 (hex display) programmed and working

## Quick Reference

```
make ex1          make ex2          make ex3
make ex4          make ex5          make ex2_show
make clean
```
