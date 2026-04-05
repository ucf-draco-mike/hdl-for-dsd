# Accelerated HDL for Digital System Design 

## Course Parameters
**Format:** 4 weeks · 4 sessions/week · 2.5 hours/session (16 sessions total)  
**Delivery:** Flipped — recorded lectures pre-class; class = mini-lecture (25–35 min) + hands-on lab (~2 hrs)  
**Platform:** Nandland Go Board (Lattice iCE40 HX1K · 4 LEDs · 4 buttons · dual 7-seg · VGA)  
**Toolchain:** Yosys + nextpnr-ice40 + icepack/iceprog (synthesis/PnR), Icarus Verilog + GTKWave (simulation)  
**Students:** ≤15, primarily CompE with some CS; no prior HDL; varying programming maturity  
**Assessment:** Continuous lab deliverables (Weeks 1–3), final project (Week 4)

---

## Weekly Arc
| Week | Theme | Culmination |
|------|-------|-------------|
| **1** | Verilog Foundations & Combinational Design | First designs on hardware |
| **2** | Sequential Design, Verification & AI-Assisted Testing | Verified module library + first AI-generated TB |
| **3** | Memory, Communication & Numerical Architectures | "HELLO" on the PC terminal + numerical module on FPGA |
| **4** | Advanced Design, Verification & Final Project | Complete demonstrated system with PPA report |

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
- Toolchain walkthrough — the open-source iCE40 flow: Verilog → Yosys → nextpnr → icepack → iceprog
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
4. **Stretch:** 4:1 mux using only 2:1 mux instances (structural composition)
**Deliverable:** Hex-to-7-seg decoder displaying button-selected values on hardware.

---

### Day 3 — Procedural Combinational Logic
**Pre-class (~45 min):**
- `always @(*)`: wildcard sensitivity, `reg` in combinational contexts
- `if/else` and `case`/`casez` statements
- Latch inference: why it happens, how to prevent it (default assignments, complete branches)
- Blocking (`=`) vs. nonblocking (`<=`) — rule for combinational: use `=`
**In-class mini-lecture (35 min):**
- Latch detection with Yosys `show` command (live demo, as before)
- `if/else` vs `case` — synthesis implications deep dive (10 min)
  - `if/else` → priority mux chain: each condition evaluated in order, later branches have longer paths
  - `case` → parallel mux: all branches evaluated simultaneously, tool selects by opcode
  - **Live Yosys comparison:** Synthesize priority encoder using `if/else`, then using `case`. Run `show` on both — inspect the generated circuits side by side.
  - `casez` for don't-care matching — when priority IS intended, `casez` is explicit about it
  - **Design heuristic:** Use `case` when all conditions are mutually exclusive (ALU opcodes, FSM states). Use `if/else` when priority matters (interrupt controllers, arbiters). Use `casez` for pattern matching with explicit don't-cares.
  - **Timing implication preview:** Priority chains have longer worst-case paths — matters for Fmax.
- ALU design: 4-bit ALU using `case` for opcode decode
**Lab (~2 hrs):**
1. Latch detection exercise: buggy code → Yosys warnings → fix
2. Priority encoder using `if/else` (as before)
3. Priority encoder using `casez` — compare Yosys schematics
4. Implement the same 4-input priority encoder three ways: (a) `if/else`, (b) `case` with explicit priorities, (c) `casez`. Compare `yosys stat` output (LUT count) and `show` schematics. **Record the LUT counts.** *(5 min, but plants the seed for PPA thinking)*
5. 4-bit ALU with `case` for opcode decode
6. **Stretch:** ALU with both `case` (opcode) and `if/else` (overflow detection) — mixed usage in one module
**Deliverable:** ALU on hardware + screenshot comparing `yosys show` output for `if/else` vs `case` priority encoders.

---

### Day 4 — Sequential Logic: Flip-Flops, Clocks & Counters
**Pre-class (~50 min):**
- Edge-triggered logic: `always @(posedge clk)`
- Nonblocking assignment: `<=` and why it matters for sequential logic
- D flip-flop from first principles; register as N flip-flops
- Reset strategies: synchronous vs. asynchronous, active-high vs. active-low
- RTL thinking: every `<=` is a flip-flop, every `=` in `always @(*)` is combinational
**In-class mini-lecture (30 min):**
- FF variations: with enable, with load, with clear
- Counter as the canonical sequential building block
- Clock divider concept: counting clock cycles to generate slower events
- Live demo: build a visible blinker from a 25 MHz clock
**Lab (~2 hrs):**
1. D flip-flop → verify in simulation (Icarus + GTKWave) first, then on board
2. 4-bit loadable register
3. Free-running counter (8-bit, 16-bit, 24-bit)
4. Clock divider: 25 MHz → ~1 Hz using a counter, blink an LED
5. Dual-speed blinker: two LEDs at different rates from independent dividers
6. **Stretch:** Up/down counter controlled by buttons, display count on 7-seg
**Deliverable:** LED blinker at visible rate (~1 Hz), counter value on 7-seg.

---

## Week 2: Sequential Design, Verification & AI-Assisted Testing
*Goal: Students master FSMs, write proper testbenches, learn to leverage AI for verification scaffolding, and build reusable parameterized modules. Simulation becomes a first-class part of the workflow.*

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

### Day 6 — Testbenches, Simulation & AI-Assisted Verification
**Pre-class (~50 min):**
- Testbench anatomy: no ports, instantiate DUT, apply stimulus
- `initial` blocks, `#` delay, `$finish`
- Waveform dumping: `$dumpfile`, `$dumpvars`
- Display/debug: `$display`, `$monitor`, `$write`, format specifiers
- Stimulus patterns: exhaustive, directed, corner-case
- Self-checking testbenches: `if` checks with `$display` pass/fail messages
- **AI for Verification — Philosophy & Ground Rules**
  - Why AI-assisted testbench generation is a professional skill (industry context)
  - The "you can't evaluate what you can't write" rule: manual first, AI second
  - Anatomy of a good AI prompt for TB generation (what to specify: DUT interface, protocol, corner cases, self-checking requirements)
  - What AI gets right (boilerplate, structure, stimulus patterns) vs. what it gets wrong (subtle timing, protocol edge cases, tool-specific syntax)
  - The critical skill: **reviewing and debugging AI-generated verification code**
**In-class mini-lecture (30 min):**
- Verification mindset: "if you haven't simulated it, it doesn't work"
- Workflow: simulate first, **then** synthesize to board — always
- Self-checking testbenches: automating correctness checks vs. staring at waveforms
- **Live demo: AI testbench generation (10 min)**
  - Take the Day 3 ALU module interface
  - Live-prompt an AI to generate a self-checking testbench
  - **Critically review the output together:** What did the AI get right? What did it miss? What's syntactically wrong for iverilog?
  - Fix the issues, run it, compare to a hand-written version
  - **Key lesson:** AI generates the 80% scaffolding; you provide the 20% domain expertise
**Lab (~2 hrs):**
1. **Write a testbench for the Day 3 ALU by hand** — directed stimulus for all opcodes *(this exercise is mandatory before using AI)*
2. Make it self-checking: expected vs. actual with automated pass/fail
3. **AI-Assisted Exercise:** Use AI to generate a testbench for the debouncer module. Student task:
   - Write a prompt specifying: module interface, expected behavior (noisy input → clean output after threshold), corner cases (rapid toggles, glitches shorter than threshold)
   - Generate the TB, review it, fix any issues, run it
   - **Deliverable for this exercise:** Submit both the prompt and the corrected testbench, with annotations explaining what was changed and why
4. Testbench for the counter: check rollover, reset behavior, enable
5. **Stretch:** Task-based testbench organization, file-based stimulus (`$readmemh`)
**Deliverable:** (1) Hand-written self-checking ALU testbench with pass/fail report. (2) AI-generated debouncer testbench with annotated corrections.
**Assessment note:** Grading distinguishes between "prompt quality" and "review quality." A student who writes a vague prompt and accepts broken output scores lower than one who writes a precise prompt and catches the AI's errors.

---

### Day 7 — Finite State Machines
**Pre-class (~50 min):**
- Moore vs. Mealy: outputs depend on state only vs. state + input
- State diagrams to HDL: a systematic translation process
- 3-always-block FSM coding style: state register, next-state logic, output logic
- State encoding: binary, one-hot, gray — trade-offs
- `localparam` or `parameter` for state names (readability)
**In-class mini-lecture (30 min):**
- FSM design methodology: (1) draw the diagram, (2) enumerate states/transitions, (3) code it, (4) simulate it
- Why three always blocks? Separation of concerns, easier debugging, cleaner synthesis
- Live design: vending machine or pattern detector, paper to code
**Lab (~2 hrs):**
1. Traffic light controller: 3 states (R/Y/G), timed transitions using counters
2. Write a thorough testbench — verify all state transitions, timing
3. Pushbutton pattern detector: detect a specific button press sequence
4. **Stretch:** Mealy version of the pattern detector, compare behavior
**Deliverable:** Traffic light FSM running on board with waveform-verified testbench.

---

### Day 8 — Hierarchy, Parameters, Generate & Design Reuse
**Pre-class (~45 min):**
- Module instantiation: positional vs. named port connections (always use named!)
- `parameter` and `localparam`: making modules reusable
- `#(.PARAM(value))` override syntax
- `generate` blocks: `for`-generate, `if`-generate — hardware replication and conditional instantiation
- **Recursive Generate Patterns**
  - `generate if` for conditional feature inclusion (e.g., optional parity, configurable pipeline depth)
  - Nested `generate for` for 2D structures (e.g., array of processing elements)
  - The "recursive module" pattern: a module that instantiates itself with different parameters (tree adder preview)
- Design for reuse: building a personal Verilog library
**In-class mini-lecture (30 min):**
- Hierarchy as the key to managing complexity — top-down vs. bottom-up
- Parameterization philosophy: what should be parameterized and what shouldn't
- `generate` block: thinking of it as a compile-time loop, not a runtime loop
- Live demo: parameterized N-bit counter, instantiated at multiple widths
- **PPA seed (5 min):** After synthesizing the parameterized counter at WIDTH=4, 8, 16, 32, run `yosys stat` for each. **Show the resource scaling.** "How does LUT count grow with width? Is it linear? What would this look like in an ASIC?" — plant the question, answer it fully on Day 10.
**Lab (~2 hrs):**
1. Parameterized N-bit counter module — instantiate as 8-bit, 16-bit, 24-bit
2. **AI-Assisted TB for parameterized modules:** Use AI to generate a testbench that tests the counter at multiple WIDTH configurations. Student evaluates: Does the AI correctly use `parameter` overrides? Does it test rollover at the right value for each width?
3. `generate`-based LED driver: N instances of a blink module at different rates
4. Clean hierarchical top module that ties everything together on the Go Board
5. **Resource comparison:** Run `yosys stat` on the hierarchical design. Record LUT, FF, and EBR counts. *(30-second exercise that builds PPA habits)*
6. **Stretch:** Parameterized LFSR with configurable polynomial via `generate`
**Deliverable:** Hierarchical design with 3+ levels + AI-generated parameterized TB with annotations + `yosys stat` resource snapshot.

---

## Week 3: Memory, Communication & Numerical Architectures
*Goal: Students design real communication interfaces (UART), work with on-chip memory, build numerical circuits with PPA awareness, and understand timing constraints. Designs become systems, not just modules.*

### Day 9 — Memory: RAM, ROM & Block RAM
**Pre-class (~45 min):**
- Modeling ROM in Verilog: `case`-based, array-based
- `$readmemh` / `$readmemb`: initializing memory from files
- RAM modeling: synchronous read/write patterns
- iCE40 Block RAM (EBR): 16 blocks × 4 Kbit = 64 Kbit total
- Inference patterns: how to write Verilog that Yosys maps to EBR
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

### Day 10 — Numerical Architectures & Design Trade-offs
**Pre-class (~55 min):**
- **Segment 1: Timing & Constraints Essentials (15 min)**
  - Setup time, hold time, critical path — the concepts
  - nextpnr timing analysis: what "timing met" means, reading the summary line
  - When timing fails: restructure logic, pipeline, relax clock
  - `.pcf` deep dive and PLL basics on iCE40 (conceptual — lab is optional stretch)
- **Segment 2: Numerical Architecture Trade-offs (20 min)**
  - Adder architectures: ripple-carry (Day 2 review) → carry-lookahead (concept + equations) → the `+` operator (what does the tool actually build?)
  - **Key insight:** Writing `assign sum = a + b;` lets the synthesis tool choose the architecture. Understanding what it chooses and why is the designer's job.
  - Multiplication: shift-and-add algorithm → why `*` on an FPGA uses DSP blocks or LUT chains → the iCE40 has NO DSP blocks, so `*` is pure LUT logic
  - Fixed-point representation: Q-format notation (e.g., Q4.4 = 4 integer bits, 4 fractional bits), why it matters for DSP and control
  - Signed vs. unsigned: `$signed()` cast, sign extension, and arithmetic gotchas
- **Segment 3: PPA — Performance, Power, Area (15 min)**
  - What is PPA? The three axes of digital design optimization
  - **FPGA PPA proxies:**
    - **Performance** → Fmax from nextpnr timing report
    - **Area** → LUT/FF/EBR count from `yosys stat`
    - **Power** → estimated from toggle rate × capacitance (conceptual; iCE40 power analysis is limited)
  - **ASIC PPA** (conceptual comparison):
    - Area = gate count × cell size; standard cell libraries
    - Power = dynamic (switching) + static (leakage); process node matters
    - Performance = critical path through placed-and-routed standard cells
  - **The trade-off triangle:** You can't optimize all three simultaneously. Pipelining improves Fmax but costs FFs. Parallelism improves throughput but costs area. Clock gating reduces power but adds complexity.
  - `if/else` vs `case` revisited from PPA perspective: priority chains may have longer critical paths (lower Fmax) but similar area; parallel muxes may use more LUTs but have shorter critical paths.
  - **Open-source ASIC PPA (aspirational):** The [OpenROAD](https://openroad.readthedocs.io/) project and its user-facing flow [OpenLane](https://openlane.readthedocs.io/) provide a fully open-source RTL-to-GDSII flow. You can synthesize Verilog to standard cells (e.g., SKY130 from SkyWater/Google), run place-and-route, and extract real ASIC PPA metrics — all without commercial licenses. We won't use it in this course (the learning curve is steep), but the PPA analysis habits you build with `yosys stat` transfer directly. This is the same flow used in the Google/Efabless shuttle program that fabricates real chips from open-source designs.
**In-class mini-lecture (30 min):**
- **Quick timing check (5 min):** Read a nextpnr timing report together — is timing met? What's the critical path?
- **Numerical architectures live demo (15 min):**
  - Synthesize `assign sum = a + b;` at 4-bit, 8-bit, 16-bit, 32-bit widths
  - Run `yosys stat` for each — **plot the LUT count vs. width** (should be roughly linear for ripple-carry)
  - Synthesize `assign product = a * b;` at 4-bit, 8-bit — **show the LUT explosion** (quadratic growth, no DSP blocks on iCE40)
  - Compare: `a + b` vs. `a + b + c` (3-input addition — does the tool chain adders or use something smarter?)
  - **Inspect with `yosys show`:** What does the synthesized adder actually look like? Can you see the carry chain?
- **PPA thinking (10 min):**
  - Design decision framework: "For this application, do I care more about Fmax, area, or power?"
  - FPGA vs. ASIC: on FPGA, LUTs are fixed-size so "area" is really "LUT utilization." On ASIC, a 2-input gate is physically smaller than a 4-input gate.
  - Real example: A 32-bit multiplier on iCE40 HX1K uses ~30% of available LUTs. On an ASIC at 28nm, it's a tiny fraction of the die.
  - **Brief aside:** "Everything we're doing with `yosys stat` has an ASIC equivalent. The OpenROAD/OpenLane open-source flow takes the same Verilog, synthesizes to real standard cells, and gives you gate count, wire delay, and power estimates. The PPA habits transfer directly."
**Lab (~2 hrs):**
1. **Adder architecture comparison (30 min):**
   - Implement a ripple-carry adder manually (from full-adder chain, reuse Day 2 code)
   - Implement using `assign sum = a + b;` (behavioral)
   - Compare: `yosys stat` (LUT count), `yosys show` (schematic), and nextpnr Fmax at 8-bit and 16-bit
   - **Record results in a comparison table** *(builds PPA analysis habits)*
2. **Shift-and-add multiplier (30 min):**
   - Implement a sequential (multi-cycle) 8-bit unsigned multiplier using shift-and-add
   - FSM + shift register + accumulator architecture
   - Compare resource usage to `assign product = a * b;` (combinational)
   - **Discussion:** When would you choose sequential over combinational multiplication? (latency vs. area trade-off)
3. **Fixed-point exercise (20 min):**
   - Implement a Q4.4 fixed-point adder and multiplier
   - Key challenge: the product of two Q4.4 numbers is Q8.8 — handling the bit growth
   - Display the integer part on 7-seg
4. Timing constraint exercise: add constraints to an existing design, analyze the report
5. **Stretch:** Instantiate `SB_PLL40_CORE` for a different frequency; CDC exercise with 2-FF synchronizer
**Deliverable:** Adder/multiplier PPA comparison table (LUTs, FFs, Fmax for each variant) + working shift-and-add multiplier on FPGA.

---

### Day 11 — UART TX: Your First Communication Interface
**Pre-class (~50 min):**
- UART protocol: start bit, 8 data bits, stop bit, baud rate
- Baud rate generation: deriving precise timing from a fast clock
- TX architecture: FSM + PISO shift register + baud generator
- Connecting to a PC: USB-to-serial, terminal emulator settings
**In-class mini-lecture (30 min):**
- UART as an FSM + datapath design exercise — everything from Weeks 1–2 comes together
- Baud rate math: 25 MHz / 115200 = 217 clocks per bit (with rounding considerations)
- Live build: UART TX from block diagram to code
- Terminal setup: connecting and configuring the serial monitor
**Lab (~2 hrs):**
1. Implement UART TX module from provided architecture diagram
2. Top module: button press → transmit a character → see it on PC terminal
3. Transmit "HELLO\r\n" on reset or button press
4. **Stretch:** Hex-to-ASCII converter, transmit counter value as readable text
**Deliverable:** "HELLO" appearing on the PC terminal from the Go Board.

---

### Day 12 — UART RX, SPI & AI-Assisted Protocol Verification
**Pre-class (~55 min):**
- **Segment 1: UART RX — The Oversampling Challenge (15 min)**
  - UART RX design: oversampling (16×), start-bit detection, bit centering
  - RX FSM: idle → detect start → sample bits at center → stop → valid
  - Finding the center of each bit
- **Segment 2: AI for Protocol Verification (8 min)**
  - Prompting for protocol-aware testbenches: specifying timing constraints, frame structure, error conditions
  - What AI needs to know: baud rate, clock frequency, protocol (8N1), expected sequences
  - What to watch for: AI may not handle baud-rate timing accurately, may miss center-sampling verification
  - **Note on tool comparison:** "Different AI tools have different strengths for HDL. Some handle Verilog syntax better; some reason about timing more carefully. If you have time, try generating the same TB prompt with two different tools and compare the outputs — this kind of comparative evaluation is itself a professional skill."
- **Segment 3: SPI Protocol (12 min)**
  - SPI vs. UART vs. I²C: when to use what, trade-offs
  - SPI signals: SCLK, MOSI, MISO, CS_N — master provides the clock
  - CPOL/CPHA modes — four configurations
  - SPI as connected shift registers: "Everything you built in Week 2"
- **Segment 4: Constraint-Based Design Thinking + IP Integration (10 min)**
  - Constraint-based design *concept*: `generate if` for optional features (parity, configurable stop bits)
  - "Same RTL, different hardware" — the power of parameterized protocol modules
  - Brief example: UART TX with `parameter PARITY_EN` — how `generate if` conditionally includes parity logic *(concept shown; lab implementation on Day 14)*
  - Working with third-party IP: trust but verify, write a wrapper, verify resource usage
  - IP integration checklist: read docs → wrapper → synchronizers → testbench → resource check
**In-class mini-lecture (30 min):**
- UART RX walkthrough (10 min): 16× oversampling implementation, center-sampling strategy
- SPI master overview (5 min): Block diagram — FSM + shift register + clock divider. Students implement in lab.
- **AI protocol TB demo (10 min):**
  - Live-prompt AI to generate a UART loopback testbench (TX drives RX, verify data integrity)
  - Review together: Does it handle baud timing? Does it check all 8 data bits? Does it verify start/stop framing?
  - Fix the issues, run it
  - Key lesson: protocol testbenches require domain expertise that AI approximates but doesn't guarantee
- IP integration quick note (5 min): For SPI — students choose: implement from scratch (recommended) or integrate open-source IP with a wrapper. Both are valid.
**Lab (~2 hrs):**
1. **UART RX implementation (35 min):**
   - Implement UART RX with 16× oversampling
   - Test in simulation: TX module drives RX, verify byte-level data integrity
2. **UART loopback on hardware (15 min):**
   - RX → TX loopback. Type on PC → see echo
   - 7-seg displays hex value of last received byte
3. **AI-generated protocol testbench (20 min):**
   - Use AI to generate a comprehensive UART loopback testbench
   - Prompt requirements: test at least 10 byte values including 0x00 and 0xFF, verify frame timing, include timeout detection for hung RX
   - Student reviews, corrects, runs the TB
   - **Submit:** Prompt, raw AI output, corrected version with brief annotations on what was changed
   - **Optional bonus:** Run the same prompt through a second AI tool. In 2–3 sentences, note which produced better Verilog and why.
4. **SPI master (25 min):**
   - **Option A (recommended): Implement from scratch** — Mode 0 SPI master, 8-bit, FSM + shift register. Simulate with a simple SPI slave model (provided or student-written loopback).
   - **Option B: Integrate open-source IP** — Find/use a simple SPI master, write a wrapper with our naming conventions, write a testbench.
   - Either option: verify one complete SPI transaction in simulation.
5. **Stretch:** UART-to-SPI bridge — receive a command byte via UART, forward it via SPI, return the SPI response via UART.
**Deliverable:** (1) UART loopback working on hardware. (2) AI-generated protocol TB with annotated corrections. (3) SPI master simulated with testbench.
**Instructor note on AI tool comparison:** If time permits during debrief, ask 2–3 students to share their tool comparison findings. Five minutes of peer discussion here is high-value.

---

## Week 4: Advanced Design, Verification & Final Project
*Goal: Introduce SystemVerilog for cleaner design and modern verification. Apply PPA analysis. Students complete a capstone project demonstrating design, verification, and analysis competence.*

### Day 13 — SystemVerilog for Design
**Pre-class (~45 min):**
- Why SystemVerilog? Evolution from Verilog-2001, IEEE 1800 standard
- `logic` replaces both `wire` and `reg` — one type to rule them all
- `always_ff`, `always_comb`, `always_latch` — intent-based always blocks
- `enum`: named states for FSMs — no more `localparam` state definitions
- `struct` and `typedef`: grouping related signals
- `package` and `import`: sharing definitions across modules
**In-class mini-lecture (30 min):**
- Side-by-side comparison: Verilog vs. SystemVerilog for the same module
- The safety net: `always_comb` catches missing assignments, `always_ff` enforces edge-triggered
- `enum` FSMs: automatic next-state validation, `.name()` for debug printing
- **PPA with SV (5 min):** Synthesize Verilog and SV versions of the same module — compare `yosys stat`. (Spoiler: identical. SV is about designer productivity and safety, not hardware.)
- Tool note: Icarus Verilog has partial SV support; Verilator is a good complement
**Lab (~2 hrs):**
1. Refactor the traffic light FSM into SystemVerilog: `logic`, `always_ff`, `always_comb`, `enum` states
2. Refactor the UART TX: use `struct` for configuration, `enum` for states
3. Simulate both versions (Icarus with `-g2012` flag), compare waveforms
4. **PPA comparison:** `yosys stat` on Verilog vs. SV versions. Document that they produce identical hardware.
5. **Stretch:** Create a `package` with shared type definitions, import into multiple modules
**Deliverable:** SystemVerilog-refactored module(s) with PPA comparison notes.

---

### Day 14 — Verification Techniques, AI-Driven Testing & PPA Analysis
**Pre-class (~55 min):**
- **Segment 1: Assertions — Executable Specifications (12 min)**
  - Immediate assertions: `assert`, `$error`, `$fatal` — inline design checks
  - Concurrent assertions (brief): `assert property`, sequence syntax, `|->` and `|=>`
  - Assertions as executable documentation — catching bugs at the source
- **Segment 2: AI-Driven Verification Workflows (15 min)**
  - The verification productivity stack: manual -> self-checking -> AI-scaffolded -> assertion-enhanced -> coverage-driven
  - Prompt engineering for complex testbenches: specifying constraints, corner cases, coverage goals
  - **Constraint-based stimulus generation** (not UVM, but the concept):
    - Defining legal input ranges and relationships
    - Using `$urandom_range()` for bounded random stimulus
    - Writing a constraint specification in comments, then having AI generate the stimulus loop
    - Example: "Generate random UART frames where baud rate is in {9600, 115200}, data in [0x00, 0xFF], inter-frame gap in [1, 100] bit periods"
  - Reviewing AI-generated TBs for coverage completeness: "Did the AI test the boundaries?"
  - **Industry context:** "AI-assisted verification is increasingly common for testbench scaffolding, regression debugging, and coverage analysis. The prompt/generate/review/correct workflow you have practiced in this course is the same loop verification engineers use on production chip projects. The difference is scale; the evaluation skill is identical."
- **Segment 3: PPA Analysis Methodology (12 min)**
  - Structured PPA reporting: what to measure, how to present it
  - **FPGA PPA report template:**
    - Resource table: LUTs, FFs, EBR, PLL from `yosys stat`
    - Timing: Fmax from nextpnr, critical path identification
    - Utilization: % of iCE40 HX1K used
  - **ASIC context discussion:**
    - How ASIC PPA differs: gate count, wire delay dominance, process node impact
    - Why an 8-bit multiplier that takes 64 LUTs on FPGA might take only a few hundred gates on ASIC
    - Liberty files, standard cell libraries — conceptual awareness
    - Reminder: OpenROAD/OpenLane provides open-source ASIC PPA analysis for the same Verilog
  - **Design-space exploration:** Synthesizing the same module at different parameters (WIDTH=4,8,16,32) and plotting area/timing curves
- **Segment 4: Coverage **Segment 4: Coverage & the Road Ahead (11 min)** ** the Road Ahead (11 min)**
  - Functional coverage concepts: `covergroup`, `coverpoint`, `bins`
  - Coverage-driven verification: how do you know when you are *done* testing?
  - Interfaces and `modport` (brief)
  - Industry context: UVM, formal verification, the department's V&V course
  - Verification maturity scale: where students are now (Level 2-3)
**In-class mini-lecture (30 min):**
- **Assertions quick-start (10 min):** Add immediate assertions to UART TX (live demo)
- **AI constraint-based TB demo (10 min):**
  - Prompt AI to generate a constrained-random testbench for the ALU:
    - "Test all 4 opcodes with random operands in [0, 2^WIDTH-1]. For ADD/SUB, ensure at least 10 cases each of: no overflow, overflow, zero result, max result. Include a self-checking scoreboard. Use `$urandom_range()`."
  - Review the output: Does it actually cover the corner cases? Does it count coverage?
  - Fix and run
- **PPA analysis walkthrough (10 min):**
  - Take the shift-and-add multiplier from Day 10 and the behavioral `*` version
  - Run `yosys stat` and nextpnr on both
  - Build a PPA comparison table on the board together
  - "This is what your final project PPA report should look like"
**Lab (~2 hrs):**
1. **Assertion-enhanced UART TX (25 min):**
   - Add 5+ immediate assertions (idle=high, busy consistency, bit index bounds, start/stop values)
   - Intentionally inject bugs, verify assertions catch them
2. **Constraint-based UART parity extension (20 min):** *(moved from Day 12)*
   - Add configurable parity to UART TX using `generate if`:
   - `parameter PARITY_EN = 0` (0 = no parity, 1 = enabled); `parameter PARITY_TYPE = 0` (0 = even, 1 = odd)
   - When `PARITY_EN=1`, TX sends: start + 8 data + parity + stop (11 bits)
   - Use `generate if (PARITY_EN) begin : gen_parity ... end` for conditional parity logic
   - Synthesize both configurations. Compare `yosys stat`: how many extra LUTs does parity cost?
   - **This exercise bridges constraint-based design (Day 12 concept) with PPA analysis (today's theme).**
   - *Instructor escape valve:* Students behind on their project can skip this exercise and use the time for Exercise 3/4. Parity can be completed at home.
3. **AI constraint-based testbench for final project module (25 min):**
   - Each student writes a constraint specification for their final project's core module
   - Use AI to generate the testbench from the spec
   - Review, correct, run, document coverage gaps
   - **Deliverable:** Constraint spec + AI output + corrected TB + coverage analysis
4. **PPA analysis exercise (25 min):**
   - Pick 2-3 modules from the course library (e.g., ALU, counter, UART TX, parity-enabled UART TX)
   - For each, synthesize at 2+ parameter configurations
   - Record: LUTs, FFs, Fmax
   - Write a brief PPA comparison (1 paragraph per module)
   - **Deliverable:** PPA analysis table + 1-page design trade-off discussion
5. **Project work time (15 min):** Apply assertions + AI TBs to final project modules *(Day 15 provides 2.25 hrs of dedicated project time)*
6. **Stretch:** Interface-based testbench refactoring (SV `interface` + `modport`)
**Deliverable:** (1) Assertion-enhanced UART. (2) Parity-parameterized UART with PPA comparison. (3) AI constraint-based TB for project module with annotations. (4) PPA analysis report (table + discussion).

---

### Day 15 — Final Project: Build Day
**Mini-lecture (15 min):**
- Project check-in: quick stand-up, each student states progress and blockers
- Debugging strategies: divide and conquer, simulation first, use assertions, check pin assignments
- Integration tips: test each module independently before combining
- **Reminder:** Final project deliverables now include a brief PPA analysis (LUTs, FFs, Fmax, % utilization) and at least one AI-generated testbench for a core module
**Lab (~2.25 hrs):**
- Dedicated project work time
- Mike circulates for 1-on-1 debugging and design review
- Peer collaboration encouraged
**Deliverable:** Working prototype or demonstrable progress. Testbench (manual or AI-assisted) for at least one key module. PPA snapshot (`yosys stat` output + Fmax).

---

### Day 16 — Final Project Demos & Course Wrap
**Demos (~1.5 hrs):**
- Each student presents their project (5–7 min each)
- Format: 1 min context, live hardware demo, show key testbench/waveforms, lessons learned
- **Demo elements:**
  - Show `yosys stat` resource utilization — "My design uses X% of the iCE40 HX1K"
  - Briefly discuss one design trade-off made (e.g., "I chose a sequential multiplier over combinational to save LUTs")
  - Show one AI-assisted testbench and explain what was corrected
- Class Q&A after each demo
**Mini-lecture / Discussion (30 min):**
- Where to go from here:
  - ASIC vs. FPGA career paths — with PPA context from the course
  - Advanced SystemVerilog and UVM — how today's constraint-based testing maps to UVM concepts
  - **AI in professional verification workflows** — how industry uses AI for TB generation, regression analysis, coverage closure
  - Formal verification
  - The open-source FPGA ecosystem (SymbiFlow, Amaranth, LiteX)
  - The department's V&V course — how this course feeds into it
- Course retrospective: what worked, what to improve
**Wrap (15 min):**
- Feedback collection

---

## Cross-Cutting Threads: Summary

### Thread 1: AI-Assisted Testbench Generation (Progressive)
| Day | AI Integration | Student Skill |
|-----|---------------|---------------|
| 6 | Philosophy + first live demo; manual TB required first | Understand what AI generates; write prompts |
| 8 | AI-generated TB for parameterized modules | Evaluate AI's parameter handling |
| 12 | AI-generated protocol-level TB (UART loopback) + optional tool comparison | Prompt for protocol-aware verification; catch timing errors; evaluate AI tools |
| 14 | AI constraint-based testbench for own project module | Write constraint specs; review coverage completeness |
| 15–16 | AI TB as final project deliverable | Independent AI-assisted verification |
**Progression:** Observe → Prompt + Review → Prompt + Correct + Analyze → Independent Application

### Thread 2: PPA Analysis (Progressive)
| Day | PPA Activity | Student Skill |
|-----|-------------|---------------|
| 3 | Compare `if/else` vs `case` LUT counts | First `yosys stat` exposure |
| 8 | Resource scaling with parameterized width | Relate parameters to area |
| 10 | Adder/multiplier PPA comparison table | Structured PPA analysis |
| 12 | Parity-enabled vs. disabled UART resource comparison | Feature cost analysis |
| 13 | Verilog vs. SV PPA comparison | Confirm SV has zero hardware cost |
| 14 | Multi-module PPA analysis exercise + ASIC context | Design-space exploration; FPGA↔ASIC mapping |
| 15–16 | Final project PPA report | Independent PPA reporting |

### Thread 3: `if/else` vs `case` & Constraint-Based Design
| Day | Activity |
|-----|---------|
| 3 | `if/else` → priority chain, `case` → parallel mux; Yosys schematic comparison |
| 7 | FSM `case` statements; state encoding trade-offs (binary vs one-hot) |
| 8 | `generate if` for conditional hardware; `generate for` for replication |
| 10 | Numerical architectures: when `case` makes sense (ALU opcodes) vs `if/else` (overflow detection) |
| 12 | Constraint-based UART: `generate if` for optional parity, parameterized protocol variants |
| 14 | Design-space exploration: synthesizing across parameter configurations |

---

## Assessment Weights
| Component | Weight | Notes |
|---|---|---|
| Daily lab deliverables (12 sessions) | 40% | Completion + demonstrated understanding |
| Testbench quality (manual + AI-assisted) | 15% | Self-checking, coverage, AI prompt quality, review annotations |
| **AI verification portfolio** | 5% | Quality of prompts, corrections, and constraint specs across the course |
| **PPA analysis** | 5% | Resource tables, design trade-off reasoning |
| Final project | 25% | Functionality, design quality, testbench (incl. AI-assisted), PPA report, presentation |
| Participation / engagement | 10% | Questions, helping peers, video prep |

---

## Final Project Requirements
All projects require the following:
**Required for all projects:**
1. At least one manually-written self-checking testbench for a core module
2. At least one AI-generated testbench with annotated corrections
3. A brief PPA report: `yosys stat` output, Fmax, % iCE40 utilization, one paragraph on a design trade-off
4. Live hardware demo
**Additional project option:**
| Project | Key Concepts Exercised | Difficulty |
|---|---|---|
| **Numerical Compute Engine** | Parameterized ALU + sequential multiplier + fixed-point operations + FSM sequencer. Accepts operands via buttons/UART, displays results on 7-seg, reports via UART. Emphasis on PPA optimization. | ★★★ |

---

## Pre-Class Video Guide
| Session | Duration | Topic |
|---|---|---|
| Day 1 | 40 min | HDL mindset, synthesis vs. sim, module anatomy |
| Day 2 | 45 min | Data types, vectors, operators, assign |
| Day 3 | 45 min | `always @(*)`, if/case, latch inference |
| Day 4 | 50 min | Clocks, posedge, nonblocking, resets, RTL thinking |
| Day 5 | 45 min | Counters, shift registers, bounce/metastability |
| Day 6 | **55 min** | Testbench anatomy, self-checking, **AI for verification intro** |
| Day 7 | 50 min | FSM theory, Moore/Mealy, 3-block style |
| Day 8 | **50 min** | Hierarchy, parameters, generate, **recursive generate** |
| Day 9 | 45 min | ROM/RAM modeling, readmemh, EBR inference |
| Day 10 | **55 min** | **Timing essentials, numerical architectures, PPA intro** |
| Day 11 | 50 min | UART protocol, baud rate, TX architecture |
| Day 12 | **55 min** | UART RX, **AI protocol TBs, SPI protocol, constraint-based design concepts** |
| Day 13 | 45 min | SV: logic, always_ff/comb, enum, struct, package |
| Day 14 | **55 min** | **Assertions, AI constraint-based TBs, PPA methodology, coverage** |
**Total recording time: ~685 min (~11.4 hours)**

---

## Toolchain Reference
```bash
# PPA analysis
yosys -p "read_verilog module.v; synth_ice40 -top module; stat"
# Schematic comparison
yosys -p "read_verilog module.v; synth_ice40 -top module; show"
# Timing analysis
nextpnr-ice40 ... --report timing_report.json
# AI testbench generation
# Students use Claude, ChatGPT, or Copilot — no tool installation
# Prompts and outputs are submitted as part of lab deliverables
```

---
