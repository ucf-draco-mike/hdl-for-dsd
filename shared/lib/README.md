# Shared Module Library

Reusable Verilog modules built incrementally during the course. Each module is tested with a self-checking testbench.

## Module Inventory

*Modules are added as they're developed in labs. This table will be populated throughout the course.*

| Module | Introduced | Description | Testbench |
|--------|-----------|-------------|-----------|
| `hex_to_7seg.v` | Day 2 | Hexadecimal to 7-segment decoder | `tb_hex_to_7seg.v` |
| `debounce.v` | Day 5 | Counter-based button debouncer (parameterized) | `tb_debounce.v` |
| `counter_mod_n.v` | Day 5 | Modulo-N counter (parameterized) | `tb_counter_mod_n.v` |
| `uart_tx.v` | Day 11 | UART transmitter (parameterized baud rate) | `tb_uart_tx.v` |
| `uart_rx.v` | Day 12 | UART receiver with 16× oversampling | `tb_uart_rx.v` |

## Usage

Copy or symlink modules into your project directory, or reference them in your Makefile:

```bash
# Symlink approach
ln -s ../../shared/lib/debounce.v .

# Or include in Makefile SRCS
SRCS = top.v ../../shared/lib/debounce.v ../../shared/lib/uart_tx.v
```

## Design Conventions

All shared modules follow these conventions:
- **ANSI-style** port declarations
- **Naming:** `i_` inputs, `o_` outputs, `r_` registers, `w_` wires
- **Parameterized** where appropriate (widths, thresholds, baud rates)
- **Self-checking testbench** included
- **Active-high internal logic** (active-low handled at boundaries)
