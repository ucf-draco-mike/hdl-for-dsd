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
│   ├── setup_guide.md           ← toolchain installation instructions
│   ├── video_lecture_scaffold.md ← lecture production guide
│   └── day*_*.md                ← detailed daily session plans (instructor guides)
│
├── lectures/                    ← pre-class video lecture materials
│   ├── theme/ucf-hdl.css        ← UCF-branded reveal.js theme
│   ├── week1/ through week4/   ← slide decks (reveal.js HTML)
│
├── labs/                        ← in-class lab materials & starter code
│   ├── week1/day01/ through day04/
│   ├── week2/day05/ through day08/
│   ├── week3/day09/ through day12/
│   └── week4/day13/ through day16/
│
├── projects/                    ← final project specifications & rubrics
│
├── shared/
│   ├── pcf/go_board.pcf         ← Go Board pin constraint file
│   ├── lib/                     ← reusable verified module library
│   └── scripts/Makefile.template ← build automation template
│
├── scripts/                     ← slide generators & build tools
│   ├── generate_week1.py through generate_week4.py
│   └── build_repo.py           ← repository scaffolding generator
│
└── assets/img/                  ← logos, board photos, etc.
```

## Quick Start

### 1. Install the Toolchain

See [`docs/setup_guide.md`](docs/setup_guide.md) for platform-specific instructions.

```bash
# Ubuntu/Debian (quickest path)
sudo apt install -y yosys nextpnr-ice40 fpga-icestorm iverilog gtkwave git make
```

### 2. Verify Installation

```bash
yosys --version && nextpnr-ice40 --version && iverilog -V
```

### 3. First Build (Day 1)

```bash
cd labs/week1/day01
make prog    # synthesize + program the Go Board
```

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

## License

Course materials © UCF ECE. Verilog source code released under MIT License for educational use.
