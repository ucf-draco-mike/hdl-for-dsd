# Day 10: Numerical Architectures & Design Trade-offs

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 10 of 16

---

## Student Learning Objectives

1. **SLO 10.1:** Compare adder architectures (ripple-carry, behavioral `+`, carry-lookahead concept) and explain their PPA trade-offs.
2. **SLO 10.2:** Implement a sequential shift-and-add multiplier and explain when sequential multiplication is preferable to combinational.
3. **SLO 10.3:** Implement fixed-point (Q-format) arithmetic and handle bit growth in multiplication.
4. **SLO 10.4:** Perform structured PPA analysis: measure LUTs, FFs, and Fmax across design variants using `yosys stat` and `nextpnr`.
5. **SLO 10.5:** Read a nextpnr timing report and identify whether timing constraints are met.
6. **SLO 10.6:** Articulate the PPA trade-off triangle: performance vs. power vs. area, and why optimizing all three simultaneously is impossible.

---

## Pre-Class Video (~55 min) ★ Revised lecture

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Timing & constraints essentials: setup/hold, critical path, nextpnr reports | 15 min | `video/day10_seg1_timing_essentials.mp4` |
| 2 | Numerical architecture trade-offs: adders, multipliers, `+` and `*` operators | 20 min | `video/day10_seg2_numerical_architectures.mp4` |
| 3 | PPA — Performance, Power, Area: the three axes of digital design | 15 min | `video/day10_seg3_ppa_intro.mp4` |
| 4 | OpenROAD/OpenLane: open-source ASIC PPA (aspirational context) | 5 min | `video/day10_seg4_asic_ppa_context.mp4` |

**Segment 2 key points:**
- Ripple-carry (Day 2 review) → carry-lookahead (concept) → the `+` operator (what does the tool build?)
- Writing `assign sum = a + b;` lets the tool choose the architecture — understanding the choice is the designer's job
- Multiplication: shift-and-add → why `*` on iCE40 uses pure LUT logic (no DSP blocks)
- Fixed-point Q-format: Q4.4 = 4 integer + 4 fractional bits

**Segment 3 key points:**
- FPGA PPA proxies: Fmax (performance), LUT/FF count (area), toggle rate × capacitance (power, conceptual)
- ASIC PPA: gate count, standard cells, process node, leakage
- The trade-off triangle: pipelining helps Fmax but costs FFs; parallelism costs area
- `if/else` vs `case` revisited from PPA perspective

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: pre-class questions, timing concepts check | 5 min |
| 0:05 | Mini-lecture: timing, numerical demo, PPA thinking | 30 min |
| 0:35 | Lab Exercise 1: Adder architecture comparison | 30 min |
| 1:05 | Lab Exercise 2: Shift-and-add multiplier | 30 min |
| 1:35 | Break | 5 min |
| 1:40 | Lab Exercise 3: Fixed-point exercise | 20 min |
| 2:00 | Lab Exercise 4: Timing constraint exercise | 10 min |
| 2:10 | Lab Exercise 5 (Stretch): PLL / CDC | 10 min |
| 2:20 | Wrap-up and Day 11 preview | 10 min |

---

## In-Class Mini-Lecture (30 min)

### Quick Timing Check (5 min)
- Read a nextpnr timing report together
- Key line: "Max frequency for clock 'clk': XX.XX MHz (PASS at 25.00 MHz)"
- What's the critical path? Where does delay accumulate?

### Numerical Architectures Live Demo (15 min)
- Synthesize `assign sum = a + b;` at 4-bit, 8-bit, 16-bit, 32-bit widths
- Run `yosys stat` for each — plot LUT count vs. width (should be roughly linear)
- Synthesize `assign product = a * b;` at 4-bit, 8-bit — **show the LUT explosion** (quadratic growth, no DSP blocks on iCE40)
- Compare: `a + b` vs. `a + b + c` — does the tool chain adders or use something smarter?
- Inspect with `yosys show`: what does the synthesized adder actually look like?

### PPA Thinking (10 min)
- Design decision framework: "For this application, do I care more about Fmax, area, or power?"
- FPGA vs. ASIC: on FPGA, LUTs are fixed-size so "area" is really "LUT utilization"; on ASIC, a 2-input gate is physically smaller than a 4-input gate
- Real example: a 32-bit multiplier on iCE40 HX1K uses ~30% of available LUTs; on 28nm ASIC, it's a tiny fraction
- **Brief aside:** "The PPA habits you build with `yosys stat` transfer directly to ASIC flows like OpenROAD/OpenLane."

---

## Lab Exercises

### Exercise 1: Adder Architecture Comparison (30 min)

**Objective (SLO 10.1, 10.4):** Compare manual and behavioral adder implementations using PPA metrics.

**Tasks:**
1. **Manual ripple-carry adder:** Chain full-adder instances (reuse Day 2 code) at 8-bit and 16-bit widths.
2. **Behavioral adder:** `assign sum = a + b;` at the same widths.
3. For each variant and width, record:
   - LUT count (`yosys stat`)
   - Schematic structure (`yosys show`)
   - Fmax (`nextpnr` timing report)
4. Fill in a comparison table:

| Variant | Width | LUTs | FFs | Fmax (MHz) |
|---------|-------|------|-----|------------|
| Ripple-carry | 8 | | | |
| Ripple-carry | 16 | | | |
| Behavioral `+` | 8 | | | |
| Behavioral `+` | 16 | | | |

5. **Analysis question:** Does the synthesis tool produce the same circuit for both? When would you manually implement an adder instead of using `+`?

**Checkpoint:** Comparison table filled in with real data. At least one observation about the results.

---

### Exercise 2: Shift-and-Add Multiplier (30 min)

**Objective (SLO 10.2, 10.4):** Implement a sequential multiplier and compare to combinational.

**Tasks:**
1. Implement an 8-bit unsigned shift-and-add multiplier:
   - FSM controls the operation (IDLE → COMPUTE → DONE)
   - Shift register holds the multiplier, accumulator holds the partial product
   - Takes up to 8 clock cycles to complete
2. Write a testbench: verify at least 10 test cases including 0×N, N×0, 1×N, max×max.
3. Synthesize the sequential multiplier. Record LUTs, FFs, Fmax.
4. Synthesize `assign product = a * b;` (8-bit, combinational). Record LUTs, FFs, Fmax.
5. Compare:

| Variant | LUTs | FFs | Fmax | Latency |
|---------|------|-----|------|---------|
| Shift-and-add (sequential) | | | | 8 cycles |
| Behavioral `*` (combinational) | | | | 1 cycle |

6. **Discussion:** When would you choose sequential over combinational? (High area pressure, relaxed latency requirements.)

**Checkpoint:** Working multiplier. Comparison table with both variants.

---

### Exercise 3: Fixed-Point Arithmetic (20 min)

**Objective (SLO 10.3):** Handle the practical challenges of fixed-point computation.

**Tasks:**
1. Implement a Q4.4 fixed-point adder: two 8-bit inputs (4 integer, 4 fractional), 9-bit output (with carry).
2. Implement a Q4.4 fixed-point multiplier: two 8-bit inputs → 16-bit product (Q8.8).
   - **Key challenge:** The product of two Q4.4 numbers is Q8.8 — you need to extract the right bits for the integer part.
3. Drive the integer part of the result to the 7-seg display.
4. Test with known values: e.g., 2.5 × 3.0 = 7.5 → integer part = 7 on display.

**Checkpoint:** Fixed-point multiplication gives correct integer result on 7-seg.

---

### Exercise 4: Timing Constraint Exercise (10 min)

**Objective (SLO 10.5):** Practice reading timing reports.

**Tasks:**
1. Add a timing constraint to an existing design (e.g., the shift-and-add multiplier).
2. Synthesize with nextpnr. Read the timing report.
3. Does timing pass at 25 MHz? At 50 MHz? At 100 MHz?
4. Identify what limits Fmax in your design.

**Checkpoint:** Timing report read and Fmax identified.

---

### Exercise 5 (Stretch): PLL & CDC (10 min)

**Objective (SLO 10.5):** Explore clock generation and domain crossing.

**Tasks:**
1. Instantiate `SB_PLL40_CORE` to generate a different frequency from 25 MHz.
2. Build a 2-FF synchronizer to pass a signal between the two clock domains.

---

## Deliverable

1. Adder/multiplier PPA comparison table with real data (LUTs, FFs, Fmax for each variant).
2. Working shift-and-add multiplier on the FPGA.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — Adder comparison | 10.1, 10.4 | Core |
| 2 — Shift-and-add multiplier | 10.2, 10.4 | Core |
| 3 — Fixed-point | 10.3 | Core |
| 4 — Timing constraints | 10.5 | Core |
| 5 — PLL / CDC | 10.5 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> Day 10 is about numerical architectures and your first structured PPA analysis. Understanding the trade-offs here is directly relevant to your final project.

- **Behavioral `+` is just as good as my ripple-carry adder?** Often yes — and that's the point. Yosys optimizes behavioral operators aggressively. A hand-built ripple-carry adder may use the same or more LUTs than `assign sum = a + b;`. The lesson: let the tool work for you, but understand what it produces so you can make informed decisions when it matters.
- **Shift-and-add multiplier FSM is complex — where do I start?** Draw the block diagram first: FSM controller, shift register (for the multiplier), accumulator (for the partial product), and a bit counter. Label the connections between them. Then code each block separately before wiring them together.
- **Fixed-point: extracting the wrong bits?** For Q8.8 multiplication (8 integer bits, 8 fractional bits), the full product is 32 bits wide. The integer result is in bits [23:16], not [31:24] or [15:8]. Draw out the bit positions on paper — label the integer and fractional portions — before writing the extraction code.
- **Where do I find the timing report?** After `nextpnr` runs, look for the "Max frequency" line in the output and the critical path description. The path name tells you which flip-flops are at the start and end of the longest combinational delay.

### 🔗 Bigger Picture

This is the anchor day for PPA analysis. The comparison tables you build in today's exercises establish the exact format you'll use in your final project PPA report (Days 15–16).
---

## Preview: Day 11

UART TX — your first real communication interface. Everything from Weeks 1–2 comes together: FSMs, counters, shift registers, and testbenches, all combined to send data from the Go Board to your PC.
