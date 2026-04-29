# Day 4 Lab: Sequential Logic Fundamentals

!!! abstract "Starter Code"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day04/day04_all_starter.zip){ .md-button .md-button--primary }

    Individual exercise downloads and file links are below each exercise.


> **Week 1, Session 4** · Accelerated HDL for Digital System Design · UCF ECE

## Overview

| | |
|---|---|
| **Duration** | ~2 hours |
| **Prerequisites** | Pre-class video (50 min): clocks, edges, nonblocking assignment, flip-flops, resets, counters |
| **Deliverable** | LED blinker at ~1 Hz + counter value on 7-segment display |
| **Tools** | Icarus Verilog + GTKWave (simulation), Yosys + nextpnr (synthesis) |

## Learning Objectives

| SLO | Description |
|-----|-------------|
| 4.1 | Write `always @(posedge clk)` blocks with synchronous reset |
| 4.2 | Use nonblocking assignment (`<=`) correctly in sequential blocks |
| 4.3 | Implement D flip-flops with enable and reset |
| 4.4 | Design counter-based clock dividers |
| 4.5 | Debug sequential logic using Icarus Verilog simulation and GTKWave |
| 4.6 | Integrate sequential and combinational modules into a working system |

## Exercises

### Exercise 1: D Flip-Flop — Simulate First! (25 min)

!!! code "Exercise 1 — Code"
    [:material-download: Starter .zip](../../downloads/day04/ex1_d_ff_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day04/ex1_d_ff_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex1_d_ff/starter/Makefile){ target=_blank } [:material-github: `ex1_d_ff.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex1_d_ff/starter/ex1_d_ff.v){ target=_blank } [:material-github: `ex1_tb_d_ff.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex1_d_ff/starter/ex1_tb_d_ff.v){ target=_blank }


Implement in `starter/w1d4_ex1_d_ff.v`, run testbench with `make ex1_sim`. Open waveforms in GTKWave. Mark the moment `i_d` changes vs. when `o_q` changes.

### Exercise 2: Loadable Register (20 min)

!!! code "Exercise 2 — Code"
    [:material-download: Starter .zip](../../downloads/day04/ex2_register_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day04/ex2_register_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex2_register/starter/Makefile){ target=_blank } [:material-github: `ex2_register_4bit.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex2_register/starter/ex2_register_4bit.v){ target=_blank } [:material-github: `ex2_tb_register.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex2_register/starter/ex2_tb_register.v){ target=_blank }


4-bit register with load enable. `make ex2_sim` to verify load/hold/reset behavior.

### Exercise 3: LED Blinker (25 min) ★ KEY EXERCISE

!!! code "Exercise 3 — Code"
    [:material-download: Starter .zip](../../downloads/day04/ex3_led_blinker_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day04/ex3_led_blinker_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex3_led_blinker/starter/Makefile){ target=_blank } [:material-github: `ex3_led_blinker.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex3_led_blinker/starter/ex3_led_blinker.v){ target=_blank } [:material-github: `tb_led_blinker.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex3_led_blinker/starter/tb_led_blinker.v){ target=_blank }


Free-running counter with multi-speed LED output. `make ex3` to program. LED1 slowest, LED4 fastest — visually demonstrates binary counting.

### Exercise 4: 7-Segment Counter — Week 1 Capstone (30 min) ★ CAPSTONE

!!! code "Exercise 4 — Code"
    [:material-download: Starter .zip](../../downloads/day04/ex4_seg_counter_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day04/ex4_seg_counter_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex4_seg_counter/starter/Makefile){ target=_blank } [:material-github: `ex4_seg_counter.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex4_seg_counter/starter/ex4_seg_counter.v){ target=_blank }


Running hex counter on the display. Integrates clock division + counting + combinational decoding. `make ex4`.

### Exercise 5: Dual-Speed Blinker (15 min)

!!! code "Exercise 5 — Code"
    [:material-download: Starter .zip](../../downloads/day04/ex5_dual_blinker_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day04/ex5_dual_blinker_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex5_dual_blinker/starter/Makefile){ target=_blank } [:material-github: `ex5_dual_blinker.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex5_dual_blinker/starter/ex5_dual_blinker.v){ target=_blank }


Two independent dividers, complementary LED pairs. `make ex5`.

### Exercise 6 — Stretch: Up/Down Counter (if time permits)

!!! code "Exercise 6 — Code"
    [:material-download: Starter .zip](../../downloads/day04/ex6_updown_counter_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day04/ex6_updown_counter_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex6_updown_counter/starter/Makefile){ target=_blank } [:material-github: `ex6_updown_counter.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day04/ex6_updown_counter/starter/ex6_updown_counter.v){ target=_blank }


Button-controlled counter on 7-seg. Will be bouncy without debouncing — this previews Day 5!

## Deliverable Checklist

- [ ] Exercise 1: Testbench passes, waveforms examined in GTKWave
- [ ] Exercise 2: Testbench passes all 5 test cases
- [ ] Exercise 3: LEDs blink at visible rates on board
- [ ] Exercise 4: 7-seg counts 0→F at readable speed ← **primary deliverable**
- [ ] At minimum: Exercise 3 (LED blinker) working on board

## Quick Reference

```
make ex1_sim # Simulate D flip-flop
make ex2_sim # Simulate register
make ex3 # Program LED blinker
make ex4 # Program 7-seg counter (capstone)
make ex5 # Program dual blinker
make ex6 # Program up/down counter (stretch)
make clean
```

## End of Week 1! 🎉

You went from zero HDL to a counter running on a display in 4 days. That's a real accomplishment. Next week: debouncing, testbench methodology, FSMs, and parameterization.
