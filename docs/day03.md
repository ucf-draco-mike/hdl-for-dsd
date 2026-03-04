# Day 3: Procedural Combinational Logic

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 3 of 16

---

## Student Learning Objectives

1. **SLO 3.1:** Write combinational logic using `always @(*)` blocks with correct use of blocking assignment (`=`).
2. **SLO 3.2:** Identify and prevent unintentional latch inference through default assignments and complete branches.
3. **SLO 3.3:** Explain the synthesis implications of `if/else` (priority mux chain) vs `case` (parallel mux) and choose appropriately.
4. **SLO 3.4:** Design a multi-operation ALU using `case` statement for opcode decoding.
5. **SLO 3.5:** Use `yosys show` and `yosys stat` to compare synthesized circuits (first PPA exposure).

---

## Pre-Class Video (~45 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The `always @(*)` block: wildcard sensitivity, `reg` in combinational contexts | 12 min | `video/day03_seg1_always_star.mp4` |
| 2 | `if/else` and `case`/`casez` statements | 15 min | `video/day03_seg2_if_else_case.mp4` |
| 3 | The latch problem: why it happens, how to prevent it | 12 min | `video/day03_seg3_latch_problem.mp4` |
| 4 | Blocking (`=`) vs. nonblocking (`<=`) — rule for combinational: use `=` | 6 min | `video/day03_seg4_blocking_vs_nonblocking.mp4` |

**Key concepts:**
- `always @(*)` + `=` = combinational logic — synthesis produces gates, not flip-flops
- Incomplete branches or missing defaults → Yosys infers latches (synthesis warning!)
- `if/else` creates a priority chain; `case` creates a parallel mux structure
- `casez` provides explicit don't-care matching for priority encoding

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up Q&A: Day 2 follow-up, pre-class questions | 5 min |
| 0:05 | Mini-lecture: latch detection, if/else vs case deep dive, ALU walkthrough | 35 min |
| 0:40 | Lab Exercise 1: Latch detection | 15 min |
| 0:55 | Lab Exercise 2: Priority encoder — if/else | 15 min |
| 1:10 | Lab Exercise 3: Priority encoder — casez | 10 min |
| 1:20 | Break | 5 min |
| 1:25 | Lab Exercise 4: Three-way synthesis comparison (PPA seed) | 10 min |
| 1:35 | Lab Exercise 5: 4-bit ALU | 25 min |
| 2:00 | Lab Exercise 6 (Stretch): Mixed ALU | 15 min |
| 2:15 | Debrief: synthesis comparison discussion | 10 min |
| 2:25 | Preview Day 4 | 5 min |

---

## In-Class Mini-Lecture (35 min) — expanded

### Latch Detection with Yosys (10 min)
- Live demo: synthesize buggy code with an incomplete `if` (no `else`) — observe the Yosys latch warning
- Use `yosys show` to visualize the inferred latch in the netlist — "this is not what you intended"
- Fix: default assignments at the top of `always` blocks, or ensure every branch is complete
- Rule: if Yosys says "latch," you have a bug. Always.

### `if/else` vs `case` — Synthesis Deep Dive (15 min)
- `if/else` → priority mux chain: each condition evaluated in order, later branches have longer combinational paths
- `case` → parallel mux: all branches evaluated simultaneously, tool selects by index
- **Live Yosys comparison:** Synthesize a priority encoder using `if/else`, then using `case`. Run `show` on both — inspect the generated circuits side by side on the projector.
- `casez` for don't-care matching — when priority IS intended, `casez` is explicit about it
- **Design heuristic:** Use `case` when all conditions are mutually exclusive (ALU opcodes, FSM states). Use `if/else` when priority matters (interrupt controllers, arbiters). Use `casez` for pattern matching with explicit don't-cares.
- **Timing implication preview:** Priority chains have longer worst-case paths — matters for Fmax. "We'll quantify this on Day 10."

### ALU Design Walkthrough (10 min)
- 4-bit ALU using `case` for opcode decode: ADD, SUB, AND, OR, XOR
- Walk through the code structure, discuss why `case` is natural for opcode decoding
- Mention `default` handling — what should the ALU output for undefined opcodes?

---

## Lab Exercises

### Exercise 1: Latch Detection (15 min)

**Objective (SLO 3.2):** Identify and fix latch inference in provided buggy code.

**Tasks:**
1. Download the provided `buggy_comb.v` file (or type in the buggy code from the handout).
2. Synthesize with Yosys. Find the latch warning in the output.
3. Use `yosys show` to visualize the latch in the netlist diagram.
4. Fix the code by adding a default assignment. Re-synthesize and confirm the latch warning is gone.
5. Try a second bug: `case` statement with a missing branch (no `default`). Observe, fix, and verify.

**Checkpoint:** Both buggy files synthesize latch-free after fixes. Student can explain why each fix works.

---

### Exercise 2: Priority Encoder — if/else (15 min)

**Objective (SLO 3.1, 3.3):** Implement a 4-input priority encoder using `if/else` chains.

**Tasks:**
1. Create `priority_enc.v` with `input [3:0] req` and `output reg [1:0] grant`.
2. Implement using `always @(*) begin ... end` with `if/else` chain: highest-numbered request wins.
3. Include a `valid` output that indicates whether any request is active.
4. Synthesize with Yosys and inspect the circuit using `show` — observe the priority mux chain.

**Checkpoint:** Priority encoder synthesizes cleanly (no latch warnings), produces correct output.

---

### Exercise 3: Priority Encoder — casez (10 min)

**Objective (SLO 3.3):** Re-implement the priority encoder using `casez` and compare the synthesis result.

**Tasks:**
1. Create `priority_enc_casez.v` using `casez(req)` with don't-care patterns: `4'b1???`, `4'b01??`, `4'b001?`, `4'b0001`.
2. Synthesize with Yosys and run `show`.
3. Compare visually: does the `casez` version look different from the `if/else` version? (They should be similar — both express priority.)

**Checkpoint:** `casez` version synthesizes and matches behavior of `if/else` version.

---

### Exercise 4: Three-Way Synthesis Comparison (10 min) — PPA seed

**Objective (SLO 3.5):** First hands-on PPA exposure — compare LUT counts across implementations.

**Tasks:**
1. You now have three versions of the same logic: `if/else`, `case` (non-priority), and `casez`.
2. Run `yosys stat` on each version. Record the LUT count for each in a simple table:

   | Implementation | LUTs |
   |----------------|------|
   | `if/else`      |      |
   | `case`         |      |
   | `casez`        |      |

3. Are they the same? Different? Why? (Brief discussion — full analysis comes on Day 10.)

**Checkpoint:** LUT counts recorded. Student can articulate at least one observation about the differences (or lack thereof).

> **Cross-cutting thread note:** This 10-minute exercise plants the seed for PPA analysis that becomes a major thread from Day 10 onward. Students will reference these numbers later.

---

### Exercise 5: 4-Bit ALU (25 min)

**Objective (SLO 3.1, 3.4):** Implement a multi-operation ALU — the first "real" design.

**Tasks:**
1. Create `alu.v` with inputs `a[3:0]`, `b[3:0]`, `opcode[2:0]` and output `result[3:0]`.
2. Implement at minimum: ADD (000), SUB (001), AND (010), OR (011), XOR (100).
3. Include a `default` case for undefined opcodes (output zero or hold — discuss the trade-off).
4. Create a top module wiring buttons to inputs and displaying the result on the 7-seg decoder from Day 2.
5. Program the Go Board and verify: manually test at least ADD, SUB, and AND.

**Checkpoint:** ALU on hardware. Multiple opcodes verified by changing button inputs and observing 7-seg output.

---

### Exercise 6 (Stretch): Mixed ALU with Overflow (15 min)

**Objective (SLO 3.3, 3.4):** Demonstrate appropriate mixed use of `case` and `if/else` in one module.

**Tasks:**
1. Extend the ALU with an `overflow` output flag.
2. Use `case` for opcode decoding (parallel — opcodes are mutually exclusive).
3. Use `if/else` within the ADD/SUB branches for overflow detection (priority — check sign bits in order).
4. Synthesize and compare with the base ALU using `yosys stat`.

---

## Deliverable

ALU running on hardware + screenshot comparing `yosys show` output for `if/else` vs `case` priority encoders.

**Submit:** ALU source file, top module, and synthesis comparison screenshot.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — Latch detection | 3.2 | Core |
| 2 — Priority encoder (if/else) | 3.1, 3.3 | Core |
| 3 — Priority encoder (casez) | 3.3 | Core |
| 4 — Synthesis comparison | 3.5 | Core |
| 5 — 4-bit ALU | 3.1, 3.4 | Core — graded deliverable |
| 6 — Mixed ALU | 3.3, 3.4 | Stretch (bonus) |

---

## Common Issues & Instructor Notes

- **Latch inference not understood:** Students may fix the warning without understanding why. Ask them: "What was the hardware trying to do? Why does a missing `else` create memory?" Connect it to the concept that hardware must always drive something — if you don't specify, it holds the old value.
- **`=` vs `<=` confusion:** This comes up again even though the pre-class video covers it. Reinforce: `always @(*)` + `=` = combinational. `always @(posedge clk)` + `<=` = sequential. Day 4 goes deep on this.
- **Priority encoder all-zero input:** Students often forget to handle the case where no request is active. The `valid` output addresses this — good time to discuss "what should hardware do with invalid inputs?"
- **`case` vs `casez` nuance:** Some students will think `casez` is always better. Clarify: `casez` treats `z` and `?` in the case items as don't-cares, which is powerful but can mask bugs if used carelessly. `case` is safer when inputs are fully determined.
- **ALU `default` debate:** Students will ask what the ALU should output for unused opcodes. Good discussion: zero? Previous value (latch!)? A specific error pattern? There's no single right answer, but "whatever you choose, be intentional about it."
- **Yosys `show` on larger designs:** The `show` command can produce overwhelming diagrams. Teach students to synthesize small modules in isolation for clear comparison — don't try to `show` the entire top module.

### Cross-Cutting Thread: PPA Analysis
**First exposure.** Exercise 4 is brief but intentional — students record LUT counts for three synthesis variants. This data point is referenced on Day 8 (resource scaling with parameterization) and becomes a structured exercise on Day 10.

---

## Preview: Day 4

Sequential logic — flip-flops, clocks, counters, and the crucial `<=` nonblocking assignment. Everything so far has been combinational (outputs depend only on current inputs). Tomorrow, your circuits gain memory. Watch the Day 4 video (~50 min).
