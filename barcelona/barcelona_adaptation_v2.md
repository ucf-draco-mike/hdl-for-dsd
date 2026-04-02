# HDL for Digital System Design — Barcelona Abroad Adaptation v2

## Adaptation Overview

**Baseline:** 16-session curriculum (v2, with AI-assisted testbenches, PPA, numerical architectures)
**Barcelona schedule:** 14 teaching sessions + 1 guest lecture + 3 academic visits
**Pedagogical overlay:** CRAFT cycle (Contextualize → Reframe → Assemble → Fortify → Transfer) infused into every session and enrichment activity

### What This Document Is

This is the **abroad overlay** — it maps the baseline curriculum onto the Barcelona calendar, identifies where content compresses, and specifies how CRAFT phases manifest in every session. The baseline course repo (`hdl-for-dsd`) remains the canonical source; this document drives the schedule and scaffolds the pedagogy.

---

## Compression Strategy

Two baseline days are absorbed, and UART is condensed from two days to one:

| Change | Rationale |
|--------|-----------|
| **D5+D6 → single session** | Testbenches verify the counters/shift registers just built — natural pairing. Students build a counter, then immediately write (and AI-generate) a testbench for it. The Fortify phase is built into the Assemble arc rather than living on its own day. |
| **UART: 2 days → 1 day** | UART TX is the core learning (baud timing, shift register, FSM-driven serialization). UART RX is structurally similar — oversampling and frame detection are covered in pre-class video + a stretch exercise, not a full lab day. Loopback becomes optional/self-study. |
| **Project rescoped** | Reduced from 2 full build days + demo to 1 build day + demo. Project scope tightened to match. |

What's **not** compressed: Week 1 foundations (D1–D4), FSMs (D7), Hierarchy/Parameters (D8), Memory (D9), Timing/Numerical Architectures (D10), SystemVerilog (both design and verification get full days).

---

## CRAFT Session Template

Every 2.5-hour teaching session follows this structure:

```
┌─────────────────────────────────────────────────────┐
│  🌍 CONTEXTUALIZE (10 min)                          │
│  "Where This Lives" opener — real-world framing     │
│  Connect to academic visit / Barcelona context       │
├─────────────────────────────────────────────────────┤
│  ⚠️ REFRAME (15 min)                                │
│  Mini-lecture: surface the misconception, install    │
│  the correct mental model.                           │
│  "If You're Thinking Like a [X]..." moment           │
│  ❓ "No Dumb Questions" pause before lab             │
├─────────────────────────────────────────────────────┤
│  👁️🤝🧪 ASSEMBLE (80–90 min)                       │
│  👁️ I Do: Instructor live-codes the concept (15)    │
│  🤝 We Do: Guided exercise, students follow (25)    │
│  🧪 You Do: Independent lab exercises (40–50)       │
│  💡 Pattern named when first introduced              │
│  🔑 Key Insight captured on board/slide              │
├─────────────────────────────────────────────────────┤
│  🔧🤖 FORTIFY (20 min)                              │
│  🔧 "What Did the Tool Build?" — synthesis/sim      │
│  🤖 "Check the Machine" — AI verification exercise  │
│  🧠 "How You Learn" metacognitive moment             │
├─────────────────────────────────────────────────────┤
│  🔗 TRANSFER (10 min)                               │
│  "What's Next" — bridge to tomorrow's content       │
│  📊 Industry Alignment connection                    │
│  Homework + pre-class video assignment               │
└─────────────────────────────────────────────────────┘
```

---

## Full Calendar Mapping

### Week 1: Verilog Foundations (May 25–29)

| Date | Cal Day | Baseline | Barcelona Session | Key CRAFT Moments |
|------|---------|----------|-------------------|-------------------|
| Mon 5/25 | CLASS | D1 | Welcome to Hardware Thinking | 🌍 "You're learning HDL in a city built by Gaudí — an architect who thought in parallel structures and modular repetition." |
| Tue 5/26 | CLASS | D2 | Data Types, Vectors & Operators | ⚠️ "If You're Thinking Like a Programmer: variables are storage. Reframe: wires are physical connections that exist simultaneously." |
| Wed 5/27 | CLASS | D3 | Combinational Logic & always@(*) | 🔧 Yosys schematic: see `if/else` vs `case` synthesis side-by-side. PM: Sagrada Familia |
| Thu 5/28 | EXCURSION | — | Montserrat Day Trip | 🌍 Informal: parallel mountain paths ≈ parallel hardware; funicular = state machine |
| Fri 5/29 | CLASS | D4 | Clocked Logic & RTL Thinking | 🤖 First "Check the Machine": ask AI to explain blocking vs. nonblocking — verify against what you just learned |

**Notes:** Identical to baseline D1–D4. Montserrat replaces Thursday; D4 shifts to Friday. No compression needed.

---

### Week 2: Sequential Design, Verification & Structure (Jun 1–4)

| Date | Cal Day | Baseline | Barcelona Session | Key CRAFT Moments |
|------|---------|----------|-------------------|-------------------|
| Mon 6/1 | CLASS | **D5+D6** | **Counters, Testbenches & AI Verification** | 🌍 "The counters you build today are inside every RISC-V pipeline — you'll see them at Semidynamics this afternoon." 🤖 Build-then-verify arc: counter → testbench → AI testbench. PM: Semidynamics visit |
| Tue 6/2 | CLASS | D7 | Finite State Machines | ⚠️ "If You're Thinking Like a Programmer: FSM = switch in a loop. Reframe: FSM = physical flip-flops + combinational next-state logic." PM: HP visit |
| Wed 6/3 | CLASS | D8 | Hierarchy, Parameters & Generate | 🔧 Parameterize a module, synth at 3 widths, compare `yosys stat`. Eve: Cooking workshop |
| Thu 6/4 | CLASS | D9 | Memory: RAM, ROM & Block RAM | 🔑 "Memory has physical constraints: read latency, port count, initialization. Coding patterns determine whether Yosys infers EBR or LUTs." |

**D5+D6 Merge — CRAFT Overlay:**

- 🌍 **Contextualize:** Semidynamics visit — counters and shift registers in RISC-V pipelines
- ⚠️ **Reframe:** Bounce needs a saturating counter, not `delay()`; simulation ≠ proof of correctness
- 🔑 **Key Insight:** A testbench is not optional — writing it *before* the design is better
- 🤖 **Check the Machine:** AI-generate a TB for debounce; compare coverage against manual TB
- 🔗 **Transfer:** Sequential + verification mastered → FSMs tomorrow

See `craft/day05_day06_craft.md` for full CRAFT overlay.

**Pre-class video:** Students watch *both* the D5 video (counters/debounce, 45 min) and D6 video (testbench anatomy, 55 min) over the weekend. Total: ~100 min, split Sat/Sun.

---

### Week 3: Timing, Communication & SystemVerilog (Jun 8–11)

| Date | Cal Day | Baseline | Barcelona Session | Key CRAFT Moments |
|------|---------|----------|-------------------|-------------------|
| Mon 6/8 | CLASS | D10 | Timing, Numerical Architectures & PPA | 🌍 "Every interface you'll build depends on timing. The Barcelona Metro runs on precisely timed digital control — you'll see that control room next week." |
| Tue 6/9 | CLASS | **D11+D12 condensed** | **UART: Protocol Design & Implementation** | 👁️🤝🧪 Full Assemble arc for TX; RX covered conceptually + stretch exercise. Eve: Flamenco |
| Wed 6/10 | CLASS | D13 | SystemVerilog for Design | 🔗 "Everything you learned in Verilog translates. SV doesn't replace it — it sharpens it." PM: Park Güell |
| Thu 6/11 | CLASS | D14 | SystemVerilog for Verification | 🤖 AI constraint-based TB for project module — capstone Fortify exercise |

**UART Condensed — What Stays, What Goes:**

| Content | Status | Rationale |
|---------|--------|-----------|
| UART protocol fundamentals (framing, baud, start/stop) | ✅ Stays — in pre-class video + mini-lecture | Essential context |
| UART TX design & implementation | ✅ Stays — full I Do → We Do → You Do | Core learning: FSM-driven serialization, baud timing |
| UART TX testbench (AI-assisted) | ✅ Stays — Fortify exercise | Reinforces AI verification thread |
| UART TX deployment to Go Board | ✅ Stays — HW verification | Students see their bytes on a terminal |
| UART RX (16× oversampling, frame detection) | 📹 Pre-class video only | Conceptually important but structurally similar to TX |
| UART RX implementation lab | ⬇️ Stretch exercise | Available for fast students; not required |
| UART loopback (TX→RX echo) | ❌ Dropped from required | Cool demo but not essential for learning objectives |
| SPI Master | ❌ Dropped | Was already a stretch exercise; out of scope for abroad |

**Condensed UART — CRAFT Overlay:**

- 🌍 **Contextualize:** Serial communication everywhere — Go Board USB-UART, Semidynamics debug ports, Metro telemetry
- ⚠️ **Reframe:** `print()` → FSM that shifts bits at a precise baud rate; no `print`, just shift register + counter + FSM
- 🔑 **Key Insight:** UART TX = FSM shifting bits at a fixed rate; complexity is in timing, not logic
- 🤖 **Check the Machine:** AI protocol-aware UART TB — does it check baud timing, all 8 data bits, back-to-back TX?
- 🔗 **Transfer:** Communication interface from scratch → SystemVerilog tomorrow

See `craft/day11_craft.md` for full CRAFT overlay.

---

### Week 4: Integration, Transfer & Demonstration (Jun 15–18)

| Date | Cal Day | Baseline | Barcelona Session | Key CRAFT Moments |
|------|---------|----------|-------------------|-------------------|
| Mon 6/15 | VISIT | — | Barcelona Metro Control Room (10 AM) | 🌍 Capstone Contextualize: FSMs, serial buses, memory, timing — running a city's transit |
| Tue 6/16 | CLASS | D15 | Project Build Day | 🧪 All You Do: structured project work + PPA analysis + AI-assisted final TB |
| Wed 6/17 | GUEST | — | RISC-V Lecture (David Castells Rufas, UAB) | 🌍🔗 Capstone Transfer: from your first module to processor design |
| Thu 6/18 | CLASS | D16 | Project Demos & Course Wrap | 🔗 "Where to go from here" — ASIC/FPGA careers, UVM, formal verification |

---

## Rescoped Final Project

### Why Rescope

The baseline project assumed 2 full build days (D15–D16 with demo on D16 afternoon). The Barcelona schedule provides 1 build day (Tue 6/16) + demo (Thu 6/18), with independent work time on evenings and the Wed 6/17 afternoon. Students have comparable *total* project time but less *structured* class time.

### Revised Project Parameters

| Parameter | Baseline | Barcelona |
|-----------|----------|-----------|
| Build days in class | 2 (D15 full + D16 morning) | 1 (D16 full) |
| Demo format | 10-min presentation + live demo | 5-min live demo + 2-min Q&A |
| Core deliverables | Working demo + code + testbenches + PPA report + AI portfolio | Working demo + code + 1 testbench + brief PPA snapshot |
| Scope | Full project from 9-option list | **Reduced project from 6-option list** (3 highest-complexity options removed) |

### Revised Project Options (6 options, complexity-capped)

| # | Project | Key Concepts | Difficulty | Removed? |
|---|---------|-------------|------------|----------|
| 1 | **UART Command Parser** | FSM + UART TX + string matching + LED control | ★★ | |
| 2 | **Digital Clock / Timer** | Counters + 7-seg multiplexing + button FSM | ★★ | |
| 3 | **Pattern Generator** | Shift registers + LFSR + LED sequencing + parameterization | ★☆ | |
| 4 | **Reaction Time Game** | FSM + counter + random delay + 7-seg display | ★★ | |
| 5 | **Tone Generator** | Counter-based frequency synthesis + button UI + 7-seg | ★★ | |
| 6 | **Conway's Game of Life** | Memory + neighbor logic + VGA/LED display + FSM | ★★ | |
| — | ~~SPI Sensor Interface~~ | ~~SPI master + FSM + data parsing~~ | ~~★★★~~ | ❌ Requires SPI (dropped) |
| — | ~~VGA Pattern Display~~ | ~~Timing-critical VGA + frame buffer~~ | ~~★★★~~ | ❌ Too much timing work for schedule |
| — | ~~Simple Processor~~ | ~~ALU + register file + FSM sequencer~~ | ~~★★★~~ | ❌ Scope too large; RISC-V lecture covers conceptually |

### Revised Project Deliverables

Each project requires:

1. **Working hardware demo** (5 min) — deployed on Go Board, demonstrated live
2. **Source code** — clean, commented, following course conventions (`r_`/`w_`/`i_`/`o_` prefixes, parameterized where appropriate)
3. **One self-checking testbench** — for the core module (FSM, counter, or data path). May be manually written or AI-generated-then-corrected.
4. **PPA snapshot** — `yosys stat` output for the top-level module: LUT count, FF count, % iCE40 utilization. Two sentences on what's using the most resources and why.
5. **AI interaction log** — one example of AI-assisted testbench or code generation with annotations: what you prompted, what it produced, what you corrected.

### Revised Project Timeline

| Date | Milestone |
|------|-----------|
| Thu 6/4 (end of Week 2) | **Project selection due** — choose from 6 options or propose custom (approved by instructor) |
| Mon 6/8 (start of Week 3) | Block diagram and module list submitted (1-page sketch) |
| Thu 6/11 (end of Week 3) | **Core module implemented** — at least the primary FSM or data path compiles and simulates. Testbench started. |
| Fri 6/12 – Mon 6/15 | Independent work time (weekend + Metro visit day afternoon) |
| Tue 6/16 | **Build day** — integration, debugging, PPA analysis, AI-assisted TB polish |
| Wed 6/17 afternoon | Independent polish time (after RISC-V lecture) |
| Thu 6/18 | **Demo day** — 5-min demos, all deliverables due by end of day |

### Revised Project Grading

| Component | Weight | Notes |
|-----------|--------|-------|
| Working hardware demo | 35% | Does it work? Does it match the spec? |
| Code quality | 20% | Conventions, parameterization, readability |
| Testbench + verification | 20% | Self-checking, covers core functionality |
| PPA snapshot + AI log | 15% | Shows synthesis awareness + AI literacy |
| Live demo presentation | 10% | Clear explanation, handles Q&A |

---

## Academic Visit Integration

### Semidynamics (Mon 6/1, 4:00–5:30 PM)

**Pre-visit framing (end of morning class):**
> "Semidynamics designs RISC-V processors. Every counter, shift register, and testbench you built today is a building block of what they ship. As you tour: How do they verify their designs? What's their relationship between simulation and silicon?"

**Post-visit reflection (start of Tue class, 5 min):**
> "What surprised you? → bridges into FSMs: "The pipeline control they described? That's an FSM. Today you build one."

### HP Customer Center (Tue 6/2, afternoon)

**Pre-visit framing:**
> "HP is using AI to transform how people work. We just used AI to transform how we write testbenches. Same concept, different domain."

**Post-visit reflection (start of Wed class, 5 min):**
> "HP showed AI assisting humans, not replacing them. Same with our AI testbenches — you decide what to test, the AI scaffolds the code, you verify the result."

### Barcelona Metro Control Room (Mon 6/15, 10 AM)

**Pre-visit prep (assigned end of Thu 6/11):**
> "The Metro's automated lines run on digital control systems. As you tour: Where are the FSMs? Where is serial communication happening? Where is memory being used? Write down 3 observations connecting what you see to what you've built."

**Post-visit debrief (start of Tue 6/16, 10 min):**
> Student share-out → transitions into project build day. "Everything you saw yesterday — you have the skills to build the components of those systems."

### David Castells Rufas RISC-V Lecture (Wed 6/17, 10 AM)

**Pre-lecture prep (assigned end of Tue 6/16):**
> "David designs RISC-V processors in the same HDL you've been writing. Come with 2 questions about how your course concepts apply to processor design."

**Role in CRAFT arc:** This is the course's capstone 🌍 Contextualize + 🔗 Transfer moment. "You now have the foundation to understand and contribute to what David does."

---

## CRAFT Threads Across the Full Course

### 🌍 Contextualize — "Where This Lives"

| Session | Anchor |
|---------|--------|
| D1 (Mon 5/25) | Gaudí's Barcelona — parallel structures, modular design |
| D2 (Tue 5/26) | Binary in everything: phone, metro reader, airport scanner |
| D3 (Wed 5/27) | Real-time decisions → Sagrada Familia: structural calculations |
| D4 (Fri 5/29) | Clocked systems: traffic lights, metro schedules, departure boards |
| D5+6 (Mon 6/1) | Pipeline counters → **Semidynamics** that afternoon |
| D7 (Tue 6/2) | FSMs control vending machines, train doors → **HP AI tools** |
| D8 (Wed 6/3) | Parameterized IP = how companies build products |
| D9 (Thu 6/4) | Memory in every system: cache, frame buffers, lookup tables |
| D10 (Mon 6/8) | Timing is what makes hardware *hard*; Metro timing next week |
| D11 (Tue 6/9) | Serial protocols: same UART on your Go Board's USB bridge |
| D12 (Wed 6/10) | SV: "This is what you'll write on day one of your first job" |
| D13 (Thu 6/11) | Assertions as executable specs → industry verification standards |
| Metro (Mon 6/15) | 🌍 **Capstone:** Digital systems running a city |
| Build (Tue 6/16) | Your project = same development cycle professionals follow |
| RISC-V (Wed 6/17) | 🔗 **Capstone Transfer:** From first module to processor design |
| Demo (Thu 6/18) | You are an HDL designer. Where does this take you? |

### ⚠️ Reframe — "If You're Thinking Like a..."

| Session | Misconception → Correct Model |
|---------|-------------------------------|
| D1 | "HDL is a programming language" → "HDL describes physical hardware that runs in parallel" |
| D2 | "Variables store values" → "Wires are connections; `reg` is storage, not a variable" |
| D3 | "`if/else` is like C" → "Priority-encoded mux chains vs. parallel muxes — different HW cost" |
| D4 | "Code executes top to bottom" → "Everything in `always` describes what happens on a clock edge — simultaneously" |
| D5+6 | "Buttons just work" → "Mechanical contacts bounce; you need a saturating counter" / "If it simulates, it works" → "Simulation proves correctness for tested cases only" |
| D7 | "FSM = switch in a loop" → "FSM = flip-flops + combinational logic; 3-block separates concerns" |
| D8 | "Copy-paste is reuse" → "Parameters + generate create hardware at elaboration, not runtime" |
| D9 | "Memory is just an array" → "Physical constraints: latency, ports, init. Coding patterns → EBR inference" |
| D10 | "Faster clock = better" → "Timing closure means *every* path must meet setup/hold" |
| D11 | "Serial is slow" → "Serial saves pins. 115200 baud = 11.5 KB/s — enough for embedded control" |
| D12 | "SV is a different language" → "SV is Verilog with guardrails — `always_ff` catches mistakes sooner" |
| D13 | "Testing is optional" → "Assertions are executable documentation — they catch bugs at the source" |

### 👁️🤝🧪 Assemble — Key I Do → We Do → You Do Arcs

| Session | I Do | We Do | You Do |
|---------|------|-------|--------|
| D1 | Live-code `hello_led` | Modify blink pattern | Design 4-LED binary counter |
| D3 | Build mux, show synthesis | Build 7-seg decoder together | Priority encoder + ALU |
| D5+6 | Counter + TB | Add LFSR + AI TB together | Mod-N counter + TB comparison |
| D7 | Traffic light FSM | Add pedestrian button | Pattern detector or vending FSM |
| D9 | ROM lookup table | RAM read/write together | Memory-backed pattern sequencer |
| D11 | UART TX live build | Add baud parameter together | Deploy — send your name to terminal |
| D12 | Refactor FSM to SV | Add `always_comb` guardrails | Refactor your own module to SV |
| D13 | Add assertions to UART TX | Coverage exercise together | Assertion-enhanced project module |

### 🔧🤖 Fortify — Tool + AI Verification Progression

| Session | 🔧 Tool Verification | 🤖 AI Verification |
|---------|----------------------|---------------------|
| D3 | Yosys schematic: `if/else` vs `case` | — |
| D4 | GTKWave: clock edge behavior | Ask AI to explain blocking vs. nonblocking |
| **D5+6** | **GTKWave: manual vs AI waveforms** | **First AI TB generation + comparison** |
| D8 | `yosys stat` at multiple widths (PPA) | AI TB for parameterized counter |
| D9 | EBR inference check in synthesis report | AI-generated memory test patterns |
| **D11** | **PPA: UART at 9600 vs 115200** | **AI protocol-aware UART TB** |
| D13 | Assertion failures as verification | AI constraint-based TB for project module |
| Build Day | PPA snapshot for final project | AI-assisted final TB with corrections |

### 🔗 Transfer — "What's Next" Bridges

| Session | Bridge |
|---------|--------|
| D4 → D5+6 | "You can build anything on a clock edge. Tomorrow: useful sequential circuits + how to verify them." |
| D5+6 → D7 | "You can build and verify sequential blocks. Tomorrow: FSMs tie everything together." |
| D8 → D9 | "You build reusable, parameterized blocks. Next: memory — where your data lives." |
| D11 → D12 | "You built a communication interface from scratch. Tomorrow: SV sharpens everything you've learned." |
| D13 → Metro | "Next week: see your skills at city scale, then build your project." |
| RISC-V → Demo | "David showed where HDL skills lead. Tomorrow: you demonstrate yours." |

---

## Standing CRAFT Elements — Per Session Checklist

| Element | Manifestation | When |
|---------|--------------|------|
| 🔑 Key Insight | Written on board at the moment it lands; students photograph | During Reframe or Assemble |
| 📊 Industry Alignment | Explicit professional connection — amplified by visits | During Contextualize |
| ❓ No Dumb Questions | 3-min pause: "What question are you embarrassed to ask?" | After Reframe, before Assemble |
| 💡 Pattern | Named and catalogued (e.g., "3-block FSM," "parameterized counter") | During I Do |
| 📜 Legacy Alert | Verilog-95 vs -2001 vs SV when it matters | As encountered |
| 🧠 How You Learn | Metacognitive moment: "What changed in your mental model today?" | End of Assemble, before Fortify |
| 🤖 Check the Machine | AI exercise — minimum one per session from D4 onward | During Fortify |

---

## Pre-Class Video Schedule

| Barcelona Session | Pre-Class Video(s) | Watch Time | Assigned |
|-------------------|--------------------|-----------:|----------|
| D1 (Mon 5/25) | V1: HDL Mindset | 40 min | Before arrival (online) |
| D2 (Tue 5/26) | V2: Data Types & Operators | 45 min | Mon evening |
| D3 (Wed 5/27) | V3: Combinational Logic | 45 min | Tue evening |
| D4 (Fri 5/29) | V4: Clocked Logic | 50 min | Thu evening (after Montserrat) |
| **D5+6 (Mon 6/1)** | **V5 + V6** | **100 min** | **Split over Sat/Sun weekend** |
| D7 (Tue 6/2) | V7: FSMs | 50 min | Mon evening |
| D8 (Wed 6/3) | V8: Hierarchy & Parameters | 50 min | Tue evening |
| D9 (Thu 6/4) | V9: Memory | 45 min | Wed evening |
| D10 (Mon 6/8) | V10: Timing & Numerical Architectures | 55 min | Over Fri–Sun weekend |
| D11 (Tue 6/9) | V11 + V12 (TX focus + RX conceptual) | 90 min | Split Mon evening + early Tue |
| D12 (Wed 6/10) | V13: SV Design | 45 min | Tue evening |
| D13 (Thu 6/11) | V14: SV Verification | 55 min | Wed evening |
| Build (Tue 6/16) | None — project work | — | — |
| Demo (Thu 6/18) | None | — | — |

**Total pre-class video: ~710 min (~11.8 hrs)** — unchanged from baseline, just rescheduled.

---

## Assessment

| Component | Weight | Notes |
|-----------|--------|-------|
| Lab exercises (12 sessions) | 35% | Quality over quantity; 12 graded lab sets |
| Final project | 35% | Increased weight to match independent work emphasis |
| Pre-class video quizzes | 10% | Unchanged |
| Participation + visit reflections | 10% | Includes 3 visit write-ups (CRAFT-aligned) |
| AI workflow portfolio | 10% | AI TB generations + corrections + reflections |

**Academic Visit Reflection Format (CRAFT-aligned, 1 page max):**

1. 🌍 **What did you see?** — Describe the technology or system
2. ⚠️ **What surprised you?** — What contradicted your expectations?
3. 🔧 **What connects?** — Which course concepts did you recognize?
4. 🔗 **What's next?** — How does this shift your thinking about your project or career?

---

## Cultural Activities as Informal CRAFT Touchpoints

Not graded, not forced — just seeds for organic conversation:

| Activity | Possible Connection |
|----------|---------------------|
| Sagrada Familia (Wed 5/27) | Parallel construction, modular repetition, systems thinking |
| Montserrat (Thu 5/28) | Funicular = state machine with safety interlocks |
| Cooking Workshop (Wed 6/3) | Recipe = sequential; kitchen with multiple cooks = parallel |
| Flamenco (Tue 6/9) | Rhythm structures (palos) = clock domains; improvisation within constraints |
| Park Güell (Wed 6/10) | Modular tile system = parameterized design; repeating with variation = `generate` |

---

## Summary: Baseline → Barcelona

| Dimension | Preserved | Compressed | Dropped | New |
|-----------|-----------|------------|---------|-----|
| D1–D4 foundations | ✅ | | | |
| D5 counters + D6 testbenches | | ✅ Merged → 1 session | | |
| D7 FSMs | ✅ | | | |
| D8 hierarchy/params | ✅ | | | |
| D9 memory | ✅ | | | |
| D10 timing/numerical | ✅ | | | |
| D11 UART TX | ✅ | | | |
| D12 UART RX + loopback | | ✅ RX → stretch | ❌ Loopback, SPI | |
| D13 SV Design | ✅ | | | |
| D14 SV Verification | ✅ | | | |
| D15+D16 Project | | ✅ 1 build + 1 demo | | |
| 3 highest-complexity projects | | | ❌ | |
| Academic visits | | | | ✅ 3 visits |
| Guest lecture | | | | ✅ RISC-V |
| CRAFT session template | | | | ✅ Every session |
| Visit reflections | | | | ✅ Assessment |
