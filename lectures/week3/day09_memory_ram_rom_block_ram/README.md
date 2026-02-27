# Day 9: Memory — RAM, ROM & Block RAM

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | ROM in Verilog | ~12 min | `seg1_rom_in_verilog.html` |
| 2 | RAM in Verilog | ~12 min | `seg2_ram_in_verilog.html` |
| 3 | iCE40 Memory Resources | ~10 min | `seg3_ice40_memory_resources.html` |
| 4 | Practical Memory Applications | ~11 min | `seg4_memory_applications.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/rom_sync.v` | Parameterized synchronous ROM (block RAM inference) |
| `code/ram_sp.v` | Single-port synchronous RAM |
| `code/pattern_sequencer.v` | ROM-based LED pattern player |
| `code/pattern.mem` | Sample LED pattern data (binary) |

## Key Concepts
- `case`-based ROM vs. array + `$readmemh` ROM
- Async read → LUTs. Sync read → block RAM inference
- Single-port and dual-port RAM patterns
- iCE40 HX1K: 16 EBR × 4 Kbit = 64 Kbit total
- Read-before-write vs. write-first behavior
