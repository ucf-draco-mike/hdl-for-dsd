# Day 9 Lab: Memory — RAM, ROM & Block RAM

!!! abstract "Starter Code & Notebooks"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day09/day09_all_starter.zip){ .md-button .md-button--primary }

    [:material-notebook: Open in JupyterLab](http://localhost:8888/lab/tree/notebooks/labs/lab_day09.ipynb){ .md-button target=_blank }
    [:material-download: Download .ipynb](../../notebooks/labs/lab_day09.ipynb){ .md-button target=_blank }
    [:material-github: View on GitHub](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/notebooks/labs/lab_day09.ipynb){ .md-button target=_blank }

    Individual exercise downloads and file links are below each exercise.


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


---

## :material-download: Exercise Code

### Ex 1 — Rom Sequencer

[:material-download: Starter .zip](../../downloads/day09/ex1_rom_sequencer_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day09/ex1_rom_sequencer_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex1_rom_sequencer/starter/Makefile){ target=_blank }
- :material-chip: [`pattern_sequencer.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex1_rom_sequencer/starter/pattern_sequencer.v){ target=_blank }
- :material-hexadecimal: [`patterns.hex`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex1_rom_sequencer/starter/patterns.hex){ target=_blank }
- :material-chip: [`tb_pattern_sequencer.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex1_rom_sequencer/starter/tb_pattern_sequencer.v){ target=_blank }

### Ex 2 — Sync Ram

[:material-download: Starter .zip](../../downloads/day09/ex2_sync_ram_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day09/ex2_sync_ram_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex2_sync_ram/starter/Makefile){ target=_blank }
- :material-chip: [`ram_sp.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex2_sync_ram/starter/ram_sp.v){ target=_blank }
- :material-chip: [`tb_ram_sp.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex2_sync_ram/starter/tb_ram_sp.v){ target=_blank }

### Ex 3 — Initialized Ram

[:material-download: Starter .zip](../../downloads/day09/ex3_initialized_ram_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day09/ex3_initialized_ram_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex3_initialized_ram/starter/Makefile){ target=_blank }
- :material-hexadecimal: [`init_data.hex`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex3_initialized_ram/starter/init_data.hex){ target=_blank }
- :material-chip: [`ram_init.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex3_initialized_ram/starter/ram_init.v){ target=_blank }
- :material-chip: [`tb_ram_init.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex3_initialized_ram/starter/tb_ram_init.v){ target=_blank }

### Ex 4 — Dual Display

[:material-download: Starter .zip](../../downloads/day09/ex4_dual_display_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day09/ex4_dual_display_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex4_dual_display/starter/Makefile){ target=_blank }
- :material-hexadecimal: [`display1_patterns.hex`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex4_dual_display/starter/display1_patterns.hex){ target=_blank }
- :material-hexadecimal: [`display2_patterns.hex`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex4_dual_display/starter/display2_patterns.hex){ target=_blank }
- :material-chip: [`dual_rom.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex4_dual_display/starter/dual_rom.v){ target=_blank }

### Ex 5 — Register File

[:material-download: Starter .zip](../../downloads/day09/ex5_register_file_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day09/ex5_register_file_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex5_register_file/starter/Makefile){ target=_blank }
- :material-chip: [`register_file.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex5_register_file/starter/register_file.v){ target=_blank }
- :material-chip: [`tb_register_file.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day09/ex5_register_file/starter/tb_register_file.v){ target=_blank }
