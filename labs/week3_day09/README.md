# Day 9 Lab: Memory — RAM, ROM & Block RAM

## Overview
Today you'll work with on-chip memory: ROM for lookup tables and pattern
storage, RAM for read/write data, and the iCE40's block RAM (EBR) resources.
You'll learn to initialize memory from `.hex` files and write testbenches that
verify memory operations with proper handling of synchronous read latency.

## Prerequisites
- Completed Day 8 lab (hierarchical design)
- Pre-class video on ROM, RAM, and iCE40 memory resources watched

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | ROM Pattern Sequencer | 30 min | 9.1, 9.5, 9.6 |
| 2 | Synchronous RAM — Write/Read | 30 min | 9.2, 9.3, 9.4 |
| 3 | Initialized RAM with `$readmemh` | 25 min | 9.2, 9.6 |
| 4 | Dual-Display Pattern Player (stretch) | 20 min | 9.5, 9.6 |
| 5 | Register File (stretch) | 20 min | 9.2 |

## Key Concepts
- `case`-based ROM vs. array + `$readmemh` ROM
- Async read → LUT inference. Sync read → block RAM inference
- Single-port synchronous RAM with read-before-write behavior
- iCE40 HX1K: 16 EBR blocks × 4 Kbit = 64 Kbit total block RAM
- One-cycle read latency is the #1 source of memory bugs

## Deliverables
- [ ] ROM pattern sequencer displaying on LEDs and 7-seg (Ex 1)
- [ ] RAM write/read verified with self-checking testbench (Ex 2)
- [ ] Initialized RAM with `.hex` file verified (Ex 3)
- [ ] `make stat` output showing block RAM inference for Ex 2
