# Day 16: Demos, Reflection & Next Steps

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 16 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 16.1:** Present a working FPGA-based digital system, demonstrating live hardware functionality, explaining the design architecture, and showing the verification methodology.
2. **SLO 16.2:** Articulate the design decisions made during the project — why specific architectures were chosen, what trade-offs were considered, and what alternatives existed.
3. **SLO 16.3:** Critically reflect on the project experience — identifying what worked, what failed, what was learned, and what they would change with more time.
4. **SLO 16.4:** Map the skills acquired in this course to the broader landscape of digital design, identifying pathways into ASIC design, FPGA engineering, embedded systems, hardware security, and verification.

---

## Session Structure

| Time | Activity |
|---|---|
| 0:00–0:10 | Setup and demo order |
| 0:10–2:00 | Student demonstrations (~7 min each) |
| 2:00–2:15 | Course retrospective |
| 2:15–2:30 | Where to go from here |

---

## Demo Setup (10 min)

### Logistics

- **Demo order:** Randomized or volunteer-first.
- **Equipment:** Each student's Go Board connected to their laptop, terminal emulator open, projector shows their screen (GTKWave, terminal, code).
- **Backup plan:** If hardware fails during demo, show simulation waveforms and explain the design. Partial credit is full credit for verified simulation with clear explanation of what didn't translate to hardware.

### Demo Format Reminder

Each demo is 5–7 minutes:

1. **Introduction** (30 sec): Project name, one-sentence description
2. **Live demo** (2 min): Show it working. If UART-based, type commands. If visual, show the LEDs/display. If VGA, show the monitor.
3. **Architecture** (1–2 min): Block diagram on screen. Walk through the data path. Identify which modules are reused and which are new.
4. **Verification** (1 min): Show testbench output (pass/fail summary). Mention assertions if used. Describe what's tested.
5. **Reflection** (1 min): What's the most interesting challenge? What would you do differently?
6. **Q&A** (remaining): Instructor and peer questions.

---

## Student Demonstrations (~110 min)

### Evaluation Rubric

Each demo is assessed on the following rubric. Students should have received this on Day 15.

#### Functionality (30%)

| Score | Criteria |
|---|---|
| Excellent | Full project scope working on hardware. All features functional. Handles edge cases. |
| Good | Core functionality working on hardware. Most features present. Minor issues at edges. |
| Adequate | Minimum viable demo working on hardware. Some features incomplete but core idea demonstrated. |
| Developing | Simulation works but hardware has issues. Or: partial functionality on hardware. |
| Incomplete | Neither simulation nor hardware demonstrates the intended functionality. |

#### Design Quality (25%)

| Score | Criteria |
|---|---|
| Excellent | Clean module hierarchy. Appropriate use of FSMs, parameterization, and module reuse. Resource usage is reasonable. SystemVerilog features used where appropriate. |
| Good | Clear architecture. Most modules well-structured. Minor code quality issues. |
| Adequate | Design works but has structural issues (e.g., everything in one module, magic numbers, unused signals). |
| Developing | Significant structural problems (e.g., hardcoded values throughout, no module hierarchy, copy-paste code). |

#### Verification (20%)

| Score | Criteria |
|---|---|
| Excellent | Self-checking testbenches for all custom modules. Assertions present. Coverage awareness demonstrated. Test plan documented. |
| Good | Self-checking testbenches for core modules. Basic assertions or clear test strategy. |
| Adequate | Testbenches exist but are not fully self-checking. Some manual verification. |
| Developing | Minimal testbenching. Relies primarily on hardware testing. |

#### Integration (15%)

| Score | Criteria |
|---|---|
| Excellent | Clean top module. Proper debouncing. Correct clock domain handling. No synthesis warnings. Timing met. |
| Good | Top module is organized. Most integration is clean. Minor warnings acceptable. |
| Adequate | Working integration but messy (unnecessary signals, commented-out code, workarounds). |
| Developing | Integration incomplete or has fundamental issues (multi-driven nets, timing violations). |

#### Presentation (10%)

| Score | Criteria |
|---|---|
| Excellent | Clear, confident explanation. Honest about what didn't work. Insightful reflection. Good use of time. |
| Good | Solid explanation. Reasonable reflection. Stays within time. |
| Adequate | Gets the point across. Some difficulty explaining decisions. |
| Developing | Unclear explanation. No reflection. Significantly over/under time. |

### Questions to Ask During Demos

**Design questions:**
- Why did you choose [architecture X] instead of [alternative Y]?
- What's on the critical path? What's your Fmax?
- How many LUTs/FFs does this use? Is that more or less than you expected?
- If you needed to add [feature Z], where would it go in the architecture?

**Verification questions:**
- What's the most subtle bug you found during testing?
- What's the hardest thing to test in your design?
- If you had more time, what would you add to your testbench?
- Are there any corner cases you know you haven't tested?

**Reflection questions:**
- What was the most surprising thing you learned?
- If you started over, what would you do differently in the first week?
- Which module was the hardest to get right? Why?
- What's the most useful technique you'll take forward?

---

## Course Retrospective (15 min)

### What We Built in 4 Weeks

#### Module Library Inventory

By the end of this course, students have designed, tested, and (in most cases) synthesized the following modules:

**Week 1 — Combinational & Sequential Foundations:**
- `mux_2to1`, `mux_4to1` — multiplexers
- `alu_4bit` — arithmetic logic unit
- `hex_to_7seg` — 7-segment decoder
- `d_flip_flop`, `register_N` — basic sequential elements

**Week 2 — Robustness, Verification & Structure:**
- `debounce` — button debouncer with synchronizer
- `edge_detect` — rising/falling edge detector
- `shift_reg_*` — various shift register configurations
- `lfsr` — pseudo-random number generator
- `counter_mod_n` — parameterized modulo-N counter
- `traffic_light` — timed FSM controller
- `pattern_detector` — sequence recognizer FSM
- `go_board_input` — generate-based multi-channel debounce

**Week 3 — Memory, Timing & Communication:**
- `rom_array`, `rom_sync` — ROM (async and sync read)
- `ram_sp` — single-port synchronous RAM
- `ram_init` — initialized RAM
- `baud_gen` — baud rate tick generator
- `uart_tx` — UART transmitter (FSM + PISO shift register)
- `uart_rx` — UART receiver (16× oversampling)
- `spi_master` — SPI master controller
- `pattern_sequencer` — ROM-driven pattern display

**Week 4 — SystemVerilog & Integration:**
- All of the above, refactored with `logic`, `always_ff`, `always_comb`, `enum`
- Assertion-enhanced versions of critical modules
- Final project: a complete multi-module system

That's roughly 20–25 verified, reusable modules — a genuine IP library.

#### Skills Progression

| Skill | Week 1 | Week 2 | Week 3 | Week 4 |
|---|---|---|---|---|
| **Design** | Gates, muxes, FFs | FSMs, counters, shift regs | Memory, protocols | SystemVerilog, integration |
| **Verification** | Manual observation | Self-checking TBs | Protocol-aware TBs | Assertions, coverage |
| **Tools** | iverilog, GTKWave | yosys, nextpnr | icepll, terminal | Verilator, full flow |
| **Hardware** | LED blink | Debounced buttons | UART to PC | Complete system |
| **Methodology** | "Does it light up?" | "Does the TB pass?" | "Does the protocol work?" | "Is it verified?" |

### Group Discussion Prompts

Spend 5–10 minutes on an open discussion:

1. **What was the most valuable thing you learned?** (Not the most interesting — the most *useful*)
2. **What was the hardest concept to grasp?** (Honest answers help improve the course)
3. **What surprised you about FPGA development?** (Compared to software, compared to expectations)
4. **If you had a 5th week, what would you want to learn?**

---

## Where to Go From Here (15 min)

### Immediate Next Steps

#### Keep the Go Board

The Go Board is yours. Projects to try on your own:
- **VGA output:** 640×480 with a character display. Needs only a VGA PMOD or direct resistor-DAC.
- **Audio synthesis:** PWM or delta-sigma DAC through PMOD. Generate tones, play melodies from ROM.
- **Game:** Pong on VGA with button controls. Classic FPGA project.
- **Logic analyzer:** Use the FPGA to capture and display digital signals via UART. Practical tool.
- **RISC-V core:** The iCE40 HX1K is tight but a minimal RV32I core can fit. PicoRV32 is open-source.

#### Open-Source FPGA Resources

- **Nandland.com:** Russell Merrick's tutorials (Go Board creator). Excellent beginner-to-intermediate content.
- **fpga4fun.com:** Practical project tutorials (UART, VGA, audio, SPI).
- **ZipCPU blog:** Dan Gisselquist's deep technical articles on formal verification, UART, Wishbone bus, and more.
- **Lattice iCE40 documentation:** The official datasheet and programming guide are essential references for the Go Board's FPGA.

### Career Pathways

#### FPGA Engineering

**What it is:** Designing digital systems for FPGAs in production — signal processing, networking, defense, medical devices, data centers.

**What you need next:** More complex designs (PCIe, Ethernet, DSP pipelines), larger FPGAs (Xilinx/AMD or Intel/Altera), vendor tools (Vivado, Quartus), high-speed I/O, embedded processors (MicroBlaze, Nios II, RISC-V soft cores).

**Courses:** Advanced digital design, DSP, computer architecture, embedded systems.

#### ASIC Design

**What it is:** Designing chips that get manufactured in silicon — processors, GPUs, AI accelerators, wireless modems, SoCs.

**What you need next:** Deep SystemVerilog, logic synthesis theory, static timing analysis, physical design awareness (floorplanning, clock tree, power), Design-for-Test (DFT), standard cell libraries.

**Courses:** VLSI design, computer architecture, advanced logic synthesis.

#### Verification Engineering

**What it is:** Proving that a chip design is correct before it's manufactured. The majority of engineering effort on any serious chip project.

**What you need next:** UVM methodology, constrained random verification, functional coverage, formal verification (SVA, model checking), emulation/prototyping.

**Courses:** Advanced verification, formal methods. Industry certifications (Synopsys, Cadence, Siemens EDA).

#### Hardware Security

**What it is:** Analyzing and defending hardware against side-channel attacks, fault injection, reverse engineering, supply chain threats, and hardware trojans.

**What you need next:** Cryptographic implementations in hardware, power analysis (DPA/CPA), electromagnetic analysis, fault injection techniques, secure design methodologies.

**Courses:** Cryptography, hardware security, side-channel analysis. (The DRACO Lab is a great place to start.)

#### Embedded Systems

**What it is:** Designing systems where software meets hardware — microcontrollers, SoCs, firmware, real-time systems.

**What you need next:** Microcontroller programming (ARM Cortex-M), RTOS, hardware/software co-design, bus protocols (AXI, Wishbone, AHB), peripheral design.

**Courses:** Embedded systems, real-time operating systems, computer architecture.

### Connecting to Research

For students interested in research, the skills from this course directly apply to:

- **Side-channel analysis:** Building custom acquisition hardware for power/EM analysis
- **Hardware trojan detection:** Designing and analyzing circuits with hidden malicious functionality
- **Secure processor design:** Implementing countermeasures against speculative execution attacks
- **AI/ML hardware accelerators:** Designing custom neural network inference engines
- **Post-quantum cryptography:** Implementing lattice-based cryptosystems in hardware

### Recommended Next Courses

| Interest Area | Recommended Course | Why |
|---|---|---|
| Chip design | Computer Architecture | Processor design, pipelines, caches |
| FPGA engineering | Advanced Digital Design | Complex state machines, DSP, high-speed I/O |
| Verification | Formal Methods / Advanced Verification | SVA, model checking, UVM |
| Security | Hardware Security | Side-channel attacks, secure design |
| Embedded | Embedded Systems Design | HW/SW co-design, RTOS |

---

## Course Feedback

Distribute the end-of-course survey. Key questions to include:

1. **Pacing:** Was the course too fast, too slow, or about right for each week?
2. **Flipped format:** Did the pre-class videos prepare you adequately for lab? What would improve them?
3. **Lab exercises:** Which exercises were most valuable? Which felt like busywork?
4. **Go Board:** Was the hardware platform appropriate? What would you change?
5. **Tools:** Were the open-source tools (Icarus, Yosys, nextpnr, GTKWave) adequate? Where did they frustrate you?
6. **Final project:** Was the project scope appropriate? Was there enough build time?
7. **Preparation:** How well did this course prepare you for [your next course / research / career goals]?
8. **One thing to keep:** What single aspect of the course should definitely be kept?
9. **One thing to change:** What single change would most improve the course?

---

## Closing Remarks

### What You've Accomplished

Four weeks ago, most of you had never written a line of HDL. Today you have:

- Designed and verified 20+ digital modules
- Built a complete bidirectional communication interface from scratch
- Programmed a real FPGA and talked to it from your PC
- Written protocol-aware testbenches with automated pass/fail checking
- Learned both Verilog and SystemVerilog
- Integrated multiple modules into a working system and demonstrated it live

That's a genuine engineering achievement. The gap between "I've never done this" and "I can build a working FPGA system" is real, and you've crossed it.

### The Transferable Skills

The specific HDL syntax will fade if you don't use it regularly. But the deeper skills transfer everywhere:

- **Thinking in parallelism:** Hardware doesn't execute sequentially. Neither do distributed systems, GPU programs, or concurrent software.
- **Verification discipline:** "Does the test pass?" is a mindset that applies to any engineering artifact.
- **Interface design:** Clean module boundaries, well-defined handshakes, and documented protocols are universal.
- **Debugging methodology:** Systematic narrowing from symptom to root cause — the same process whether you're debugging Verilog, C++, or a physical circuit.
- **Resource awareness:** In hardware, every gate costs silicon area and power. That awareness of efficiency transfers to algorithm design, systems engineering, and architecture.

### Final Words

The digital design community is remarkably open and collaborative. The open-source FPGA toolchain you used (Yosys, nextpnr, Project IceStorm) was built by volunteers who believed this technology should be accessible to everyone. The tutorials, forum posts, and open-source IP cores you've used were shared by engineers who want to help others learn.

Pay it forward. Share what you've built. Help the next person who's stuck on their first testbench. Write up your project for others to learn from. Contribute to the tools and communities that helped you.

Good luck. Go build things.

---

## Instructor Notes

- **Demo time management is critical.** With 15+ students at 7 minutes each, you need 105+ minutes. Enforce the time limit kindly but firmly. A visible countdown timer helps.
- **Hardware failures during demos happen.** Be generous. If the student can show simulation waveforms, explain the architecture, and articulate why the hardware didn't work, they've demonstrated understanding. The failure mode itself is often instructive.
- **The retrospective discussion** can be very valuable if you let students talk. Ask the opening question and then be quiet. Let them share experiences with each other.
- **Career pathways section:** Tailor this to your audience. If most students are heading toward software, emphasize the hardware/software interface and embedded systems. If they're heading toward chip design or security research, emphasize those paths.
- **Course feedback:** Collect it today while the experience is fresh. Anonymous written feedback is more honest than verbal feedback in front of the class.
- **The Go Board goes home with them.** This is important for retention. Students who keep tinkering after the course retain far more than those who stop on Day 16. Encourage them to try one more project within a week of the course ending.
- **Personal notes:** After the demos, take 10 minutes to write yourself notes on each student's strengths and areas for growth. This is invaluable for recommendation letters and for improving next semester's course.
