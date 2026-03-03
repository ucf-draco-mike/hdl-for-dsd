# Day 9: Memory — RAM, ROM & Block RAM

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | ROM in Verilog | ~12 min | `d09_s1_rom_in_verilog.html` |
| 2 | RAM in Verilog | ~12 min | `d09_s2_ram_in_verilog.html` |
| 3 | iCE40 Memory Resources | ~10 min | `d09_s3_ice40_memory_resources.html` |
| 4 | Practical Memory Applications | ~11 min | `d09_s4_memory_applications.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day09_ex01_rom_sync.v` | Parameterized synchronous ROM with `$readmemb`, self-checking TB |
| `code/day09_ex02_ram_sp.v` | Single-port synchronous RAM (read-before-write), self-checking TB |
| `code/day09_ex03_pattern_sequencer.v` | ROM-driven LED pattern player, self-checking TB |
| `code/pattern.mem` | 16-entry walking-1 LED pattern (binary format) |

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
day09_memory_ram_rom_block_ram/
├── d09_s1_rom_in_verilog.html
├── d09_s2_ram_in_verilog.html
├── d09_s3_ice40_memory_resources.html
├── d09_s4_memory_applications.html
├── code/
│   ├── day09_ex01_rom_sync.v
│   ├── day09_ex02_ram_sp.v
│   ├── day09_ex03_pattern_sequencer.v
│   └── pattern.mem
├── diagrams/
│   ├── d09_mem_landscape.svg
│   └── d09_sync_vs_async.svg
├── day09_quiz.md
└── day09_readme.md
```
