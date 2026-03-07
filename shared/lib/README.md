# Shared Module Library

Canonical, reusable modules used throughout the course. Every module includes
a matching self-checking testbench (`tb_<module>.v`).

## Testbench Utilities

`tb_utils.vh` provides shared infrastructure for all testbenches:

- `check_eq` / `check_eq_1` — assertion tasks with PASS/FAIL reporting
- `tb_summary` — prints a final pass/fail summary line
- Clock and reset generator snippets
- ASIC vs. FPGA gate-level simulation notes (use `+define+GATE_LEVEL`)

Include it in any testbench: `` `include "tb_utils.vh" ``

## Module Inventory

| Module | Description | Introduced | Testbench |
|--------|-------------|------------|-----------|
| `hex_to_7seg.v` | Hex-to-7-segment decoder (Go Board 7-segment) | Day 2 | `tb_hex_to_7seg.v` |
| `debounce.v` | Counter-based button debouncer with 2-FF sync | Day 5 | `tb_debounce.v` |
| `counter_mod_n.v` | Parameterized modulo-N counter | Day 5 | `tb_counter_mod_n.v` |
| `uart_tx.v` | UART transmitter (parameterized baud rate) | Day 11 | `tb_uart_tx.v` |
| `uart_rx.v` | UART receiver with 16× oversampling | Day 12 | `tb_uart_rx.v` |
| `baud_gen.v` | Standalone baud rate tick generator | Day 15 | `tb_baud_gen.v` |
| `edge_detect.v` | Rising/falling edge detector (1-cycle pulse) | Day 15 | `tb_edge_detect.v` |
| `heartbeat.v` | Parameterized LED heartbeat blinker | Day 15 | `tb_heartbeat.v` |

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
