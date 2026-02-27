# Day 13: SystemVerilog for Design

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Why SystemVerilog? | ~8 min | `seg1_why_systemverilog.html` |
| 2 | `logic` — One Type to Rule Them All | ~10 min | `seg2_logic_type.html` |
| 3 | Intent-Based Always Blocks | ~12 min | `seg3_intent_based_always.html` |
| 4 | `enum`, `struct`, and `package` | ~15 min | `seg4_enum_struct_package.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/uart_tx_sv.sv` | UART TX refactored with logic, always_ff, enum |
| `code/alu_sv.sv` | ALU refactored with always_comb and enum opcodes |

## Key Concepts
- `logic` replaces both `wire` and `reg` (single-driver restriction)
- `always_ff`: enforces clock edge, non-blocking, single driver
- `always_comb`: auto-sensitivity, errors on latch inference (biggest win)
- `always_latch`: documents intentional latches (rare)
- `enum`: type-safe FSM states, `.name()` for debug, zero cost
- `struct packed`: grouped signals with dot notation, synthesizable
- `package`: shared types/constants across modules
- Toolchain: `iverilog -g2012`, `yosys read_verilog -sv`
