# Day 12: UART RX, SPI & IP Integration

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | UART RX — Oversampling | ~15 min | `d12_s1_uart_rx_oversampling.html` |
| 2 | UART RX Implementation | ~15 min | `d12_s2_uart_rx_implementation.html` |
| 3 | SPI Protocol | ~12 min | `d12_s3_spi_protocol.html` |
| 4 | IP Integration Philosophy | ~8 min | `d12_s4_ip_integration.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day12_ex01_uart_rx.v` | UART RX with 16× oversampling, built-in 2-FF sync, self-checking TB |
| `code/day12_ex02_uart_loopback.v` | RX → TX echo top module for Go Board integration test |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d12_oversampling.svg` | 16× oversampling: 16 ticks per bit, center sampling at tick 7-8 |

## Key Concepts
- RX must discover timing (TX controls it)
- 16× oversampling: center-of-bit sampling for noise immunity
- Start-bit verification: wait to center, re-check for glitches
- Loopback test = gold standard integration verification
- SPI: 4 wires, synchronous, full duplex, 4 modes (CPOL/CPHA)
- IP integration: read spec → wrapper → synchronizers → testbench → verify

## Week 3 Summary

Your module library after Week 3:
`rom_sync`, `ram_sp`, `pattern_sequencer`, `top_pll_demo`, `uart_tx`, `uart_rx`, `uart_loopback`
+ all Week 1-2 modules.

Complete communication stack: FPGA ↔ PC via UART. Ready for Week 4.

## Directory Structure

```
day12_uart_rx_spi_ip_integration/
├── d12_s1_uart_rx_oversampling.html
├── d12_s2_uart_rx_implementation.html
├── d12_s3_spi_protocol.html
├── d12_s4_ip_integration.html
├── code/
│   ├── day12_ex01_uart_rx.v
│   └── day12_ex02_uart_loopback.v
├── diagrams/
│   └── d12_oversampling.svg
├── day12_quiz.md
└── day12_readme.md
```
