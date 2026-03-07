# Day 13: SystemVerilog for Design

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 13 of 16

---

## Student Learning Objectives

1. **SLO 13.1:** Use `logic` instead of `wire`/`reg` and explain why this eliminates a major class of declaration errors.
2. **SLO 13.2:** Write sequential logic with `always_ff` and combinational logic with `always_comb`, leveraging their built-in safety checks.
3. **SLO 13.3:** Implement FSMs using `enum` for named states with automatic width and debug printing (`.name()`).
4. **SLO 13.4:** Use `typedef` and `struct` to group related signals for cleaner module interfaces.
5. **SLO 13.5:** Verify that SystemVerilog refactoring produces identical synthesized hardware using PPA comparison.

---

## Pre-Class Video (~45 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Why SystemVerilog? Evolution from Verilog-2001, IEEE 1800 standard | 8 min | `video/day13_seg1_why_sv.mp4` |
| 2 | `logic` replaces `wire` and `reg` — one type to rule them all | 8 min | `video/day13_seg2_logic_type.mp4` |
| 3 | `always_ff`, `always_comb`, `always_latch` — intent-based always blocks | 12 min | `video/day13_seg3_always_blocks.mp4` |
| 4 | `enum` for FSM states: named states, `.name()` for debug | 10 min | `video/day13_seg4_enum_fsm.mp4` |
| 5 | `struct`, `typedef`, `package`, `import`: grouping and sharing definitions | 7 min | `video/day13_seg5_struct_package.mp4` |

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: SV motivation, pre-class questions | 5 min |
| 0:05 | Mini-lecture: SV side-by-side comparison, PPA note | 30 min |
| 0:35 | Lab Exercise 1: Refactor traffic light FSM to SV | 30 min |
| 1:05 | Lab Exercise 2: Refactor UART TX to SV | 30 min |
| 1:35 | Break | 5 min |
| 1:40 | Lab Exercise 3: Simulate both versions | 15 min |
| 1:55 | Lab Exercise 4: PPA comparison | 10 min |
| 2:05 | Lab Exercise 5 (Stretch): Package creation | 15 min |
| 2:20 | Wrap-up and Day 14 preview | 10 min |

---

## In-Class Mini-Lecture (30 min)

### Side-by-Side: Verilog vs. SystemVerilog (15 min)
- Show the same module in both languages — highlight every difference
- `logic` eliminates the `wire` vs. `reg` question entirely
- `always_comb` catches missing assignments at compile time — no more accidental latches
- `always_ff @(posedge clk)` enforces edge-triggered semantics — compiler warns if you try combinational logic inside it
- **Key message:** SV is about designer productivity and safety, not different hardware

### Enum FSMs (10 min)
- Verilog way: `localparam IDLE = 2'b00, ...` — error-prone, no type safety
- SV way: `typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;` — compiler tracks valid states
- `.name()` method: `$display("State: %s", state.name())` — human-readable debug output
- Automatic width: compiler determines the minimum encoding width

### PPA with SV (5 min)
- Synthesize a Verilog module and its SV refactored version
- Compare `yosys stat` output — **spoiler: identical**
- SV adds zero hardware cost. It's purely a designer-productivity and safety improvement.
- Tool note: Icarus Verilog supports SV features with the `-g2012` flag. Verilator is another option for better SV support.

---

## Lab Exercises

### Exercise 1: Refactor Traffic Light FSM (30 min)

**Objective (SLO 13.1, 13.2, 13.3):** Convert an existing Verilog FSM to SystemVerilog.

**Tasks:**
1. Take your Day 7 traffic light FSM (Verilog version).
2. Refactor to SystemVerilog:
   - Replace all `wire`/`reg` declarations with `logic`
   - Replace `always @(posedge clk)` with `always_ff @(posedge clk)`
   - Replace `always @(*)` with `always_comb`
   - Replace `localparam` state definitions with `typedef enum logic [N:0] {...} state_t;`
3. Add `$display` statements using `.name()` to print state names during simulation.
4. Compile with `iverilog -g2012` flag.

**Checkpoint:** SV traffic light compiles and simulates correctly with readable state names in output.

---

### Exercise 2: Refactor UART TX (30 min)

**Objective (SLO 13.2, 13.3, 13.4):** Apply SV features to a more complex module.

**Tasks:**
1. Take your Day 11 UART TX module (Verilog version).
2. Refactor to SystemVerilog:
   - `logic` throughout
   - `always_ff` / `always_comb`
   - `enum` for FSM states
3. **Bonus:** Create a `typedef struct` for UART configuration:
   ```systemverilog
   typedef struct packed {
       logic [15:0] clks_per_bit;
       logic        parity_en;   // preview for Day 14
       logic        parity_type; // preview for Day 14
   } uart_config_t;
   ```
4. Compile with `-g2012`.

**Checkpoint:** SV UART TX compiles and simulates, producing identical waveforms to Verilog version.

---

### Exercise 3: Simulate Both Versions (15 min)

**Objective (SLO 13.2):** Confirm behavioral equivalence.

**Tasks:**
1. Run the same testbench against both the Verilog and SV versions of the traffic light or UART TX.
2. Compare waveforms side by side in GTKWave.
3. Verify identical behavior cycle by cycle.

**Checkpoint:** Waveforms match between Verilog and SV versions.

---

### Exercise 4: PPA Comparison (10 min)

**Objective (SLO 13.5):** Verify SV has zero hardware cost.

**Tasks:**
1. Synthesize both the Verilog and SV versions with Yosys.
2. Run `yosys stat` on both. Record LUTs and FFs.
3. Compare: are they identical? (They should be.)
4. Document: "SV refactoring produced identical hardware. Benefit is designer productivity only."

**Checkpoint:** PPA comparison documented. Numbers match.

---

### Exercise 5 (Stretch): Package Creation (15 min)

**Objective (SLO 13.4):** Share type definitions across modules.

**Tasks:**
1. Create a SystemVerilog `package` containing:
   - The UART configuration struct
   - The FSM state enum(s)
   - Any shared constants
2. `import` the package into both the UART TX and a test module.
3. Verify compilation.

---

## Deliverable

SystemVerilog-refactored module(s) with PPA comparison notes documenting identical synthesis results.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — SV traffic light | 13.1, 13.2, 13.3 | Core |
| 2 — SV UART TX | 13.2, 13.3, 13.4 | Core |
| 3 — Behavioral equivalence | 13.2 | Core |
| 4 — PPA comparison | 13.5 | Core |
| 5 — Package | 13.4 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> Day 13 introduces SystemVerilog constructs. The language is more expressive, but toolchain support varies — watch for compatibility issues.

- **Getting cryptic syntax errors?** Make sure your Makefile passes `-g2012` to `iverilog`. Without it, SystemVerilog constructs like `logic`, `always_comb`, and `enum` will not be recognized.
- **`enum` type width mismatch?** If you declare `typedef enum logic [1:0] {...} state_t;` but list more than 4 states, the compiler should warn about overflow. Match the width to `$clog2(num_states)`.
- **`always_comb` flagging errors that `always @(*)` didn't?** Good — that means `always_comb` is catching real latches or incomplete sensitivity issues that were silently hidden before. This is one of the main reasons to use SV: the compiler does more checking for you.
- **Yosys rejects your SystemVerilog code?** Yosys has growing but incomplete SV support. Features like `interface`, `modport`, and `class` are not supported. Stick to the SV subset covered in the lectures: `logic`, `always_comb`/`always_ff`, `enum`, `typedef`, `struct`.
---

## Preview: Day 14

The capstone verification session — assertions, AI-driven constraint-based testing, the constraint-based UART parity extension, and structured PPA analysis. This is where all the cross-cutting threads converge before the final project.
