# Day 12: UART RX, SPI & IP Integration

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | UART RX — Oversampling | ~15 min | `seg1_uart_rx_oversampling.html` |
| 2 | UART RX Implementation | ~15 min | `seg2_uart_rx_implementation.html` |
| 3 | SPI Protocol | ~12 min | `seg3_spi_protocol.html` |
| 4 | IP Integration Philosophy | ~8 min | `seg4_ip_integration.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/uart_rx.v` | Complete UART RX with built-in synchronizer |
| `code/uart_loopback.v` | Loopback top module (RX → TX echo test) |

## Key Concepts
- RX requires bit-boundary detection (TX controls timing)
- 16× oversampling: center-of-bit sampling via half-bit alignment
- Start-bit detection: falling edge → half-bit delay → verify
- Loopback test: type in terminal, see echo = both modules work
- SPI: SCLK, MOSI, MISO, CS_N — synchronous, 4 modes (CPOL/CPHA)
- IP integration checklist: docs, wrapper, synchronizers, testbench
