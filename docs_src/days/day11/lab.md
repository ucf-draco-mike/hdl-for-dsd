# Day 11 Lab: UART Transmitter

!!! abstract "Starter Code & Notebooks"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day11/day11_all_starter.zip){ .md-button .md-button--primary }

    [:material-notebook: Open in JupyterLab](http://localhost:8888/lab/tree/notebooks/labs/lab_day11.ipynb){ .md-button target=_blank }
    [:material-download: Download .ipynb](../../notebooks/labs/lab_day11.ipynb){ .md-button target=_blank }
    [:material-github: View on GitHub](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/notebooks/labs/lab_day11.ipynb){ .md-button target=_blank }

    Individual exercise downloads are linked below each exercise.
    Full file listing: [Code & Notebooks Reference](code.md)


## Overview
Build and verify a complete UART TX module, then send "HELLO" from the
Go Board to your PC terminal.

## Prerequisites
- Pre-class video on UART protocol and TX architecture
- Working debounce module from Day 5
- Working hex_to_7seg from Day 2

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Baud Rate Generator | 15 min | 11.2 |
| 2 | UART TX Module + Testbench | 40 min | 11.3, 11.4 |
| 3 | Hardware Verification | 25 min | 11.5 |
| 4 | Multi-Character Sender | 20 min | 11.3, 11.5 |
| 5 | Parity Support (Stretch) | 15 min | 11.3 |

## Deliverables
1. Baud generator verified in simulation
2. UART TX with self-checking protocol-aware testbench (all tests pass)
3. "HELLO" received on PC terminal emulator

## Terminal Setup
| Platform | Command |
|----------|---------|
| Linux | `screen /dev/ttyUSB0 115200` |
| macOS | `screen /dev/cu.usbserial-* 115200` |
| Windows | PuTTY → COMx, 115200, 8N1 |


---

## :material-download: Exercise Code

### Ex 1 — Baud Gen

[:material-download: Starter .zip](../../downloads/day11/ex1_baud_gen_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day11/ex1_baud_gen_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex1_baud_gen/starter/Makefile){ target=_blank }
- :material-chip: [`baud_gen.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex1_baud_gen/starter/baud_gen.v){ target=_blank }
- :material-chip: [`tb_baud_gen.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex1_baud_gen/starter/tb_baud_gen.v){ target=_blank }

### Ex 2 — Uart Tx

[:material-download: Starter .zip](../../downloads/day11/ex2_uart_tx_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day11/ex2_uart_tx_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex2_uart_tx/starter/Makefile){ target=_blank }
- :material-chip: [`tb_uart_tx.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex2_uart_tx/starter/tb_uart_tx.v){ target=_blank }
- :material-chip: [`uart_tx.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex2_uart_tx/starter/uart_tx.v){ target=_blank }

### Ex 3 — Hardware Verify

[:material-download: Starter .zip](../../downloads/day11/ex3_hardware_verify_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day11/ex3_hardware_verify_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex3_hardware_verify/starter/Makefile){ target=_blank }
- :material-chip: [`top_uart_hello.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day11/ex3_hardware_verify/starter/top_uart_hello.v){ target=_blank }
