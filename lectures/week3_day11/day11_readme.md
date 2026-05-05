# Day 11: UART Transmitter

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The UART Protocol | ~15 min | `d11_s1_uart_protocol.html` |
| 2 | UART TX Architecture | ~15 min | `d11_s2_uart_tx_architecture.html` |
| 3 | Implementation Walk-Through | ~12 min | `d11_s3_uart_tx_implementation.html` |
| 4 | Connecting to a PC | ~8 min | `d11_s4_connecting_to_pc.html` |

## Code Examples

| File | Description | Live Demo Slide | Example dir |
|------|-------------|-----------------|-------------|
| `day11_ex01_uart_tx.v` | Complete UART TX (8N1, parameterized, FSM + PISO + baud counter) with protocol-aware self-checking testbench | `d11_s1`, `d11_s2`, `d11_s3` | `lecture_examples/week3_day11/d11_s3_ex1/` |
| `day11_ex02_hello_emitter.v` | "HELLO\r\n" emitter that drives the UART TX once per ~200 ms — board-to-PC end-to-end | `d11_s4` | `lecture_examples/week3_day11/d11_s4_ex2/` |

For the canonical Live Demo registry, see [`docs/live_demos.md`](../../docs/live_demos.md).

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d11_uart_frame.svg` | UART frame for byte 0x48 ('H'): idle, start, 8 data LSB first, stop |
| `diagrams/d11_uart_tx_block.svg` | TX architecture: FSM + PISO shift register + baud counter |
| `diagrams/d11_uart_tx_fsm.svg`   | UART TX state machine: IDLE → START → DATA(×8) → STOP |

## Key Concepts
- UART frame: idle → start → 8 data (LSB first) → stop
- 115200 baud @ 25 MHz = 217 clocks per bit
- FSM + datapath decomposition (general design pattern)
- Valid/busy handshake protocol
- Go Board FTDI → USB → PC terminal (screen, PuTTY)

## Directory Structure

```
lectures/week3_day11/
├── d11_s1_uart_protocol.html
├── d11_s2_uart_tx_architecture.html
├── d11_s3_uart_tx_implementation.html
├── d11_s4_connecting_to_pc.html
├── diagrams/
│   ├── d11_uart_frame.svg
│   ├── d11_uart_tx_block.svg
│   └── d11_uart_tx_fsm.svg
├── day11_quiz.md
└── day11_readme.md

lecture_examples/week3_day11/
├── Makefile                          # dispatcher: ex1, ex2, sim/wave/stat/prog
├── go_board.pcf                      # shared pin constraints
├── d11_s3_ex1/                       # d11_s1, d11_s2, d11_s3 Live Demos
│   ├── Makefile
│   ├── day11_ex01_uart_tx.v          # UART TX (8N1, parameterized)
│   ├── tb_uart_tx.v                  # self-checking TB, byte = 'A'
│   ├── decode_uart.py                # d11_s1 demo: decode a scope CSV
│   └── capture.csv                   # d11_s1 sample capture (byte 'A')
└── d11_s4_ex2/                       # d11_s4 Live Demo
    ├── Makefile
    ├── day11_ex02_hello_emitter.v    # "HELLO\r\n" emitter top
    ├── uart_tx.v                     # copy of day11_ex01 (self-contained)
    ├── tb_hello_emitter.v            # self-checking TB
    └── rx_display.py                 # PC-side serial reader
```
