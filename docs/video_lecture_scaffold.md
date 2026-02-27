# Video Lecture Production Scaffold

## Accelerated HDL for Digital System Design — Pre-Class Videos

**Production scope:** 14 pre-class video lectures (Days 1–14)
**Target format:** reveal.js slides + narration script + live-coding segments
**Recording style:** Mix of slides and live coding (OBS or similar)
**Total target duration:** ~660 minutes (~11 hours of recording)

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
lectures/dayNN_topic/
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

**Pre-class quiz (already exists in day file):**
- Q1: Three differences between HDL and software
- Q2: Which tool (synthesis or simulation) processes `$display`?
- Q3: Write a 2-input AND module from memory

---

### Lecture 02: Combinational Building Blocks (~45 min)

**Theme:** Data types, operators, and your first real building blocks (mux, adder, 7-seg decoder).

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Data Types and Vectors | 15 | 50% slides, 50% live code | wire/reg decision diagram; bit-slice visualizer |
| 2 | Operators | 12 | 40% slides, 60% live code | Operator → hardware cost table |
| 3 | Sized Literals and Width Matching | 8 | 30% slides, 70% live code | Width mismatch bug examples |
| 4 | The 7-Segment Display | 10 | 20% slides, 80% live code | Go Board 7-seg pinout; segment mapping diagram |

**Live coding moments:**
- Seg 1: Concatenation, slicing, replication in iverilog — predict then run
- Seg 2: Conditional operator chain building a 4:1 mux
- Seg 3: Show actual synthesis warnings from width mismatches in Yosys
- Seg 4: Build hex_to_7seg decoder live, test in simulation

**Diagrams needed:**
- [SVG] Bit vector visualization (MSB/LSB, slicing, concatenation)
- [SVG] 7-segment display with labeled segments (a–g), active-low annotation
- [MERMAID] Wire vs. reg decision flowchart

---

### Lecture 03: Procedural Combinational Logic (~45 min)

**Theme:** `always @(*)`, `if/else`, `case` — and the dreaded unintentional latch.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | The `always @(*)` Block | 12 | 50% slides, 50% code | Sensitivity list comparison; `@(*)` vs. manual |
| 2 | `if/else` and `case` | 15 | 30% slides, 70% live code | Priority chain hardware vs. parallel mux hardware |
| 3 | The Latch Problem | 12 | 40% slides, 60% live code | Yosys `show` output with latch; before/after fix |
| 4 | Blocking vs. Nonblocking (first pass) | 6 | 60% slides, 40% code | Simple rule card: `=` for comb, `<=` for seq |

**Live coding moments:**
- Seg 2: Build a priority encoder, then an ALU with `case`
- Seg 3: **Critical demo** — write buggy code that infers a latch, show it in Yosys `show`, then fix it
- Seg 4: Side-by-side blocking vs. nonblocking — just establish the rule for now

**Diagrams needed:**
- [MERMAID] `if/else` → priority chain hardware
- [MERMAID] `case` → parallel mux hardware
- [SVG] Latch vs. combinational logic — the "transparent" problem
- [WAVEDROM] Latch behavior vs. intended combinational behavior

---

### Lecture 04: Sequential Logic Fundamentals (~50 min)

**Theme:** Clocks, flip-flops, nonblocking assignment, and the RTL paradigm.

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

### Lecture 06: Testbenches & Simulation-Driven Development (~50 min)

**Theme:** Verification isn't optional. Simulate first, always.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Testbench Anatomy | 12 | 30% slides, 70% live code | Testbench structure diagram (no ports, DUT instance, stimulus) |
| 2 | Self-Checking Testbenches | 15 | 20% slides, 80% live code | Pass/fail automated output; comparison pattern |
| 3 | Tasks for Testbench Organization | 10 | 20% slides, 80% live code | Before/after refactor |
| 4 | File-Driven Testing and Sequential Testbenches | 13 | 30% slides, 70% live code | `$readmemh` flow; clock generation pattern |

**Live coding moments:**
- Seg 1: Build a complete testbench from scratch for a simple mux — step by step
- Seg 2: Add self-checking to the ALU testbench — automated pass/fail with error count
- Seg 3: Refactor repetitive stimulus into tasks
- Seg 4: Show `$readmemh` loading test vectors, clock generation pattern

**Diagrams needed:**
- [MERMAID] Testbench architecture: testbench (no ports) → DUT (ports) → waveform dump
- [SVG] Simulate-first workflow: write TB → simulate → pass? → synthesize → program

---

### Lecture 07: Finite State Machines (~50 min)

**Theme:** The most important design pattern in digital logic. Paper first, then code.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | FSM Theory and Architecture | 12 | 70% slides, 30% code | Moore vs. Mealy block diagrams; state diagram notation |
| 2 | The 3-Always-Block Coding Style | 15 | 30% slides, 70% live code | Template code with annotations; traffic light FSM |
| 3 | State Encoding | 8 | 60% slides, 40% code | Binary vs. one-hot vs. gray comparison table |
| 4 | FSM Design Methodology | 15 | 20% slides, 80% live code | Paper state diagram → code translation live |

**Live coding moments:**
- Seg 2: Build the 3-block FSM template, then fill in traffic light controller
- Seg 3: Show Yosys synthesis with different encodings, compare resource usage
- Seg 4: **Full walkthrough** — draw state diagram on paper/tablet → translate to Verilog → simulate → verify all transitions

**Diagrams needed:**
- [MERMAID] Moore FSM block diagram (state register, next-state logic, output logic)
- [MERMAID] Mealy FSM block diagram (output depends on state + input)
- [MERMAID] Traffic light state diagram (GREEN → YELLOW → RED → GREEN)
- [WAVEDROM] FSM state transitions over time with input/output signals

---

### Lecture 08: Hierarchy, Parameters & Generate (~45 min)

**Theme:** Scaling up — reusable, configurable modules and clean system architecture.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Module Hierarchy Deep Dive | 12 | 50% slides, 50% live code | 3-level hierarchy tree; named vs. positional ports |
| 2 | Parameters and Parameterization | 15 | 30% slides, 70% live code | `parameter`, `localparam`, `$clog2` patterns |
| 3 | Generate Blocks | 12 | 40% slides, 60% live code | `for`-generate unrolled visualization |
| 4 | Design for Reuse | 6 | 80% slides, 20% code | Module library checklist |

**Live coding moments:**
- Seg 1: Build a 3-level hierarchy: top → subsystem → leaf modules
- Seg 2: Parameterize the counter, instantiate at 8/16/24 bits, show all three working
- Seg 3: `generate`-based multi-rate blinker — N instances of blink module

**Diagrams needed:**
- [MERMAID] Module hierarchy tree (top_module → sub_a, sub_b → leaf modules)
- [SVG] Generate unrolling: `for (i=0; i<4; i++)` → 4 physical instances

---

### Lecture 09: Memory — RAM, ROM & Block RAM (~45 min)

**Theme:** On-chip storage — from lookup tables to real memory blocks.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | ROM in Verilog | 12 | 40% slides, 60% live code | Case-based vs. array-based ROM; `$readmemh` flow |
| 2 | RAM in Verilog | 12 | 30% slides, 70% live code | Synchronous RAM template; read-before-write vs. write-first |
| 3 | iCE40 Memory Resources | 10 | 70% slides, 30% code | EBR block diagram; inference requirements |
| 4 | Practical Memory Applications | 11 | 20% slides, 80% live code | Sine LUT, character ROM, pattern sequencer |

**Live coding moments:**
- Seg 1: Build a ROM with `$readmemh`, create the `.hex` file, simulate
- Seg 2: Build synchronous RAM, write testbench verifying read-after-write
- Seg 4: Sine wave lookup table or LED pattern sequencer from ROM

**Diagrams needed:**
- [SVG] iCE40 HX1K memory map: 1,280 LUTs + 16 EBR blocks
- [MERMAID] `$readmemh` flow: `.hex` file → memory array → address/data interface
- [WAVEDROM] Synchronous RAM read/write timing

---

### Lecture 10: Timing, Clocking & Constraints (~50 min)

**Theme:** The physical reality behind RTL — setup time, hold time, and why timing matters.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | The Physics of Timing | 15 | 80% slides, 20% code | Setup/hold timing diagram; critical path visualization |
| 2 | Timing Constraints and nextpnr Reports | 12 | 40% slides, 60% live code | Real nextpnr report walkthrough |
| 3 | The iCE40 PLL | 12 | 50% slides, 50% live code | PLL block diagram; `SB_PLL40_CORE` instantiation |
| 4 | Clock Domain Crossing | 11 | 60% slides, 40% code | CDC problem diagram; 2-FF synchronizer revisited |

**Live coding moments:**
- Seg 2: Add timing constraints, run nextpnr, read the report line-by-line
- Seg 2: **Intentionally create a timing violation**, show the FAIL, fix it
- Seg 3: Instantiate `SB_PLL40_CORE`, derive a different frequency
- Seg 4: Build a CDC transfer with 2-FF synchronizer

**Diagrams needed:**
- [WAVEDROM] Setup time, hold time, and clock-to-q annotated on a timing diagram
- [SVG] Critical path through combinational logic between two registers
- [SVG] PLL block diagram (reference clock → PFD → loop filter → VCO → divider → output clock)
- [WAVEDROM] Clock domain crossing failure and 2-FF synchronizer fix

---

### Lecture 11: UART Transmitter (~50 min)

**Theme:** Your first communication interface — FSM + datapath as a design methodology.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | The UART Protocol | 15 | 70% slides, 30% code | UART frame diagram (idle, start, D0–D7, stop); baud rate math |
| 2 | UART TX Architecture | 15 | 50% slides, 50% code | Block diagram: FSM + shift register + baud generator |
| 3 | Implementation Walk-Through | 12 | 10% slides, 90% live code | Build UART TX from scratch |
| 4 | Connecting to a PC | 8 | 60% slides, 40% live code | USB-serial setup; terminal emulator demo |

**Live coding moments:**
- Seg 1: Calculate baud divider for 115200 baud @ 25 MHz
- Seg 3: **Full build** — baud generator → FSM → shift register → integrate → simulate
- Seg 4: Show terminal emulator receiving data (can be a screen recording segment)

**Diagrams needed:**
- [WAVEDROM] Complete UART frame: idle → start bit → 8 data bits (LSB first) → stop bit
- [MERMAID] UART TX FSM state diagram (IDLE → START → DATA → STOP)
- [SVG] UART TX block diagram: baud tick generator + FSM + PISO shift register

---

### Lecture 12: UART RX, SPI & IP Integration (~50 min)

**Theme:** Receiving serial data, a second protocol, and working with third-party IP.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | UART RX — The Oversampling Challenge | 15 | 60% slides, 40% code | 16× oversampling diagram; bit-center alignment |
| 2 | UART RX Implementation | 15 | 20% slides, 80% live code | Full RX build |
| 3 | SPI Protocol | 12 | 70% slides, 30% code | SPI timing diagram; CPOL/CPHA modes; 4-wire diagram |
| 4 | IP Integration Philosophy | 8 | 90% slides, 10% code | IP evaluation checklist; wrapper pattern |

**Live coding moments:**
- Seg 2: Build UART RX with 16× oversampling, simulate with TX driving RX
- Seg 3: SPI master skeleton or waveform analysis

**Diagrams needed:**
- [WAVEDROM] 16× oversampling: oversample ticks within one UART bit period, center sample highlighted
- [MERMAID] UART RX FSM (IDLE → START_DET → SAMPLE_BITS → STOP → VALID)
- [WAVEDROM] SPI timing for all 4 CPOL/CPHA modes
- [SVG] SPI 4-wire connection diagram (master ↔ slave)

---

### Lecture 13: SystemVerilog for Design (~45 min)

**Theme:** Modern Verilog — cleaner, safer, more expressive.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Why SystemVerilog? | 8 | 80% slides, 20% code | Verilog timeline → SystemVerilog evolution |
| 2 | `logic` — One Type to Rule Them All | 10 | 40% slides, 60% live code | wire/reg confusion → logic solution; side-by-side |
| 3 | Intent-Based Always Blocks | 12 | 30% slides, 70% live code | `always_ff`, `always_comb`, `always_latch` with compiler error demos |
| 4 | `enum`, `struct`, and `package` | 15 | 20% slides, 80% live code | FSM refactor: localparam → enum; signal grouping → struct |

**Live coding moments:**
- Seg 2: Refactor a Verilog module replacing wire/reg with logic
- Seg 3: Show compiler catching a mistake with `always_comb` that Verilog missed
- Seg 4: Full FSM refactor: Verilog → SystemVerilog, side-by-side comparison

**Diagrams needed:**
- [MERMAID] Verilog → SystemVerilog evolution timeline
- [SVG] `wire`/`reg` confusion diagram → unified `logic` type

---

### Lecture 14: SystemVerilog for Verification (~50 min)

**Theme:** Professional verification techniques — assertions, coverage, and what comes next.

| Seg | Title | Min | Slide/Code Split | Key Visual |
|-----|-------|-----|-------------------|------------|
| 1 | Assertions — Executable Specifications | 15 | 40% slides, 60% live code | Immediate assertion syntax; inline checks |
| 2 | Concurrent Assertions | 12 | 50% slides, 50% live code | `assert property` with sequence syntax |
| 3 | Functional Coverage | 12 | 40% slides, 60% live code | `covergroup`/`coverpoint`/`bins`; coverage report |
| 4 | Interfaces, Classes & the Road to UVM | 11 | 70% slides, 30% code | Verification landscape pyramid |

**Live coding moments:**
- Seg 1: Add assertions to UART TX — catch a deliberately introduced bug
- Seg 2: Write a concurrent assertion for UART protocol compliance
- Seg 3: Build a covergroup for the ALU, run simulation, show coverage report

**Diagrams needed:**
- [SVG] Verification landscape pyramid: directed tests → self-checking → assertions → coverage → constrained random → formal
- [MERMAID] Interface + modport connection diagram (DUT ↔ interface ↔ testbench)

---

## Diagram Inventory Summary

| Type | Count | Tool |
|---|---|---|
| WaveDrom timing diagrams | ~14 | WaveDrom JSON → SVG |
| Mermaid flowcharts/block diagrams | ~16 | Mermaid → SVG (embedded in reveal.js) |
| Custom SVG diagrams | ~12 | Hand-crafted or code-generated |
| **Total diagrams** | **~42** | |

---

## Production Schedule

### Recommended Batch Order

| Batch | Lectures | Total Duration | Rationale |
|---|---|---|---|
| **Batch 1** | Days 1–4 (Week 1) | ~180 min | Foundation — every subsequent lecture builds on these. Record first, iterate. |
| **Batch 2** | Days 5–8 (Week 2) | ~190 min | Sequential + verification + FSM — the conceptual peak |
| **Batch 3** | Days 9–12 (Week 3) | ~195 min | Memory + interfaces — most live-coding heavy |
| **Batch 4** | Days 13–14 (Week 4) | ~95 min | SystemVerilog — lighter load, can refine earlier batches |

### Per-Batch Workflow

```
1. I generate all 4 lectures' slide decks + scripts + code files + diagrams
2. You review the batch for:
   - Technical accuracy
   - Pacing (too fast? too slow? wrong emphasis?)
   - Code correctness (I'll test what I can with iverilog, but you verify on Go Board)
   - Voice/tone (does the script sound like you?)
3. We iterate on any issues
4. You record the batch
5. We commit to the repo
```

### Estimated Production Time (My Side)

| Per lecture | Time estimate |
|---|---|
| reveal.js slide deck (~30-50 slides) | Primary deliverable |
| Script refinement | Embedded in slides as speaker notes |
| Code file extraction + commenting | Included in slide build |
| Diagram generation | Included in slide build |
| Quiz formatting | Quick — content already exists |
| **Estimated per lecture** | **One focused session** |
| **Per batch (4 lectures)** | **One working session with iteration** |

---

## Open Decisions Before We Start Batch 1

### 1. Slide Theme / Branding
- University branding required? (logo, colors, footer)
- Or clean/generic academic theme?
- Dark background preferred for code-heavy content — confirm?

### 2. Video Segment Granularity
Each day has 4 segments (e.g., Day 1: 12 + 10 + 12 + 8 = 42 min). Options:
- **Option A: One continuous video per day** (~40-50 min) with chapter markers
- **Option B: 4 separate short videos per day** (~8-15 min each) — more EdPuzzle/Panopto friendly
- **Option C: 2 videos per day** — concepts (segs 1-2) + code (segs 3-4)

### 3. Code Presentation Strategy
For the live-coding segments, how do you want to present code in the video?
- **Slides with progressive reveal** (code appears line-by-line on slides)
- **Screen-share of actual editor** (VS Code, vim, etc.) — more authentic
- **Hybrid:** Slides show the final code structure, then you switch to editor for the build-up

### 4. Starter Lecture
Want me to produce **Day 1 as a complete prototype** first? That way you can:
- Record it as a test
- Identify what works and what doesn't in the format
- Give me concrete feedback before I produce the other 13

This is the standard approach in instructional design — pilot one, refine the template, then batch-produce the rest.

---

## Recommended Next Step

**Produce Day 1 as a complete prototype.** I'll generate:
1. Full reveal.js slide deck (all 4 segments, ~30-40 slides)
2. Complete narration script with timing marks
3. All Verilog code files (extracted, commented, buildable)
4. Diagrams (Mermaid + WaveDrom + SVG)
5. Pre-class quiz in both Markdown and reveal.js quiz format

You review, record a test, and we calibrate the template before scaling to all 14.
