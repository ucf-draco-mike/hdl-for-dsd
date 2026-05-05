# Day 12: UART RX, SPI & IP Integration

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | UART RX — Oversampling | ~15 min | `d12_s1_uart_rx_oversampling.html` |
| 2 | UART RX Implementation | ~15 min | `d12_s2_uart_rx_implementation.html` |
| 3 | SPI Protocol | ~12 min | `d12_s3_spi_protocol.html` |
| 4 | IP Integration Philosophy | ~8 min | `d12_s4_ip_integration.html` |

## Code Examples

| Slide | Example dir (`lecture_examples/week3_day12/...`) | Files | Description |
|-------|--------------------------------------------------|-------|-------------|
| `d12_s1` | `d12_s2_ex1/` | `plot_sampling.py` | Numerical visualization of why 16× is the right amount of oversampling |
| `d12_s2` | `d12_s2_ex1/` | `day12_ex01_uart_rx.v`, `tb_uart_rx.v` | UART RX with 16× oversampling, built-in 2-FF sync, self-checking TB |
| `d12_s3` | `d12_s3_ex2/` | `day12_ex02_spi_master.v`, `tb_spi_master.v` | SPI master (Mode 0) talking to a model ADC slave |
| `d12_s4` | `d12_s4_ex3/` | `day12_ex03_uart_loopback.v`, `uart_rx.v`, `uart_tx.v`, `hex_to_7seg.v`, `tb_uart_loopback.v` | RX→TX echo top module for Go Board integration test |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d12_oversampling.svg` | 16× oversampling: 16 ticks per bit, center sampling at tick 7-8 |
| `diagrams/d12_uart_rx_fsm.svg`  | UART RX FSM: IDLE → START → DATA → STOP |
| `diagrams/d12_spi_master_fsm.svg` | SPI master FSM: IDLE → ASSERT_CS → SHIFT → DEASSERT |

## Key Concepts
- RX must discover timing (TX controls it)
- 16× oversampling: center-of-bit sampling for noise immunity
- Start-bit verification: wait to center, re-check for glitches
- Loopback test = gold standard integration verification
- SPI: 4 wires, synchronous, full duplex, 4 modes (CPOL/CPHA)
- IP integration: read spec → wrapper → synchronizers → testbench → verify

## Week 3 Summary

Your module library after Week 3:
`rom_sync`, `ram_sp`, `pattern_sequencer`, `top_pll_demo`, `uart_tx`, `uart_rx`, `uart_loopback`, `spi_master`
+ all Week 1-2 modules.

Complete communication stack: FPGA ↔ PC via UART, plus SPI for fast peripherals. Ready for Week 4.

## Directory Structure

```
lectures/week3_day12/
├── d12_s1_uart_rx_oversampling.html
├── d12_s2_uart_rx_implementation.html
├── d12_s3_spi_protocol.html
├── d12_s4_ip_integration.html
├── diagrams/
│   ├── d12_oversampling.svg
│   ├── d12_uart_rx_fsm.svg
│   └── d12_spi_master_fsm.svg
├── day12_quiz.md
└── day12_readme.md

lecture_examples/week3_day12/
├── Makefile                    # day-level dispatcher (ex1/ex2/ex3)
├── go_board.pcf
├── d12_s2_ex1/                 # UART RX (slides s1, s2)
│   ├── Makefile
│   ├── day12_ex01_uart_rx.v
│   ├── tb_uart_rx.v
│   └── plot_sampling.py
├── d12_s3_ex2/                 # SPI master (slide s3)
│   ├── Makefile
│   ├── day12_ex02_spi_master.v
│   └── tb_spi_master.v
└── d12_s4_ex3/                 # UART loopback (slide s4 capstone)
    ├── Makefile
    ├── day12_ex03_uart_loopback.v
    ├── uart_rx.v
    ├── uart_tx.v
    ├── hex_to_7seg.v
    └── tb_uart_loopback.v
```
