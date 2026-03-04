# Accelerated HDL for Digital System Design — Syllabus

> **UCF · College of Engineering & Computer Science · Department of Electrical & Computer Engineering**

---

## Course Information

| | |
|---|---|
| **Course** | Accelerated HDL for Digital System Design |
| **Format** | 4 weeks · 4 sessions/week · 2.5 hours/session (16 sessions, 40 contact hours) |
| **Delivery** | Flipped classroom — recorded video lectures before class; class = mini-lecture + hands-on lab |
| **Instructor** | Prof. Mike (Office hours by appointment) |
| **Prerequisites** | Digital logic fundamentals (gates, Boolean algebra, flip-flops). No prior HDL experience required. |

---

## Course Description

This accelerated course takes students from zero HDL experience to confidently designing, simulating, and implementing digital systems in Verilog on real FPGA hardware. Students will learn fundamental to intermediate Verilog through a hands-on, project-based approach using the Nandland Go Board and an entirely open-source toolchain. The course integrates modern verification practices including AI-assisted testbench generation, PPA (Performance, Power, Area) analysis, and constraint-based design — skills directly relevant to industry and advanced coursework.

By the end of this course, you will be able to design, verify, and implement multi-module digital systems that communicate with a host PC, and you will have the vocabulary and habits to continue learning independently.

---

## Learning Outcomes

Upon successful completion of this course, students will be able to:

1. **Design** combinational and sequential digital circuits in Verilog, including multiplexers, ALUs, counters, shift registers, FSMs, and communication interfaces (UART, SPI).
2. **Simulate** designs using self-checking testbenches, interpreting waveforms, and diagnosing common errors (latches, timing violations, width mismatches).
3. **Implement** designs on FPGA hardware using the open-source iCE40 synthesis flow (Yosys → nextpnr → iceprog).
4. **Verify** designs using both manual testbenches and AI-assisted verification, critically evaluating and correcting AI-generated code.
5. **Analyze** design trade-offs using PPA metrics (LUT/FF counts, Fmax, resource utilization) and make informed design decisions based on quantitative data.
6. **Apply** parameterization, hierarchy, and `generate` constructs to create reusable, configurable modules.
7. **Communicate** design decisions through structured PPA reports, testbench documentation, and live demonstrations.
8. **Transition** to SystemVerilog, using `logic`, `always_ff`/`always_comb`, `enum`, and `struct` for cleaner, safer designs.

---

## Hardware & Software

### Required Hardware
- **Nandland Go Board** (Lattice iCE40 HX1K · 4 LEDs · 4 switches · dual 7-segment displays · VGA · USB)
  - Available from [nandland.com](https://nandland.com/the-go-board/)
  - Students keep the board after the course

### Software Toolchain (all free, open-source)
- **Yosys** — Verilog synthesis
- **nextpnr-ice40** — Place and route for iCE40 FPGAs
- **icepack / iceprog** — Bitstream packing and FPGA programming
- **Icarus Verilog (iverilog)** — Simulation
- **GTKWave** — Waveform viewer
- **Git** — Version control (all work submitted via repository)

Installation instructions: see `docs/course_setup_guide.md` in the course repository.

### AI Tools
Students will use AI-assisted verification tools (e.g., Claude, ChatGPT, Copilot) beginning in Week 2. No specific tool is required — students may use any AI assistant. The critical skill is evaluating and correcting AI-generated code, not the tool itself.

---

## Course Schedule

### Week 1: Verilog Foundations & Combinational Design

| Day | Topic | Pre-class Video | Key Deliverable |
|-----|-------|----------------|-----------------|
| 1 | Welcome to Hardware Thinking | 40 min | Buttons-to-LEDs on hardware |
| 2 | Combinational Building Blocks | 45 min | Hex-to-7-seg decoder on hardware |
| 3 | Procedural Combinational Logic | 45 min | ALU on hardware + if/else vs case synthesis comparison |
| 4 | Sequential Logic: FFs, Clocks & Counters | 50 min | LED blinker + counter on 7-seg |

### Week 2: Sequential Design, Verification & AI-Assisted Testing

| Day | Topic | Pre-class Video | Key Deliverable |
|-----|-------|----------------|-----------------|
| 5 | Counters, Shift Registers & Debouncing | 45 min | Debounced LED chase pattern |
| 6 | Testbenches, Simulation & AI-Assisted Verification | 55 min | Hand-written ALU TB + AI-generated debouncer TB |
| 7 | Finite State Machines | 50 min | Traffic light FSM with testbench |
| 8 | Hierarchy, Parameters, Generate & Design Reuse | 50 min | Hierarchical design + AI-generated parameterized TB |

### Week 3: Memory, Communication & Numerical Architectures

| Day | Topic | Pre-class Video | Key Deliverable |
|-----|-------|----------------|-----------------|
| 9 | Memory: RAM, ROM & Block RAM | 45 min | ROM pattern sequencer + RAM demo |
| 10 | Numerical Architectures & Design Trade-offs | 55 min | Adder/multiplier PPA comparison table |
| 11 | UART TX: Your First Communication Interface | 50 min | "HELLO" on the PC terminal |
| 12 | UART RX, SPI & AI Protocol Verification | 55 min | UART loopback + SPI master + AI protocol TB |

### Week 4: Advanced Design, Verification & Final Project

| Day | Topic | Pre-class Video | Key Deliverable |
|-----|-------|----------------|-----------------|
| 13 | SystemVerilog for Design | 45 min | SV-refactored module with PPA comparison |
| 14 | Verification, AI-Driven Testing & PPA Analysis | 55 min | Assertion-enhanced UART + PPA report |
| 15 | Final Project: Build Day | — | Working prototype + testbench |
| 16 | Final Project Demos & Course Wrap | — | Live demo + presentation |

**Total pre-class video: ~12 hours across 14 sessions**

---

## Class Session Structure (typical)

| Time | Activity |
|------|----------|
| 0:00–0:05 | Warm-up: pre-class quiz review, questions |
| 0:05–0:35 | Mini-lecture: key concepts, live coding, Yosys/GTKWave demos |
| 0:35–0:45 | Lab kickoff: objectives, deliverables, hints |
| 0:45–2:15 | Hands-on lab: students work, instructor circulates |
| 2:15–2:25 | Debrief: show student work, common mistakes, preview next session |
| 2:25–2:30 | Assign pre-class video for next session |

---

## Assessment

| Component | Weight | Description |
|-----------|--------|-------------|
| Daily lab deliverables | 40% | 12 graded lab sessions (Weeks 1–3). Completion + demonstrated understanding. |
| Testbench quality | 15% | Self-checking coverage, edge cases, code quality — both manual and AI-assisted. |
| AI verification portfolio | 5% | Quality of prompts, AI output corrections, and constraint specs accumulated across the course. |
| PPA analysis | 5% | Resource tables, Fmax data, design trade-off reasoning across labs. |
| Final project | 25% | Functionality, design quality, verification, PPA report, and live presentation. |
| Participation & engagement | 10% | In-class questions, helping peers, pre-class video preparation. |

### Grading Scale

| Grade | Range |
|-------|-------|
| A | 90–100% |
| B | 80–89% |
| C | 70–79% |
| D | 60–69% |
| F | Below 60% |

---

## AI Policy

AI-assisted verification is an **explicit learning objective** of this course, introduced beginning Day 6. The course policy is:

1. **Manual first, AI second.** You must demonstrate the ability to write testbenches by hand before using AI tools. Day 6 requires a hand-written testbench.
2. **Transparency required.** When using AI, submit the prompt, the raw AI output, and your corrected version with annotations explaining every change.
3. **Critical evaluation is graded.** Writing a vague prompt and accepting broken output is worse than writing a precise prompt and catching the AI's errors. Grading distinguishes "prompt quality" from "review quality."
4. **AI may not be used for design modules** unless explicitly permitted. AI assistance is scoped to testbench generation and verification.
5. **Tool-agnostic.** You may use any AI tool. Comparing outputs across tools is encouraged as a professional skill.

---

## Final Project

The final project is an individual capstone spanning Days 13–16.
The Day 13 session requires a project design document (block diagram + module list) before full build time begins on Day 15. Students design, verify, and demonstrate a complete FPGA-based system on the Go Board.

### Requirements (all projects)
1. At least one manually-written self-checking testbench for a core module
2. At least one AI-generated testbench with annotated corrections
3. A PPA report: `yosys stat` output, Fmax, % iCE40 HX1K utilization, one paragraph on a design trade-off
4. Live hardware demonstration (5–7 min presentation on Day 16)

### Project Options

| Project | Description | Difficulty |
|---------|-------------|------------|
| **Reaction Timer** | Measure reaction time to LED stimulus, display on 7-seg, report via UART | ★★ |
| **Digital Lock** | FSM-based combination lock with button input, 7-seg feedback, lockout timer | ★★ |
| **Serial Calculator** | Receive expressions via UART, compute result, transmit back | ★★★ |
| **VGA Pattern Generator** | Generate patterns/animation on VGA display, button-controlled | ★★★ |
| **Numerical Compute Engine** | Parameterized ALU + sequential multiplier + fixed-point ops + UART I/O | ★★★ |
| **Custom Proposal** | Student-designed project, approved by instructor by Day 13 | Varies |

---

## Cross-Cutting Skill Threads

These skills build progressively across the course:

**AI-Assisted Verification:** Day 6 (observe) → Day 8 (prompt + review) → Day 12 (protocol-level, tool comparison) → Day 14 (constraint-based, independent) → Days 15–16 (project application)

**PPA Analysis:** Day 3 (first `yosys stat`) → Day 8 (resource scaling) → Day 10 (structured comparison) → Day 12 (feature cost) → Day 13 (SV equivalence) → Day 14 (design-space exploration) → Days 15–16 (project report)

**Constraint-Based Design:** Day 3 (if/else vs case) → Day 7 (FSM encoding) → Day 8 (generate) → Day 10 (numerical trade-offs) → Day 12 (parameterized protocols) → Day 14 (design-space exploration)

---

## Course Policies

### Attendance
This is an intensive, accelerated course. Every session builds directly on the previous one. Missing even one session puts you significantly behind. If you must miss a session, notify the instructor in advance and complete the lab independently before the next class.

### Pre-class Videos
You are expected to watch the assigned video segments and complete the pre-class quiz before each session. Class time assumes you have seen the video. Students who arrive unprepared will struggle with the lab exercises.

### Academic Integrity
All submitted work must be your own, with AI usage documented as described in the AI Policy above. Sharing code between students is not permitted except during explicitly collaborative exercises. The Go Board hardware enforces individual work — each student has their own board and their own project.

### Late Work
Lab deliverables are due at the end of each session. Late submissions receive a 10% penalty per day. The final project has no late submission window.

---

## Toolchain Quick Reference

```bash
# Simulation
iverilog -o sim.vvp -g2012 tb_module.v module.v
vvp sim.vvp
gtkwave dump.vcd

# Synthesis & Programming
yosys -p "synth_ice40 -top top_module -json top.json" top.v sub1.v sub2.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json top.json --asc top.asc
icepack top.asc top.bin
iceprog top.bin

# PPA Analysis
yosys -p "read_verilog module.v; synth_ice40 -top module; stat"
yosys -p "read_verilog module.v; synth_ice40 -top module; show"
```

---

## Resources

- **Course Repository:** All materials, starter code, and lab instructions
- **Nandland Go Board:** [nandland.com](https://nandland.com/the-go-board/)
- **Verilog Reference:** Stuart Sutherland, *Verilog and SystemVerilog Gotchas* (recommended, not required)
- **Online References:** [fpga4fun.com](http://fpga4fun.com), [ZipCPU Blog](https://zipcpu.com/blog/), [ASIC World Verilog](http://www.asic-world.com/verilog/)
- **Open-Source ASIC (aspirational):** [OpenROAD](https://openroad.readthedocs.io/) / [OpenLane](https://openlane.readthedocs.io/) — same Verilog, real ASIC PPA metrics

---

*Syllabus version: v2.1 · Curriculum revision date: March 2026*
