# Day 10 Lab: Numerical Architectures & Design Trade-offs

!!! abstract "Starter Code"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day10/day10_all_starter.zip){ .md-button .md-button--primary }

    Individual exercise downloads and file links are below each exercise.


## Overview
Today you'll compare adder and multiplier architectures, implement a sequential
multiplier, work with fixed-point arithmetic, and produce your first structured
PPA comparison table. These are the same analysis habits you'll use in the
final project report.

## Prerequisites
- Completed Day 9 lab (memory)
- Pre-class videos on timing essentials, numerical architectures, and PPA watched
- Reuse your `hex_to_7seg.v` from Day 2 and `full_adder.v` from Day 2

## Exercises

> **CTF flow.** Today's exercises continue the flag chain you started on [Day 1](../day01/lab.md#how-exercises-are-gated-ctf-chain). For each chained exercise, run `make test` from inside the exercise's `starter/` directory to confirm correctness and earn the per-exercise flag. The flag from one exercise unlocks the *next* exercise's reference DUT via `make unlock FLAG=<flag>`. You don't have to unlock to make progress — the chain just gates peeking at the official answer.

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Adder Architecture Comparison | 30 min | 10.1, 10.4 |
| 2 | Shift-and-Add Multiplier | 30 min | 10.2, 10.4 |
| 3 | Fixed-Point Arithmetic | 20 min | 10.3 |
| 4 | Timing Constraint Exercise | 10 min | 10.5 |
| 5 | PLL & CDC (Stretch) | 15 min | 10.5 |

### Ex 1 — Adder Comparison

- **Earn the flag:** `cd ex1_adder_comparison/starter && make test`. Save the printed flag for Exercise 2's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex5-register-file-9018341dc27d` (Day 9 Exercise 5's flag).

### Ex 2 — Shift-and-Add Multiplier

- **Earn the flag:** `cd ex2_shift_add_multiplier/starter && make test`. Save the printed flag for Exercise 3's optional unlock.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex1-adder-comparison-c3fbea849e85`

### Ex 3 — Fixed Point

- **Earn the flag:** `cd ex3_fixed_point/starter && make test`. This is the last chained exercise of the day; keep the flag for Day 11 Exercise 1.
- **(Optional) Peek at the reference:** `make unlock FLAG=flag-ex2-shift-add-multiplier-2c5b106240d4`

### Ex 4 — Timing Exercise

- **Note:** This exercise isn't in the CTF chain — it's a paper/analysis worksheet with no `make test` target, so there's no flag to capture. Continue using Exercise 3's flag (`flag-ex3-fixed-point-9d0f6eb0df21`) to unlock Day 11 Exercise 1's reference.

### Ex 5 — PLL & CDC (Stretch)

- **Note:** This exercise isn't in the CTF chain — its reference solution ships unencrypted in `solution/`, so there's no `make test` flag to capture for it. Continue using Exercise 3's flag (`flag-ex3-fixed-point-9d0f6eb0df21`) to unlock Day 11 Exercise 1's reference.

## Deliverables
1. **Adder/multiplier PPA comparison table** with real data (LUTs, FFs, Fmax)
2. **Working shift-and-add multiplier** on FPGA with testbench
3. **Fixed-point demo** showing correct Q4.4 multiplication result on 7-seg

## PPA Comparison Table Template

| Module | Configuration | LUTs | FFs | Fmax (MHz) | Notes |
|--------|---------------|------|-----|------------|-------|
| Adder | Ripple-carry, 8-bit | | | | Manual chain |
| Adder | Ripple-carry, 16-bit | | | | Manual chain |
| Adder | Behavioral `+`, 8-bit | | | | Tool-chosen |
| Adder | Behavioral `+`, 16-bit | | | | Tool-chosen |
| Multiplier | Combinational `*`, 8-bit | | | | 1 cycle |
| Multiplier | Shift-and-add, 8-bit | | | | 8 cycles |

## Shared Resources
- `go_board.pcf` — Pin constraint file
- Reuse your `hex_to_7seg.v` and `full_adder.v` from previous labs

## Build Commands Quick Reference

```bash
# ── from labs/week3_day10/exN_*/starter/ ──
make test                            # run published testbench → flag on pass
make unlock FLAG=<previous-flag>     # peek at reference DUT (optional)
```


---

## :material-download: Exercise Code

### Ex 1 — Adder Comparison

[:material-download: Starter .zip](../../downloads/day10/ex1_adder_comparison_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day10/ex1_adder_comparison_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex1_adder_comparison/starter/Makefile){ target=_blank }
- :material-chip: [`adder_comparison.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex1_adder_comparison/starter/adder_comparison.v){ target=_blank }
- :material-text: [`ppa_worksheet.md`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex1_adder_comparison/starter/ppa_worksheet.md){ target=_blank }

### Ex 2 — Shift Add Multiplier

[:material-download: Starter .zip](../../downloads/day10/ex2_shift_add_multiplier_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day10/ex2_shift_add_multiplier_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex2_shift_add_multiplier/starter/Makefile){ target=_blank }
- :material-chip: [`shift_add_mult.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex2_shift_add_multiplier/starter/shift_add_mult.v){ target=_blank }
- :material-chip: [`tb_shift_add_mult.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex2_shift_add_multiplier/starter/tb_shift_add_mult.v){ target=_blank }

### Ex 3 — Fixed Point

[:material-download: Starter .zip](../../downloads/day10/ex3_fixed_point_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day10/ex3_fixed_point_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex3_fixed_point/starter/Makefile){ target=_blank }
- :material-chip: [`fixed_point.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex3_fixed_point/starter/fixed_point.v){ target=_blank }
- :material-chip: [`tb_fixed_point.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex3_fixed_point/starter/tb_fixed_point.v){ target=_blank }

### Ex 4 — Timing Exercise

[:material-download: Starter .zip](../../downloads/day10/ex4_timing_exercise_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day10/ex4_timing_exercise_solution.zip){ .md-button }

- :material-text: [`README.md`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex4_timing_exercise/starter/README.md){ target=_blank }

### Ex 5 — Pll Cdc Stretch

[:material-download: Starter .zip](../../downloads/day10/ex5_pll_cdc_stretch_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day10/ex5_pll_cdc_stretch_solution.zip){ .md-button }

- :material-cog: [`Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex5_pll_cdc_stretch/starter/Makefile){ target=_blank }
- :material-text: [`README.md`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex5_pll_cdc_stretch/starter/README.md){ target=_blank }
- :material-chip: [`top_cdc_demo.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex5_pll_cdc_stretch/starter/top_cdc_demo.v){ target=_blank }
- :material-chip: [`top_pll_demo.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week3_day10/ex5_pll_cdc_stretch/starter/top_pll_demo.v){ target=_blank }
