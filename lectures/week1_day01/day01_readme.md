# Day 1: Welcome to Hardware Thinking

## Pre-Class Videos (~42 minutes total)

| # | Segment | Duration | File | Slides |
|---|---------|----------|------|--------|
| 1 | HDL ≠ Software | ~12 min | `d01_s1_hdl_not_software.html` | 9 |
| 2 | Synthesis vs. Simulation | ~10 min | `d01_s2_synthesis_vs_simulation.html` | 11 |
| 3 | Anatomy of a Verilog Module | ~12 min | `d01_s3_anatomy_of_a_module.html` | 11 |
| 4 | Digital Logic Refresher | ~8 min | `d01_s4_digital_logic_refresher.html` | 11 |

**Total slides:** 42 (including title, bridge, and quiz slides)

## Code Examples

| File | Description | Live Demo Slide | Example dir | Synthesizable? |
|------|-------------|-----------------|-------------|----------------|
| `day01_ex01_led_driver.v` | Simplest module — switch to LED wire | `d01_s3` (1) | `lecture_examples/week1_day01/d01_s3_ex1/` | ✓ |
| `day01_ex02_button_logic.v` | Multiple concurrent gates (AND, OR, XOR, NOT) | `d01_s3` (2) | `lecture_examples/week1_day01/d01_s3_ex2/` | ✓ |
| `day01_ex03_gates_demo.v` | Gate-by-gate `assign` walkthrough + SOP/DeMorgan equivalent | `d01_s4` | `lecture_examples/week1_day01/d01_s4_ex3/` | ✓ |

All three examples ship as runnable lecture examples with `Makefile` + `tb_*.v`.
They compile with:
```bash
yosys -p "synth_ice40 -top <module_name> -json out.json" <file>.v
```

For the canonical Live Demo registry covering every "▶ LIVE DEMO" cue in the
course, see [`docs/live_demos.md`](../../docs/live_demos.md).

## Diagrams

| File | Type | Used In | Description |
|------|------|---------|-------------|
| `diagrams/d01_river_analogy.svg` | SVG | Seg 1 | Software recipe vs. hardware river system |
| `diagrams/d01_synth_vs_sim_flow.svg` | SVG | Seg 2 | Two-path iCE40 toolchain flowchart |
| `diagrams/d01_synth_vs_sim_flow.mmd` | Mermaid src | — | Mermaid source (documentation) |
| `diagrams/d01_module_anatomy.svg` | SVG | Seg 3 | Module as labeled box with input/output ports |
| `diagrams/d01_go_board_placeholder.svg` | SVG | Seg 2 | Go Board I/O layout (replace with photo) |
| `diagrams/d01_fpga_anatomy.svg` | SVG | Seg 2 | FPGA fabric grid + zoom-in on a LUT4+FF logic cell |

> **Note:** `d01_go_board_placeholder.svg` is a schematic placeholder. Replace with an actual
> board photo before final recording. The SVG has a dashed border and label to remind you.

## Pre-Class Quiz

See `day01_quiz.md` — 5 questions covering all 4 segments.

Quiz questions are also **embedded as interactive slides** at the end of Segment 4,
with fragment-based answer reveals. `day01_quiz.md` remains the canonical source.

## Recording Instructions

1. Open each `.html` file in Chrome or Firefox
2. Press `S` for presenter view (notes on your screen, slides on recorded screen)
3. Arrow keys to advance slides; fragments auto-advance
4. Record screen + audio using OBS or similar
5. For live demo cue slides (dark background, "▶ LIVE DEMO" label): switch to your editor/terminal

### Segment Progress Breadcrumb

Each title slide includes a 4-dot breadcrumb showing the current segment position
within the Day 1 lecture series. This helps students orient when watching individual
segments or when re-watching specific topics.

## Naming Convention

Files follow the course naming scheme:

| Pattern | Example | Meaning |
|---------|---------|---------|
| `d##_s#_topic.html` | `d01_s1_hdl_not_software.html` | Day 01, Segment 1 slide deck |
| `day##_ex##_name.v` | `day01_ex01_led_driver.v` | Day 01, Exercise 01 Verilog source |
| `d##_diagram_name.svg` | `d01_river_analogy.svg` | Day 01 diagram asset |
| `day##_support.md` | `day01_quiz.md` | Day 01 support document |

## Directory Structure

```
week1_day01/
├── day01_readme.md                         ← this file
├── day01_quiz.md                           ← pre-class self-check (5 questions)
├── d01_s1_hdl_not_software.html            ← Video 1: concurrency, river analogy
├── d01_s2_synthesis_vs_simulation.html      ← Video 2: toolchain, Go Board intro
├── d01_s3_anatomy_of_a_module.html          ← Video 3: module template, naming
├── d01_s4_digital_logic_refresher.html      ← Video 4: gates→Verilog, embedded quiz
├── code/
│   ├── day01_ex01_led_driver.v             ← simplest module (switch → LED)
│   └── day01_ex02_button_logic.v           ← concurrent gates demo
└── diagrams/
    ├── d01_river_analogy.svg               ← software recipe vs hardware river
    ├── d01_synth_vs_sim_flow.svg           ← two-path toolchain flowchart
    ├── d01_synth_vs_sim_flow.mmd           ← Mermaid source
    ├── d01_module_anatomy.svg              ← module box diagram with ports
    ├── d01_fpga_anatomy.svg                ← FPGA fabric + LUT/FF zoom-in (Seg 2)
    └── d01_go_board_placeholder.svg        ← 📷 replace with photo before recording
```

## Enhancement Changelog

All 10 identified enhancements applied:

1. **CSS path fix** — all segments reference `../../theme/ucf-hdl.css` (correct depth)
2. **Panel styles consolidated** — `.panel-*`, `.two-col`, `.check`/`.cross` moved to theme CSS; no per-file `<style>` blocks for shared classes
3. **Segment breadcrumb** — 4-dot progress indicator on every title slide
4. **River analogy SVG** — visual diagram replaces text-only panels in Seg 1
5. **Live demo cue slides** — 3 `live-demo` class slides in Segs 3 and 4
6. **Toolchain flowchart SVG** — proper two-path diagram in Seg 2
7. **Go Board placeholder** — labeled I/O diagram in Seg 2 (replace with photo)
8. **Module anatomy SVG** — labeled box diagram in Seg 3
9. **Embedded quiz** — 5 questions as fragment-reveal slides at end of Seg 4
10. **Standalone code files** — `day01_ex01_led_driver.v` and `day01_ex02_button_logic.v` with full headers
