# Day 3: Procedural Combinational Logic

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 3 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 3.1:** Write `always @(*)` blocks to describe combinational logic and explain why the wildcard sensitivity list is preferred over manual lists.
2. **SLO 3.2:** Implement decision structures using `if/else` and `case`/`casez` statements and map them to the hardware they imply (priority chains vs. parallel muxes).
3. **SLO 3.3:** Identify conditions that cause unintentional latch inference and apply at least two techniques (default assignment, fully specified `case`) to prevent it.
4. **SLO 3.4:** Distinguish between blocking (`=`) and nonblocking (`<=`) assignment and correctly apply blocking assignment in combinational `always` blocks.
5. **SLO 3.5:** Design a parameterized 4-bit ALU supporting at least four operations using procedural combinational logic.
6. **SLO 3.6:** Use Yosys to identify unintentional latches in a synthesized netlist and correct the source Verilog.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: The `always @(*)` Block (12 min)

#### Why We Need Procedural Blocks for Combinational Logic

Yesterday you expressed combinational logic using `assign`. That works well for simple expressions, but as logic gets complex (multi-way decisions, large lookup tables, deeply nested conditions), `assign` becomes unwieldy. The `always` block gives us access to `if/else`, `case`, and other procedural constructs.

#### Sensitivity Lists

An `always` block re-evaluates whenever a signal in its **sensitivity list** changes:

```verilog
// Manual sensitivity list (DON'T do this)
always @(a or b or sel)
    if (sel)
        y = a;
    else
        y = b;

// Wildcard sensitivity list (DO this)
always @(*)
    if (sel)
        y = a;
    else
        y = b;
```

**Why `@(*)` is mandatory for combinational logic:**
- The `*` automatically includes every signal read inside the block
- Manual lists are error-prone — forget one signal and you get a simulation/synthesis mismatch
- Synthesis tools always infer all inputs regardless of your list, but simulation respects your list literally
- If you list `a` and `sel` but forget `b`, simulation won't update when `b` changes, but synthesis will. Your simulation lies to you.

**Rule:** For combinational logic, always use `always @(*)`. No exceptions.

#### `reg` in Combinational Contexts

Signals assigned inside an `always` block must be declared as `reg`:

```verilog
reg [3:0] r_result;  // declared as reg...

always @(*)          // ...but used in a combinational block
    r_result = a + b;  // ...so it synthesizes to combinational logic, not a register!
```

The `reg` keyword means "can be assigned procedurally." It does NOT mean "register" in this context. This is the most confusing aspect of Verilog naming. (SystemVerilog's `logic` type fixes this — Week 4.)

---

### Video Segment 2: `if/else` and `case` (15 min)

#### `if/else` — Priority Logic

```verilog
always @(*) begin
    if (condition1)
        y = value1;
    else if (condition2)
        y = value2;
    else if (condition3)
        y = value3;
    else
        y = default_value;
end
```

**Critical hardware insight:** `if/else` chains imply **priority**. The synthesizer builds a priority multiplexer chain — `condition1` is checked first, and if true, the remaining conditions are irrelevant. This creates a longer critical path as the chain grows.

```
condition1 ──┐
             MUX──┐
value1 ──────┘    │
                  MUX──┐
condition2 ──┐    │    │
             MUX──┘    MUX── y
value2 ──────┘         │
                       │
condition3 ──┐         │
             MUX───────┘
value3 ──────┘
default ─────┘
```

**When to use `if/else`:** When conditions have natural priority (e.g., interrupt priority encoder, error conditions that override normal operation).

#### `case` — Parallel Selection

```verilog
always @(*) begin
    case (sel)
        2'b00:   y = d0;
        2'b01:   y = d1;
        2'b10:   y = d2;
        2'b11:   y = d3;
        default: y = 4'b0000;
    endcase
end
```

**Hardware insight:** `case` implies a **parallel multiplexer**. All conditions are checked simultaneously. This is typically more efficient than `if/else` for multi-way selection.

**`begin`/`end`:** Required when a branch contains multiple statements, similar to `{}` in C. Optional for single statements, but many style guides recommend always using them.

```verilog
always @(*) begin
    case (opcode)
        2'b00: begin
            result = a + b;    // multiple statements
            carry  = cout;     // need begin/end
        end
        2'b01:
            result = a - b;    // single statement, begin/end optional
        default: begin
            result = 4'b0000;
            carry  = 1'b0;
        end
    endcase
end
```

#### `casez` — Don't-Care Matching

```verilog
always @(*) begin
    casez (input)
        4'b1???: y = 3'd4;  // MSB is 1, don't care about rest
        4'b01??: y = 3'd3;
        4'b001?: y = 3'd2;
        4'b0001: y = 3'd1;
        default: y = 3'd0;
    endcase
end
```

`casez` treats `?` (or `z`) as don't-care bits in the case items. This is perfect for priority encoders and address decoders. Note that `casez` still implies priority among the case items (first match wins).

---

### Video Segment 3: The Latch Problem (12 min)

#### What Is an Unintentional Latch?

A latch is a level-sensitive storage element. Unlike a flip-flop (edge-triggered), a latch is transparent when its enable is active and holds its value when the enable is inactive.

**Latches are almost never what you want in FPGA design.** They cause timing analysis difficulties, are hard to constrain, and are a red flag in code review.

#### How Latches Are Inferred

A latch is created when a combinational `always` block **does not assign a value to an output in every possible execution path**.

**Example — missing `else`:**
```verilog
always @(*) begin
    if (enable)
        q = d;
    // What happens when enable = 0?
    // q must hold its previous value → LATCH!
end
```

The synthesizer reasons: "When `enable = 0`, `q` is not assigned. It must retain its value. The only combinational element that retains value is a latch."

**Example — incomplete `case`:**
```verilog
always @(*) begin
    case (sel)
        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        // Missing 2'b11 → latch on y!
    endcase
end
```

#### Three Techniques to Prevent Latches

**Technique 1: Default assignment at the top of the block**
```verilog
always @(*) begin
    y = 4'b0000;         // Default: assign FIRST, override later
    if (enable)
        y = data;
    // When enable = 0, y keeps the default value (0) — no latch!
end
```

This is the **most reliable and recommended** pattern. Always assign every output a default value at the very beginning of the block.

**Technique 2: Complete `if/else` — always have an `else`**
```verilog
always @(*) begin
    if (enable)
        y = data;
    else
        y = 4'b0000;   // Explicit else — no latch
end
```

**Technique 3: `default` in every `case`**
```verilog
always @(*) begin
    case (sel)
        2'b00:   y = a;
        2'b01:   y = b;
        2'b10:   y = c;
        2'b11:   y = d;    // Complete enumeration
        default: y = 4'b0; // Belt AND suspenders — include default even when complete
    endcase
end
```

**Best practice: Use Technique 1 (default assignment) AND Technique 3 (`default` clause).** Belt and suspenders. The cost is one extra line; the safety is worth it.

---

### Video Segment 4: Blocking vs. Nonblocking Assignment (6 min)

#### The Rule (For Now)

| Context | Assignment | Operator |
|---|---|---|
| Combinational `always @(*)` | **Blocking** | `=` |
| Sequential `always @(posedge clk)` | **Nonblocking** | `<=` |

**Blocking (`=`):** "Execute this assignment immediately and use the result in subsequent statements within this block."

```verilog
always @(*) begin
    temp = a + b;      // temp gets a+b NOW
    result = temp * 2; // result uses the just-computed temp
end
```

This behaves like sequential software execution — which is fine for combinational blocks, because we're just describing how values flow through gates.

**Nonblocking (`<=`):** "Schedule this assignment for the end of the time step." We will cover this in detail tomorrow (Day 4) when we get to sequential logic. For today, just remember: **use `=` in `always @(*)` blocks.**

**What happens if you use `<=` in a combinational block?** It will simulate correctly in most cases but can cause subtle simulation bugs with zero-delay feedback loops. More importantly, it signals to readers of your code that you don't understand the distinction. Always follow the convention.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Predict the output — draw on the board:**
```verilog
always @(*) begin
    if (sel == 2'b00)
        y = a;
    else if (sel == 2'b01)
        y = b;
end
```

1. Is there a problem with this code?
2. What hardware does the synthesizer infer?
3. How would you fix it?

> *Answer: (1) Yes — `y` is unassigned when `sel == 2'b10` or `2'b11`. (2) A latch on `y`. (3) Add a default: either `else y = 4'b0;` at the end, or `y = 4'b0000;` at the top of the block before the `if`.*

---

### Mini-Lecture: Seeing Latches, Building ALUs (30 min)

#### Live Demo: Yosys Latch Detection (10 min)

**Step 1:** Synthesize the buggy code from the warm-up:
```bash
yosys -p "read_verilog buggy.v; synth_ice40 -top buggy_module; show"
```

Point out in the schematic: the latch element. Yosys will also print a warning:
```
Warning: Latch inferred for signal `\y` from process `\buggy_module.$proc$buggy.v:...`
```

**Step 2:** Fix the code, re-synthesize, show the difference. The latch disappears, replaced by a clean mux.

**Teaching point:** Yosys warnings are not noise — they are the tool screaming at you. Read them. Every warning about latches is a bug until proven otherwise.

#### The `case` Statement Refactor (10 min)

Yesterday's 7-seg decoder used nested conditionals. Let's refactor:

```verilog
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg    // NOTE: reg because assigned in always block
);

    always @(*) begin
        case (i_hex)
            4'h0:    o_seg = 7'b0000001;
            4'h1:    o_seg = 7'b1001111;
            4'h2:    o_seg = 7'b0010010;
            4'h3:    o_seg = 7'b0000110;
            4'h4:    o_seg = 7'b1001100;
            4'h5:    o_seg = 7'b0100100;
            4'h6:    o_seg = 7'b0100000;
            4'h7:    o_seg = 7'b0001111;
            4'h8:    o_seg = 7'b0000000;
            4'h9:    o_seg = 7'b0000100;
            4'hA:    o_seg = 7'b0001000;
            4'hB:    o_seg = 7'b1100000;
            4'hC:    o_seg = 7'b0110001;
            4'hD:    o_seg = 7'b1000010;
            4'hE:    o_seg = 7'b0110000;
            4'hF:    o_seg = 7'b0111000;
            default: o_seg = 7'b1111111;  // all segments off
        endcase
    end

endmodule
```

**Key changes from yesterday:**
1. `o_seg` is now `reg` (assigned inside `always` block)
2. `case` statement is far more readable than nested `?:`
3. `default` included even though all 16 values are enumerated (belt and suspenders)
4. The behavior is identical — same hardware, better code

#### ALU Design Pattern (10 min)

An ALU is a natural fit for `case`:

```verilog
module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_result,
    output reg        o_carry
);

    always @(*) begin
        // Default assignments — prevent latches on BOTH outputs
        o_result = 4'b0000;
        o_carry  = 1'b0;

        case (i_opcode)
            2'b00: {o_carry, o_result} = i_a + i_b;    // ADD
            2'b01: {o_carry, o_result} = i_a - i_b;    // SUB
            2'b10: o_result = i_a & i_b;                // AND
            2'b11: o_result = i_a | i_b;                // OR
        endcase
    end

endmodule
```

**Design points:**
- Default assignments at the top handle any unexpected opcode (even though our case is fully specified)
- `{o_carry, o_result}` is a 5-bit concatenation on the left side — captures the carry bit from addition/subtraction
- AND and OR don't produce a carry, so `o_carry` keeps its default value of `0`
- The `case` naturally maps to a 4:1 mux selecting between four ALU results

---

### Concept Check Questions

**Q1 (SLO 3.1):** A student writes `always @(a, b)` but the block also reads signal `c`. What happens in simulation vs. synthesis?

> **Expected answer:** In simulation, the block won't re-evaluate when `c` changes — output will be stale until `a` or `b` changes. In synthesis, the tool infers `c` as an input regardless. The synthesized hardware is correct, but the simulation doesn't match the hardware. This is a simulation/synthesis mismatch — a serious bug. Use `always @(*)`.

**Q2 (SLO 3.2):** Does this `if/else` chain and this `case` produce the same hardware?

```verilog
// Version A
always @(*) begin
    if (sel == 2'b00)      y = a;
    else if (sel == 2'b01) y = b;
    else if (sel == 2'b10) y = c;
    else                   y = d;
end

// Version B
always @(*) begin
    case (sel)
        2'b00:   y = a;
        2'b01:   y = b;
        2'b10:   y = c;
        default: y = d;
    endcase
end
```

> **Expected answer:** Functionally identical output for all inputs. Structurally, `if/else` implies a priority chain (longer worst-case path) while `case` implies a parallel mux. In practice, synthesis tools often optimize both to the same hardware when the conditions are mutually exclusive (as they are here with a 2-bit select). But `case` more clearly communicates the designer's intent and is preferred for parallel selection.

**Q3 (SLO 3.3):** Find the latch(es) in this code:

```verilog
always @(*) begin
    case (opcode)
        2'b00: result = a + b;
        2'b01: result = a - b;
        2'b10: begin
            result = a & b;
            flag   = 1'b1;
        end
        2'b11: result = a | b;
    endcase
end
```

> **Expected answer:** `flag` has a latch. It is only assigned in the `2'b10` case. For all other opcodes, `flag` retains its previous value → latch. Fix: add `flag = 1'b0;` as a default assignment at the top of the block.

**Q4 (SLO 3.4):** What happens if you use `<=` instead of `=` in a combinational `always @(*)` block?

> **Expected answer:** For most simple cases, it simulates correctly. But with zero-delay feedback, it can cause simulation differences. More importantly, it violates the coding convention and signals to other engineers that you don't understand the blocking/nonblocking distinction. Convention: `=` in combinational blocks, `<=` in sequential blocks. Always.

**Q5 (SLO 3.3, 3.6):** You synthesize a design and Yosys prints:
```
Warning: Latch inferred for signal `\result` from process ...
```
What are your next two actions?

> **Expected answer:** (1) Go to the `always` block that drives `result` and check for incomplete assignment paths — missing `else`, missing `default`, or a path where `result` isn't assigned. (2) Add a default assignment at the top of the block: `result = <some_default>;`. Then re-synthesize and confirm the warning disappears.

---

### Lab Exercises (2 hours)

#### Exercise 1: Latch Hunting (20 min)

**Objective (SLO 3.3, 3.6):** Develop intuition for latch inference by intentionally creating and then fixing latches.

Create `latch_bugs.v` — a file with intentional latch-inducing bugs:

```verilog
// BUGGY CODE — intentional latches for learning
// Your job: find and fix every latch

module latch_bugs (
    input  wire [1:0] i_sel,
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [3:0] i_c,
    input  wire       i_enable,
    output reg  [3:0] o_result,
    output reg        o_flag,
    output reg  [2:0] o_encoded
);

    // --- Bug 1: Missing else ---
    always @(*) begin
        if (i_enable)
            o_result = i_a + i_b;
    end

    // --- Bug 2: Incomplete case ---
    always @(*) begin
        case (i_sel)
            2'b00: o_flag = 1'b0;
            2'b01: o_flag = 1'b1;
            2'b10: o_flag = 1'b0;
            // Missing 2'b11!
        endcase
    end

    // --- Bug 3: Partial assignment in one branch ---
    always @(*) begin
        o_encoded = 3'b000;
        case (i_sel)
            2'b00: o_encoded = 3'b001;
            2'b01: begin
                o_encoded[2]   = 1'b1;
                // o_encoded[1:0] not assigned in this branch!
                // Even though there's a default at top...
                // Actually, the default at top DOES cover this.
                // This is a trick question — IS there a latch here?
            end
            2'b10: o_encoded = 3'b100;
            default: o_encoded = 3'b000;
        endcase
    end

endmodule
```

**Student task:**
1. Synthesize with Yosys: `yosys -p "read_verilog latch_bugs.v; synth_ice40 -top latch_bugs" latch_bugs.v`
2. Read every warning. Which signals have latches?
3. Fix each bug. Re-synthesize until all latch warnings are gone.
4. For Bug 3: explain why the default assignment at the top does (or doesn't) prevent a latch on `o_encoded[1:0]`.

> **Bug 3 answer:** The default assignment `o_encoded = 3'b000;` at the top of the block assigns all 3 bits. In the `2'b01` branch, only `o_encoded[2]` is reassigned — bits `[1:0]` keep their default value of `2'b00`. There is **no latch** because every bit is assigned in every path (the default covers what the branch doesn't override). This is why the "default at top" technique is so powerful.

---

#### Exercise 2: Priority Encoder (20 min)

**Objective (SLO 3.2):** Implement `if/else`-based priority logic with `casez` as an alternative.

**Part A:** Implement a 4-input priority encoder using `if/else`:

```verilog
// 4-input priority encoder
// Input:  4-bit request vector (active high)
// Output: 2-bit encoded value of highest-priority active input
//         1-bit valid signal (any input active)
// Priority: bit 3 (highest) → bit 0 (lowest)
module priority_encoder (
    input  wire [3:0] i_request,
    output reg  [1:0] o_encoded,
    output reg        o_valid
);

    always @(*) begin
        // Default assignments
        o_encoded = 2'b00;
        o_valid   = 1'b0;

        // ---- YOUR CODE HERE ----
        // Use if/else chain: check i_request[3] first (highest priority)
        // Set o_encoded to the bit position, o_valid to 1

    end

endmodule
```

**Part B:** Implement the same encoder using `casez`:

```verilog
module priority_encoder_casez (
    input  wire [3:0] i_request,
    output reg  [1:0] o_encoded,
    output reg        o_valid
);

    always @(*) begin
        o_encoded = 2'b00;
        o_valid   = 1'b0;

        casez (i_request)
            4'b1???: begin o_encoded = 2'd3; o_valid = 1'b1; end
            4'b01??: begin o_encoded = 2'd2; o_valid = 1'b1; end
            4'b001?: begin o_encoded = 2'd1; o_valid = 1'b1; end
            4'b0001: begin o_encoded = 2'd0; o_valid = 1'b1; end
            default: begin o_encoded = 2'd0; o_valid = 1'b0; end
        endcase
    end

endmodule
```

**Discussion:** Both versions produce identical hardware. Which is more readable? (Most engineers prefer `casez` for priority encoders.)

**Board test:** Map the 4 buttons to `i_request`, display `o_encoded` on two LEDs, and `o_valid` on a third.

| Buttons pressed | Expected encoded | Valid |
|---|---|---|
| None | XX | 0 |
| Only sw4 (bit 0) | 00 | 1 |
| sw3 + sw4 (bits 1,0) | 01 | 1 |
| sw1 + any (bit 3 + any) | 11 | 1 |

---

#### Exercise 3: 4-Bit ALU (35 min)

**Objective (SLO 3.2, 3.3, 3.5):** Design, code, and verify a multi-operation ALU.

Create `alu_4bit.v`:

```verilog
module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_result,
    output reg        o_zero,    // 1 if result is zero
    output reg        o_carry    // carry/borrow output
);

    always @(*) begin
        // ---- YOUR CODE: default assignments ----

        case (i_opcode)
            2'b00: begin   // ADD
                // ---- YOUR CODE ----
            end
            2'b01: begin   // SUB
                // ---- YOUR CODE ----
            end
            2'b10: begin   // AND
                // ---- YOUR CODE ----
            end
            2'b11: begin   // OR
                // ---- YOUR CODE ----
            end
        endcase

        // Zero flag — derived from result
        // ---- YOUR CODE: use reduction operator ----
    end

endmodule
```

**Student task:**
1. Implement all four operations
2. Compute the zero flag using the NOR reduction operator: `o_zero = ~(|o_result);`
3. Handle carry for ADD and SUB using concatenation on the left-hand side

**Top module for Go Board:**
```verilog
module top_alu (
    input  wire i_switch1,   // opcode[1]
    input  wire i_switch2,   // opcode[0]
    input  wire i_switch3,   // (used for a[1] or b input — flexible)
    input  wire i_switch4,   // (used for a[0] or b input — flexible)
    output wire o_led1,      // result[3] or carry
    output wire o_led2,      // result[2]
    output wire o_led3,      // result[1] or zero flag
    output wire o_led4,      // result[0]
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // Design choice: with only 4 switches, you can't fully control
    // two 4-bit inputs AND a 2-bit opcode simultaneously.
    //
    // Option A: Hardcode i_a, use sw1-sw2 as opcode, sw3-sw4 as i_b[1:0]
    // Option B: Use sw1-sw2 as i_a[1:0], sw3-sw4 as i_b[1:0], hardcode opcode
    //
    // Choose what makes your demo most interesting.

    // ---- YOUR CODE HERE ----
    // Instantiate alu_4bit and hex_to_7seg
    // Display result on the 7-segment display

endmodule
```

**Verification matrix (fill in on paper before programming):**

| opcode | Operation | a | b | Expected result | Carry | Zero |
|---|---|---|---|---|---|---|
| 00 | ADD | 0011 | 0010 | 0101 | 0 | 0 |
| 00 | ADD | 1111 | 0001 | 0000 | 1 | 1 |
| 01 | SUB | 0101 | 0011 | 0010 | 0 | 0 |
| 01 | SUB | 0011 | 0011 | 0000 | 0 | 1 |
| 10 | AND | 1010 | 1100 | 1000 | 0 | 0 |
| 11 | OR  | 1010 | 0101 | 1111 | 0 | 0 |

---

#### Exercise 4: BCD-to-7-Segment with Decimal Point (20 min)

**Objective (SLO 3.2, 3.5):** Refactor yesterday's decoder using `case` and add BCD-specific behavior.

Create `bcd_to_7seg.v`:

```verilog
// BCD-to-7-segment: only valid for inputs 0–9
// For inputs 10–15 (invalid BCD), display an error pattern (e.g., all segments on or 'E')
module bcd_to_7seg (
    input  wire [3:0] i_bcd,
    output reg  [6:0] o_seg,
    output reg        o_valid   // 1 if input is valid BCD (0-9)
);

    always @(*) begin
        o_valid = 1'b1;     // Default: valid
        o_seg   = 7'b1111111; // Default: all off

        case (i_bcd)
            4'd0:    o_seg = 7'b0000001;
            4'd1:    o_seg = 7'b1001111;
            4'd2:    o_seg = 7'b0010010;
            4'd3:    o_seg = 7'b0000110;
            4'd4:    o_seg = 7'b1001100;
            4'd5:    o_seg = 7'b0100100;
            4'd6:    o_seg = 7'b0100000;
            4'd7:    o_seg = 7'b0001111;
            4'd8:    o_seg = 7'b0000000;
            4'd9:    o_seg = 7'b0000100;
            default: begin
                o_seg   = 7'b0110000;  // Display 'E' for error
                o_valid = 1'b0;
            end
        endcase
    end

endmodule
```

**Student task:**
1. Create a top module that drives this decoder from the buttons
2. Use the `o_valid` signal to control an LED (LED on = valid BCD input)
3. Verify all 16 input combinations: 0–9 should show the digit, 10–15 should show 'E'

**Reflection:** Compare this `case`-based decoder with yesterday's nested conditional version. Which would you rather maintain?

---

#### Exercise 5 (Stretch): ALU + 7-Seg Integration (25 min)

**Objective (SLO 3.5):** Full system integration — ALU result displayed on 7-segment.

Create a top module that:
1. Uses switches 1–2 as opcode
2. Hardcodes two operands (e.g., `i_a = 4'd7`, `i_b = 4'd3`)
3. Displays the ALU result on the 7-segment display
4. Displays carry on LED1, zero on LED2
5. Uses the second 7-segment to display the opcode as a symbol (optional: `A` for add, `-` for sub, `&` for AND... or just the opcode number)

**Stretch on top of stretch:** Make the operands configurable by changing which switches map to what (e.g., hold sw3 to switch between editing `i_a` and `i_b`, use sw4 to increment).

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. `always @(*)` is the entry point for procedural combinational logic — always use `*`
2. `case` for parallel selection, `if/else` for priority logic — know the hardware implications
3. **Latch inference is the #1 beginner bug** — prevent it with default assignments and `default` clauses
4. Blocking assignment (`=`) in combinational blocks — it means "evaluate now"
5. Yosys warns you about latches — read the warnings, fix the code

#### Three Things That Will Cause You Pain (And How to Avoid Them)

| Pain | Cause | Prevention |
|---|---|---|
| Latch warnings | Incomplete assignment paths | Default assignments at top of block |
| Simulation mismatch | Manual sensitivity list | Always use `@(*)` |
| Wrong output type | `wire` assigned in `always` | Use `reg` for `always` block outputs |

#### Preview: Day 4 — Sequential Logic
Tomorrow we add time to our designs. Clocks, edge-triggered flip-flops, nonblocking assignment, and counters. You'll make LEDs blink at human-visible rates and display a running counter on the 7-segment display.

**The key concept to prepare for:** `always @(posedge clk)` and `<=` (nonblocking assignment). These are the sequential counterparts to today's `always @(*)` and `=`.

**Homework:** Watch the Day 4 pre-class video (~50 min). Focus on the blocking vs. nonblocking section — tomorrow we'll see why mixing them up creates real bugs.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Latch Hunting | 3.3, 3.6 | All latch warnings eliminated; student explains Bug 3 |
| Ex 2: Priority Encoder | 3.2 | Both versions produce correct output on board |
| Ex 3: ALU | 3.2, 3.3, 3.5 | All operations correct; no latches; zero/carry flags work |
| Ex 4: BCD Decoder | 3.2 | Digits 0–9 display correctly; 10–15 show error |
| Ex 5: ALU + Display | 3.5 | Integrated system shows ALU result on 7-seg |
| Concept check Qs | 3.1, 3.2, 3.3, 3.4, 3.6 | In-class discussion responses |

---

## Instructor Notes

- **The latch exercise is the most important exercise today.** Students who internalize latch avoidance here will save themselves hours of debugging for the rest of the course. Don't rush it.
- **Bug 3 in the latch exercise** is deliberately tricky — it teaches that default assignment at the top *does* protect partial assignments in branches. Some students will incorrectly identify it as a latch. Use this as a teaching moment about how default assignment works (it assigns all bits, and the branch override only changes what it explicitly touches).
- **The ALU top module** is constrained by having only 4 switches. Let students choose their own mapping — the design tradeoff is itself educational. Some will hardcode operands, others will multiplex switches between opcode and data.
- **`casez` vs. `casex`:** If students ask, `casex` also treats `x` as don't-care. This is dangerous in simulation (x-propagation is useful for catching bugs). Recommend `casez` and never `casex`.
- **Timing:** Exercises 1–3 are the priority. Exercise 4 is important but lower priority. Exercise 5 is genuine stretch.
- **If students are stuck on the ALU:** The carry concatenation syntax `{o_carry, o_result} = i_a + i_b` is the most common stumbling point. Explain: the `+` operator on two 4-bit values produces a 5-bit result; the concatenation on the left captures the 5th bit as the carry.
