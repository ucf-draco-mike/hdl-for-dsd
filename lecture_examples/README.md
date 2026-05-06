# Lecture Examples

Runnable code for every "▶ LIVE DEMO" cue shown in the lecture videos /
slide decks. Mirrors the `labs/` layout (per-day Makefile + per-example
subdir) so students can `make sim`, `make stat`, `make prog` from any
example.

## Source of truth

The canonical mapping from each Live Demo cue slide → example directory →
expected files lives in [`../docs/live_demos.md`](../docs/live_demos.md).
**Update that file in the same commit any time you add, remove, or move a
Live Demo.** The slide deck, the example directory, and `docs/live_demos.md`
must agree.

## Layout

```
lecture_examples/<weekN_dayMM>/d<MM>_s<X>_exN/
```

- `weekN_dayMM` matches the lecture deck folder.
- `d<MM>_s<X>_exN` ties each example to the slide segment (`sX` is the
  segment / video index used in the deck filename `d<MM>_s<X>_*.html`)
  and a per-day numeric index. The slides reference these directories
  by name when pointing students at runnable code.

## Coverage at a glance

| Day | Examples | Live Demos covered |
|-----|----------|--------------------|
| Week 1 · Day 1  | `d01_s3_ex1`, `d01_s3_ex2`, `d01_s4_ex3`                                | `d01_s3` (1, 2), `d01_s4` |
| Week 1 · Day 2  | `d02_s1_ex1`, `d02_s1_ex4`, `d02_s2_ex2`, `d02_s4_ex3`                  | `d02_s1`, `d02_s2`, `d02_s3`, `d02_s4` |
| Week 1 · Day 3  | `d03_s1_ex1`, `d03_s2_ex1`, `d03_s3_ex2`, `d03_s3_ex3`, `d03_s4_ex5`    | `d03_s1..s4` |
| Week 1 · Day 4  | `d04_s2_ex1`, `d04_s3_ex2`, `d04_s4_ex3`                                | `d04_s1..s4` |
| Week 2 · Day 5  | `d05_s1_ex1`, `d05_s2_ex2`, `d05_s3_ex3`, `d05_s4_ex4`                  | `d05_s1..s4` |
| Week 2 · Day 6  | `d06_s1_ex1`                                                            | `d06_s1..s4` (testbench evolution in one dir) |
| Week 2 · Day 7  | `d07_s2_ex1`, `d07_s4_ex2`                                              | `d07_s1..s4` |
| Week 2 · Day 8  | `d08_s1_ex1`, `d08_s2_ex2`, `d08_s3_ex3`                                | `d08_s1..s3` |
| Week 3 · Day 9  | `d09_s1_ex1`, `d09_s2_ex2`, `d09_s4_ex3`                                | `d09_s1`, `d09_s2`, `d09_s4` |
| Week 3 · Day 10 | `d10_s2_ex1`, `d10_s2_ex2`                                              | `d10_s1..s3` |
| Week 3 · Day 11 | `d11_s3_ex1`, `d11_s4_ex2`                                              | `d11_s1..s4` |
| Week 3 · Day 12 | `d12_s2_ex1`, `d12_s3_ex2`, `d12_s4_ex3`                                | `d12_s1..s4` |
| Week 4 · Day 13 | `d13_s3_ex1`, `d13_s4_ex2`                                              | `d13_s2`, `d13_s4` |
| Week 4 · Day 14 | `d14_s1_ex1`, `d14_s3_ex2`                                              | `d14_s1`, `d14_s3` |

## Common targets (per example)

- `make sim`   — iverilog + vvp (auto-detects `tb_*.v` unless the local
  Makefile pins a `TB=` explicitly)
- `make wave`  — open `*.vcd` in gtkwave
- `make stat`  — yosys synth_ice40 report
- `make synth` — synth to JSON (yosys)
- `make prog`  — nextpnr → icepack → iceprog (Go Board)
- `make clean` — remove build artefacts

## Day-level dispatcher

Each day's `Makefile` forwards `make exN[_target]` into the matching
example dir, e.g. `make ex1_stat` from `lecture_examples/week1_day01/`.
