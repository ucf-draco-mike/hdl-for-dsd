# Day 8: Hierarchy, Parameters, Generate & Design Reuse

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 8 of 16

---

## Student Learning Objectives

1. **SLO 8.1:** Use named port connections and parameter overrides to instantiate and configure reusable modules.
2. **SLO 8.2:** Design parameterized modules using `parameter` and explain when parameterization is appropriate.
3. **SLO 8.3:** Use `generate for` and `generate if` to replicate hardware and conditionally include features.
4. **SLO 8.4:** Build a hierarchical top-level module that integrates multiple parameterized sub-modules.
5. **SLO 8.5:** Use AI to generate testbenches for parameterized modules and evaluate whether AI correctly handles parameter overrides and width-dependent edge cases.
6. **SLO 8.6:** Record and compare `yosys stat` resource utilization across parameter configurations (PPA thread).

---

## Pre-Class Video (~50 min) ★ Revised lecture

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Module instantiation: positional vs. named ports (always use named!) | 10 min | `video/day08_seg1_instantiation.mp4` |
| 2 | `parameter` and `localparam`: making modules reusable | 12 min | `video/day08_seg2_parameters.mp4` |
| 3 | `generate` blocks: `for`-generate, `if`-generate, hardware replication | 13 min | `video/day08_seg3_generate.mp4` |
| 4 | Recursive generate patterns: conditional features, nested structures ★ | 10 min | `video/day08_seg4_recursive_generate.mp4` |
| 5 | Design for reuse: building a personal Verilog library | 5 min | `video/day08_seg5_design_reuse.mp4` |

**Segment 4 key points (new content):**
- `generate if` for conditional feature inclusion (e.g., optional parity, configurable pipeline depth)
- Nested `generate for` for 2D structures (e.g., array of processing elements)
- The "recursive module" pattern: a module that instantiates itself with different parameters (tree adder preview)

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: hierarchy questions, pre-class review | 5 min |
| 0:05 | Mini-lecture: parameterization, generate, PPA seed | 30 min |
| 0:35 | Lab Exercise 1: Parameterized N-bit counter | 20 min |
| 0:55 | Lab Exercise 2: AI-assisted parameterized TB | 25 min |
| 1:20 | Break | 5 min |
| 1:25 | Lab Exercise 3: Generate-based LED driver | 20 min |
| 1:45 | Lab Exercise 4: Hierarchical top module | 25 min |
| 2:10 | Lab Exercise 5: Resource comparison | 5 min |
| 2:15 | Lab Exercise 6 (Stretch): Parameterized LFSR | 10 min |
| 2:25 | Wrap-up and Day 9 preview | 5 min |

---

## In-Class Mini-Lecture (30 min)

### Hierarchy as the Key to Complexity (5 min)
- Top-down vs. bottom-up design approaches
- Named port connections: `.port_name(signal_name)` — always, no exceptions
- The difference between `parameter` (overridable from outside) and `localparam` (internal constants)

### Parameterization Philosophy (10 min)
- **What to parameterize:** width, depth, timing thresholds, feature enables
- **What not to parameterize:** fundamental architecture choices, protocol definitions
- `#(.WIDTH(8))` override syntax
- Live demo: parameterized N-bit counter, instantiated at WIDTH=4, 8, 16, 32

### Generate Blocks (10 min)
- `generate for`: compile-time loop that replicates hardware
- `generate if`: conditional hardware inclusion — "same RTL, different hardware"
- Think of `generate` as **instantiation automation**, not a runtime loop
- Live demo: `generate for` to create N instances of a blink module

### PPA Seed (5 min)
- After synthesizing the parameterized counter at WIDTH=4, 8, 16, 32:
  - Run `yosys stat` for each configuration
  - Show the resource scaling: how does LUT count grow with width?
  - "Is it linear? What would this look like in an ASIC?"
- Plant the question — answer it fully on Day 10

---

## Lab Exercises

### Exercise 1: Parameterized N-Bit Counter (20 min)

**Objective (SLO 8.1, 8.2):** Build a reusable counter module that can be instantiated at any width.

**Tasks:**
1. Create a parameterized counter module with:
   - `parameter WIDTH = 8`
   - Synchronous reset, enable, rollover output
2. Instantiate as 8-bit, 16-bit, and 24-bit in a test top module.
3. Simulate all three instances in a single testbench. Verify rollover at the correct value for each width.

**Checkpoint:** Three counter instances, each rolling over at their respective max values.

---

### Exercise 2: AI-Assisted TB for Parameterized Modules (25 min)

**Objective (SLO 8.5):** Use AI to generate a testbench that handles multiple parameter configurations.

**Tasks:**
1. **Write a prompt** specifying:
   - Counter module interface (with `parameter WIDTH`)
   - Request: test the counter at WIDTH=4, WIDTH=8, and WIDTH=16 in a single testbench
   - Required checks: reset, count-up, rollover at `2^WIDTH - 1`, enable toggling
2. **Generate** the testbench using AI.
3. **Evaluate** the AI output. Key questions:
   - Does the AI correctly use `#(.WIDTH(N))` parameter overrides?
   - Does it test rollover at the right value for each width (not hardcoded)?
   - Does it handle the different counter ranges properly?
4. **Correct** and annotate any issues.
5. **Run** the corrected testbench.

**Deliverable for this exercise:** Prompt + corrected AI TB with annotations.

**Checkpoint:** AI-generated TB correctly tests 3 width configurations.

---

### Exercise 3: Generate-Based LED Driver (20 min)

**Objective (SLO 8.3):** Use `generate for` to replicate parameterized instances.

**Tasks:**
1. Create a parameterized blink module: takes `parameter HALF_PERIOD` and toggles an output.
2. Use `generate for` to instantiate 4 blink modules, each with a different `HALF_PERIOD`, driving the 4 Go Board LEDs.
3. Result: 4 LEDs blinking at 4 different rates from a single `generate` block.
4. Synthesize and program.

**Checkpoint:** Four LEDs blinking at visibly different rates on the Go Board.

---

### Exercise 4: Hierarchical Top Module (25 min)

**Objective (SLO 8.4):** Integrate multiple modules into a clean hierarchical design.

**Tasks:**
1. Create a top module that instantiates:
   - Debouncer (from Day 5) for each button
   - Parameterized counter (from Exercise 1) — width controlled by buttons
   - 7-segment decoder (from Day 2)
   - LED blink generators (from Exercise 3)
2. Wire everything together using named port connections.
3. The design should have at least 3 levels of hierarchy.
4. Synthesize and program the Go Board.

**Checkpoint:** Hierarchical design running on hardware with button-controlled counter displayed on 7-seg.

---

### Exercise 5: Resource Comparison (5 min)

**Objective (SLO 8.6):** Build PPA analysis habits by recording resource utilization.

**Tasks:**
1. Run `yosys stat` on the hierarchical design from Exercise 4.
2. Record: LUTs, FFs, and EBR counts.
3. Change the counter WIDTH parameter — does the resource count change as expected?

**Checkpoint:** Resource counts recorded. You'll reference these on Day 10.

---

### Exercise 6 (Stretch): Parameterized LFSR with Generate (10 min)

**Objective (SLO 8.2, 8.3):** Combine parameterization and generate for a configurable pseudo-random generator.

**Tasks:**
1. Implement a parameterized LFSR where the feedback polynomial is configured via `generate if` based on WIDTH (e.g., different taps for 4-bit, 8-bit, 16-bit).
2. Verify each configuration produces a maximal-length sequence.

---

## Deliverable

1. Hierarchical design with 3+ levels of hierarchy running on the Go Board.
2. AI-generated parameterized testbench with annotated corrections.
3. `yosys stat` resource snapshot for the hierarchical design.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — Parameterized counter | 8.1, 8.2 | Core |
| 2 — AI-assisted parameterized TB | 8.5 | Core |
| 3 — Generate-based LED driver | 8.3 | Core |
| 4 — Hierarchical top module | 8.4 | Core |
| 5 — Resource comparison | 8.6 | Core |
| 6 — Parameterized LFSR | 8.2, 8.3 | Stretch (bonus) |

---

## Common Issues & Instructor Notes

- **Positional vs. named ports:** Students may try positional connections for speed. Insist on named — the bugs from misordered ports are painful and instructive.
- **Generate scope:** Remind students that `generate for` requires a `genvar` declaration and a named `begin:` block. Icarus gives cryptic errors without these.
- **AI and parameter overrides:** This is often where AI stumbles — it may hardcode rollover values instead of computing `2**WIDTH - 1`. High-value teaching moment.
- **Resource scaling insight:** Students often expect LUT count to exactly double with WIDTH. It's close but not exact — synthesis optimization makes it interesting.

### Cross-Cutting Threads

- **AI Verification (Day 2 of thread):** Students now prompt for parameterized modules. The evaluation question shifts from "does it work?" to "does it handle configuration correctly?"
- **PPA Analysis:** Exercise 5 is brief but intentional — builds the habit of running `yosys stat` after every synthesis. Referenced on Day 10.

---

## Preview: Day 9

Memory — RAM, ROM, and Block RAM. You'll model memory in Verilog, use `$readmemh` to initialize from files, and learn how to write Verilog that Yosys maps to the iCE40's Block RAM resources.
