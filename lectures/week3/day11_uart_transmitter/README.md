# Day 11: UART Transmitter

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The UART Protocol | ~15 min | `seg1_uart_protocol.html` |
| 2 | UART TX Architecture | ~15 min | `seg2_uart_tx_architecture.html` |
| 3 | Implementation Walk-Through | ~12 min | `seg3_uart_tx_implementation.html` |
| 4 | Connecting to a PC | ~8 min | `seg4_connecting_to_pc.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/uart_tx.v` | Complete UART TX module (8N1, parameterized) |
| `code/tb_uart_tx.v` | Self-checking testbench with frame capture |

## Key Concepts
- UART frame: idle → start → 8 data (LSB first) → stop
- 115200 baud @ 25 MHz = 217 clocks per bit
- Decomposition: FSM + PISO shift register + baud counter
- Valid/busy handshake protocol
- Go Board FTDI → USB → PC terminal at 115200/8N1
