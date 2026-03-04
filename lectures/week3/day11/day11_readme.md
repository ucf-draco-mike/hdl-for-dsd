# Day 11: UART Transmitter

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The UART Protocol | ~15 min | `d11_s1_uart_protocol.html` |
| 2 | UART TX Architecture | ~15 min | `d11_s2_uart_tx_architecture.html` |
| 3 | Implementation Walk-Through | ~12 min | `d11_s3_uart_tx_implementation.html` |
| 4 | Connecting to a PC | ~8 min | `d11_s4_connecting_to_pc.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day11_ex01_uart_tx.v` | Complete UART TX (8N1, parameterized, FSM + PISO + baud counter) with protocol-aware self-checking testbench |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d11_uart_frame.svg` | UART frame for byte 0x48 ('H'): idle, start, 8 data LSB first, stop |
| `diagrams/d11_uart_tx_block.svg` | TX architecture: FSM + PISO shift register + baud counter |

## Key Concepts
- UART frame: idle → start → 8 data (LSB first) → stop
- 115200 baud @ 25 MHz = 217 clocks per bit
- FSM + datapath decomposition (general design pattern)
- Valid/busy handshake protocol
- Go Board FTDI → USB → PC terminal (screen, PuTTY)

## Directory Structure

```
day11_uart_transmitter/
├── d11_s1_uart_protocol.html
├── d11_s2_uart_tx_architecture.html
├── d11_s3_uart_tx_implementation.html
├── d11_s4_connecting_to_pc.html
├── code/
│   └── day11_ex01_uart_tx.v
├── diagrams/
│   ├── d11_uart_frame.svg
│   └── d11_uart_tx_block.svg
├── day11_quiz.md
└── day11_readme.md
```
