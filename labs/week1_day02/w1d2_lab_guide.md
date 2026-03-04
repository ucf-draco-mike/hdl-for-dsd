# Day 2 Lab: Combinational Building Blocks

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
Reduction operators on a 4-bit vector → LED display. Fill in `starter/w1d2_ex1_vector_ops.v`.

### Exercise 2: 2:1 → 4:1 Multiplexer (25 min)
Build a 4:1 mux from three 2:1 mux instances. Fill in `starter/w1d2_ex2_mux4to1.v` and `starter/w1d2_ex2_top_mux.v`. Use `make ex2_show` to visualize the netlist in Yosys.

### Exercise 3: 4-Bit Ripple-Carry Adder (25 min)
Chain four `full_adder` modules. Fill in `starter/w1d2_ex3_ripple_adder_4bit.v` and `starter/w1d2_ex3_top_adder.v`.

### Exercise 4: Hex-to-7-Segment Decoder (30 min)
Complete the nested conditional decoder in `starter/w1d2_ex4_hex_to_7seg.v`. Wire up the top module. Cycle through all 16 button combinations and verify each hex digit displays correctly.

### Exercise 5 — Stretch: Adder + Display Integration (20 min)
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
