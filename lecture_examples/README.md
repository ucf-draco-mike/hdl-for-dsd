# Lecture Examples

Runnable code for the snippets shown in the lecture videos / slides.
Mirrors the `labs/` layout (per-day Makefile + per-example subdir) so
students can `make sim`, `make stat`, `make prog` from any example.

## Layout

```
lecture_examples/<weekN_dayMM>/d<MM>_s<X>_exN/
```

- `weekN_dayMM` matches the lecture deck folder.
- `d<MM>_s<X>_exN` ties each example to the slide segment (`sX` is the
  segment / video index used in the deck filename `d<MM>_s<X>_*.html`)
  and a per-day numeric index. The slides reference these directories
  by name when pointing students at runnable code.

## Common targets (per example)

- `make sim`   — iverilog + vvp (auto-detects `tb_*.v`)
- `make wave`  — open `*.vcd` in gtkwave
- `make stat`  — yosys synth_ice40 report
- `make synth` — synth to JSON (yosys)
- `make prog`  — nextpnr → icepack → iceprog (Go Board)
- `make clean` — remove build artefacts

## Day-level dispatcher

Each day's `Makefile` forwards `make exN[_target]` into the matching
example dir, e.g. `make ex1_stat` from `lecture_examples/week1_day01/`.
