# Accelerated HDL for Digital System Design

## Course Curriculum & Session Map

**Format:** 4 weeks · 4 sessions/week · 2.5 hours/session (16 sessions total)
**Delivery:** Flipped — recorded lectures pre-class; class = mini-lecture (25–35 min) + hands-on lab (~2 hrs)
**Platform:** Nandland Go Board (Lattice iCE40 HX1K · 4 LEDs · 4 buttons · dual 7-seg · VGA)
**Toolchain:** Yosys + nextpnr-ice40 + icepack/iceprog (synthesis/PnR), Icarus Verilog + GTKWave (simulation)
**Students:** <15, primarily CompE with some CS; no prior HDL; varying programming maturity
**Assessment:** Continuous lab deliverables (Weeks 1–3), final project (Week 4)

---

## Week 1: Verilog Foundations & Combinational Design

*Goal: Students go from zero HDL to confidently writing and simulating combinational modules and basic sequential logic targeting real hardware.*

### Day 1 — Welcome to Hardware Thinking

**Pre-class (flipped recording, ~40 min):**
- HDL vs. software mental model — concurrency, not sequentiality
- Synthesis vs. simulation: two very different execution contexts
- Brief digital logic refresher: gates, truth tables, Boolean simplification (reference, not reteach)
- Anatomy of a Verilog module: `module`, ports, `endmodule`

**In-class mini-lecture (30 min):**
- Course roadmap and expectations
- Toolchain walkthrough — the open-source iCE40 flow: Verilog → Yosys (synthesis) → nextpnr (PnR) → icepack → iceprog
- Live demo: from source to blinking LED in under 2 minutes
- `.pcf` pin constraint file — mapping HDL signals to physical pins on the Go Board

**Lab (~2 hrs):**
1. Environment setup & toolchain verification (Yosys, nextpnr, iceprog, iverilog, gtkwave)
2. LED on: hardwire an LED high — synthesize, program, verify
3. Buttons to LEDs: wire each button to its corresponding LED (`assign`)
4. Add inversion, AND/OR combinations between buttons and LEDs
5. **Stretch:** XOR toggle pattern, create a simple Makefile for the build flow

**Deliverable:** Buttons-to-LEDs with at least one logic modification, programmed on hardware.

---

### Day 2 — Combinational Building Blocks

**Pre-class (~45 min):**
- Data types: `wire`, `reg` (and why `reg` doesn't always mean register)
- Vectors and buses: `[MSB:LSB]`, bit slicing, concatenation `{}`, replication `{N{...}}`
- Operators: bitwise, arithmetic, relational, logical, conditional (`?:`)
- Continuous assignment: `assign` and its synthesis implications

**In-class mini-lecture (30 min):**
- Multiplexer as the fundamental combinational building block
- Design pattern: `assign y = sel ? a : b;` and nested conditional
- Common early mistakes: mismatched widths, undriven wires
- 7-segment display encoding — mapping 4-bit hex to segment patterns

**Lab (~2 hrs):**
1. 2:1 mux → 4:1 mux (both `assign`-based and nested conditional)
2. 4-bit ripple-carry adder from full-adder modules (first taste of hierarchy)
3. Hex-to-7-segment decoder — drive the Go Board's display from button inputs
4. **Stretch:** Display the sum of two 2-bit button inputs on 7-seg

**Deliverable:** 7-segment display showing button states as a hex digit, programmed on board.

---

### Day 3 — Procedural Combinational Logic

**Pre-class (~45 min):**
- `always @(*)` — sensitivity lists and the wildcard
- `if/else`, `case`, `casez`, `casex`
- Blocking (`=`) vs. nonblocking (`<=`) — first pass (blocking for combinational)
- **Critical concept:** unintentional latch inference and how to avoid it (default assignments, fully specified case)

**In-class mini-lecture (30 min):**
- When to use `assign` vs. `always @(*)` — readability and complexity thresholds
- Visualizing what the synthesizer builds: draw the hardware, then code it
- Live demo: Yosys `show` command to see the synthesized netlist as a schematic
- Priority encoder: `if/else` chains imply priority — use it intentionally

**Lab (~2 hrs):**
1. Priority encoder (4-input)
2. 4-bit ALU: AND, OR, ADD, SUB selected by 2-bit opcode from buttons
3. BCD-to-7-seg decoder with decimal point control
4. Display ALU result on 7-seg (integrate prior modules)
5. **Stretch:** Signed operations, overflow detection flag on an LED

**Deliverable:** Mini-ALU with result displayed on 7-segment, opcode selected by buttons.

---

### Day 4 — Sequential Logic Fundamentals

**Pre-class (~50 min):**
- Clocks and edge-triggered behavior: `always @(posedge clk)`
- Nonblocking assignments (`<=`) for sequential logic — and why this matters
- Flip-flops in Verilog: D-FF, D-FF with enable, D-FF with sync/async reset
- Reset strategies: synchronous vs. asynchronous, active-high vs. active-low
- Register Transfer Level (RTL) thinking: data moves between registers on clock edges

**In-class mini-lecture (35 min):**
- The clock is everything — draw timing diagrams by hand before you simulate
- The Go Board's 25 MHz oscillator: too fast to see — enter the clock divider
- Common sequential mistakes: mixing blocking/nonblocking, missing resets, clock in sensitivity list wrong
- Live coding: counter-based clock divider, predict behavior before running

**Lab (~2 hrs):**
1. D flip-flop → verify in simulation (Icarus + GTKWave) first, then on board
2. 4-bit loadable register
3. Free-running counter (8-bit, 16-bit, 24-bit)
4. Clock divider: 25 MHz → ~1 Hz using a counter, blink an LED
5. Dual-speed blinker: two LEDs at different rates from independent dividers
6. **Stretch:** Up/down counter controlled by buttons, display count on 7-seg

**Deliverable:** LED blinker at visible rate (~1 Hz), counter value on 7-seg.

---

## Week 2: Sequential Design & Verification

*Goal: Students master FSMs, write proper testbenches, and build reusable parameterized modules. Simulation becomes a first-class part of the workflow.*

### Day 5 — Counters, Shift Registers & Debouncing

**Pre-class (~45 min):**
- Counter variations: up, down, up/down, modulo-N, loadable
- Shift registers: SISO, SIPO, PISO, PIPO — and why they matter (serial I/O, later UART)
- The button bounce problem: mechanical switches are noisy
- Synchronizer chains: metastability and the 2-FF synchronizer

**In-class mini-lecture (30 min):**
- Metastability: what it is, why it's terrifying, how synchronizers help
- Debounce strategies: counter-based, shift-register-based
- Live demo: scope/logic analyzer view of button bounce (or simulation equivalent)

**Lab (~2 hrs):**
1. Build a reusable debouncer module (counter-based, parameterized threshold)
2. 8-bit shift register with serial in, parallel out
3. LED chase pattern ("Knight Rider" / Cylon): shift register drives LEDs
4. Debounced button controls direction and speed of chase
5. **Stretch:** LFSR-based pseudo-random LED pattern

**Deliverable:** Debounced button-controlled LED chase pattern on the Go Board.

---

### Day 6 — Testbenches & Simulation-Driven Development

**Pre-class (~50 min):**
- Testbench anatomy: no ports, instantiate DUT, apply stimulus
- `initial` blocks, `#` delay, `$finish`
- Waveform dumping: `$dumpfile`, `$dumpvars`
- Display/debug: `$display`, `$monitor`, `$write`, format specifiers
- Stimulus patterns: exhaustive, directed, corner-case
- Self-checking testbenches: `if` checks with `$display` pass/fail messages

**In-class mini-lecture (30 min):**
- Verification mindset: "if you haven't simulated it, it doesn't work"
- Workflow: simulate first, **then** synthesize to board — always
- Self-checking testbenches: automating correctness checks vs. staring at waveforms
- Practical GTKWave navigation: zoom, markers, signal grouping, analog display

**Lab (~2 hrs):**
1. Write a testbench for the Day 3 ALU — directed stimulus for all opcodes
2. Make it self-checking: expected vs. actual with automated pass/fail
3. Testbench for the debouncer: simulate noisy input, verify clean output
4. Testbench for the counter: check rollover, reset behavior, enable
5. **Stretch:** Task-based testbench organization, file-based stimulus (`$readmemh`)

**Deliverable:** Self-checking ALU testbench with automated pass/fail report. Screenshot of GTKWave waveforms.

---

### Day 7 — Finite State Machines

**Pre-class (~50 min):**
- Moore vs. Mealy: outputs depend on state only vs. state + input
- State diagrams to HDL: a systematic translation process
- 3-always-block FSM coding style: state register, next-state logic, output logic
- State encoding: binary, one-hot, gray — trade-offs
- `localparam` or `parameter` for state names (readability)

**In-class mini-lecture (30 min):**
- FSM design methodology: (1) draw the diagram on paper, (2) enumerate states/transitions, (3) code it, (4) simulate it
- Why three always blocks? Separation of concerns, easier debugging, cleaner synthesis
- Live design: vending machine or pattern detector, paper to code

**Lab (~2 hrs):**
1. Traffic light controller: 3 states (R/Y/G), timed transitions using counters, display state on LEDs + 7-seg
2. Write a thorough testbench — verify all state transitions, timing
3. Pushbutton pattern detector: detect a specific button press sequence, light an LED
4. **Stretch:** Mealy version of the pattern detector, compare behavior at transitions

**Deliverable:** Traffic light FSM running on board with waveform-verified testbench.

---

### Day 8 — Hierarchy, Parameters & Generate

**Pre-class (~45 min):**
- Module instantiation: positional vs. named port connections (always use named!)
- `parameter` and `localparam`: making modules reusable
- `#(.PARAM(value))` override syntax
- `generate` blocks: `for`-generate, `if`-generate — hardware replication and conditional instantiation
- Design for reuse: building a personal Verilog library

**In-class mini-lecture (30 min):**
- Hierarchy as the key to managing complexity — top-down vs. bottom-up
- Parameterization philosophy: what should be parameterized and what shouldn't
- `generate` block: thinking of it as a compile-time loop, not a runtime loop
- Live demo: parameterized N-bit counter, instantiated at multiple widths

**Lab (~2 hrs):**
1. Parameterized N-bit counter module — instantiate as 8-bit, 16-bit, 24-bit
2. Parameterized N-bit ALU — reuse from Day 3, now with configurable width
3. `generate`-based LED driver: N instances of a blink module at different rates
4. Clean hierarchical top module that ties everything together on the Go Board
5. **Stretch:** Parameterized LFSR with configurable polynomial via `generate`

**Deliverable:** Hierarchical design with at least 3 levels of module instantiation, parameterized.

---

## Week 3: Interfaces, Memory & Communication

*Goal: Students design real communication interfaces (UART, SPI), work with on-chip memory, and understand timing constraints. Designs become systems, not just modules.*

### Day 9 — Memory: RAM, ROM & Block RAM

**Pre-class (~45 min):**
- Modeling ROM in Verilog: `case`-based, array-based
- `$readmemh` / `$readmemb`: initializing memory from files
- RAM modeling: synchronous read/write patterns
- iCE40 Block RAM (EBR): 16 blocks × 4 Kbit = 64 Kbit total
- Inference patterns: how to write Verilog that Yosys maps to EBR (synchronous read is key)

**In-class mini-lecture (30 min):**
- FPGA memory landscape: LUT RAM vs. Block RAM vs. external memory
- iCE40 `SB_RAM256x16` and inference — what Yosys needs to see
- Practical: use `$readmemh` to load a lookup table from a `.hex` file
- Live demo: sine wave lookup table or character ROM

**Lab (~2 hrs):**
1. ROM-based pattern sequencer: step through LED/7-seg patterns stored in ROM
2. Inferred Block RAM: write data via buttons, read and display on 7-seg
3. Testbench: verify RAM read-after-write behavior
4. **Stretch:** Dual-port RAM, simple display buffer concept

**Deliverable:** ROM-driven 7-seg pattern sequencer + RAM read/write demo, with testbench.

---

### Day 10 — Timing, Clocking & Constraints

**Pre-class (~50 min):**
- Setup time, hold time, and the critical path
- Clock period constraints and how they relate to Fmax
- The `.pcf` file in depth: pin assignments, I/O standards on iCE40
- nextpnr timing analysis: reading the timing report
- PLLs on iCE40: `SB_PLL40_CORE`, frequency multiplication/division
- Clock domain crossing basics: the two-FF synchronizer revisited

**In-class mini-lecture (35 min):**
- Reading a nextpnr timing report line by line — what "timing met" means in practice
- When timing fails: what are your options? (restructure logic, pipeline, relax clock)
- PLL configuration on the Go Board: deriving clocks from the 25 MHz input
- Clock domain crossing: a real problem you *will* encounter, and the safe patterns

**Lab (~2 hrs):**
1. Add timing constraints to an existing design, analyze the report
2. Intentionally create a timing violation (long combinational chain), observe the report
3. Instantiate `SB_PLL40_CORE`: generate a different frequency, drive LED blinker from it
4. Clock domain crossing exercise: pass a signal between two clock domains safely
5. **Stretch:** Pipelining a combinational path to meet timing

**Deliverable:** Design with PLL-derived clock, annotated timing report with all constraints met.

---

### Day 11 — UART Transmitter

**Pre-class (~50 min):**
- UART protocol deep dive: idle, start bit, 8 data bits (LSB first), optional parity, stop bit
- Baud rate generation: deriving a baud tick from 25 MHz (e.g., 115200 baud → divide by 217)
- UART TX architecture: FSM + shift register + baud generator
- Designing a communication interface: decompose into FSM (control) + datapath

**In-class mini-lecture (30 min):**
- FSM + datapath decomposition as a general design pattern
- UART TX: draw the block diagram together, identify the states
- Live walkthrough: TX FSM state diagram → Verilog skeleton
- Connecting to a PC: USB-serial adapter, terminal emulator (screen, minicom, PuTTY)

**Lab (~2 hrs):**
1. Implement baud rate generator (parameterized for different baud rates)
2. Implement UART TX module: idle → start → data[0:7] → stop → idle
3. Testbench: self-checking, verify bit timing and data correctness
4. Synthesize and program: transmit a hardcoded byte to PC terminal
5. Transmit "HELLO" as a repeated sequence
6. **Stretch:** Add parity bit support, button-triggered message transmission

**Deliverable:** Go Board transmitting readable characters to a PC terminal. Self-checking testbench with waveforms.

---

### Day 12 — UART Receiver, SPI & IP Integration

**Pre-class (~50 min):**
- UART RX design: oversampling (16×), start-bit detection, bit centering
- RX FSM: idle → detect start → sample bits at center → stop → valid
- SPI protocol: clock polarity (CPOL), clock phase (CPHA), MOSI/MISO/SCLK/CS
- SPI master: shift register + clock generation + FSM
- IP integration: evaluating, documenting, and wrapping third-party modules

**In-class mini-lecture (30 min):**
- UART RX: why 16× oversampling? Finding the center of each bit
- SPI vs. UART vs. I²C: when to use what, trade-offs
- Working with third-party IP: trust but verify, write a wrapper, constrain the interface
- Preview: what "IP integration" means in industry (vendor IP, licensing, verification burden)

**Lab (~2 hrs):**
1. Implement UART RX with 16× oversampling
2. Create UART loopback: RX → TX, type on PC → echo back
3. Testbench: simulate TX driving RX, verify end-to-end data integrity
4. SPI master: implement or integrate an open-source SPI master, simulate
5. **Stretch:** UART-to-SPI bridge — receive commands via UART, forward via SPI

**Deliverable:** UART loopback working on hardware. SPI master simulated with testbench.

---

## Week 4: SystemVerilog Primer & Final Project

*Goal: Introduce SystemVerilog for cleaner design and modern verification. Students apply everything in a capstone project.*

### Day 13 — SystemVerilog for Design

**Pre-class (~45 min):**
- Why SystemVerilog? Evolution from Verilog-2001, IEEE 1800 standard
- `logic` replaces both `wire` and `reg` — one type to rule them all
- `always_ff`, `always_comb`, `always_latch` — intent-based always blocks (compiler catches mistakes)
- `enum`: named states for FSMs — no more `localparam` state definitions
- `struct` and `typedef`: grouping related signals
- `package` and `import`: sharing definitions across modules

**In-class mini-lecture (30 min):**
- Side-by-side comparison: Verilog vs. SystemVerilog for the same module
- The safety net: `always_comb` catches missing assignments, `always_ff` enforces edge-triggered
- `enum` FSMs: automatic next-state validation, `.name()` for debug printing
- Note on toolchain: Icarus Verilog has partial SV support; Verilator is a good complement

**Lab (~2 hrs):**
1. Refactor the traffic light FSM into SystemVerilog: `logic`, `always_ff`, `always_comb`, `enum` states
2. Refactor the UART TX: use `struct` for configuration, `enum` for states
3. Simulate both versions (Icarus with `-g2012` flag), compare waveforms
4. Compare synthesis results in Yosys (resource usage, Fmax)
5. **Stretch:** Create a `package` with shared type definitions, import into multiple modules

**Deliverable:** SystemVerilog-refactored module(s) with notes comparing the Verilog and SV versions.

---

### Day 14 — SystemVerilog for Verification

**Pre-class (~50 min):**
- Immediate assertions: `assert`, `$error`, `$fatal` — inline design checks
- Concurrent assertions (brief intro): `assert property`, sequence syntax
- `$error` and `$fatal` severity levels
- Functional coverage: `covergroup`, `coverpoint`, `bins` — are you testing what you think you're testing?
- Interfaces and `modport`: cleaner testbench-DUT connections
- Object-oriented verification preview: classes, randomization (conceptual — full UVM is out of scope)

**In-class mini-lecture (30 min):**
- The verification gap: designs get more complex, verification must scale
- Assertions as executable documentation — catching bugs at the source
- Coverage-driven verification: how do you know when you're *done* testing?
- Industry context: UVM, formal verification, where this all leads
- Tool note: Verilator and commercial tools for full SV verification support

**Lab (~2 hrs):**
1. Add immediate assertions to UART TX: assert valid baud timing, assert correct start/stop bits
2. Add assertions to the FSM: assert no illegal state transitions
3. Write a basic `covergroup` for the ALU: cover all opcodes, edge-case operands
4. Interface-based testbench: refactor a testbench to use an SV `interface` + `modport`
5. **Stretch:** Concurrent assertion for UART protocol compliance (start bit followed by 8 data bits followed by stop bit)

**Deliverable:** Assertion-enhanced testbench with coverage report. Brief write-up on what assertions caught (or would catch).

---

### Day 15 — Final Project: Build Day

**Mini-lecture (15 min):**
- Project check-in: quick stand-up, each student states progress and blockers
- Debugging strategies: divide and conquer, simulation first, use assertions, check pin assignments
- Integration tips: test each module independently before combining

**Lab (~2.25 hrs):**
- Dedicated project work time
- Mike circulates for 1-on-1 debugging and design review
- Peer collaboration encouraged

**Deliverable:** Working prototype or demonstrable progress. Testbench for at least one key module.

---

### Day 16 — Final Project Demos & Course Wrap

**Demos (~1.5 hrs):**
- Each student presents their project (5–7 min each)
- Format: 1 min context, live hardware demo, show key testbench/waveforms, lessons learned
- Class Q&A after each demo

**Mini-lecture / Discussion (30 min):**
- Where to go from here:
  - ASIC vs. FPGA career paths
  - Advanced SystemVerilog and UVM
  - Formal verification
  - The open-source FPGA ecosystem (SymbiFlow, Amaranth, LiteX)
  - Resources: fpga4fun, ZipCPU blog, nandland.com, ASIC World
- Course retrospective: what worked, what to improve

**Wrap (15 min):**
- Feedback collection
- You keep the Go Board — keep building!

---

## Final Project Options

Students choose one (or propose their own with approval). All projects must include a testbench for at least one nontrivial module.

| Project | Key Concepts Exercised | Difficulty |
|---|---|---|
| **VGA Pattern Generator** | VGA timing, counters, ROM, pixel addressing | ★★☆ |
| **Digital Clock** | Counters, 7-seg multiplexing, UART time-set | ★★☆ |
| **Reaction Time Game** | FSM, counters, RNG (LFSR), 7-seg display | ★★☆ |
| **UART Command Parser** | UART RX/TX, FSM, string matching, LED control | ★★★ |
| **SPI Sensor Interface** | SPI master, data formatting, display | ★★★ |
| **Simple 4-bit Processor** | ALU + register file + sequencer/FSM + ROM program | ★★★ |
| **Conway's Game of Life** | Block RAM grid, FSM update logic, LED/VGA display | ★★★ |
| **Music/Tone Generator** | Counters, frequency dividers, PWM, button sequencer | ★★☆ |
| **Stopwatch / Lap Timer** | Precision counters, debounce, 7-seg mux, UART log | ★★☆ |

---

## Daily Structure Template (2.5 hours)

| Time | Activity |
|---|---|
| 0:00–0:05 | Warm-up: quick question or "what confused you in the video?" |
| 0:05–0:35 | Mini-lecture: key concepts, live coding, Yosys/GTKWave demos |
| 0:35–0:45 | Lab kickoff: objectives, deliverables, hints |
| 0:45–2:15 | Hands-on lab: students work, Mike circulates |
| 2:15–2:25 | Debrief: show a student's work, common mistakes, preview tomorrow |
| 2:25–2:30 | Assign pre-class video for next session |

---

## Pre-Class Video Guide

| Session | Video Duration (target) | Topic |
|---|---|---|
| Day 1 | 40 min | HDL mindset, synthesis vs. sim, module anatomy |
| Day 2 | 45 min | Data types, vectors, operators, assign |
| Day 3 | 45 min | always @(*), if/case, latch inference |
| Day 4 | 50 min | Clocks, posedge, nonblocking, resets, RTL thinking |
| Day 5 | 45 min | Counters, shift registers, bounce/metastability |
| Day 6 | 50 min | Testbench anatomy, self-checking, GTKWave |
| Day 7 | 50 min | FSM theory, Moore/Mealy, 3-block style |
| Day 8 | 45 min | Hierarchy, parameters, generate |
| Day 9 | 45 min | ROM/RAM modeling, readmemh, EBR inference |
| Day 10 | 50 min | Timing analysis, PCF deep dive, PLLs, CDC |
| Day 11 | 50 min | UART protocol, baud rate, TX architecture |
| Day 12 | 50 min | UART RX, SPI protocol, IP integration |
| Day 13 | 45 min | SV: logic, always_ff/comb, enum, struct, package |
| Day 14 | 50 min | SV: assertions, coverage, interfaces, OOP preview |

**Total recording time: ~660 min (~11 hours)**

---

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

# Useful Yosys commands (interactive)
yosys> read_verilog top.v
yosys> synth_ice40 -top top_module
yosys> show                          # visualize synthesized netlist
yosys> stat                          # resource utilization summary
```

---

## Suggested Grading Weights

| Component | Weight | Notes |
|---|---|---|
| Daily lab deliverables (12 sessions) | 50% | Completion + demonstrated understanding |
| Testbench quality (across all labs) | 15% | Self-checking, coverage of edge cases |
| Final project | 25% | Functionality, design quality, testbench, presentation |
| Participation / engagement | 10% | Questions, helping peers, video prep |
