# Accelerated HDL for Digital System Design

> **Dr. Mike Borowczak · UCF · College of Engineering & Computer Science · Department of Electrical & Computer Engineering**

A 4-week, 16-session accelerated course in Verilog and digital system design using the Nandland Go Board (Lattice iCE40 HX1K) and a fully open-source toolchain.

---

## Course Overview

| | |
|---|---|
| **Format** | 4 weeks · 4 sessions/week · 2.5 hours/session |
| **Delivery** | Flipped — recorded video lectures pre-class; class = mini-lecture + hands-on lab |
| **Platform** | [Nandland Go Board](https://nandland.com/the-go-board/) (Lattice iCE40 HX1K) |
| **Toolchain** | Yosys + nextpnr-ice40 + icepack/iceprog (synthesis/PnR) · Icarus Verilog + GTKWave (simulation) |
| **Environment** | Reproducible [Nix](https://nixos.org/) dev shell — identical tool versions on Linux, macOS, and WSL2 |
| **Students** | ≤15 · primarily CompE with some CS · no prior HDL |
| **Assessment** | Continuous lab deliverables (Weeks 1–3) · Final project (Week 4) |

## Weekly Arc

| Week | Theme | Culmination |
|------|-------|-------------|
| **1** | Verilog Foundations & Combinational Design | First LED blink from HDL |
| **2** | Sequential Design, Verification & AI-Assisted Testing | Verified module library + first AI-generated TB |
| **3** | Memory, Communication & Numerical Architectures | "HELLO" on the PC terminal + numerical module on FPGA |
| **4** | Advanced Design, Verification & Final Project | Complete demonstrated system with PPA report |

## Repository Structure

```
hdl-for-dsd/
├── README.md                    ← you are here
├── flake.nix                    ← Nix dev environment (all tools, all platforms)
├── .envrc                       ← optional direnv auto-activation
├── docs/
│   ├── course_curriculum.md            ← full 16-day course_curriculum & session map
│   ├── course_syllabus.md              ← student-facing course_syllabus
│   ├── course_setup_guide.md           ← toolchain installation instructions
│   ├── course_video_scaffold.md ← lecture production guide
│   └── course_dev_status.md     ← development status tracker
│   └── day01.md … day16.md      ← daily session plans (instructor guides)
│
├── lectures/                    ← pre-class video lecture materials
│   ├── theme/ucf-hdl.css        ← UCF-branded reveal.js theme
│   ├── week1_day01/ … week4_day16/ ← slide decks (reveal.js HTML)
│
├── labs/                        ← in-class lab materials & starter code
│   ├── week1_day01/ through week1_day04/
│   ├── week2_day05/ through week2_day08/
│   ├── week3_day09/ through week3_day12/
│   └── week4_day13/ through week4_day16/
│
├── projects/                    ← spec & rubrics
│
├── shared/
│   ├── pcf/go_board.pcf         ← pin constraint file
│   ├── lib/                     ← reusable module library
│   └── .gtkwaverc              ← GTKWave display defaults
│
└── assets/img/                  ← logos, board photos, etc.
```

## Quick Start

### 1. Complete OS Prerequisites

See [`docs/course_setup_guide.md`](docs/course_setup_guide.md) — complete **only** your platform's Step 0:

| Platform | What to do |
|----------|------------|
| **Linux** | Install `curl` & `xz-utils`; add udev rules for USB |
| **macOS** | Install Xcode Command Line Tools (`xcode-select --install`) |
| **Windows** | Install WSL2 (`wsl --install`) and [usbipd-win](https://github.com/dorssel/usbipd-win) for USB passthrough |

### 2. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a **new terminal** after installation completes.

### 3. Clone & Enter the Course Environment

```bash
git clone https://github.com/ucf-draco-mike/hdl-for-dsd.git
cd hdl-for-dsd
nix develop
```

The first run downloads the toolchain (~5–15 min). Subsequent runs are instant. You'll see a banner confirming all tool versions.

### 4. Verify

```bash
yosys --version && nextpnr-ice40 --version && iverilog -V
```

### 5. First Build (Day 1)

```bash
cd labs/week1_day01
make prog    # synthesize + program the Go Board
```

> **Full setup details** — including USB verification, GTKWave testing, serial terminal config, and troubleshooting — are in [`docs/course_setup_guide.md`](docs/course_setup_guide.md).

## Toolchain Quick Reference

```bash
# Enter the course environment (every session)
cd hdl-for-dsd && nix develop

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

All materials released under the MIT License. See [LICENSE](LICENSE) for details.