# Video Lecture Production Scaffold

## Accelerated HDL for Digital System Design — Pre-Class Videos

**Production scope:** 14 pre-class video lectures (Days 1–14)
**Target format:** reveal.js slides + narration script + live-coding segments
**Recording style:** Mix of slides and live coding (OBS or similar)
**Total target duration:** ~685 minutes (~11.4 hours of recording)

---

## Key Finding: We're Closer Than You Think

After analyzing all 14 daily plan files, here's the critical insight: **the daily plans already contain ~80% of the narration content**. Each day's "Pre-Class Material" section reads like a detailed lecture script — complete with code examples, analogies, and explanations written in an instructor voice.

What we actually need to produce for each lecture:

| Deliverable | Status | Work Remaining |
|---|---|---|
| Narration content | ~80% done | Polish, add transitions, timing marks, live-coding cues |
| Slide decks | 0% | Transform content into reveal.js slides |
| Standalone code files | ~60% (embedded in markdown) | Extract, add comments, make buildable |
| Timing/block diagrams | ~20% (ASCII art exists) | Convert to WaveDrom/Mermaid/SVG |
| Pre-class quiz | ~90% done | Already at bottom of each day file |

**Bottom line:** This is a *transformation* task, not a *creation* task. The intellectual content exists. We're packaging it for video delivery.

---

## Production Architecture

### Per-Lecture Deliverable Set

```
lectures/weekN/dayNN_topic/
├── slides.html              # reveal.js deck (what's on screen)
├── script.md                # Narration script with timing marks and cues
├── code/
│   ├── example_01.v         # Progressive examples shown during video
│   ├── example_02.v
│   └── ...
├── diagrams/
│   ├── block_diagram.mermaid
│   ├── timing.wavedrom.json
│   └── *.svg                # Any custom diagrams
└── quiz.md                  # Pre-class comprehension check (3-5 questions)
```

### reveal.js Slide Design Principles

Since you're doing **slides + live coding**, the slides need to support clean transitions to terminal/editor:

1. **Code slides use syntax-highlighted `<pre><code>`** — not screenshots
2. **Progressive builds** via reveal.js fragments — code appears line-by-line
3. **"Switch to editor" cue slides** — a simple slide that says "▶ Live Demo: [description]" so viewers know you're transitioning
4. **Minimal text per slide** — the narration carries the explanation, slides show visuals + code
5. **Consistent visual language:**
   - Dark theme (code-friendly, reduces eye strain for video)
   - Left-aligned code, centered diagrams
   - Color coding: green = synthesizable, orange = simulation-only, red = common mistake

### Script Format

```markdown
## Slide 3: The River Analogy [01:45–02:30]

**[SLIDE: Side-by-side — recipe steps vs. river diagram]**

> Software is like following a recipe: do step 1, then step 2, then step 3.
> Hardware is like a river system. Water flows through ALL tributaries simultaneously.
> Adding a dam here affects the flow there. Everything is happening at once.
> You're not writing instructions — you're describing the geography of the river.

**[PAUSE — let this sink in]**

> This analogy will carry us through the entire first week. When you're confused
> about why Verilog behaves a certain way, come back to the river.

---
```

Key script conventions:
- **Timestamp ranges** in square brackets
- **Stage directions** in bold brackets: `[SLIDE: ...]`, `[SWITCH TO EDITOR]`, `[PAUSE]`, `[DRAW ON SCREEN]`
- **Narration** in blockquotes (what you actually say)
- **Notes** in italics (reminders to yourself, not spoken)

---

## The 14 Lectures: Segment-Level Scaffold

### Lecture 01: Welcome to Hardware Thinking (~40 min)

**Theme:** Unlearn software thinking. Everything is concurrent.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | HDL ≠ Software | 12 | 90% slides, 10% code | Side-by-side C vs. Verilog; river analogy diagram |
| 2 | Synthesis vs. Simulation | 10 | 80% slides, 20% code | Two-path flowchart: same source → synthesis path / sim path |
| 3 | Anatomy of a Verilog Module | 12 | 40% slides, 60% live code | Module template with labeled parts; first `assign` |
| 4 | Digital Logic Refresher | 8 | 70% slides, 30% code | Gate symbols → Verilog equivalents table |

**Live coding moments:**
- Seg 3: Build a module from scratch — `module`, ports, `assign`, `endmodule`
- Seg 4: Gate-level Verilog → `assign` equivalents

**Diagrams needed:**
- [MERMAID] Two-path flow: Verilog source → Yosys → nextpnr → FPGA / Verilog source → iverilog → GTKWave
- [SVG] River analogy (software recipe vs. hardware river)
- [SVG] Module anatomy diagram with labeled ports

**Pre-class quiz:**
- Q1: Three differences between HDL and software
- Q2: Which tool (synthesis or simulation) processes `$display`?
- Q3: Write a 2-input AND module from memory

---

### Lecture 02: Combinational Building Blocks (~45 min)

**Theme:** Data types, operators, and your first real building blocks (mux, adder, 7-seg decoder).

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Data Types & Vectors | 12 | 60% slides, 40% code | `wire` vs. `reg` comparison table; vector diagram |
| 2 | Operators | 10 | 40% slides, 60% live code | Operator precedence table; bitwise vs. logical |
| 3 | Multiplexers & Conditional Assignment | 12 | 30% slides, 70% live code | 2:1 → 4:1 mux progressive build |
| 4 | Your First Building Blocks | 11 | 20% slides, 80% live code | Full-adder, ripple-carry, 7-seg decoder |

**Live coding moments:**
- Seg 2: Concatenation, replication, bit slicing demos
- Seg 3: Build 2:1 mux → nest into 4:1 → show alternative `?:` chains
- Seg 4: Full-adder → chain into ripple-carry → hex-to-7-seg decoder

**Diagrams needed:**
- [SVG] Vector bit numbering diagram (MSB:LSB)
- [SVG] 2:1 mux schematic → 4:1 mux from 2:1 components
- [SVG] 7-segment display segment labeling (a–g)

---

### Lecture 03: Procedural Combinational Logic (~45 min)

**Theme:** `always` blocks for combinational logic — power and pitfalls.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | `always @(*)` and `if/else` | 12 | 50% slides, 50% code | Latch inference warning; priority mux chain diagram |
| 2 | `case` / `casez` | 10 | 40% slides, 60% live code | Parallel mux structure; `casez` with don't-care bits |
| 3 | `if/else` vs `case` — Synthesis Deep Dive | 10 | 30% slides, 70% live code | Side-by-side Yosys `show` output: priority chain vs. parallel mux |
| 4 | ALU Design | 13 | 20% slides, 80% live code | 4-bit ALU architecture; opcode decode |

**Live coding moments:**
- Seg 1: Write a combinational block with missing `else`, show Yosys latch warning, fix it
- Seg 2: Priority encoder in `if/else` vs. `casez` — compare behavior
- Seg 3: **Key demo** — synthesize the same priority encoder with `if/else` and `case`, run `yosys show` on both, compare the circuits. Run `yosys stat` on both — record LUT counts. First PPA exposure.
- Seg 4: Build 4-bit ALU with `case` for opcode decode

**Diagrams needed:**
- [SVG] Priority mux chain (`if/else`) vs. parallel mux (`case`) — architecture comparison
- [SVG] Latch inference diagram: missing `else` → transparent latch
- [SVG] ALU block diagram with opcode decoder

---

### Lecture 04: Sequential Logic — Flip-Flops, Clocks & Counters (~50 min)

**Theme:** The `posedge` revolution — everything changes when there's a clock.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Clocks and Edge-Triggered Behavior | 12 | 60% slides, 40% code | Clock waveform with posedge arrows; RTL diagram |
| 2 | Nonblocking Assignment — Why It Matters | 15 | 40% slides, 60% live code | Two-register pipeline: blocking (broken) vs. nonblocking (correct) |
| 3 | Flip-Flops With Reset and Enable | 10 | 30% slides, 70% live code | D-FF variants side-by-side |
| 4 | Counters and Clock Division | 13 | 20% slides, 80% live code | Clock divider math; Go Board 25 MHz → 1 Hz |

**Live coding moments:**
- Seg 2: **The key demo** — simulate 2-stage shift register with `=` (broken), then `<=` (correct), show waveforms
- Seg 3: Build D-FF variants live: basic → sync reset → async reset → enable
- Seg 4: Calculate divider value, build counter, simulate, predict LED blink rate

**Diagrams needed:**
- [WAVEDROM] Clock signal with posedge labels
- [WAVEDROM] Blocking vs. nonblocking shift register comparison (the "smoking gun" timing diagram)
- [WAVEDROM] Counter counting up with rollover
- [SVG] RTL diagram: registers + combinational clouds + clock

---

### Lecture 05: Counters, Shift Registers & Debouncing (~45 min)

**Theme:** Practical sequential building blocks and the real-world problem of noisy inputs.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Counter Variations | 10 | 40% slides, 60% code | Counter type comparison table |
| 2 | Shift Registers | 12 | 40% slides, 60% live code | SISO/SIPO/PISO/PIPO animations (fragment builds) |
| 3 | Metastability and Synchronizers | 12 | 70% slides, 30% code | Metastability probability diagram; 2-FF synchronizer |
| 4 | Button Debouncing | 11 | 30% slides, 70% live code | Oscilloscope trace of button bounce; debouncer block diagram |

**Live coding moments:**
- Seg 1: Modulo-N counter with parameterized rollover
- Seg 2: Build SIPO shift register, simulate serial input
- Seg 4: Build counter-based debouncer, simulate noisy input, show clean output

**Diagrams needed:**
- [WAVEDROM] Shift register shifting data in over clock cycles
- [SVG] 2-FF synchronizer schematic with metastability zone
- [WAVEDROM] Button bounce waveform → debounced output (with counter threshold annotation)
- [WAVEDROM] Metastability: setup/hold violation → indeterminate output

---

### Lecture 06: Testbenches, Simulation & AI-Assisted Verification (~55 min)

**Theme:** Verification isn't optional. Simulate first, always. Then learn to leverage AI as a verification tool.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Testbench Anatomy | 12 | 50% slides, 50% code | TB structure diagram: no ports, DUT instantiation, stimulus, checks |
| 2 | Self-Checking Testbenches | 12 | 30% slides, 70% live code | Pass/fail reporting pattern; expected vs. actual |
| 3 | Waveforms and Debug | 10 | 40% slides, 60% live code | GTKWave walkthrough; `$dumpfile`/`$dumpvars` |
| 4 | AI for Verification — Philosophy & Ground Rules | 8 | 70% slides, 30% code | Verification workflow pyramid; prompt anatomy diagram |
| 5 | Stimulus Patterns | 13 | 30% slides, 70% live code | Exhaustive, directed, corner-case strategies |

**Live coding moments:**
- Seg 1: Build a testbench from scratch — instantiate DUT, apply stimulus, observe
- Seg 2: Add `if/else` checks to make it self-checking — no more staring at waveforms
- Seg 3: Add `$dumpfile`, run, open GTKWave, navigate waveforms
- Seg 4: Show anatomy of a good AI prompt — what to specify (interface, protocol, corner cases, self-checking)
- Seg 5: Exhaustive test for small designs, directed tests for larger

**Diagrams needed:**
- [MERMAID] TB structure: testbench module → DUT instantiation → stimulus block → check block → waveform dump
- [SVG] Self-checking pattern: stimulus → DUT → actual → comparison → expected
- [SVG] Verification workflow pyramid: manual directed → self-checking → AI-scaffolded → assertion-enhanced → coverage-driven

**Key message for Seg 4:**
- "You can't evaluate what you can't write" — manual TB skills come first
- AI generates the 80% scaffolding; you provide the 20% domain expertise
- The critical professional skill: reviewing and debugging AI-generated verification code

---

### Lecture 07: Finite State Machines (~50 min)

**Theme:** The most important design pattern in digital systems.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Moore vs. Mealy | 12 | 70% slides, 30% code | Side-by-side state diagrams |
| 2 | State Diagrams to HDL | 15 | 40% slides, 60% live code | Systematic translation: diagram → code |
| 3 | 3-Always-Block Style | 13 | 30% slides, 70% live code | Three blocks with clear responsibilities |
| 4 | State Encoding Trade-offs | 10 | 60% slides, 40% code | Binary vs. one-hot resource comparison |

**Live coding moments:**
- Seg 2: Draw a traffic light FSM, then translate to code step-by-step
- Seg 3: **Key demo** — build the 3-always-block pattern: state register, next-state combo, output combo
- Seg 4: Synthesize the same FSM with binary and one-hot encoding, compare `yosys stat`

**Diagrams needed:**
- [MERMAID] Moore FSM state diagram: traffic light with timed transitions
- [MERMAID] Mealy FSM: outputs on transition arrows
- [SVG] 3-always-block architecture diagram: three boxes with data flow arrows

---

### Lecture 08: Hierarchy, Parameters, Generate & Design Reuse (~50 min)

**Theme:** Scaling designs — how to build systems from reusable parts.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Module Hierarchy & Instantiation | 12 | 50% slides, 50% code | Hierarchy tree; named vs. positional ports |
| 2 | Parameters & Localparam | 12 | 30% slides, 70% live code | Parameterized counter at multiple widths |
| 3 | Generate Blocks | 13 | 30% slides, 70% live code | `for`-generate, `if`-generate; replication patterns |
| 4 | Recursive Generate Patterns | 8 | 40% slides, 60% code | Tree adder; conditional feature inclusion |
| 5 | PPA Seed: Resource Scaling | 5 | 20% slides, 80% live code | `yosys stat` at WIDTH=4,8,16,32 — LUT scaling plot |

**Live coding moments:**
- Seg 1: Instantiate modules using named ports — show the common mistakes
- Seg 2: Build a parameterized N-bit counter, instantiate at 4 widths
- Seg 3: `generate for` to create N instances; `generate if` for conditional hardware
- Seg 4: Show `generate if` for optional parity, nested `generate for` for 2D structures, "recursive module" pattern (preview)
- Seg 5: Synthesize parameterized counter at 4 widths, run `yosys stat`, show LUT scaling

**Diagrams needed:**
- [MERMAID] Hierarchy tree: top → sub1, sub2 → leaf modules
- [SVG] Generate-for producing N instances (array diagram)
- [SVG] Generate-if: two hardware variants selected by parameter

**Key message for Seg 5:**
"How does LUT count grow with width? Is it linear? This is PPA thinking — we'll go deep on Day 10."

---

### Lecture 09: Memory — RAM, ROM & Block RAM (~45 min)

**Theme:** On-chip memory and the art of making Yosys infer what you want.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Modeling ROM in Verilog | 10 | 40% slides, 60% code | `case`-based vs. array-based ROM; `$readmemh` file format |
| 2 | `$readmemh` / `$readmemb` | 10 | 30% slides, 70% live code | Loading hex files; file path gotchas |
| 3 | RAM Modeling | 12 | 30% slides, 70% live code | Synchronous read/write patterns; registered output |
| 4 | iCE40 Block RAM & Inference | 13 | 50% slides, 50% code | EBR architecture; inference patterns; `SB_RAM40_4K` in `yosys stat` |

**Live coding moments:**
- Seg 1: Build a ROM, load from file, simulate readout
- Seg 2: Show the `.hex` file format, common mistakes (0x prefix, commas)
- Seg 3: Build synchronous RAM with registered read — show combinational read vs. registered read
- Seg 4: Synthesize both versions, show `yosys stat` — only registered read produces `SB_RAM40_4K`

**Diagrams needed:**
- [SVG] FPGA memory landscape: LUT RAM vs. Block RAM vs. External
- [SVG] iCE40 EBR block diagram (16 blocks × 256×16)
- [SVG] Combinational read (→ LUT RAM) vs. registered read (→ Block RAM) comparison

---

### Lecture 10: Numerical Architectures & Design Trade-offs (~55 min)

**Theme:** The heart of digital design — how to build arithmetic circuits and measure their cost.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Timing & Constraints Essentials | 15 | 80% slides, 20% code | Setup/hold diagram; nextpnr timing report; critical path |
| 2 | Numerical Architecture Trade-offs | 20 | 40% slides, 60% live code | Adder architectures; multiplier LUT explosion; fixed-point Q-format |
| 3 | PPA — Performance, Power, Area | 15 | 60% slides, 40% code | Trade-off triangle; FPGA vs. ASIC PPA; OpenROAD/OpenLane context |
| 4 | Open-Source ASIC PPA (Aspirational) | 5 | 90% slides, 10% code | OpenROAD flow diagram; SKY130 context |

**Live coding moments:**
- Seg 1: Read a nextpnr timing report together; intentionally create timing violation; fix it
- Seg 2: Synthesize `assign sum = a + b;` at 4/8/16/32-bit widths, plot LUT count (linear). Synthesize `assign product = a * b;` at 4/8-bit — show LUT explosion (quadratic, no DSP on iCE40). Inspect with `yosys show`.
- Seg 2: Fixed-point: Q4.4 representation, multiply two Q4.4 numbers → Q8.8 product, extract the right bits
- Seg 3: Compare `if/else` vs `case` from PPA perspective (revisit Day 3). Discuss the trade-off triangle.

**Diagrams needed:**
- [WAVEDROM] Setup time, hold time, and clock-to-q annotated on timing diagram
- [SVG] Critical path through combinational logic between registers
- [SVG] Trade-off triangle: Performance ↔ Power ↔ Area
- [SVG] Adder architecture comparison: ripple-carry chain vs. carry-lookahead tree
- [SVG] Q4.4 fixed-point bit layout (integer.fraction)
- [SVG] PPA: FPGA proxies (LUTs, Fmax, toggle rate) mapped to ASIC equivalents (gates, delay, power)

**Key message for Seg 3:**
"You can't optimize all three simultaneously. The PPA habits you build with `yosys stat` transfer directly to ASIC flows like OpenROAD/OpenLane."

---

### Lecture 11: UART Transmitter (~50 min)

**Theme:** Your first communication interface — FSM + datapath as a design methodology.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | The UART Protocol | 14 | 70% slides, 30% code | UART frame diagram (idle, start, D0–D7, stop); baud rate math |
| 2 | Baud Rate Generation | 10 | 50% slides, 50% code | Clock divider for 115200 baud @ 25 MHz |
| 3 | TX Architecture & Implementation | 16 | 10% slides, 90% live code | Block diagram: FSM + shift register + baud generator |
| 4 | Connecting to a PC | 10 | 60% slides, 40% live code | USB-serial setup; terminal emulator demo |

**Live coding moments:**
- Seg 1: Calculate baud divider for 115200 baud @ 25 MHz (25M / 115200 ≈ 217)
- Seg 3: **Full build** — baud generator → FSM → shift register → integrate → simulate
- Seg 4: Show terminal emulator receiving data (screen recording segment)

**Diagrams needed:**
- [WAVEDROM] Complete UART frame: idle → start bit → 8 data bits (LSB first) → stop bit
- [MERMAID] UART TX FSM state diagram (IDLE → START → DATA → STOP)
- [SVG] UART TX block diagram: baud tick generator + FSM + PISO shift register

---

### Lecture 12: UART RX, SPI & AI-Assisted Protocol Verification (~55 min)

**Theme:** Completing the communication loop, a second protocol, and AI for protocol-level testbenches.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | UART RX — The Oversampling Challenge | 15 | 50% slides, 50% code | 16× oversampling diagram; center-bit sampling |
| 2 | AI for Protocol Verification | 8 | 70% slides, 30% code | Prompt anatomy for timing-aware TB; AI error patterns |
| 3 | SPI Protocol | 12 | 60% slides, 40% code | SPI signals; CPOL/CPHA modes; shift register connection |
| 4 | Constraint-Based Design Thinking + IP Integration | 10 | 50% slides, 50% code | `generate if` for optional parity; IP integration checklist |

**Segment 2 key points:**
- Prompting for protocol-aware TBs: specifying baud rate, clock frequency, frame format (8N1), expected sequences
- What AI gets wrong: baud-rate timing accuracy, center-sampling verification
- Professional skill: "Try the same prompt with two different AI tools — which produces better Verilog?"

**Segment 4 key points:**
- Constraint-based design concept: `generate if` for optional features (parity, configurable stop bits)
- UART TX with `parameter PARITY_EN` — `generate if` conditionally includes parity logic
- Concept introduced here; lab implementation on Day 14
- IP integration checklist: read docs → wrapper → synchronizers → testbench → resource check

**Live coding moments:**
- Seg 1: Build UART RX oversampling logic; show start-bit detection and center-sampling
- Seg 3: SPI Mode 0 timing; connect master and slave as shift registers
- Seg 4: Show `generate if` for optional parity — same RTL, different hardware

**Diagrams needed:**
- [WAVEDROM] UART RX oversampling: 16 samples per bit, arrow at center sample
- [SVG] UART RX FSM: IDLE → DETECT_START → SAMPLE_BITS → STOP → VALID
- [SVG] SPI connection diagram: master ↔ slave with SCLK, MOSI, MISO, CS_N
- [WAVEDROM] SPI Mode 0 timing: data sampled on rising SCLK, shifted on falling
- [SVG] `generate if` conditional hardware: parity enabled vs. disabled variants

---

### Lecture 13: SystemVerilog for Design (~45 min)

**Theme:** Cleaner syntax, stronger safety, same hardware.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Why SystemVerilog? | 8 | 80% slides, 20% code | Verilog-2001 → IEEE 1800 evolution timeline |
| 2 | `logic` — One Type to Rule Them All | 8 | 40% slides, 60% live code | `wire`/`reg` confusion eliminated; side-by-side comparison |
| 3 | Intent-Based Always Blocks | 12 | 30% slides, 70% live code | `always_ff`, `always_comb`, `always_latch` with safety checks |
| 4 | Enum FSMs | 10 | 30% slides, 70% live code | Named states, `.name()` debug printing, automatic width |
| 5 | Structs, Typedefs & Packages | 7 | 40% slides, 60% code | Grouping signals; sharing definitions across modules |

**Live coding moments:**
- Seg 2: Refactor a module — replace `wire`/`reg` with `logic`, show it compiles identically
- Seg 3: Deliberately introduce a missing assignment in `always_comb` — show the compiler catches it. Do the same with `always @(*)` — silence.
- Seg 4: Convert `localparam` FSM states to `enum`, add `$display(state.name())`, show readable debug output
- Seg 5: Create a `uart_config_t` struct, use it as a port

**Diagrams needed:**
- [SVG] Verilog vs. SystemVerilog side-by-side: same module, highlighting every difference
- [SVG] Safety net diagram: `always_comb` catches incomplete assignments; `always_ff` enforces edge-triggered

---

### Lecture 14: Verification Techniques, AI-Driven Testing & PPA Analysis (~55 min)

**Theme:** The capstone verification session — where all threads converge.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Assertions — Executable Specifications | 12 | 40% slides, 60% live code | Immediate assertion syntax; inline checks; bug injection demo |
| 2 | AI-Driven Verification Workflows | 15 | 60% slides, 40% code | Verification productivity stack; constraint-based stimulus; prompt engineering |
| 3 | PPA Analysis Methodology | 12 | 50% slides, 50% code | FPGA PPA report template; ASIC context; design-space exploration |
| 4 | Coverage & the Road Ahead | 11 | 70% slides, 30% code | Functional coverage concepts; verification maturity scale; industry landscape |

**Segment 1 key points:**
- Immediate assertions: `assert (condition) else $error("message");`
- Concurrent assertions (brief): `assert property`, sequence syntax, `|->` implication
- Assertions as executable documentation — catching bugs at the source, not in waveforms

**Segment 2 key points:**
- Verification productivity stack: manual → self-checking → AI-scaffolded → assertion-enhanced → coverage-driven
- Constraint-based stimulus: `$urandom_range()`, bounded random testing, constraint specs
- Writing a constraint spec in comments → having AI generate the stimulus loop
- Industry context: "The prompt/generate/review/correct workflow is the same loop verification engineers use on production chip projects."

**Segment 3 key points:**
- FPGA PPA report template: resource table (LUTs, FFs, EBR), Fmax, % utilization
- ASIC PPA context: gate count, wire delay, process nodes, Liberty files, standard cells
- Design-space exploration: synthesize at WIDTH=4,8,16,32, plot area/timing curves
- OpenROAD/OpenLane reminder: open-source ASIC PPA for the same Verilog

**Live coding moments:**
- Seg 1: Add assertions to UART TX — deliberately inject a bug, show the assertion catch it
- Seg 2: Show a constraint spec for the ALU → generate TB with AI → review together
- Seg 3: Build a PPA comparison table live (multiplier variants from Day 10)

**Diagrams needed:**
- [SVG] Verification productivity stack / maturity pyramid
- [SVG] Constraint-based stimulus flow: constraint spec → AI → generated TB → review → corrected TB → simulation
- [SVG] FPGA PPA report template layout
- [SVG] Design-space exploration: area vs. timing plot with parameter sweep

---

## Diagram Inventory Summary

| Type | Count | Tool |
|---|---|---|
| WaveDrom timing diagrams | ~14 | WaveDrom JSON → SVG |
| Mermaid flowcharts/block diagrams | ~16 | Mermaid → SVG (embedded in reveal.js) |
| Custom SVG diagrams | ~18 | Hand-crafted or code-generated |
| **Total diagrams** | **~48** | |

---

## Production Schedule

### Recommended Batch Order

| Batch | Lectures | Total Duration | Rationale |
|---|---|---|---|
| **Batch 1** | Days 1–4 (Week 1) | ~180 min | Foundation — every subsequent lecture builds on these. Record first, iterate. |
| **Batch 2** | Days 5–8 (Week 2) | ~200 min | Sequential + verification + AI intro + FSM — the conceptual peak |
| **Batch 3** | Days 9–12 (Week 3) | ~205 min | Memory + numerical + interfaces — most live-coding heavy |
| **Batch 4** | Days 13–14 (Week 4) | ~100 min | SystemVerilog + capstone verification — lighter load, can refine earlier batches |

### Per-Batch Workflow

```
1. Generate all slide decks + scripts + code files + diagrams for the batch
2. Review the batch for:
   - Technical accuracy
   - Pacing (too fast? too slow? wrong emphasis?)
   - Code correctness (test with iverilog; verify on Go Board where applicable)
   - Voice/tone (does the script sound natural?)
3. Iterate on any issues
4. Record the batch
5. Commit to the repo
```

### Estimated Production Time

| Per lecture | Deliverables |
|---|---|
| reveal.js slide deck (~30-50 slides) | Primary deliverable |
| Script refinement | Embedded in slides as speaker notes |
| Code file extraction + commenting | Included in slide build |
| Diagram generation | Included in slide build |
| Quiz formatting | Quick — content already exists |
| **Per batch (4 lectures)** | **One focused working session with iteration** |

---

## Open Decisions Before Starting Batch 1

### 1. Slide Theme / Branding
- University branding required? (logo, colors, footer)
- Or clean/generic academic theme?
- Dark background preferred for code-heavy content — confirm?

### 2. Video Segment Granularity
Each day has 3–5 segments (e.g., Day 1: 12 + 10 + 12 + 8 = 42 min). Options:
- **Option A: One continuous video per day** (~40-55 min) with chapter markers
- **Option B: 3–5 separate short videos per day** (~8-15 min each) — more EdPuzzle/Panopto friendly
- **Option C: 2 videos per day** — concepts (segs 1-2) + code (segs 3+)

### 3. Code Presentation Strategy
For the live-coding segments, how do you want to present code in the video?
- **Slides with progressive reveal** (code appears line-by-line on slides)
- **Screen-share of actual editor** (VS Code, vim, etc.) — more authentic
- **Hybrid:** Slides show the final code structure, then you switch to editor for the build-up

### 4. Starter Lecture
Recommended: **Produce Day 1 as a complete prototype** first. That way you can:
- Record it as a test
- Identify what works and what doesn't in the format
- Give concrete feedback before the other 13 are produced

This is the standard approach in instructional design — pilot one, refine the template, then batch-produce the rest.
