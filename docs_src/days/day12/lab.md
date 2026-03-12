# Day 12 Lab: UART RX, SPI & IP Integration

!!! abstract "Starter Code & Notebooks"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day12/day12_all_starter.zip){ .md-button .md-button--primary }

    [:material-notebook: Open in JupyterLab](http://localhost:8888/lab/tree/notebooks/labs/lab_day12.ipynb){ .md-button target=_blank }
    [:material-download: Download .ipynb](../../notebooks/labs/lab_day12.ipynb){ .md-button target=_blank }
    [:material-github: View on GitHub](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/notebooks/labs/lab_day12.ipynb){ .md-button target=_blank }

    Individual exercise downloads and file links are below each exercise.


## Overview
Build the UART receiver with 16× oversampling, create a loopback test, and
explore SPI master design or IP integration.

## Prerequisites
- Working UART TX from Day 11
- Pre-class video on UART RX oversampling and SPI

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | UART RX Module + Testbench | 40 min | 12.1, 12.2 |
| 2 | UART Loopback on Hardware | 25 min | 12.3 |
| 3 | SPI Master Module | 30 min | 12.4, 12.5 |
| 4 | UART-Controlled LED Pattern | 15 min | 12.3 |
| 5 | UART-to-SPI Bridge (Stretch) | 15 min | 12.4, 12.5 |

## Deliverables
1. UART RX with all test bytes passing in simulation
2. **Loopback working on hardware** — type on PC, see echo (crown jewel!)
3. SPI master verified in simulation


---

## :material-download: Exercise Code

### Ex 1 — Uart Rx

[:material-download: Starter .zip](../../downloads/day12/ex1_uart_rx_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day12/ex1_uart_rx_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day12/ex1_uart_rx/starter/Makefile){ target=_blank }
- :material-chip: [`uart_rx.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day12/ex1_uart_rx/starter/uart_rx.v){ target=_blank }

### Ex 2 — Loopback

[:material-download: Starter .zip](../../downloads/day12/ex2_loopback_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day12/ex2_loopback_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day12/ex2_loopback/starter/Makefile){ target=_blank }
- :material-chip: [`top_uart_loopback.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day12/ex2_loopback/starter/top_uart_loopback.v){ target=_blank }

### Ex 3 — Spi Master

[:material-download: Starter .zip](../../downloads/day12/ex3_spi_master_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day12/ex3_spi_master_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day12/ex3_spi_master/starter/Makefile){ target=_blank }
- :material-chip: [`spi_master.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day12/ex3_spi_master/starter/spi_master.v){ target=_blank }
