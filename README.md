# Accelerated HDL for Digital System Design

> **UCF · College of Engineering & Computer Science · Department of Electrical & Computer Engineering**

A 4-week, 16-session accelerated course in Verilog and digital system design using the Nandland Go Board (Lattice iCE40 HX1K) and a fully open-source toolchain.

---

## Course Overview

| | |
|---|---|
| **Format** | 4 weeks · 4 sessions/week · 2.5 hours/session |
| **Delivery** | Flipped — recorded video lectures pre-class; class = mini-lecture + hands-on lab |
| **Platform** | [Nandland Go Board](https://nandland.com/the-go-board/) (Lattice iCE40 HX1K) |
| **Toolchain** | Yosys + nextpnr-ice40 + icepack/iceprog (synthesis/PnR) · Icarus Verilog + GTKWave (simulation) |
| **Students** | ≤15 · primarily CompE with some CS · no prior HDL |
| **Assessment** | Continuous lab deliverables (Weeks 1–3) · Final project (Week 4) |

## Weekly Arc

| Week | Theme | Culmination |
|------|-------|-------------|
| **1** | Verilog Foundations & Combinational Design | First LED blink from HDL |
| **2** | Sequential Design & Verification | Verified module library |
| **3** | Interfaces, Memory & Communication | "HELLO" on the PC terminal |
| **4** | SystemVerilog Primer & Final Project | Complete demonstrated system |

## Repository Structure

```
hdl-course/
├── README.md                    ← you are here
├── docs/
│   ├── curriculum.md            ← full 16-day curriculum & session map
│   ├── syllabus.md              ← student-facing syllabus
│   └── setup_guide.md           ← toolchain installation instructions
│
├── lectures/                    ← pre-class video lecture materials
│   ├── theme/                   ← UCF-branded reveal.js theme
│   │   └── ucf-hdl.css
│   ├── week1/
│   │   ├── day01_welcome_to_hardware_thinking/
│   │   │   ├── seg1_hdl_not_software.html
│   │   │   ├── seg2_synthesis_vs_simulation.html
│   │   │   ├── seg3_anatomy_of_a_module.html
│   │   │   ├── seg4_digital_logic_refresher.html
│   │   │   ├── quiz.md
│   │   │   ├── code/            ← Verilog examples from the lecture
│   │   │   ├── diagrams/        ← WaveDrom, Mermaid, SVG
│   │   │   └── README.md
│   │   ├── day02_.../
│   │   ...
│   ├── week2/
│   ├── week3/
│   └── week4/
│
├── labs/                        ← in-class lab materials & starter code
│   ├── week1/
│   │   ├── day01/
│   │   ├── day02/
│   │   ...
│   ├── week2/
│   ├── week3/
│   └── week4/
│
├── projects/                    ← final project specifications & rubrics
│
├── shared/                      ← common resources used across the course
│   ├── pcf/                     ← Go Board pin constraint files
│   │   └── go_board.pcf
│   ├── lib/                     ← reusable module library (builds across weeks)
│   └── scripts/                 ← build helpers, Makefiles
│       └── Makefile.template
│
└── assets/
    └── img/                     ← logos, board photos, etc.
```

## Lecture Format

Each day's pre-class material is split into **4 short video segments** (8–15 min each), totaling ~40–50 min per day. This matches research on optimal video length for flipped instruction.

Slides are built with [reveal.js](https://revealjs.com/) — HTML-based, git-friendly, with syntax-highlighted code and progressive builds. Speaker notes contain the full narration script.

| Day | Video 1 | Video 2 | Video 3 | Video 4 | Total |
|-----|---------|---------|---------|---------|-------|
| 1   | HDL ≠ Software (12m) | Synthesis vs. Sim (10m) | Module Anatomy (12m) | Logic Refresher (8m) | ~42m |
| 2   | Data Types & Vectors (15m) | Operators (12m) | Sized Literals (8m) | 7-Segment Display (10m) | ~45m |
| 3   | `always @(*)` (12m) | `if/else` & `case` (15m) | Latch Problem (12m) | Blocking vs. Nonblocking (6m) | ~45m |
| 4   | Clocks & Edges (12m) | Nonblocking Deep Dive (15m) | FF Variants (10m) | Counters & Dividers (13m) | ~50m |
| 5   | Counter Variations (10m) | Shift Registers (12m) | Metastability (12m) | Debouncing (11m) | ~45m |
| 6   | Testbench Anatomy (12m) | Self-Checking TBs (15m) | Tasks (10m) | File-Driven Testing (13m) | ~50m |
| 7   | FSM Theory (12m) | 3-Block Style (15m) | State Encoding (8m) | FSM Methodology (15m) | ~50m |
| 8   | Hierarchy (12m) | Parameters (15m) | Generate Blocks (12m) | Design for Reuse (6m) | ~45m |
| 9   | ROM (12m) | RAM (12m) | iCE40 Memory (10m) | Memory Applications (11m) | ~45m |
| 10  | Physics of Timing (15m) | Timing Reports (12m) | iCE40 PLL (12m) | Clock Domain Crossing (11m) | ~50m |
| 11  | UART Protocol (15m) | TX Architecture (15m) | Implementation (12m) | PC Connection (8m) | ~50m |
| 12  | UART RX Oversampling (15m) | RX Implementation (15m) | SPI Protocol (12m) | IP Integration (8m) | ~50m |
| 13  | Why SystemVerilog? (8m) | `logic` Type (10m) | Intent Blocks (12m) | enum/struct/package (15m) | ~45m |
| 14  | Assertions (15m) | Concurrent Assertions (12m) | Coverage (12m) | Interfaces & UVM Road (11m) | ~50m |

**Total pre-class video: ~660 min (~11 hours)**

## Toolchain Quick Reference

```bash
# Simulation (Icarus Verilog + GTKWave)
iverilog -o sim.vvp -g2012 tb_module.v module.v
vvp sim.vvp
gtkwave dump.vcd

# Synthesis & Programming (iCE40 open-source flow)
yosys -p "synth_ice40 -top top_module -json top.json" top.v sub1.v sub2.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json top.json --asc top.asc
icepack top.asc top.bin
iceprog top.bin
```

## Getting Started

1. **Install the toolchain** — see [`docs/setup_guide.md`](docs/setup_guide.md)
2. **Get the Go Board** — [nandland.com](https://nandland.com/the-go-board/)
3. **Watch the Day 1 videos** — `lectures/week1/day01_welcome_to_hardware_thinking/`
4. **Come to class ready to build**

## License

Course materials are provided for educational use. See [LICENSE](LICENSE) for details.
