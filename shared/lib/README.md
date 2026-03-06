# Shared Module Library

Canonical, reusable modules used throughout the course. Each module includes
a matching testbench (`tb_<module>.v`).

## Module Inventory

| Module | Description | Introduced | Testbench |
|--------|-------------|------------|-----------|
| `hex_to_7seg.v` | Hex-to-7-segment decoder (Go Board 7-segment) | Day 2 | `tb_hex_to_7seg.v` |
| `debounce.v` | Counter-based button debouncer with 2-FF sync | Day 5 | `tb_debounce.v` |
| `counter_mod_n.v` | Parameterized modulo-N counter | Day 5 | `tb_counter_mod_n.v` |
| `uart_tx.v` | UART transmitter (parameterized baud rate) | Day 11 | `tb_uart_tx.v` |
| `uart_rx.v` | UART receiver with 16× oversampling | Day 12 | `tb_uart_rx.v` |
| `baud_gen.v` | Standalone baud rate tick generator | Day 15 | — |
| `edge_detect.v` | Rising/falling edge detector (1-cycle pulse) | Day 15 | — |
| `heartbeat.v` | Parameterized LED heartbeat blinker | Day 15 | — |

## Port Naming Convention

These canonical modules use `i_`/`o_` prefixed port names. Note that earlier
lab exercises (Days 5–9) may use slightly different naming for pedagogical
reasons (e.g., `i_bouncy`/`o_clean` instead of `i_switch`/`o_switch` for the
debouncer). The implementations are functionally equivalent.

## Usage

Lab exercises include local copies of these modules. For final projects, you
can reference either the local copy or this shared library:

```bash
# From a project directory
iverilog -g2012 -o sim.vvp tb_top.v top.v ../../shared/lib/uart_tx.v
```
