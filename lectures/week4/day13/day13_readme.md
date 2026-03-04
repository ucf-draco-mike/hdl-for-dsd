# Day 13: SystemVerilog for Design

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Why SystemVerilog? | ~8 min | `d13_s1_why_systemverilog.html` |
| 2 | `logic` — One Type to Rule Them All | ~10 min | `d13_s2_logic_type.html` |
| 3 | Intent-Based Always Blocks | ~12 min | `d13_s3_intent_based_always.html` |
| 4 | `enum`, `struct`, and `package` | ~15 min | `d13_s4_enum_struct_package.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day13_ex01_uart_tx_sv.sv` | UART TX refactored: logic, always_ff, always_comb, enum states |
| `code/day13_ex02_alu_sv.sv` | ALU refactored: always_comb, enum opcodes, self-checking TB |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d13_safety_net.svg` | Safety comparison: Verilog risks vs. SV protections |

## Key Concepts
- `logic` replaces `wire` + `reg` (single-driver restriction)
- `always_ff`: enforces clock edge, warns on blocking assignments
- `always_comb`: auto-sensitivity, **errors on latch inference**
- `enum`: type-safe FSM states, `.name()` for debug, zero cost
- `struct packed`: grouped signals with dot notation, synthesizable
- `package`: shared types/constants across modules
- Toolchain: `iverilog -g2012`, `yosys read_verilog -sv`

## Directory Structure

```
day13_systemverilog_for_design/
├── d13_s1_why_systemverilog.html
├── d13_s2_logic_type.html
├── d13_s3_intent_based_always.html
├── d13_s4_enum_struct_package.html
├── code/
│   ├── day13_ex01_uart_tx_sv.sv
│   └── day13_ex02_alu_sv.sv
├── diagrams/
│   └── d13_safety_net.svg
├── day13_quiz.md
└── day13_readme.md
```
