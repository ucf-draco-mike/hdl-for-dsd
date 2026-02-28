# Shared Module Library

Verified, reusable Verilog modules built across the course.
Each module has been tested with a self-checking testbench.

## Modules

| Module | Description | Built | Tested |
|--------|-------------|-------|--------|
| `hex_to_7seg` | Hex digit to 7-segment decoder | Day 2 | Day 6 |
| `debounce` | Counter-based button debouncer | Day 5 | Day 6 |
| `edge_detect` | Rising/falling edge detector | Day 5 | Day 6 |
| `counter_mod_n` | Parameterized modulo-N counter | Day 5 | Day 6 |
| `shift_reg_piso` | Parallel-in serial-out shift register | Day 5 | Day 6 |
| `uart_tx` | UART transmitter (8N1, parameterized) | Day 11 | Day 11 |
| `uart_rx` | UART receiver with oversampling | Day 12 | Day 12 |

## Usage

Copy or reference modules from this library into your project:
```bash
cp ../../shared/lib/debounce.v .
```

Or include in your Makefile SRCS path.
