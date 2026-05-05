# Day 9: Memory — RAM, ROM & Block RAM

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | ROM in Verilog | ~12 min | `d09_s1_rom_in_verilog.html` |
| 2 | RAM in Verilog | ~12 min | `d09_s2_ram_in_verilog.html` |
| 3 | iCE40 Memory Resources | ~10 min | `d09_s3_ice40_memory_resources.html` |
| 4 | Practical Memory Applications | ~11 min | `d09_s4_memory_applications.html` |

## Code Examples

Live demos for this day live in `lecture_examples/week3_day09/`. Each
example has its own self-contained directory with a Makefile (`make sim`,
`make wave`, `make stat`, `make synth`, `make prog`, `make clean`) and a
self-checking testbench.

| Example | Slide | Module(s) | Init file | Description |
|---------|-------|-----------|-----------|-------------|
| `d09_s1_ex1/` | 9.1 ROM | `rom_case`, `rom_array` | `hello.hex` | Case-vs-array ROM comparison; `make stat_case` and `make stat_array` show the LUT-vs-EBR difference |
| `d09_s2_ex2/` | 9.2 RAM | `ram_1p` | — | 1024×8 single-port synchronous RAM that infers `SB_RAM40_4K`; 64-test self-check |
| `d09_s4_ex3/` | 9.4 Apps | `pattern_sequencer` (uses `rom_array`) + `top` | `pattern.hex` | LED pattern player: step timer + address counter + ROM. Edit `pattern.hex` to change the animation |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d09_mem_landscape.svg` | iCE40 memory landscape: LUT RAM vs. Block RAM vs. External |
| `diagrams/d09_sync_vs_async.svg` | Side-by-side: async read (LUTs) vs. sync read (EBR) |

## Key Concepts
- `case`-ROM vs. array + `$readmemh` ROM
- Async read → LUTs; sync read → block RAM (EBR) inference
- Single-port RAM: read-before-write vs. write-first
- iCE40 HX1K: 16 EBR × 4 Kbit = 64 Kbit total
- Counter + ROM = sequencer (LED patterns, sine waves, fonts)

## Directory Structure

```
lectures/week3_day09/                       # slides + notes
├── d09_s1_rom_in_verilog.html
├── d09_s2_ram_in_verilog.html
├── d09_s3_ice40_memory_resources.html
├── d09_s4_memory_applications.html
├── diagrams/
│   ├── d09_mem_landscape.svg
│   └── d09_sync_vs_async.svg
├── day09_quiz.md
└── day09_readme.md

lecture_examples/week3_day09/               # demo code (this file's targets)
├── Makefile                                # dispatches ex1 / ex2 / ex3
├── go_board.pcf                            # iCE40 HX1K (Go Board) pin map
├── d09_s1_ex1/    rom_case.v + rom_array.v + hello.hex + tb_rom.v
├── d09_s2_ex2/    ram_1p.v                 + tb_ram_1p.v
└── d09_s4_ex3/    pattern_sequencer.v + rom_array.v + top.v
                   + pattern.hex + tb_pattern_sequencer.v
```
