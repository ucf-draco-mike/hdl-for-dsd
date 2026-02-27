# Day 5: Counters, Shift Registers & Debouncing

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Counter Variations | ~10 min | `seg1_counter_variations.html` |
| 2 | Shift Registers | ~12 min | `seg2_shift_registers.html` |
| 3 | Metastability & Synchronizers | ~12 min | `seg3_metastability_synchronizers.html` |
| 4 | Button Debouncing | ~11 min | `seg4_button_debouncing.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/counter_mod_n.v` | Parameterized modulo-N counter with `$clog2` |
| `code/shift_reg_piso.v` | PISO shift register (UART TX building block) |
| `code/synchronizer.v` | 2-FF metastability synchronizer |
| `code/debounce.v` | Counter-based debouncer with built-in synchronizer |

## Key Concepts
- Counter variations: modulo-N, up/down, loadable
- Shift register types: SISO, SIPO, PISO, PIPO
- Metastability, setup/hold, and 2-FF synchronizers
- Counter-based debouncing, edge detection
- Input pipeline: sync → debounce → edge detect
