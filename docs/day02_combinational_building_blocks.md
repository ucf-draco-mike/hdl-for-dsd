# Day 2: Combinational Building Blocks

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 2 of 16

---

## Student Learning Objectives

1. **SLO 2.1:** Declare and use vectors, bit slicing, concatenation, and replication in Verilog.
2. **SLO 2.2:** Implement multiplexers using continuous assignment and conditional operators.
3. **SLO 2.3:** Build hierarchical designs by instantiating sub-modules with port connections (structural Verilog).
4. **SLO 2.4:** Design a hex-to-7-segment decoder and verify it on the Go Board's displays.

---

## Pre-Class Video (~45 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Data types & vectors: `wire`, `reg`, `[MSB:LSB]`, bit slicing, concatenation, replication | 15 min | `video/day02_seg1_data_types_vectors.mp4` |
| 2 | Operators: bitwise, arithmetic, relational, logical, conditional (`?:`) | 12 min | `video/day02_seg2_operators.mp4` |
| 3 | Sized literals & concatenation: `4'hA`, `{a, b}`, `{4{1'b0}}` | 8 min | `video/day02_seg3_sized_literals.mp4` |
| 4 | 7-segment display encoding: mapping 4-bit hex to segment patterns | 10 min | `video/day02_seg4_seven_segment.mp4` |

**Key concepts:**
- `wire` vs `reg` — `reg` does NOT always mean register; it means "variable assigned in a procedural block"
- Vectors: `[MSB:LSB]` notation, bit slicing `data[3:0]`, concatenation `{a, b}`, replication `{4{1'b0}}`
- `assign` creates combinational logic — synthesis produces real gates
- Conditional operator `? :` is the hardware mux

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up Q&A: Day 1 follow-up, pre-class questions | 5 min |
| 0:05 | Mini-lecture: mux patterns, common mistakes, 7-seg encoding | 30 min |
| 0:35 | Lab Exercise 1: 2:1 and 4:1 multiplexer | 20 min |
| 0:55 | Lab Exercise 2: Ripple-carry adder (first hierarchy) | 25 min |
| 1:20 | Break | 5 min |
| 1:25 | Lab Exercise 3: Hex-to-7-segment decoder | 30 min |
| 1:55 | Lab Exercise 4 (Stretch): Structural 4:1 mux | 15 min |
| 2:10 | Debrief: common bugs, synthesis observations | 10 min |
| 2:20 | Preview Day 3 | 5 min |

---

## In-Class Mini-Lecture (30 min)

### Multiplexer as Fundamental Building Block (10 min)
- `assign y = sel ? a : b;` — the 2:1 mux pattern
- Nested conditionals for 4:1 mux: `assign y = s[1] ? (s[0] ? d : c) : (s[0] ? b : a);`
- Mux as the hardware implementation of "choose" — every `if/else` and `case` becomes muxes in hardware

### Common Early Mistakes (5 min)
- Mismatched bit widths — Yosys warnings to look for
- Undriven wires — nothing connected, unpredictable behavior on hardware
- Forgetting `wire` vs `reg` context — which goes where
- Sized literal mistakes: `8` vs `8'd8` vs `4'b1000`

### 7-Segment Display Encoding (15 min)
- Go Board's dual 7-seg: active-high segments, directly pin-mapped
- Mapping 4-bit hex (0–F) to 7-segment patterns
- Live design walkthrough: truth table → `assign` statements or look-up approach
- Segment naming convention: a–g, and how they map to display pins
- Building the truth table on the whiteboard together

---

## Lab Exercises

### Exercise 1: 2:1 and 4:1 Multiplexer (20 min)

**Objective (SLO 2.1, 2.2):** Implement muxes using `assign` and the conditional operator.

**Tasks:**
1. Create `mux_2to1.v`: a 1-bit 2:1 mux using `assign y = sel ? a : b;`.
2. Test on the Go Board: use Button 0 as `sel`, Button 1 as `a`, Button 2 as `b`, LED 0 as `y`.
3. Extend to `mux_4to1.v`: use two select bits (buttons) to choose among four inputs. Display on an LED.
4. Widen to 4-bit inputs: create a 4-bit 2:1 mux using vector ports `[3:0]`.

**Checkpoint:** 4:1 mux working on hardware — correct LED output for all select combinations.

---

### Exercise 2: 4-Bit Ripple-Carry Adder (25 min)

**Objective (SLO 2.1, 2.3):** First taste of hierarchy — build a module and instantiate it multiple times.

**Tasks:**
1. Create `full_adder.v` with ports `(input a, b, cin, output sum, cout)` using continuous assignment.
2. Verify the full adder: check all 8 input combinations mentally or in simulation.
3. Create `adder_4bit.v` that instantiates four `full_adder` modules, chaining `cout` to the next stage's `cin`.
4. Use **named port connections**: `.a(a[0]), .b(b[0]), .cin(carry_in), .sum(sum[0]), .cout(c1)`.
5. Create a top module: buttons provide two 2-bit inputs, display the sum on LEDs or 7-seg.

**Checkpoint:** Adder produces correct sums on hardware for several input combinations.

---

### Exercise 3: Hex-to-7-Segment Decoder (30 min)

**Objective (SLO 2.1, 2.4):** Design the decoder that will be reused throughout the course.

**Tasks:**
1. Create `hex_to_7seg.v` with `input [3:0] hex_digit` and `output [6:0] segments`.
2. Implement the mapping using either:
   - (a) Sixteen `assign` statements using nested conditionals, or
   - (b) A combinational `always @(*)` with `case` (preview of Day 3 — instructor can mention this alternative)
3. Build the segment truth table: for each hex value (0–F), determine which segments (a–g) should be lit.
4. Wire it up: use buttons (or a counter) to select hex values, drive the Go Board display.
5. Test all 16 values: cycle through 0–F and verify the display shows the correct character.

**Checkpoint:** All 16 hex digits display correctly on the Go Board's 7-segment display.

> **Note:** Keep this module — you will reuse `hex_to_7seg.v` in nearly every lab going forward.

---

### Exercise 4 (Stretch): Structural 4:1 Mux (15 min)

**Objective (SLO 2.3):** Build a 4:1 mux using only 2:1 mux instances — no conditional operators at the top level.

**Tasks:**
1. Instantiate three `mux_2to1` modules to implement 4:1 selection.
2. Draw the tree structure first: two muxes select pairs, one mux selects between pair outputs.
3. Verify on hardware — should behave identically to the Exercise 1 behavioral version.

---

## Deliverable

Hex-to-7-segment decoder displaying button-selected hex values on the Go Board's display.

**Submit:** All Verilog source files (mux, adder, 7-seg decoder) + top module + `.pcf` constraint file.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — 2:1 / 4:1 Mux | 2.1, 2.2 | Core |
| 2 — Ripple-carry adder | 2.1, 2.3 | Core |
| 3 — Hex-to-7-seg decoder | 2.1, 2.4 | Core — graded deliverable |
| 4 — Structural 4:1 mux | 2.3 | Stretch (bonus) |

---

## Common Issues & Instructor Notes

- **Bit width mismatches:** Students frequently mix 1-bit and multi-bit signals. Yosys will warn, but the warnings can be buried in output. Teach them to read synthesis output for width mismatch warnings early — this habit pays off all course.
- **Named vs. positional port connections:** Exercise 2 is the first time students instantiate modules. Some will try positional for speed (`.full_adder fa0(a[0], b[0], cin, s[0], c1)`). Allow it here but flag that Day 8 will enforce named-only — and show them a bug caused by misordered ports.
- **7-seg segment mapping confusion:** Students will get segments wrong. Have the Go Board segment map drawn on the whiteboard (or in a handout). Encourage them to light one segment at a time to identify the mapping before coding the full decoder.
- **`wire` vs `reg` errors:** Students may try to assign to a `wire` inside an `always` block (if they peek ahead), or declare a `reg` for a simple `assign`. Clarify: `assign` → `wire`, `always` → `reg`.
- **Replication operator confusion:** `{4{1'b0}}` looks strange. Walk through it: inner braces are the value, outer braces are concatenation, the number is the repeat count.
- **Students finishing early:** Direct them to Exercise 4 (structural mux) — it's an excellent exercise in thinking about hierarchy.

---

## Preview: Day 3

Procedural combinational logic — `always @(*)`, `if/else`, `case`, and the notorious latch inference problem. Plus a deep dive into how `if/else` and `case` synthesize differently, with your first look at comparing synthesis results. Watch the Day 3 video (~45 min).
