# Live Demo Registry

> **Purpose** — This is the single source of truth for the **Live Demos** referenced in
> the lecture slide decks. Every "▶ LIVE DEMO" cue in the reveal.js decks (`lectures/`)
> must resolve to a runnable example in `lecture_examples/` and must be cross-referenced
> from the corresponding `docs/dayNN.md` and `lectures/weekN_dayMM/dayMM_readme.md`.
>
> If you add or remove a Live Demo from a slide, **update this file in the same commit**.

---

## How to read this file

| Column | Meaning |
|--------|---------|
| **Slide** | The reveal.js deck the demo appears in (e.g. `d05_s4`). |
| **Title** | The headline shown on the dark `▶ LIVE DEMO` cue slide. |
| **Example dir** | Path under `lecture_examples/` that the slide tells students to `cd` into. |
| **Top file(s)** | The Verilog/SystemVerilog/auxiliary files the demo expects to find there. |
| **Make targets** | The `make` targets actually exercised on screen. |

When a single example dir hosts more than one demo (common when several segments converge
on the same artefact, e.g. UART TX), each demo lives on its own row but points at the same
directory.

---

## Week 1 — Verilog Foundations & Combinational Design

### Day 1 — Welcome to Hardware Thinking

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d01_s3` (1) | Build a Module from Scratch | `lecture_examples/week1_day01/d01_s3_ex1/` | `day01_ex01_led_driver.v`, `tb_led_driver.v` | `sim`, `stat`, `prog` |
| `d01_s3` (2) | `day01_ex02_button_logic.v` | `lecture_examples/week1_day01/d01_s3_ex2/` | `day01_ex02_button_logic.v`, `tb_button_logic.v` | `sim`, `stat` |
| `d01_s4`     | Gates in Verilog | `lecture_examples/week1_day01/d01_s4_ex3/` | `day01_ex03_gates_demo.v`, `tb_gates_demo.v` | `sim`, `stat` |

### Day 2 — Combinational Building Blocks

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d02_s1` | Vector Operations in iverilog | `lecture_examples/week1_day02/d02_s1_ex1/` | `day02_ex01_vector_ops.v`, `tb_vector_ops.v` | `sim`, `wave`, `stat` |
| `d02_s2` | Building a 4:1 Mux + Cost Comparison | `lecture_examples/week1_day02/d02_s2_ex2/` | `day02_ex02_mux_2to1.v`, `day02_ex02_mux_4to1.v`, `tb_mux_2to1.v`, `tb_mux_4to1.v` | `sim`, `wave`, `stat` |
| `d02_s3` | Width Mismatch — Compiler & Synthesis Warnings | `lecture_examples/week1_day02/d02_s2_ex2/` | `width_bugs.v` | (manual `iverilog -Wall` + `yosys`) |
| `d02_s4` | Flash the Decoder to the Go Board | `lecture_examples/week1_day02/d02_s4_ex3/` | `day02_ex03_hex_to_7seg.v`, `tb_hex_to_7seg.v` | `sim`, `wave`, `prog` |

> Bonus runnable: `lecture_examples/week1_day02/d02_s1_ex4/` (`day02_ex04_wire_vs_reg.v`) is
> referenced from a `▶ RUNNABLE` callout (not a `▶ LIVE DEMO` cue) on `d02_s1`.

### Day 3 — Procedural Combinational Logic

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d03_s1` | `always @(*)` vs `assign` — Same Hardware | `lecture_examples/week1_day03/d03_s2_ex1/` | `day03_ex03_alu_4bit.v`, `tb_alu_4bit.v` | `sim`, `stat` |
| `d03_s2` | 4-bit ALU with `case` | `lecture_examples/week1_day03/d03_s2_ex1/` | `day03_ex03_alu_4bit.v` | `sim`, `stat` |
| `d03_s3` | Inducing & Fixing a Latch | `lecture_examples/week1_day03/d03_s3_ex2/` (buggy) and `lecture_examples/week1_day03/d03_s3_ex3/` (fixed) | `day03_ex01_latch_demo.v`, `day03_ex02_latch_fixed.v` | `sim`, `stat` |
| `d03_s4` | Shift Register: `=` vs `<=` Side-by-Side | `lecture_examples/week1_day04/d04_s2_ex1/` (cross-day) | `day04_ex03_shift_register_demo.v`, `tb_shift_register_demo.v` | `sim`, `wave` |

### Day 4 — Sequential Logic: Flip-Flops, Clocks & Counters

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d04_s1` | One-Flop, Two-Flop in GTKWave | `lecture_examples/week1_day04/d04_s3_ex2/` | `day04_ex01_d_flip_flop.v`, `tb_d_flip_flop.v` | `sim`, `wave` |
| `d04_s2` | Blocking vs Nonblocking Side-by-Side | `lecture_examples/week1_day04/d04_s2_ex1/` | `day04_ex03_shift_register_demo.v`, `tb_shift_register_demo.v` | `sim`, `wave` |
| `d04_s3` | Reset + Enable Register in Action | `lecture_examples/week1_day04/d04_s3_ex2/` | `day04_ex01_d_flip_flop.v` | `sim`, `wave` |
| `d04_s4` | LED Blinker: Simulate → Flash → Behold | `lecture_examples/week1_day04/d04_s4_ex3/` | `day04_ex02_led_blinker.v`, `tb_led_blinker.v` | `sim`, `wave`, `prog` |

---

## Week 2 — Sequential Design, Verification & AI-Assisted Testing

### Day 5 — Counters, Shift Registers & Debouncing

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d05_s1` | Modulo-N Counter + Cascade | `lecture_examples/week2_day05/d05_s1_ex1/` | `day05_ex01_counter_mod_n.v`, `tb_counter_mod_n.v` | `sim`, `wave`, `stat` |
| `d05_s2` | Shift Register in GTKWave | `lecture_examples/week2_day05/d05_s2_ex2/` | `day05_ex02_shift_reg_piso.v`, `tb_shift_reg_piso.v` | `sim`, `wave` |
| `d05_s3` | Synchronizer on an Asynchronous Button | `lecture_examples/week2_day05/d05_s3_ex3/` | `day05_ex03_synchronizer.v`, `tb_synchronizer.v` | `sim`, `wave`, `stat` |
| `d05_s4` | Debouncer on the Go Board | `lecture_examples/week2_day05/d05_s4_ex4/` | `day05_ex04_debounce.v`, `tb_debounce.v` | `sim`, `prog` |

### Day 6 — Testbenches, Simulation & AI-Assisted Verification

All four Day-6 demos converge on the same example directory because the demo IS the testbench
itself, evolving across the four segments.

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d06_s1` | Build a Testbench from Scratch | `lecture_examples/week2_day06/d06_s1_ex1/` | `adder.v`, `tb_adder.v` | `sim` |
| `d06_s2` | Convert a "Print" Testbench to Self-Checking | `lecture_examples/week2_day06/d06_s1_ex1/` | `tb_adder_before.v`, `tb_adder_after.v` | `sim` (each), `diff` |
| `d06_s3` | Refactor a Real Testbench | `lecture_examples/week2_day06/d06_s1_ex1/` | `tb_before.v`, `tb_after.v` | `sim` (each), `diff` |
| `d06_s4` | 1000-Vector Adder Test | `lecture_examples/week2_day06/d06_s1_ex1/` | `gen_vectors.py`, `vectors.hex`, `tb_adder_file.v` | `python3 gen_vectors.py`, `sim` |

> The day's lab also exercises the `day06_ex01_tb_alu_template.v` self-checking ALU
> testbench template that ships in the same directory; it is the seed for the lab
> deliverable rather than a Live Demo.

### Day 7 — Finite State Machines

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d07_s1` | Traffic Light FSM — Simulation + Synthesis | `lecture_examples/week2_day07/d07_s2_ex1/` | `day07_ex01_fsm_template.v`, `tb_traffic_light.v` | `sim`, `wave`, `stat` |
| `d07_s2` | Traffic Light FSM — From Diagram to Working Chip | `lecture_examples/week2_day07/d07_s2_ex1/` | `day07_ex01_fsm_template.v` | `sim`, `prog` |
| `d07_s3` | Encoding Comparison Live | `lecture_examples/week2_day07/d07_s2_ex1/` | `day07_ex01_fsm_template.v` | `stat` (with parameter sweep) |
| `d07_s4` | Pattern Detector: From Diagram to Working FSM | `lecture_examples/week2_day07/d07_s4_ex2/` | `day07_ex02_pattern_detector.v`, `tb_pattern_detector.v` | `sim`, `wave` |

### Day 8 — Hierarchy, Parameters, Generate & Design Reuse

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d08_s1` | Build a Hierarchical Design | `lecture_examples/week2_day08/d08_s2_ex1/` | `day08_ex02_param_alu.v`, `tb_param_alu.v` | `sim`, `stat` |
| `d08_s2` | One Module, Three Instances, Three Sizes | `lecture_examples/week2_day08/d08_s2_ex1/` | `day08_ex02_param_alu.v` | `stat` (sweep) |
| `d08_s3` | Scaling with Generate: 4 → 16 Debouncers | `lecture_examples/week2_day08/d08_s4_ex2/` | `day08_ex01_parallel_debounce.v`, `debounce.v`, `tb_parallel_debounce.v` | `sim`, `stat` |

---

## Week 3 — Memory, Communication & Numerical Architectures

### Day 9 — Memory: RAM, ROM & Block RAM

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d09_s1` | Case vs Array ROM: Same Output, Different Silicon | `lecture_examples/week3_day09/d09_s1_ex1/` | `day09_ex01_rom_sync.v`, `tb_rom_sync.v` | `sim`, `stat` |
| `d09_s2` | Write, Read, Confirm Block RAM Inference | `lecture_examples/week3_day09/d09_s2_ex2/` | `day09_ex02_ram_sp.v`, `tb_ram_sp.v` | `sim`, `wave`, `stat` |
| `d09_s4` | Pattern Sequencer on the Go Board | `lecture_examples/week3_day09/d09_s4_ex3/` | `day09_ex03_pattern_sequencer.v`, `tb_pattern_sequencer.v` | `sim`, `prog` |

### Day 10 — Numerical Architectures & Design Trade-offs

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d10_s1` | Live Timing Closure | `lecture_examples/week3_day10/d10_s2_ex1/` | `day10_adder_widths.v`, `tb_adder_widths.v` | `synth`, `prog` (timing report) |
| `d10_s2` | Adder & Multiplier Synthesis Comparison | `lecture_examples/week3_day10/d10_s2_ex1/` | `day10_adder_widths.v`, `tb_adder_widths.v` | `stat` (sweep) |
| `d10_s3` | PPA of Three FSM Variants | `lecture_examples/week3_day10/d10_s2_ex2/` | `day10_mult_widths.v`, `tb_mult_widths.v` | `stat` (sweep) |

### Day 11 — UART TX

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d11_s1` | Real UART Trace on a Scope | `lecture_examples/week3_day11/d11_s3_ex1/` | `day11_ex01_uart_tx.v`, `tb_uart_tx.v` | `sim`, `wave` |
| `d11_s2` | FSM Trace Walkthrough | `lecture_examples/week3_day11/d11_s3_ex1/` | `day11_ex01_uart_tx.v` | `sim`, `wave` |
| `d11_s3` | Build UART TX from Scratch | `lecture_examples/week3_day11/d11_s3_ex1/` | `day11_ex01_uart_tx.v`, `tb_uart_tx.v` | `sim`, `wave`, `stat` |
| `d11_s4` | Your Go Board Says HELLO | `lecture_examples/week3_day11/d11_s4_ex2/` | `day11_ex02_hello_emitter.v`, `tb_hello_emitter.v`, `rx_display.py` | `sim`, `prog` |

### Day 12 — UART RX, SPI & IP Integration

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d12_s1` | Oversampling Decision Visualization | `lecture_examples/week3_day12/d12_s2_ex1/` | `day12_ex01_uart_rx.v`, `tb_uart_rx.v` | `sim`, `wave` |
| `d12_s2` | UART RX + Loopback Test | `lecture_examples/week3_day12/d12_s2_ex1/` | `day12_ex01_uart_rx.v`, `tb_uart_rx.v` | `sim`, `wave` |
| `d12_s3` | SPI Master Talking to an ADC | `lecture_examples/week3_day12/d12_s4_ex2/` | `day12_ex02_uart_loopback.v`, `uart_rx.v`, `uart_tx.v` | `prog` |

---

## Week 4 — Advanced Design, Verification & Final Project

### Day 13 — SystemVerilog for Design

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d13_s2` | Modernize Your Debouncer | `lecture_examples/week4_day13/d13_s3_ex1/` | `day13_ex01_uart_tx_sv.sv`, `tb_uart_tx_sv.sv` | `sim`, `stat` |
| `d13_s4` | State Names in GTKWave | `lecture_examples/week4_day13/d13_s4_ex2/` | `day13_ex02_alu_sv.sv`, `tb_alu_sv.sv` | `sim`, `wave` |

### Day 14 — Verification, AI-Driven Testing & PPA Analysis

| Slide | Title | Example dir | Top file(s) | Make targets |
|-------|-------|-------------|-------------|--------------|
| `d14_s1` | Assert-Driven Bug Hunt | `lecture_examples/week4_day14/d14_s1_ex1/` | `day14_ex01_uart_tx_assertions.sv`, `tb_uart_tx_assertions.sv` | `sim` (with assertion failures) |
| `d14_s3` | PPA Sweep: Pipelining an Adder | `lecture_examples/week3_day10/d10_s2_ex2/` (cross-day reuse) | `day10_mult_widths.v`, `tb_mult_widths.v` | `stat` (sweep) |

---

## Cross-day reuse

Some segments deliberately reuse an example dir from another day. These are intentional and
should not be "fixed" by duplicating the file:

- `d03_s4` reuses `d04_s2_ex1` (the shift register from Day 4 visualises blocking vs.
  nonblocking; introduced one segment early to motivate Day 4).
- `d14_s3` reuses `d10_s2_ex2` (the multiplier-widths sweep is the canonical PPA artefact —
  Day 14 just re-runs it as a sweep with pipelining variations).

---

## Maintenance

When you change a Live Demo:

1. Update the slide deck (`lectures/weekN_dayMM/dMM_sX_*.html`).
2. Update / add the runnable example under `lecture_examples/weekN_dayMM/dMM_sX_exN/`.
3. Update this file (`docs/live_demos.md`).
4. Update the day's deck README (`lectures/weekN_dayMM/dayMM_readme.md`) and the daily
   instructor guide (`docs/dayNN.md`) if the change affects the session timeline.
5. Run `make stat` (and `make sim` if a testbench exists) inside the example dir to verify
   the demo still works on the open-source toolchain.
