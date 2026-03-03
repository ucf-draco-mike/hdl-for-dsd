# Day 14: Verification Techniques, AI-Driven Testing & PPA Analysis

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 14 of 16

---

## Student Learning Objectives

1. **SLO 14.1:** Write immediate assertions (`assert`, `$error`, `$fatal`) to embed executable specifications directly in RTL.
2. **SLO 14.2:** Implement constraint-based UART parity using `generate if` and parameters, demonstrating conditional feature inclusion.
3. **SLO 14.3:** Write constraint specifications for AI-driven testbench generation and critically evaluate the resulting coverage.
4. **SLO 14.4:** Perform structured PPA analysis across design variants, producing a comparison table with LUTs, FFs, and Fmax.
5. **SLO 14.5:** Articulate design trade-offs in a written PPA report, connecting resource costs to architectural decisions.
6. **SLO 14.6:** Describe the verification maturity scale (manual → self-checking → AI-scaffolded → assertion-enhanced → coverage-driven) and place their own skills on it.

---

## Pre-Class Video (~55 min) ★ Revised lecture

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Assertions — executable specifications: `assert`, `$error`, `$fatal`, concurrent assertions | 12 min | `video/day14_seg1_assertions.mp4` |
| 2 | AI-driven verification workflows: constraint-based stimulus, prompt engineering for complex TBs | 15 min | `video/day14_seg2_ai_verification_workflows.mp4` |
| 3 | PPA analysis methodology: structured reporting, FPGA vs. ASIC context, design-space exploration | 12 min | `video/day14_seg3_ppa_methodology.mp4` |
| 4 | Coverage & the road ahead: `covergroup`, `coverpoint`, interfaces, industry verification landscape | 11 min | `video/day14_seg4_coverage_road_ahead.mp4` |

**Segment 1 key points:**
- Immediate assertions: inline checks that fire when a condition is violated during simulation
- Concurrent assertions (brief): `assert property`, sequence syntax, `|->` implication operator
- Assertions as executable documentation — catching bugs at the source rather than in waveforms

**Segment 2 key points:**
- Verification productivity stack: manual → self-checking → AI-scaffolded → assertion-enhanced → coverage-driven
- Constraint-based stimulus: defining legal input ranges, using `$urandom_range()` for bounded random testing
- Writing a constraint spec in comments, then having AI generate the stimulus loop
- Industry context: AI-assisted verification is increasingly common for TB scaffolding and coverage analysis

**Segment 3 key points:**
- FPGA PPA report template: resource table, Fmax, utilization percentage
- ASIC context: gate count, wire delay, process node impact, Liberty files, standard cells
- Design-space exploration: synthesize same module at different parameters, plot area/timing curves
- OpenROAD/OpenLane reminder: open-source ASIC PPA for the same Verilog

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: verification maturity discussion, pre-class questions | 5 min |
| 0:05 | Mini-lecture: assertions demo, AI constraint-based TB, PPA walkthrough | 30 min |
| 0:35 | Lab Exercise 1: Assertion-enhanced UART TX | 25 min |
| 1:00 | Lab Exercise 2: Constraint-based UART parity extension | 20 min |
| 1:20 | Break | 5 min |
| 1:25 | Lab Exercise 3: AI constraint-based TB for project module | 25 min |
| 1:50 | Lab Exercise 4: PPA analysis exercise | 25 min |
| 2:15 | Lab Exercise 5: Project work time | 10 min |
| 2:25 | Wrap-up and Day 15 preview | 5 min |

> **Instructor note:** This is the tightest day in the course. Exercise 2 (parity extension) has an **escape valve**: students who are behind on their final project may skip it and use the time for Exercises 3–4 or project work. Parity can be completed as homework.

---

## In-Class Mini-Lecture (30 min)

### Assertions Quick-Start (10 min)
- Live demo: add immediate assertions to UART TX
  - `assert (tx_out == 1'b1) else $error("TX should idle high");`
  - Assertion on `busy` consistency: can't accept new data while busy
  - Assertion on bit index: `assert (bit_idx < 8) else $fatal("Bit index overflow");`
- Inject a bug (e.g., wrong idle polarity), re-run — show assertion catching it instantly
- "Assertions tell you *what* broke and *where*. Waveforms tell you *how* it looks. Assertions are faster."

### AI Constraint-Based TB Demo (10 min)
- Prompt AI to generate a constrained-random testbench for the ALU:
  - "Test all opcodes with random operands in [0, 2^WIDTH-1]. For ADD/SUB, ensure at least 10 cases each of: no overflow, overflow, zero result, max result. Include a self-checking scoreboard. Use `$urandom_range()`."
- Review the output together: Does it actually cover the corner cases? Does it count coverage?
- Fix and run
- **Key question to class:** "How do you know when testing is *done*?" — leads into coverage concepts from pre-class video

### PPA Analysis Walkthrough (10 min)
- Take the shift-and-add multiplier (Day 10) and the behavioral `*` version
- Run `yosys stat` and `nextpnr` on both
- Build a PPA comparison table on the board:

  | Variant | LUTs | FFs | Fmax | Latency |
  |---------|------|-----|------|---------|
  | Sequential `*` | | | | 8 cycles |
  | Behavioral `*` | | | | 1 cycle |

- "This is the format your final project PPA report should follow."

---

## Lab Exercises

### Exercise 1: Assertion-Enhanced UART TX (25 min)

**Objective (SLO 14.1):** Embed executable specifications into an existing design.

**Tasks:**
1. Open your UART TX module (Verilog or SV version).
2. Add at least 5 immediate assertions:
   - TX line idles high when not transmitting
   - `tx_busy` is asserted during the entire transmission frame
   - Bit index stays within [0, 7] during DATA state
   - Start bit is 0, stop bit is 1
   - No new `tx_start` accepted while `tx_busy` is asserted
3. Run the existing UART TX testbench. All assertions should pass.
4. **Intentionally inject a bug** (e.g., swap start/stop polarity, allow bit index overflow). Re-run. Verify the relevant assertion catches the bug with a clear error message.
5. Fix the bug, re-run, confirm all assertions pass.

**Checkpoint:** 5+ assertions added. At least one bug injected and caught by assertions.

---

### Exercise 2: Constraint-Based UART Parity Extension (20 min)

**Objective (SLO 14.2, 14.4):** Implement conditional hardware using `generate if` and measure its PPA cost.

> **Escape valve:** Students behind on their final project may skip this exercise and use the time for Exercises 3–4. Parity can be completed as homework.

**Tasks:**
1. Add configurable parity to UART TX:
   - `parameter PARITY_EN = 0` (0 = no parity, 1 = parity bit included)
   - `parameter PARITY_TYPE = 0` (0 = even, 1 = odd)
2. Use `generate if (PARITY_EN) begin : gen_parity ... end` to conditionally include parity logic:
   - When `PARITY_EN=1`: TX frame becomes start + 8 data + parity + stop (10-bit frame → 11 bits with parity)
   - Parity calculation: XOR reduction of data byte (even parity), inverted for odd
3. Simulate both configurations:
   - `PARITY_EN=0`: standard 10-bit frame (verify existing TB still passes)
   - `PARITY_EN=1, PARITY_TYPE=0`: 11-bit frame with even parity (write a brief TB extension)
4. Synthesize both configurations. Run `yosys stat`:

   | Configuration | LUTs | FFs |
   |---------------|------|-----|
   | `PARITY_EN=0` | | |
   | `PARITY_EN=1` | | |

5. **Discussion:** How many extra LUTs does parity cost? Is it significant relative to the total design?

**Checkpoint:** Both configurations simulate correctly. PPA comparison documented.

> **Cross-cutting thread note:** This exercise bridges the constraint-based design concept from Day 12's pre-class video with today's PPA analysis theme.

---

### Exercise 3: AI Constraint-Based TB for Project Module (25 min)

**Objective (SLO 14.3, 14.6):** Apply AI-driven verification to your own final project design.

**Tasks:**
1. **Write a constraint specification** for your final project's core module. Include:
   - Module name and complete port list (with types and widths)
   - Behavioral specification: what the module should do
   - Input constraints: legal ranges, relationships between signals, timing requirements
   - Corner cases to test: boundary values, error conditions, resets mid-operation
   - Coverage goals: "Test at least N cases of [scenario]"
2. **Generate** the testbench using AI from your constraint spec.
3. **Review and correct:**
   - Does the AI handle your module's specific parameters correctly?
   - Are the random ranges appropriate for your input widths?
   - Does it test the corner cases you specified?
   - Are there timing or syntax issues?
4. **Run** the corrected testbench.
5. **Document coverage gaps:** After running, are there scenarios you specified that the AI didn't test well? Note them.

**Deliverable for this exercise:** Constraint specification + AI output + corrected TB + brief coverage analysis (what was tested, what was missed).

**Checkpoint:** AI-generated TB runs against project module. At least 3 annotations explain corrections made.

---

### Exercise 4: PPA Analysis Exercise (25 min)

**Objective (SLO 14.4, 14.5):** Produce a structured PPA analysis — the same format required for the final project.

**Tasks:**
1. Pick 2–3 modules from your course library (e.g., ALU, counter, UART TX, parity-enabled UART TX).
2. For each module, synthesize at 2+ parameter configurations (e.g., different WIDTH values, features enabled/disabled).
3. Record for each configuration:
   - LUT count (`yosys stat`)
   - FF count (`yosys stat`)
   - Fmax (`nextpnr` timing report)
4. Fill in a PPA comparison table:

   | Module | Configuration | LUTs | FFs | Fmax (MHz) |
   |--------|---------------|------|-----|------------|
   | Counter | WIDTH=8 | | | |
   | Counter | WIDTH=16 | | | |
   | Counter | WIDTH=32 | | | |
   | UART TX | PARITY_EN=0 | | | |
   | UART TX | PARITY_EN=1 | | | |

5. **Write a brief PPA discussion** (1 paragraph per module):
   - How does area scale with the parameter?
   - Is the scaling linear, quadratic, or something else?
   - What is the Fmax impact of increasing width/features?
   - What trade-off would you make for a real application?

**Deliverable for this exercise:** PPA analysis table + 1-page design trade-off discussion.

**Checkpoint:** Table populated with real data. At least 2 paragraphs of trade-off analysis.

---

### Exercise 5: Project Work Time (10 min)

**Objective:** Apply today's techniques to the final project.

**Tasks:**
1. Add at least 2 assertions to a final project module.
2. Plan your project's PPA report: which modules will you compare? Which parameters?
3. Note any blockers for the Day 15 build session.

> Day 15 provides 2.25 hours of dedicated project time.

---

### Exercise 6 (Stretch): Interface-Based TB Refactoring

**Objective (SLO 14.6):** Explore SV `interface` and `modport` for cleaner testbench organization.

**Tasks:**
1. Define a SystemVerilog `interface` for the UART signals (tx, rx, data, valid, busy).
2. Use `modport` to separate driver and monitor views.
3. Refactor the UART testbench to use the interface.

---

## Deliverable

1. **Assertion-enhanced UART TX** with 5+ assertions and bug injection demonstration.
2. **Parity-parameterized UART TX** with PPA comparison (if not using escape valve).
3. **AI constraint-based testbench** for final project module with annotated corrections and coverage analysis.
4. **PPA analysis report** — comparison table with trade-off discussion.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — Assertion-enhanced UART | 14.1 | Core |
| 2 — Parity extension + PPA | 14.2, 14.4 | Core (escape valve available) |
| 3 — AI constraint-based TB | 14.3, 14.6 | Core |
| 4 — PPA analysis report | 14.4, 14.5 | Core |
| 5 — Project work | — | Participation |
| 6 — Interface-based TB | 14.6 | Stretch (bonus) |

---

## Common Issues & Instructor Notes

- **Assertion syntax in iverilog:** Icarus Verilog supports immediate assertions with `-g2012` but has limited support for concurrent/property-based assertions. Keep students focused on immediate assertions for this exercise.
- **`generate if` scope confusion:** Students may struggle with the named `begin : gen_parity` block. Remind them: generate blocks create scope — signals inside are accessed as `gen_parity.signal_name` from outside (though they usually shouldn't need to).
- **Parity timing:** The parity bit adds one bit period to the frame. Students must update the FSM to include a PARITY state between DATA and STOP. Common bug: forgetting to adjust the bit counter.
- **AI coverage gaps:** The most valuable part of Exercise 3 is often discovering what the AI *didn't* test. Students who identify specific gaps score higher than those who accept the AI output without critique.
- **PPA report quality:** Emphasize that numbers alone aren't sufficient — the analysis paragraph explaining *why* the numbers look the way they do is what demonstrates understanding.
- **Time management:** This is the tightest day. Monitor Exercise 2 closely — invoke the escape valve early if students are struggling. Exercises 3 and 4 are higher priority for the final project.

### Cross-Cutting Thread Convergence

This is the day where all four cross-cutting threads converge:
- **AI Verification (Day 4 of thread):** Students write independent constraint specs and generate TBs for their own project modules.
- **PPA Analysis:** Structured comparison exercise with the same format as the final project report.
- **Constraint-Based Design:** The parity extension brings the Day 12 concept to implementation.
- **Verification Maturity:** Students can now place themselves on the manual → coverage-driven scale.

---

## Preview: Day 15

Build day — 2.25 hours of dedicated project work time. Come prepared with your project plan, any modules still in progress, and a testing strategy. Day 15 deliverable: working prototype + testbench + PPA snapshot. Day 16: live demos.
