# Day 5: Counters, Shift Registers & Debouncing

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Counter Variations | ~10 min | `d05_s1_counter_variations.html` |
| 2 | Shift Registers | ~12 min | `d05_s2_shift_registers.html` |
| 3 | Metastability & Synchronizers | ~12 min | `d05_s3_metastability_synchronizers.html` |
| 4 | Button Debouncing | ~11 min | `d05_s4_button_debouncing.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day05_ex01_counter_mod_n.v` | Parameterized modulo-N counter with `$clog2`, self-test |
| `code/day05_ex02_shift_reg_piso.v` | PISO shift register (UART TX building block), self-test |
| `code/day05_ex03_synchronizer.v` | 2-FF metastability synchronizer |
| `code/day05_ex04_debounce.v` | Counter-based debouncer with built-in sync, self-test |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d05_synchronizer.svg` | 2-FF synchronizer schematic with metastability annotation |
| `diagrams/d05_bounce_waveform.svg` | Button bounce → debounced output waveform comparison |

## Key Concepts
- Counter variations: modulo-N, up/down, loadable
- Shift register types: SISO, SIPO, PISO, PIPO
- Metastability, setup/hold, and 2-FF synchronizers
- Counter-based debouncing, edge detection
- Input pipeline: sync → debounce → edge detect

## Directory Structure

```
day05_counters_shift_registers_debouncing/
├── d05_s1_counter_variations.html
├── d05_s2_shift_registers.html
├── d05_s3_metastability_synchronizers.html
├── d05_s4_button_debouncing.html
├── code/
│   ├── day05_ex01_counter_mod_n.v
│   ├── day05_ex02_shift_reg_piso.v
│   ├── day05_ex03_synchronizer.v
│   └── day05_ex04_debounce.v
├── diagrams/
│   ├── d05_synchronizer.svg
│   └── d05_bounce_waveform.svg
├── day05_quiz.md
└── day05_readme.md
```
