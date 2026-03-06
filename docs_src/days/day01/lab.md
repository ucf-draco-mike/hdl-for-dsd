# Day 1 Lab: Welcome to Hardware Thinking

!!! abstract "Starter Code & Notebooks"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day01/day01_all_starter.zip){ .md-button .md-button--primary }

    [:material-notebook: Open in JupyterLab](http://localhost:8888/lab/tree/notebooks/labs/lab_day01.ipynb){ .md-button target=_blank }
    [:material-download: Download .ipynb](../../notebooks/labs/lab_day01.ipynb){ .md-button target=_blank }
    [:material-github: View on GitHub](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/notebooks/labs/lab_day01.ipynb){ .md-button target=_blank }

    Individual exercise downloads are linked below each exercise.
    Full file listing: [Code & Notebooks Reference](code.md)


> **Week 1, Session 1** · Accelerated HDL for Digital System Design · UCF ECE

## Overview

| | |
|---|---|
| **Duration** | ~2 hours |
| **Prerequisites** | Pre-class video (40 min): HDL vs. software, synthesis vs. simulation, module anatomy, digital logic refresher |
| **Deliverable** | Buttons-to-LEDs with at least one logic modification, programmed on Go Board |
| **Tools** | Yosys, nextpnr-ice40, icepack, iceprog, Icarus Verilog, GTKWave |

## Learning Objectives

| SLO | Description |
|-----|-------------|
| 1.1 | Explain why `assign` statements execute concurrently, not sequentially |
| 1.3 | Write a syntactically correct Verilog module with ANSI-style ports |
| 1.4 | Execute the full iCE40 toolchain: Yosys → nextpnr → icepack → iceprog |
| 1.5 | Use a `.pcf` file to map HDL signals to physical Go Board pins |
| 1.6 | Predict and verify the behavior of active-high LEDs and buttons |

## Exercises

### Setup Verification (15 min)

Verify the full toolchain is installed and the Go Board is connected. Run the checklist in `starter/setup_check.sh` or verify manually:

```bash
yosys --version
nextpnr-ice40 --version
icepack
iceprog
iverilog -V
gtkwave --version
```

If any tool is missing, **stop and fix it now** — don't proceed with a broken toolchain.

---

### Exercise 1: LED On — The Simplest Possible Design (20 min)

!!! code "Exercise 1 — Code"
    [:material-download: Starter .zip](../../downloads/day01/ex1_led_on_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day01/ex1_led_on_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day01/ex1_led_on/starter/Makefile){ target=_blank }



**Goal:** Write, synthesize, and program the absolute minimum Verilog design. Confirm the full toolchain works end-to-end.

- Open `starter/w1d1_ex1_led_on.v` — the module is complete, just review it
- Build and program: `make ex1`
- **Verify:** LED1 on the Go Board should be lit
- **Reflection:** What did Yosys actually synthesize here? Run `make ex1_stat` to check LUT usage

---

### Exercise 2: Buttons to LEDs — Wires in Hardware (25 min)

!!! code "Exercise 2 — Code"
    [:material-download: Starter .zip](../../downloads/day01/ex2_buttons_to_leds_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day01/ex2_buttons_to_leds_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day01/ex2_buttons_to_leds/starter/Makefile){ target=_blank }



**Goal:** Use `assign` to create combinational connections between inputs and outputs.

- Open `starter/w1d1_ex2_buttons_to_leds.v` — direct mapping provided
- Build and program: `make ex2`
- **Verify:** Each button controls its corresponding LED
- **Quick check:** Are any LUTs used? Why or why not?

---

### Exercise 3: Logic Between Buttons and LEDs (30 min)

!!! code "Exercise 3 — Code"
    [:material-download: Starter .zip](../../downloads/day01/ex3_button_logic_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day01/ex3_button_logic_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day01/ex3_button_logic/starter/Makefile){ target=_blank }



**Goal:** Implement concurrent combinational logic with multiple independent `assign` statements.

- Open `starter/w1d1_ex3_button_logic.v` — fill in the `TODO` assignments
- Predict the truth tables **on paper first**, then verify on hardware
- Build and program: `make ex3`
- **Discussion:** All four `assign` statements are active simultaneously

| sw1 | sw2 | LED1 (AND) | LED3 (XOR) | LED4 (NOT) |
|-----|-----|-----------|-----------|-----------|
| released | released | ? | ? | ? |
| released | pressed | ? | ? | ? |
| pressed | released | ? | ? | ? |
| pressed | pressed | ? | ? | ? |

---

### Exercise 4: Active-Low Thinking (20 min)

!!! code "Exercise 4 — Code"
    [:material-download: Starter .zip](../../downloads/day01/ex4_active_low_clean_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day01/ex4_active_low_clean_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day01/ex4_active_low_clean/starter/Makefile){ target=_blank }



**Goal:** Develop a clean boundary pattern for readable designs.

- Open `starter/ex4_active_low_clean.v` — fill in the `TODO` sections
- The pattern: name inputs clearly at the boundary, keep internal logic readable, drive outputs directly
- Build and program: `make ex4`
- **Compare:** Does this produce more or fewer LUTs than Exercise 3? Run `make ex4_stat`

---

### Exercise 5 — Stretch: Makefile & XOR Pattern (10 min)

!!! code "Exercise 5 — Code"
    [:material-download: Starter .zip](../../downloads/day01/ex5_xor_pattern_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day01/ex5_xor_pattern_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week1_day01/ex5_xor_pattern/starter/Makefile){ target=_blank }



**Goal:** Automate the build flow and experiment with more gate combinations.

- Open `starter/w1d1_ex5_xor_pattern.v` — add creative logic combinations
- The Makefile already supports all exercises; study how it works
- **Challenge:** Can you make all 4 LEDs display a unique pattern based on the 4 buttons?

---

## Deliverable Checklist

- [ ] Toolchain verified — all tools report version
- [ ] Exercise 1: LED1 lit on board
- [ ] Exercise 2: All 4 buttons control corresponding LEDs
- [ ] Exercise 3: Truth table filled in and verified on hardware
- [ ] Exercise 4: Active-low pattern implemented and working
- [ ] At minimum: Exercise 3 or 4 programmed on board with logic modifications

## Quick Reference

```
make ex1          # Build and program Exercise 1
make ex2          # Build and program Exercise 2
make ex3          # Build and program Exercise 3
make ex4          # Build and program Exercise 4
make ex5          # Build and program Exercise 5 (stretch)
make ex1_stat     # Show resource usage for Exercise 1
make clean        # Remove all build artifacts
```
