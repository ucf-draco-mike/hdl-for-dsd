# Day 13: SystemVerilog for Design

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Why SystemVerilog? | ~8 min | `d13_s1_why_systemverilog.html` |
| 2 | `logic` — One Type to Rule Them All | ~10 min | `d13_s2_logic_type.html` |
| 3 | Intent-Based Always Blocks | ~12 min | `d13_s3_intent_based_always.html` |
| 4 | `enum`, `struct`, and `package` | ~15 min | `d13_s4_enum_struct_package.html` |

## Live-Demo Code Examples

Runnable companions to each `▶ LIVE DEMO` cue. Each lives in
`lecture_examples/week4_day13/<dir>/` with its own `Makefile`
(`make sim`, `make stat`, `make wave`, `make prog`).

| Slide | Title | Example dir | Source |
|-------|-------|-------------|--------|
| `d13_s2` | Modernize Your Debouncer | `d13_s2_ex1/` | `day13_ex01_debounce_sv.sv`, `tb_debounce_sv.sv` |
| `d13_s3` | UART TX Refactored in SV (always_ff / always_comb / typedef enum) | `d13_s3_ex2/` | `day13_ex02_uart_tx_sv.sv`, `tb_uart_tx_sv.sv` |
| `d13_s4` | State Names in GTKWave | `d13_s4_ex3/` | `day13_ex03_traffic_light_sv.sv`, `tb_traffic_light_sv.sv` |

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
lectures/week4_day13/
├── d13_s1_why_systemverilog.html
├── d13_s2_logic_type.html
├── d13_s3_intent_based_always.html
├── d13_s4_enum_struct_package.html
├── diagrams/
│   └── d13_safety_net.svg
├── day13_quiz.md
└── day13_readme.md

lecture_examples/week4_day13/
├── Makefile                       (dispatcher: ex1 / ex2 / ex3)
├── go_board.pcf
├── d13_s2_ex1/                    (s2 LIVE DEMO -- Modernize Your Debouncer)
│   ├── day13_ex01_debounce_sv.sv
│   ├── tb_debounce_sv.sv
│   └── Makefile
├── d13_s3_ex2/                    (s3 example -- UART TX in SV)
│   ├── day13_ex02_uart_tx_sv.sv
│   ├── tb_uart_tx_sv.sv
│   └── Makefile
└── d13_s4_ex3/                    (s4 LIVE DEMO -- State Names in GTKWave)
    ├── day13_ex03_traffic_light_sv.sv
    ├── tb_traffic_light_sv.sv
    └── Makefile
```

> The Day-13 **lab** exercises (ALU refactor, FSM refactor, UART refactor) live
> under `labs/week4_day13/` and are separate from the lecture-demo code above.
