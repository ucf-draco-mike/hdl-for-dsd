# Accelerated HDL for Digital System Design

> **UCF · College of Engineering & Computer Science · Department of Electrical & Computer Engineering**

A 4-week, 16-session accelerated course in Verilog and digital system design using the Nandland Go Board (Lattice iCE40 HX1K) and a fully open-source toolchain. Integrates AI-assisted verification, PPA analysis, and constraint-based design.

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
| **1** | Verilog Foundations & Combinational Design | First designs on hardware |
| **2** | Sequential Design, Verification & AI-Assisted Testing | Verified module library + first AI-generated TB |
| **3** | Memory, Communication & Numerical Architectures | "HELLO" on the PC terminal + numerical module on FPGA |
| **4** | Advanced Design, Verification & Final Project | Complete demonstrated system with PPA report |

## What Makes This Course Different

- **Hands-on from Day 1** — real hardware, real toolchain, every session
- **AI-assisted verification** — students learn to prompt, evaluate, and correct AI-generated testbenches (Days 6–16)
- **PPA awareness** — resource analysis via `yosys stat` becomes a habit, not a one-off exercise
- **Open-source everything** — no license servers, no vendor lock-in, students keep the board and tools forever
- **Flipped for depth** — 12+ hours of video content frees class time for building, debugging, and design thinking

## Repository Structure

```
hdl-for-dsd/
├── README.md                    ← top-level overview & quick start
├── flake.nix                    ← Nix dev environment (all tools, all platforms)
├── .envrc                       ← optional direnv auto-activation
├── docs/
│   ├── README.md                ← you are here
│   ├── course_curriculum.md     ← full 16-day curriculum & session map
│   ├── course_syllabus.md       ← student-facing syllabus
│   ├── course_setup_guide.md    ← toolchain installation instructions
│   ├── course_video_scaffold.md ← lecture production guide
│   ├── course_dev_status.md     ← development status tracker
│   └── day01.md … day16.md      ← daily session plans (instructor guides)
│
├── lectures/                    ← pre-class video lecture materials
│   ├── theme/ucf-hdl.css        ← UCF-branded reveal.js theme
│   └── week1_day01/ … week4_day16/
│       ├── d##_s#_topic.html    ← reveal.js slide decks
│       ├── day##_quiz.md        ← pre-class quiz
│       ├── day##_readme.md      ← segment guide
│       ├── code/                ← live-code examples
│       └── diagrams/            ← SVGs & Mermaid sources
│
├── labs/                        ← in-class lab materials & starter code
│   └── week1_day01/ … week4_day16/
│       ├── README.md            ← lab guide
│       ├── Makefile             ← build targets (sim, synth, prog)
│       ├── go_board.pcf         ← pin constraints
│       ├── starter/             ← student starting point
│       └── solutions/           ← reference solutions
│
├── projects/                    ← final project specs & rubric
│
├── shared/
│   ├── pcf/go_board.pcf         ← canonical pin constraint file
│   ├── lib/                     ← reusable module library
│   └── .gtkwaverc               ← GTKWave display defaults
│
├── scripts/                     ← maintenance & migration utilities
│
└── assets/img/                  ← logos, board photos, etc.
```

## Lecture Format

Each day's pre-class material is split into **3–4 short video segments** (8–20 min each), totaling ~40–55 min per day. Slides are built with [reveal.js](https://revealjs.com/) — HTML-based, git-friendly, with syntax-highlighted code and progressive builds.

| Day | Total | Topics |
|-----|-------|--------|
| 1 | 40 min | HDL ≠ Software, Synthesis vs. Sim, Module Anatomy, Logic Refresher |
| 2 | 45 min | Data Types & Vectors, Operators, Sized Literals, 7-Segment Display |
| 3 | 45 min | `always @(*)`, `if/else` & `case`, Latch Problem, Blocking vs. Nonblocking |
| 4 | 50 min | Clocks & Edges, Nonblocking Deep Dive, FF Variants, Counters & Dividers |
| 5 | 45 min | Counter Variations, Shift Registers, Metastability, Debouncing |
| 6 | **55 min** ★ | Testbench Anatomy, Self-Checking TBs, Tasks, **AI for Verification** |
| 7 | 50 min | FSM Theory, 3-Block Style, State Encoding, FSM Methodology |
| 8 | **50 min** ★ | Hierarchy, Parameters, Generate Blocks, **Recursive Generate** |
| 9 | 45 min | ROM, RAM, iCE40 Memory, Memory Applications |
| 10 | **55 min** ★ | **Timing Essentials, Numerical Architectures, PPA Introduction** |
| 11 | 50 min | UART Protocol, TX Architecture, Implementation, PC Connection |
| 12 | **55 min** ★ | **UART RX, AI Protocol TBs, SPI Protocol, Constraint-Based Design** |
| 13 | 45 min | Why SystemVerilog?, `logic` Type, Intent Blocks, enum/struct/package |
| 14 | **55 min** ★ | **Assertions, AI Constraint-Based TBs, PPA Methodology, Coverage** |

**Total pre-class video: ~730 min (~12.2 hours)** · ★ = revised/new in v2.1

## Cross-Cutting Threads

**Thread 1 — AI-Assisted Verification:** Observe (Day 6) → Prompt + Review (Day 8) → Protocol-Level + Tool Comparison (Day 12) → Constraint-Based (Day 14) → Independent (Days 15–16)

**Thread 2 — PPA Analysis:** First `yosys stat` (Day 3) → Resource Scaling (Day 8) → Structured Comparison (Day 10) → Feature Cost (Day 12) → SV Equivalence (Day 13) → Design-Space Exploration (Day 14) → Project Report (Days 15–16)

**Thread 3 — Constraint-Based Design:** if/else vs case (Day 3) → FSM Encoding (Day 7) → generate (Day 8) → Numerical Trade-offs (Day 10) → Parameterized Protocols (Day 12) → Design-Space Exploration (Day 14)

**Thread 4 — AI Tool Literacy:** Instructor demo (Day 6) → Optional tool comparison (Day 12) → Tool choice + peer discussion (Day 14) → Professional context (Day 16)

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

# PPA Analysis
yosys -p "read_verilog module.v; synth_ice40 -top module; stat"
yosys -p "read_verilog module.v; synth_ice40 -top module; show"
```

## Getting Started

1. **Install the toolchain** — see [`docs/course_setup_guide.md`](docs/course_setup_guide.md)
2. **Get the Go Board** — [nandland.com](https://nandland.com/the-go-board/)
3. **Watch the Day 1 videos** — `lectures/week1_day01/`
4. **Come to class ready to build**

## License

Course materials are provided for educational use. See [LICENSE](LICENSE) for details.

---

*Course version: v2.1 · March 2026*
