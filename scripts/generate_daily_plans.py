#!/usr/bin/env python3
"""
Generate all missing daily plan markdown files.
Accelerated HDL for Digital System Design — UCF ECE

Missing daily plans: Day 2, 3, 4, 5, 7, 9, 10, 11, 12, 15
Existing (from project knowledge): Day 1, 6, 8, 13, 14, 16
"""

import os

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"  ✓ {path}")


# =============================================================================
# DAY 2 — Combinational Building Blocks
# =============================================================================

DAY02 = r"""# Day 2: Combinational Building Blocks

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 2 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 2.1:** Declare and use `wire` and `reg` types correctly, and explain why `reg` does not always imply a register.
2. **SLO 2.2:** Declare and manipulate bit vectors using `[MSB:LSB]` notation, bit slicing, concatenation `{}`, and replication `{N{...}}`.
3. **SLO 2.3:** Apply bitwise, arithmetic, relational, logical, and conditional (`?:`) operators in combinational expressions.
4. **SLO 2.4:** Build a multiplexer using `assign` with the conditional operator and explain how nested conditionals create priority.
5. **SLO 2.5:** Design a hex-to-7-segment decoder using combinational logic and verify it on the Go Board hardware.
6. **SLO 2.6:** Instantiate a module inside another module to build a simple hierarchy (full adder → ripple-carry adder).

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: Data Types and Vectors (~15 min)

#### `wire` vs. `reg` — Misleading Names

The most confusing thing in Verilog for beginners: `reg` does **not** mean "register." It means "a variable that can be assigned inside a procedural block (`always`, `initial`)."

```verilog
wire w_connection;     // driven by assign or module output
reg  r_storage;        // driven inside always or initial block
```

The key rule:
- **`wire`**: must be driven by `assign` or a module output. Cannot appear on the left side of `=` inside `always`.
- **`reg`**: can be assigned inside `always` or `initial` blocks. May synthesize to combinational logic OR a register — depends on context.

We'll clarify this fully on Day 3, but for today: if you're using `assign`, the target must be `wire`.

#### Bit Vectors

Single bits are rarely useful. Real designs use multi-bit buses:

```verilog
wire [7:0] w_data;       // 8-bit bus, MSB=7, LSB=0
wire [3:0] w_nibble;     // 4-bit bus
reg  [15:0] r_counter;   // 16-bit register

// Bit selection
assign w_nibble = w_data[3:0];        // lower nibble
assign w_upper  = w_data[7:4];        // upper nibble
assign w_bit5   = w_data[5];          // single bit
```

#### Concatenation and Replication

```verilog
// Concatenation: join signals into a wider bus
wire [7:0] w_byte = {w_upper, w_nibble};   // 8 bits from two 4-bit pieces

// Replication: repeat a pattern
wire [7:0] w_sign_ext = {8{w_data[7]}};    // sign extension: 8 copies of MSB
wire [7:0] w_all_ones = {8{1'b1}};         // 8'hFF
```

**Common mistake:** Forgetting the bit count in replication. `{8{1'b1}}` is correct. `{8{1}}` uses a 32-bit literal — silent width mismatch.

### Video Segment 2: Operators (~12 min)

#### Operator Reference

| Category | Operators | Notes |
|---|---|---|
| Bitwise | `&` `\|` `^` `~` `~^` | Operate on each bit position |
| Arithmetic | `+` `-` `*` | Synthesizable; `/` and `%` only for constants |
| Relational | `<` `>` `<=` `>=` | Return 1-bit result |
| Equality | `==` `!=` | Return 1-bit; `===`/`!==` for simulation (handle x/z) |
| Logical | `&&` `\|\|` `!` | Treat entire value as true/false |
| Conditional | `? :` | Ternary — synthesizes to a mux |
| Reduction | `&a` `\|a` `^a` | Reduce vector to single bit |
| Shift | `<<` `>>` `<<<` `>>>` | Logical and arithmetic shifts |

**Critical distinction — bitwise vs. logical:**
```verilog
wire [3:0] a = 4'b1010, b = 4'b0101;

wire [3:0] bitwise_and = a & b;   // 4'b0000 (each bit ANDed)
wire       logical_and = a && b;  // 1'b1    (both nonzero → true)
```

#### The Conditional Operator — It's a Mux

```verilog
assign y = sel ? a : b;   // 2:1 mux: sel=1→a, sel=0→b
```

This is the fundamental combinational building block. Nested conditionals create larger muxes:

```verilog
assign y = sel[1] ? (sel[0] ? d3 : d2) : (sel[0] ? d1 : d0);  // 4:1 mux
```

### Video Segment 3: Sized Literals and Width Matching (~8 min)

#### Sized Literal Format

```
<bit_width>'<base><value>
```

| Example | Bits | Base | Value | Decimal |
|---|---|---|---|---|
| `4'b1010` | 4 | binary | 1010 | 10 |
| `8'hFF` | 8 | hex | FF | 255 |
| `8'd200` | 8 | decimal | 200 | 200 |
| `1'b0` | 1 | binary | 0 | 0 |

**Why sized literals matter:** Unsized literals default to 32 bits. This causes silent width mismatches:

```verilog
wire [3:0] a = 4'b1010;
wire [3:0] b = 1;           // 32-bit literal truncated to 4 bits — works but sloppy
wire [3:0] c = 4'd1;        // explicit — correct
```

**Rule:** Always use sized literals in synthesizable code.

### Video Segment 4: The 7-Segment Display (~10 min)

The Go Board has two 7-segment displays, each with segments `a` through `g`:

```
 aaaa
f    b
f    b
 gggg
e    c
e    c
 dddd
```

Segments are **active low** on the Go Board: `0` = segment ON, `1` = segment OFF.

A hex-to-7-segment decoder maps a 4-bit input (0-F) to 7 segment outputs. This is a pure combinational function — a lookup table.

---

## In-Class Mini-Lecture (30 min)

### Talking Points

1. **Mux as the universal combinational building block** — every `if/else`, every `case`, every `?:` becomes a mux tree in hardware.

2. **Design pattern:** Start with a truth table, then decide the best coding style:
   - 2-4 inputs → `assign` with `?:`
   - More complex → `always @(*)` with `case` (Day 3)

3. **Common early mistakes:**
   - Width mismatch: `wire [3:0] y = 8'hFF;` — upper bits silently dropped
   - Undriven wires: forgetting to assign a declared wire → `x` in simulation, unpredictable in hardware
   - Concatenation without sizes: `{a, b}` — know your widths

4. **7-segment encoding demo:** Show how to map hex digit 0-F to segment patterns. Use the truth table, then code it.

5. **First taste of hierarchy:** The ripple-carry adder is built from full-adder modules. This is the "module instantiation" pattern you'll use for the rest of the course.

### Concept Check Questions

**Q1 (SLO 2.2):** What is the value and width of `{4'b1010, 4'b0011}`?

> **Expected answer:** 8'b10100011 — 8 bits. Concatenation produces a bus whose width is the sum of the parts.

**Q2 (SLO 2.3):** What does `assign y = &data;` do if `data` is `4'b1010`?

> **Expected answer:** Reduction AND: `1 & 0 & 1 & 0 = 0`. It ANDs all bits of `data` together, producing a single-bit result.

**Q3 (SLO 2.4):** Write a 4:1 mux using a single `assign` statement with nested `?:`.

> **Expected answer:**
> ```verilog
> assign y = sel[1] ? (sel[0] ? d3 : d2) : (sel[0] ? d1 : d0);
> ```

**Q4 (SLO 2.6):** If module `full_adder` has ports `(input a, b, cin, output sum, cout)`, how do you instantiate it?

> **Expected answer:**
> ```verilog
> full_adder fa0 (.a(a[0]), .b(b[0]), .cin(carry_in), .sum(sum[0]), .cout(c[0]));
> ```

---

## Lab Exercises (2 hours)

#### Exercise 1: Multiplexers (25 min)

**Objective (SLO 2.4):** Build muxes of increasing complexity.

**Part A — 2:1 mux:**
```verilog
module mux_2to1 (
    input  wire       i_sel,
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    output wire [3:0] o_y
);
    assign o_y = i_sel ? i_a : i_b;
endmodule
```

**Part B — 4:1 mux (nested conditional):**
```verilog
module mux_4to1 (
    input  wire [1:0] i_sel,
    input  wire [3:0] i_d0, i_d1, i_d2, i_d3,
    output wire [3:0] o_y
);
    assign o_y = i_sel[1] ? (i_sel[0] ? i_d3 : i_d2)
                          : (i_sel[0] ? i_d1 : i_d0);
endmodule
```

**Student task:**
1. Implement both muxes
2. Simulate with Icarus Verilog — write a simple testbench that drives all select combinations
3. Verify with Yosys: `yosys -p "synth_ice40 -top mux_4to1; stat" mux_4to1.v` — how many LUTs?

---

#### Exercise 2: Ripple-Carry Adder — First Hierarchy (30 min)

**Objective (SLO 2.6):** Build a hierarchical design with module instantiation.

**Step 1:** Create `full_adder.v`:
```verilog
module full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_b & i_cin) | (i_a & i_cin);
endmodule
```

**Step 2:** Create `adder_4bit.v`:
```verilog
module adder_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire       i_cin,
    output wire [3:0] o_sum,
    output wire       o_cout
);
    wire [3:0] w_carry;

    full_adder fa0 (.i_a(i_a[0]), .i_b(i_b[0]), .i_cin(i_cin),      .o_sum(o_sum[0]), .o_cout(w_carry[0]));
    full_adder fa1 (.i_a(i_a[1]), .i_b(i_b[1]), .i_cin(w_carry[0]), .o_sum(o_sum[1]), .o_cout(w_carry[1]));
    full_adder fa2 (.i_a(i_a[2]), .i_b(i_b[2]), .i_cin(w_carry[1]), .o_sum(o_sum[2]), .o_cout(w_carry[2]));
    full_adder fa3 (.i_a(i_a[3]), .i_b(i_b[3]), .i_cin(w_carry[2]), .o_sum(o_sum[3]), .o_cout(w_carry[3]));

    assign o_cout = w_carry[3];
endmodule
```

**Step 3:** Write a simple testbench:
```verilog
module tb_adder_4bit;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    adder_4bit dut (.i_a(a), .i_b(b), .i_cin(cin), .o_sum(sum), .o_cout(cout));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_adder_4bit);

        cin = 0;
        a = 4'd3; b = 4'd5; #10;
        $display("3 + 5 = %0d (carry: %b)", sum, cout);

        a = 4'd15; b = 4'd1; #10;
        $display("15 + 1 = %0d (carry: %b)", sum, cout);

        a = 4'd15; b = 4'd15; #10;
        $display("15 + 15 = %0d (carry: %b)", sum, cout);

        cin = 1;
        a = 4'd7; b = 4'd8; #10;
        $display("7 + 8 + 1 = %0d (carry: %b)", sum, cout);

        $finish;
    end
endmodule
```

**Reflection:** How does module hierarchy in Verilog compare to function calls in C? Key difference: each `full_adder` instance creates **separate hardware** — four physical adder circuits, not one circuit called four times.

---

#### Exercise 3: Hex-to-7-Segment Decoder (30 min)

**Objective (SLO 2.5):** Build a combinational decoder and see it work on real hardware.

Create `hex_to_7seg.v`:
```verilog
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {a, b, c, d, e, f, g} — active LOW
);

    // Segment encoding: 0 = ON, 1 = OFF
    //     aaaa
    //    f    b
    //     gggg
    //    e    c
    //     dddd

    always @(*) begin
        case (i_hex)
            //                 abcdefg
            4'h0: o_seg = 7'b0000001;
            4'h1: o_seg = 7'b1001111;
            4'h2: o_seg = 7'b0010010;
            4'h3: o_seg = 7'b0000110;
            4'h4: o_seg = 7'b1001100;
            4'h5: o_seg = 7'b0100100;
            4'h6: o_seg = 7'b0100000;
            4'h7: o_seg = 7'b0001111;
            4'h8: o_seg = 7'b0000000;
            4'h9: o_seg = 7'b0000100;
            4'hA: o_seg = 7'b0001000;
            4'hB: o_seg = 7'b1100000;
            4'hC: o_seg = 7'b0110001;
            4'hD: o_seg = 7'b1000010;
            4'hE: o_seg = 7'b0110000;
            4'hF: o_seg = 7'b0111000;
            default: o_seg = 7'b1111111; // all off
        endcase
    end
endmodule
```

**Note:** This uses `always @(*)` with `case` — we preview this pattern here but explain it fully on Day 3. For now, understand it as "a lookup table that Verilog can express cleanly."

**Top module for the Go Board:**
```verilog
module top_7seg_demo (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // Invert buttons at boundary (active-low → active-high)
    wire [3:0] w_hex = {~i_switch4, ~i_switch3, ~i_switch2, ~i_switch1};

    wire [6:0] w_seg;
    hex_to_7seg decoder (.i_hex(w_hex), .o_seg(w_seg));

    // Map to individual segment pins
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f,
            o_segment1_g} = w_seg;

endmodule
```

**Student task:**
1. Implement the decoder and top module
2. Synthesize and program the Go Board
3. Press button combinations and verify each hex digit (0-F) displays correctly
4. Verify segment encoding against the truth table

---

#### Exercise 4 (Stretch): Display Adder Result on 7-Seg (15 min)

**Objective (SLO 2.5, 2.6):** Integrate the adder with the display.

Create a top module that:
- Uses buttons 1-2 as a 2-bit number A
- Uses buttons 3-4 as a 2-bit number B
- Computes A + B
- Displays the 4-bit result on the 7-segment display

This requires connecting the `adder_4bit` output to the `hex_to_7seg` input — pure hierarchical composition.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **Vectors** are the standard — single-bit signals are the exception
2. **Sized literals** prevent silent truncation bugs — always specify width
3. **The conditional operator** `?:` is a mux — the fundamental combinational building block
4. **Module instantiation** creates separate hardware — it's not a function call
5. **The 7-segment decoder** is your first real "IP block" — reusable in every future project

#### Common Mistakes Seen Today
- Width mismatch in concatenation — always know your signal widths
- Forgetting the `default` in a `case` statement — this will matter more on Day 3
- Named port connections: `.port_name(signal)` — don't use positional connections

#### Preview: Day 3
Tomorrow we go procedural — `always @(*)`, `if/else`, `case`, and the critical concept of **latch inference**. This is where Verilog starts to diverge significantly from software thinking.

**Homework:** Watch the Day 3 pre-class video (~45 min) on procedural combinational logic.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Multiplexers | 2.3, 2.4 | 4:1 mux simulates correctly; LUT count from Yosys |
| Ex 2: Ripple-Carry Adder | 2.6 | Testbench passes; student explains hierarchy vs. function calls |
| Ex 3: Hex-to-7-Seg | 2.2, 2.5 | All 16 digits display correctly on hardware |
| Ex 4: Integrated Display | 2.5, 2.6 | Adder result on 7-seg; student explains dataflow |
| Concept check Qs | 2.1, 2.2, 2.3, 2.4 | In-class discussion responses |

---

## Instructor Notes

- **Pacing:** Exercise 1 is quick (15 min for most). Exercise 2 is the learning moment for hierarchy (25 min). Exercise 3 is the day's centerpiece — budget 30+ min. Exercise 4 is stretch.
- **The `always @(*)` preview** in the 7-seg decoder is intentional. Students will see it work today and understand it fully tomorrow. This builds motivation for Day 3.
- **`reg` confusion** will start today and persist through Day 4. Repeat: "reg means assignable in a procedural block. It does NOT mean register. Whether it becomes a register depends on whether there's a clock."
- **7-segment encoding bugs:** The most common mistake is getting the segment order wrong (`{a,b,c,d,e,f,g}` vs. individual assignments). Have students verify digit '1' first — if segments b and c light up, the encoding is correct.
- **For advanced students:** Ask them to compute the adder's LUT count and compare with what a single `+` operator produces. Yosys will use `+` more efficiently than the manual ripple-carry — this motivates letting the synthesizer optimize.
- **For struggling students:** Exercise 1 and the first half of Exercise 3 are the essentials. Make sure they can wire buttons to the 7-seg display before leaving.
"""


# =============================================================================
# DAY 3 — Procedural Combinational Logic
# =============================================================================

DAY03 = r"""# Day 3: Procedural Combinational Logic

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 3 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 3.1:** Use `always @(*)` blocks to describe combinational logic and explain why `@(*)` is preferred over manual sensitivity lists.
2. **SLO 3.2:** Write `if/else` and `case`/`casez` statements inside `always @(*)` blocks and predict the synthesized hardware (mux trees, priority encoders).
3. **SLO 3.3:** Identify conditions that cause unintentional latch inference and apply techniques to prevent it (default assignments, complete case, fully specified if/else).
4. **SLO 3.4:** Distinguish when to use `assign` (simple expressions) vs. `always @(*)` (complex multi-branch logic) and choose appropriately.
5. **SLO 3.5:** Use Yosys `show` command to visualize synthesized netlists and verify that the hardware matches the intended design.
6. **SLO 3.6:** Build an ALU using procedural combinational logic with opcode-selected operations.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: The `always @(*)` Block (~12 min)

#### From `assign` to `always`

`assign` works beautifully for simple expressions. But what about a 16-way decoder? A multi-operation ALU? Complex logic with many branches is painful with nested `?:`:

```verilog
// This is legal but unreadable:
assign y = (op == 2'b00) ? (a + b) :
           (op == 2'b01) ? (a - b) :
           (op == 2'b10) ? (a & b) :
                           (a | b);
```

`always @(*)` gives you procedural constructs — `if`, `case`, `for` — that describe the same combinational hardware in a clearer way.

#### Sensitivity Lists and the Wildcard

```verilog
always @(*)    // Recommended: automatic — includes all signals read
begin
    // combinational logic here
end

always @(a, b, sel)   // Manual: error-prone, AVOID
begin
    y = sel ? a : b;
end
```

**Why `@(*)` wins:** If you forget a signal in the manual list, simulation won't update when that signal changes, but synthesis will. Your simulation disagrees with your hardware — the worst possible bug.

#### Rules for Combinational `always @(*)`

1. **Use blocking assignment `=`** (not `<=`)
2. **Assign every output in every path** — otherwise you get a latch
3. **No clock edges** — that's sequential (`always @(posedge clk)`)

### Video Segment 2: `if/else` and `case` (~15 min)

#### `if/else` — Priority Logic

```verilog
always @(*) begin
    if (condition1)
        y = a;
    else if (condition2)
        y = b;
    else
        y = c;    // default — ALWAYS include this
end
```

Hardware implication: `if/else` chains create **priority** — `condition1` is checked first. This synthesizes to a chain of muxes where earlier conditions override later ones.

#### `case` — Parallel Selection

```verilog
always @(*) begin
    case (sel)
        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        2'b11: y = d;
        default: y = 4'b0;   // ALWAYS include default
    endcase
end
```

`case` implies parallel selection — all options are equally prioritized. The synthesizer can build a balanced mux tree.

#### `casez` — Don't-Care Matching

```verilog
always @(*) begin
    casez (inputs)
        4'b1???: y = 3'd4;    // MSB=1, don't care about rest
        4'b01??: y = 3'd3;
        4'b001?: y = 3'd2;
        4'b0001: y = 3'd1;
        default: y = 3'd0;
    endcase
end
```

This is a priority encoder — `casez` allows `?` as don't-care bits, perfect for encoding priority.

### Video Segment 3: The Latch Problem (~12 min)

#### Unintentional Latch Inference

This is arguably the most important concept in combinational Verilog. If you don't assign a signal in **every** possible execution path, the synthesizer must **remember** the old value — it creates a latch.

```verilog
// BUG: latch inferred for y
always @(*) begin
    if (sel)
        y = a;
    // When sel=0, y must hold its value → LATCH
end
```

Yosys will synthesize a latch and usually produce a warning, but the warning is easy to miss.

#### Three Prevention Techniques

**Technique 1: Default assignment at the top**
```verilog
always @(*) begin
    y = 0;          // safe default
    if (sel)
        y = a;
    // When sel=0, y gets the default (0) — no latch
end
```

**Technique 2: Complete if/else**
```verilog
always @(*) begin
    if (sel)
        y = a;
    else
        y = b;      // every path assigns y
end
```

**Technique 3: default in case**
```verilog
always @(*) begin
    case (sel)
        2'b00: y = a;
        2'b01: y = b;
        default: y = 0;   // catches all other cases
    endcase
end
```

**Best practice:** Use **both** default assignment at the top AND `default` in your `case`. Belt and suspenders.

### Video Segment 4: Blocking vs. Nonblocking — First Pass (~6 min)

A quick preview:
- **`=` (blocking):** Use in `always @(*)` for combinational logic. Assignments happen in order within the block.
- **`<=` (nonblocking):** Use in `always @(posedge clk)` for sequential logic. All right-hand sides evaluated first, then all updates happen simultaneously.

**The rule is simple:** `=` for combinational, `<=` for sequential. Never mix them in the same `always` block.

We'll explore nonblocking deeply on Day 4. For today, just use `=` in all `always @(*)` blocks.

---

## In-Class Mini-Lecture (30 min)

### Talking Points

1. **When to use `assign` vs. `always @(*)`:**
   - `assign` for simple one-line expressions
   - `always @(*)` when you need `if/else`, `case`, or more than one line of logic
   - Both describe the **same combinational hardware** — it's a style choice

2. **Draw the hardware first, then code it:**
   - Mux tree for `if/else` → draw it
   - Parallel mux for `case` → draw it
   - Priority chain for `casez` → draw it

3. **Live demo: Yosys `show` command**
   ```bash
   yosys -p "read_verilog alu.v; synth_ice40 -top alu_4bit; show"
   ```
   Show students the schematic view of their synthesized logic.

4. **The latch inference demo:**
   Write an intentionally incomplete `always @(*)` block. Show the Yosys warning. Show the `show` output with a latch. Then fix it with a default assignment and show the clean output.

### Concept Check Questions

**Q1 (SLO 3.1):** Why must you use `@(*)` instead of a manual sensitivity list?

> **Expected answer:** Manual lists risk sim/synth mismatch. If you forget a signal, simulation won't update but synthesis will.

**Q2 (SLO 3.3):** What causes an unintentional latch? Give an example.

> **Expected answer:** Not assigning a signal in every path through an `always @(*)` block. Example: `if (sel) y = a;` with no `else`.

**Q3 (SLO 3.2):** What's the hardware difference between `if/else` and `case`?

> **Expected answer:** `if/else` creates priority logic (first match wins). `case` creates parallel selection (balanced mux). Both are combinational.

---

## Lab Exercises (2 hours)

#### Exercise 1: Priority Encoder (20 min)

**Objective (SLO 3.2):** Build a priority encoder using `casez`.

```verilog
module priority_encoder_4 (
    input  wire [3:0] i_req,
    output reg  [1:0] o_idx,
    output reg        o_valid
);
    always @(*) begin
        o_valid = 1'b1;       // default: valid
        casez (i_req)
            4'b1???: o_idx = 2'd3;
            4'b01??: o_idx = 2'd2;
            4'b001?: o_idx = 2'd1;
            4'b0001: o_idx = 2'd0;
            default: begin
                o_idx   = 2'd0;
                o_valid = 1'b0;  // no request
            end
        endcase
    end
endmodule
```

**Student task:**
1. Implement the encoder
2. Write a testbench that applies all 16 input patterns
3. Verify: `i_req = 4'b1010` → `o_idx = 3`, `i_req = 4'b0010` → `o_idx = 1`

---

#### Exercise 2: 4-bit ALU (35 min)

**Objective (SLO 3.6):** Build an ALU with button-selected operations.

```verilog
module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_op,
    output reg  [3:0] o_result,
    output reg        o_carry,
    output wire       o_zero
);

    always @(*) begin
        o_carry = 1'b0;   // default
        case (i_op)
            2'b00: {o_carry, o_result} = i_a + i_b;  // ADD
            2'b01: {o_carry, o_result} = i_a - i_b;  // SUB
            2'b10: o_result = i_a & i_b;              // AND
            2'b11: o_result = i_a | i_b;              // OR
            default: o_result = 4'b0;
        endcase
    end

    assign o_zero = (o_result == 4'b0);
endmodule
```

**Top module for Go Board:**
- Buttons 1-2 select the operation (i_op)
- Hardcode i_a = 4'b0011 (3) and i_b = 4'b0101 (5) for initial testing
- Display result on 7-segment display (reuse yesterday's decoder)
- Show carry on an LED, zero flag on another LED

**Student tasks:**
1. Implement the ALU
2. Integrate with the 7-seg decoder from Day 2
3. Synthesize and test on hardware — verify each operation
4. Use `yosys -p "... show"` to visualize the synthesized ALU

---

#### Exercise 3: BCD-to-7-Seg with Decimal Point (20 min)

**Objective (SLO 3.2, 3.3):** Modify the decoder to handle BCD (0-9 only) with error indication.

```verilog
module bcd_to_7seg (
    input  wire [3:0] i_bcd,
    output reg  [6:0] o_seg,
    output reg        o_error   // high if input > 9
);
    always @(*) begin
        o_error = 1'b0;        // default: no error
        case (i_bcd)
            4'd0: o_seg = 7'b0000001;
            4'd1: o_seg = 7'b1001111;
            4'd2: o_seg = 7'b0010010;
            4'd3: o_seg = 7'b0000110;
            4'd4: o_seg = 7'b1001100;
            4'd5: o_seg = 7'b0100100;
            4'd6: o_seg = 7'b0100000;
            4'd7: o_seg = 7'b0001111;
            4'd8: o_seg = 7'b0000000;
            4'd9: o_seg = 7'b0000100;
            default: begin
                o_seg   = 7'b1111111;  // blank display
                o_error = 1'b1;        // error flag
            end
        endcase
    end
endmodule
```

**Student task:** Add an error LED that lights when buttons represent a value > 9. This is a practical example of using `default` to handle invalid inputs.

---

#### Exercise 4: Latch Detective (15 min)

**Objective (SLO 3.3, 3.5):** Intentionally create a latch, detect it, and fix it.

**Step 1:** Write this intentionally buggy module:
```verilog
module latch_demo (
    input  wire [1:0] i_sel,
    input  wire [3:0] i_a, i_b, i_c,
    output reg  [3:0] o_y
);
    always @(*) begin
        case (i_sel)
            2'b00: o_y = i_a;
            2'b01: o_y = i_b;
            2'b10: o_y = i_c;
            // Missing 2'b11 and default!
        endcase
    end
endmodule
```

**Step 2:** Synthesize with Yosys and look for the latch warning:
```bash
yosys -p "read_verilog latch_demo.v; synth_ice40 -top latch_demo; stat"
```

**Step 3:** Fix it. Add `default: o_y = 4'b0;` and re-synthesize. Confirm the latch disappears.

**Step 4:** Try the "belt and suspenders" approach: add `o_y = 4'b0;` at the top of the `always` block AND the `default` case.

---

#### Exercise 5 (Stretch): Signed Operations and Overflow (15 min)

**Objective (SLO 3.6):** Extend the ALU with signed arithmetic.

Add a `signed` mode to the ALU:
- Use `$signed()` cast for subtraction
- Detect overflow: `(pos + pos = neg)` or `(neg + neg = pos)`
- Show overflow on an LED

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. `always @(*)` with `if/case` describes **combinational logic** — same hardware as `assign`, cleaner syntax for complex logic
2. **Latch inference** is the #1 combinational Verilog bug — prevent it with defaults
3. `if/else` creates priority, `case` creates parallel selection — choose intentionally
4. **Yosys `show`** lets you see what the synthesizer actually built — use it
5. The ALU is your first multi-operation module — a building block for the final project

#### Preview: Day 4
Tomorrow: **sequential logic**. Clocks, `posedge`, nonblocking assignment, flip-flops, and your first blinky LED. Everything changes when you add a clock.

**Homework:** Watch the Day 4 pre-class video (~50 min) on clocks, edges, nonblocking assignment, and resets.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Priority Encoder | 3.1, 3.2 | All 16 patterns correct; student explains casez priority |
| Ex 2: ALU | 3.2, 3.4, 3.5, 3.6 | 4 operations verified on hardware; Yosys schematic examined |
| Ex 3: BCD Decoder | 3.2, 3.3 | Error flag works for inputs > 9 |
| Ex 4: Latch Detective | 3.3, 3.5 | Latch identified in Yosys; fix confirmed |
| Ex 5: Signed ALU | 3.6 | Overflow detected correctly |
| Concept check Qs | 3.1, 3.2, 3.3 | In-class discussion responses |

---

## Instructor Notes

- **This is the most conceptually dense day in Week 1.** Latch inference and the `always @(*)` mental model are non-trivial. Budget extra time for questions.
- **The latch detective exercise (Ex 4)** is essential, not optional. Seeing the Yosys warning and the `show` output with an actual latch makes the concept concrete. Don't let students skip it.
- **Exercise 2 (ALU) is the capstone of combinational design.** If students get this working on hardware with the 7-seg display, they're in excellent shape for Week 1.
- **Common confusion:** Students will ask "why can't I use `<=` in `always @(*)`?" Answer: you technically can, but it's a recipe for simulation bugs. The convention exists because it's been proven safe over decades of practice.
- **For advanced students:** Have them compare the `show` output for an ALU with individual case arms vs. using `+` directly. The synthesizer is smarter than manual optimization.
- **For struggling students:** Focus on Exercise 2 and the latch concept. The priority encoder and BCD decoder can be homework.
"""


# =============================================================================
# DAY 4 — Sequential Logic Fundamentals
# =============================================================================

DAY04 = r"""# Day 4: Sequential Logic Fundamentals

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 4 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 4.1:** Write `always @(posedge clk)` blocks and explain edge-triggered behavior.
2. **SLO 4.2:** Use nonblocking assignment (`<=`) correctly in sequential blocks and explain why blocking assignment breaks multi-stage pipelines.
3. **SLO 4.3:** Implement D flip-flop variants (plain, with enable, with synchronous reset, with asynchronous reset) and explain the trade-offs.
4. **SLO 4.4:** Design a counter-based clock divider to produce visible-rate signals from a 25 MHz clock.
5. **SLO 4.5:** Verify sequential designs in simulation using Icarus Verilog and GTKWave, reading timing diagrams to confirm correct behavior.
6. **SLO 4.6:** Build a working LED blinker on the Go Board — the canonical "Hello World" of FPGA design.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: Clocks and Edges (~12 min)

#### The Clock Changes Everything

Days 1-3 were combinational: outputs depend only on current inputs. Today we add **time** — outputs depend on inputs AND stored state, updated on clock edges.

```verilog
always @(posedge i_clk)    // triggered on rising edge of clock
    r_q <= r_d;            // captures d into q
```

The Go Board's clock is 25 MHz — a rising edge every 40 nanoseconds. Far too fast to see directly. We'll need counters to slow it down.

#### Timing Diagram Thinking

Before you simulate, draw the timing diagram by hand:

```
        ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
clk   ──┘  └──┘  └──┘  └──┘  └──┘  └──
        
d     ──────┐     ┌─────────────┐
            └─────┘             └──────

q     ────────────┐     ┌─────────────
                  └─────┘
```

`q` follows `d`, but delayed by one clock edge. This one-cycle delay is the fundamental behavior of a flip-flop.

### Video Segment 2: Nonblocking Assignment Deep Dive (~15 min)

#### Why `<=` for Sequential

```verilog
// WRONG — blocking in sequential block
always @(posedge clk) begin
    b = a;      // b gets a's value immediately
    c = b;      // c sees b's NEW value (= a) → both get same value!
end

// CORRECT — nonblocking in sequential block
always @(posedge clk) begin
    b <= a;     // evaluate: RHS is current a, current b
    c <= b;     // evaluate: RHS is current b (not yet updated)
end             // update: b ← a_old, c ← b_old → proper pipeline
```

Nonblocking assignment evaluates ALL right-hand sides first using current values, THEN updates all left-hand sides simultaneously. This models how real flip-flops work — they all sample their inputs at the same clock edge.

### Video Segment 3: Flip-Flop Variants (~10 min)

```verilog
// Plain D flip-flop
always @(posedge i_clk)
    r_q <= i_d;

// D-FF with synchronous reset
always @(posedge i_clk)
    if (i_reset)
        r_q <= 1'b0;
    else
        r_q <= i_d;

// D-FF with enable
always @(posedge i_clk)
    if (i_enable)
        r_q <= i_d;

// D-FF with asynchronous reset (iCE40 supports this natively)
always @(posedge i_clk or posedge i_reset)
    if (i_reset)
        r_q <= 1'b0;
    else
        r_q <= i_d;
```

**Our convention:** Use synchronous reset unless there's a specific reason for async reset. It's simpler, more portable, and easier to verify.

### Video Segment 4: Counters and Clock Division (~13 min)

```verilog
module clock_divider #(
    parameter MAX_COUNT = 12_500_000  // 25MHz / 2Hz / 2 = toggle at 1Hz
)(
    input  wire i_clk,
    input  wire i_reset,
    output reg  o_slow_clk
);
    reg [$clog2(MAX_COUNT)-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_count    <= 0;
            o_slow_clk <= 1'b0;
        end else if (r_count == MAX_COUNT - 1) begin
            r_count    <= 0;
            o_slow_clk <= ~o_slow_clk;
        end else begin
            r_count <= r_count + 1;
        end
    end
endmodule
```

This is the pattern: count clock cycles, toggle an output when you reach the target. For 1 Hz blink from 25 MHz: count to 12,500,000 (half period), toggle, repeat.

---

## In-Class Mini-Lecture (35 min)

### Talking Points

1. **The clock is the heartbeat** — draw the timing diagram before you code
2. **25 MHz = 40 ns period** — need ~25 million counts for a 1-second delay
3. **`$clog2(N)`** — auto-computes the number of bits needed for a counter
4. **Common mistakes:**
   - Using `=` instead of `<=` in sequential blocks
   - Forgetting reset — simulation starts with `x`, hardware starts in a random state
   - Clock in the wrong place in sensitivity list

5. **Live coding:** Counter-based clock divider → predict behavior → simulate → compare

### Concept Check Questions

**Q1 (SLO 4.1):** What's the period of the Go Board's 25 MHz clock? How many cycles for 1 Hz blink?

> **Expected answer:** Period = 40 ns. For 1 Hz blink: 25,000,000/2 = 12,500,000 cycles per half-period.

**Q2 (SLO 4.2):** Why does `=` break a shift register in a sequential block?

> **Expected answer:** With `=`, `b = a; c = b;` makes c get a's value immediately (b is already updated). With `<=`, both right-hand sides use current values, so c gets b's old value — proper pipeline.

**Q3 (SLO 4.3):** Write a D-FF with synchronous reset from memory.

> ```verilog
> always @(posedge i_clk)
>     if (i_reset) r_q <= 1'b0;
>     else         r_q <= i_d;
> ```

---

## Lab Exercises (2 hours)

#### Exercise 1: D Flip-Flop — Simulate First (25 min)

**Objective (SLO 4.1, 4.2, 4.5):** Build and verify a D-FF in simulation before touching hardware.

```verilog
module d_flip_flop (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk)
        if (i_reset) o_q <= 1'b0;
        else         o_q <= i_d;
endmodule
```

**Testbench:**
```verilog
module tb_d_flip_flop;
    reg clk, reset, d;
    wire q;

    d_flip_flop dut (.i_clk(clk), .i_reset(reset), .i_d(d), .o_q(q));

    always #5 clk = ~clk;   // 10 time-unit period

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_d_flip_flop);

        clk = 0; reset = 1; d = 0;
        #20 reset = 0;
        #10 d = 1;
        #20 d = 0;
        #10 d = 1;
        #5  d = 0;     // change mid-cycle — should it be captured?
        #15 d = 1;
        #30;
        $finish;
    end
endmodule
```

**Student tasks:**
1. **Before simulating:** Draw the expected timing diagram by hand
2. Simulate with `iverilog` and `gtkwave`
3. Compare your hand-drawn diagram to the simulation waveform
4. **Key question:** When `d` changes mid-cycle (between clock edges), is the change captured on the next edge?

---

#### Exercise 2: N-bit Loadable Register (15 min)

**Objective (SLO 4.3):** Generalize the flip-flop to a multi-bit register.

```verilog
module register_N #(
    parameter WIDTH = 8
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_load,
    input  wire [WIDTH-1:0]  i_d,
    output reg  [WIDTH-1:0]  o_q
);
    always @(posedge i_clk)
        if (i_reset)     o_q <= {WIDTH{1'b0}};
        else if (i_load) o_q <= i_d;
endmodule
```

**Student task:** Simulate at WIDTH=4 and WIDTH=8. Verify load and reset behavior.

---

#### Exercise 3: Free-Running Counter and Clock Divider (30 min)

**Objective (SLO 4.4, 4.6):** Build the LED blinker — the "Hello World" of FPGA.

**Step 1:** Free-running counter:
```verilog
module counter_free #(
    parameter WIDTH = 24
)(
    input  wire              i_clk,
    input  wire              i_reset,
    output reg [WIDTH-1:0]   o_count
);
    always @(posedge i_clk)
        if (i_reset) o_count <= 0;
        else         o_count <= o_count + 1;
endmodule
```

**Step 2:** Top module — use upper bits of a wide counter for LED blink:
```verilog
module led_blinker (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);
    wire [23:0] w_count;

    counter_free #(.WIDTH(24)) cntr (
        .i_clk(i_clk),
        .i_reset(1'b0),
        .o_count(w_count)
    );

    // Each LED blinks at a different rate (powers of 2)
    // 25MHz / 2^24 ≈ 1.5 Hz, 2^23 ≈ 3 Hz, 2^22 ≈ 6 Hz, 2^21 ≈ 12 Hz
    assign o_led1 = ~w_count[23];   // slowest (~1.5 Hz)
    assign o_led2 = ~w_count[22];
    assign o_led3 = ~w_count[21];
    assign o_led4 = ~w_count[20];   // fastest (~12 Hz)
endmodule
```

**Student tasks:**
1. Simulate the counter — verify it counts and wraps
2. Synthesize and program the Go Board
3. **Verify:** Each LED blinks at a different rate, LED1 is slowest
4. Calculate the actual blink rate: `25,000,000 / 2^24 ≈ 1.49 Hz`

---

#### Exercise 4: Precise 1 Hz Blinker (20 min)

**Objective (SLO 4.4):** Build a counter that produces an exact 1 Hz toggle.

```verilog
module blinker_1hz (
    input  wire i_clk,
    input  wire i_reset,
    output reg  o_led
);
    localparam HALF_PERIOD = 12_500_000;  // 25MHz / 2 = 12.5M per half
    reg [$clog2(HALF_PERIOD)-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_count <= 0;
            o_led   <= 1'b1;  // LED off (active low)
        end else if (r_count == HALF_PERIOD - 1) begin
            r_count <= 0;
            o_led   <= ~o_led;
        end else begin
            r_count <= r_count + 1;
        end
    end
endmodule
```

**Student task:** Program this and time it with a stopwatch. How close to 1 Hz is it?

---

#### Exercise 5: Dual-Speed Blinker with Button Control (20 min)

**Objective (SLO 4.3, 4.4, 4.6):** Combine sequential and combinational logic.

Create a top module where:
- LED1 blinks at 1 Hz
- LED2 blinks at 2 Hz
- Button 1 enables/disables LED1
- Button 2 enables/disables LED2
- 7-segment display shows a 4-bit counter that increments once per second

---

#### Exercise 6 (Stretch): Up/Down Counter on 7-Seg (15 min)

**Objective (SLO 4.4, 4.6):** Buttons control count direction, 7-seg displays the value.

- Button 1: count up (on press)
- Button 2: count down (on press)
- Button 3: reset to 0
- Display count on 7-segment (reuse hex decoder)

**Note:** Buttons will bounce — we'll fix this properly on Day 5. For now, expect "double counting" on some presses. That's expected and motivates tomorrow's lesson.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. `always @(posedge clk)` + `<=` = sequential logic — the core of digital design
2. **Draw timing diagrams before coding** — it prevents bugs and builds intuition
3. **Counters** are the Swiss army knife of sequential logic — blinkers, dividers, delays
4. **`$clog2`** auto-sizes your counter width — use it everywhere
5. **Your LED blinks!** This is the FPGA "Hello World" — everything builds from here

#### Preview: Day 5 (Week 2)
Week 2 starts with counters and shift registers in depth, then the critical topics of metastability and debouncing. The "double counting" you saw today? That's a real-world problem we'll solve.

**Homework:** Watch the Day 5 pre-class video (~45 min) on counter variations, shift registers, metastability, and debouncing.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: D Flip-Flop | 4.1, 4.2, 4.5 | Hand-drawn timing matches sim; mid-cycle change handled correctly |
| Ex 2: Register | 4.3 | Load and reset verified at two widths |
| Ex 3: Counter & Blinker | 4.4, 4.6 | 4 LEDs blink at different rates on hardware |
| Ex 4: Precise 1 Hz | 4.4, 4.6 | Measured blink rate approximately 1 Hz |
| Ex 5: Dual-Speed | 4.3, 4.4 | Enable control works; 7-seg counter increments |
| Ex 6: Up/Down Counter | 4.4, 4.6 | Counts up/down on buttons; bounce observed |
| Concept check Qs | 4.1, 4.2, 4.3 | In-class discussion responses |

---

## Instructor Notes

- **This day is exhilarating for students** — the first LED blink is a genuine milestone. Let them enjoy it. Take a moment to acknowledge that they went from zero Verilog to a working sequential design in 4 days.
- **Exercise 1 (D-FF simulation)** must come before hardware. The hand-drawn timing diagram exercise is essential for building intuition about edge-triggered behavior.
- **The bounce problem in Exercise 6** is intentional. Students will see unpredictable counting and ask why. "That's tomorrow's lesson" is the right answer.
- **Common mistake:** Forgetting reset. Simulation starts in `x`, hardware starts in a random state. Make sure every register has a reset path.
- **`$clog2` edge case:** `$clog2(1)` returns 0 in some tools, creating `reg [-1:0]`. Mention briefly, don't dwell on it.
- **For advanced students:** Challenge them to add a "stopwatch mode" — count up at 1/10 second resolution, display on 7-seg, start/stop with a button.
- **For struggling students:** Exercises 1 and 3 are the essentials. If they have a blinking LED, they're ready for Week 2.
"""


# =============================================================================
# DAY 5 — Counters, Shift Registers, Debouncing
# =============================================================================

DAY05 = r"""# Day 5: Counters, Shift Registers & Debouncing

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 5 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 5.1:** Design parameterized counter variants (modulo-N, up/down, loadable) using `$clog2` for automatic width sizing.
2. **SLO 5.2:** Implement shift registers (SIPO, PISO, circular) and explain their role as building blocks for serial communication.
3. **SLO 5.3:** Explain metastability, identify when it can occur, and implement a 2-FF synchronizer to mitigate it.
4. **SLO 5.4:** Implement a button debouncer and explain why synchronization must precede debouncing.
5. **SLO 5.5:** Build an edge detector that generates single-cycle pulses from level signals.
6. **SLO 5.6:** Integrate a complete input pipeline (synchronizer → debouncer → edge detector) and verify it on hardware.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: Counter Variations (~10 min)

#### Modulo-N Counter

```verilog
module counter_mod_n #(
    parameter N = 10
)(
    input  wire                    i_clk,
    input  wire                    i_reset,
    input  wire                    i_enable,
    output reg  [$clog2(N)-1:0]   o_count,
    output wire                    o_wrap
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == N - 1)
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end

    assign o_wrap = i_enable && (o_count == N - 1);
endmodule
```

The `o_wrap` signal is critical — it's how you chain counters (seconds → minutes → hours) and how you generate periodic events.

### Video Segment 2: Shift Registers (~12 min)

Four types, each with a different serial/parallel interface:

| Type | Load | Output | Use Case |
|---|---|---|---|
| SIPO | Serial in | Parallel out | UART RX, SPI MISO |
| PISO | Parallel in | Serial out | UART TX, SPI MOSI |
| SISO | Serial in | Serial out | Delay line, LFSR |
| PIPO | Parallel in | Parallel out | Register (trivial) |

```verilog
// PISO shift register — foundation of UART TX
module shift_reg_piso #(parameter WIDTH = 8)(
    input  wire              i_clk, i_reset,
    input  wire              i_load,
    input  wire              i_shift,
    input  wire [WIDTH-1:0]  i_data,
    output wire              o_serial
);
    reg [WIDTH-1:0] r_shift;

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= {WIDTH{1'b0}};
        else if (i_load)
            r_shift <= i_data;
        else if (i_shift)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};  // shift right, LSB first
    end

    assign o_serial = r_shift[0];
endmodule
```

### Video Segment 3: Metastability and Synchronizers (~12 min)

#### The Problem

Buttons and external signals are **asynchronous** — they can change at any time relative to the clock. If a signal changes during a flip-flop's setup/hold window, the flip-flop enters a **metastable** state — neither 0 nor 1, potentially for longer than one clock period.

#### The Solution: 2-FF Synchronizer

```verilog
module synchronizer (
    input  wire i_clk,
    input  wire i_async,
    output wire o_sync
);
    reg r_meta, r_sync;

    always @(posedge i_clk) begin
        r_meta <= i_async;   // may go metastable
        r_sync <= r_meta;    // almost certainly resolved
    end

    assign o_sync = r_sync;
endmodule
```

The first FF may go metastable, but it has a full clock period to resolve before the second FF samples it. The probability of both going metastable is astronomically low.

### Video Segment 4: Button Debouncing (~11 min)

Mechanical buttons bounce: a single press produces multiple electrical transitions over 5-20 ms. The debouncer waits for the signal to be stable for a defined period.

```verilog
module debounce #(
    parameter CLKS_TO_STABLE = 250_000  // 10ms at 25MHz
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);
    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_bouncy != o_clean) begin
            r_count <= r_count + 1;
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= i_bouncy;
                r_count <= 0;
            end
        end else begin
            r_count <= 0;
        end
    end
endmodule
```

**Critical:** Synchronize BEFORE debouncing. The debounce counter is clocked — its input must be synchronous.

---

## In-Class Mini-Lecture (30 min)

### Talking Points

1. **Input pipeline pattern:** `raw → synchronizer → debouncer → edge_detector → clean pulse`
2. **Why this order matters:** Synchronize first (prevent metastability), then debounce (remove noise), then edge detect (produce clean single-cycle pulse)
3. **Edge detection:**
   ```verilog
   reg r_prev;
   always @(posedge i_clk) r_prev <= i_signal;
   wire w_rising_edge  = i_signal & ~r_prev;
   wire w_falling_edge = ~i_signal & r_prev;
   ```
4. **Live demo:** Show a button press on an oscilloscope (or simulation) with bounce, then show the debounced output

### Concept Check Questions

**Q1 (SLO 5.3):** What causes metastability and what is the standard mitigation?

> Metastability occurs when an async signal violates setup/hold timing. Mitigation: 2-FF synchronizer.

**Q2 (SLO 5.4):** Why must you synchronize before debouncing?

> The debounce counter uses flip-flops clocked by your system clock. Async input can cause metastability in those FFs.

---

## Lab Exercises (2 hours)

#### Exercise 1: Counter Variations (25 min)

**Objective (SLO 5.1):** Build and test a parameterized modulo-N counter.

1. Implement `counter_mod_n` from the pre-class material
2. Instantiate at N=10 (decimal digit), N=16, N=60 (seconds counter)
3. Write a testbench that verifies wrap behavior at each N
4. Chain two counters: seconds (mod-60) → minutes (mod-60) using the wrap signal

---

#### Exercise 2: Shift Register Exploration (20 min)

**Objective (SLO 5.2):** Build SIPO and PISO shift registers.

1. Implement the PISO register from the pre-class material
2. Build a SIPO register (mirror image)
3. Testbench: load 8'hA5 into PISO, shift out all 8 bits, verify serial output sequence
4. Connect PISO serial output to SIPO serial input — verify the byte is reconstructed

---

#### Exercise 3: Input Pipeline Integration (30 min)

**Objective (SLO 5.3, 5.4, 5.5, 5.6):** Build the complete input pipeline and fix yesterday's bounce problem.

1. Implement `synchronizer`, `debounce`, and `edge_detect` modules
2. Chain them: raw button → sync → debounce → edge detect
3. Use the edge pulse to increment a counter, display on 7-seg
4. **Verify:** Every button press increments the counter by exactly 1 (no double counts!)

---

#### Exercise 4: LFSR — Pseudo-Random Numbers (20 min, if time)

**Objective (SLO 5.2):** Build a linear feedback shift register.

```verilog
module lfsr #(parameter WIDTH = 8)(
    input  wire i_clk, i_reset,
    output reg [WIDTH-1:0] o_lfsr
);
    wire w_feedback = o_lfsr[7] ^ o_lfsr[5] ^ o_lfsr[4] ^ o_lfsr[3]; // x^8+x^6+x^5+x^4+1

    always @(posedge i_clk)
        if (i_reset) o_lfsr <= {WIDTH{1'b1}};  // seed (never all zeros)
        else         o_lfsr <= {o_lfsr[WIDTH-2:0], w_feedback};
endmodule
```

Display the LFSR value on LEDs or 7-seg for a visual pseudo-random pattern.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. Counters and shift registers are the workhorse sequential building blocks
2. **Metastability is real** — always synchronize external signals
3. **The input pipeline** (sync → debounce → edge detect) is a pattern you'll use in every project
4. **Clean button input** is essential for reliable interactive designs
5. **LFSRs** give you pseudo-random numbers in pure hardware

#### Preview: Day 6
Tomorrow: formal verification methodology. Testbenches that check themselves, structured test reporting, and file-driven testing. After tomorrow, no design ships without a testbench.

**Homework:** Watch the Day 6 pre-class video (~50 min) on testbench anatomy and self-checking methodology.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Counter Variations | 5.1 | Wrap verified at N=10, 16, 60; chained counters work |
| Ex 2: Shift Registers | 5.2 | PISO→SIPO loopback reconstructs byte |
| Ex 3: Input Pipeline | 5.3, 5.4, 5.5, 5.6 | Clean single-count per press on hardware |
| Ex 4: LFSR | 5.2 | Pseudo-random pattern verified |
| Concept check Qs | 5.3, 5.4 | In-class discussion responses |

---

## Instructor Notes

- **Exercise 3 is the critical exercise.** The input pipeline fixes yesterday's bounce problem. Students who get this working experience a tangible "aha" moment — their counter now reliably increments by 1.
- **Debounce timing:** Use short debounce values in simulation (e.g., CLKS_TO_STABLE=5) and realistic values for hardware (250,000 for 10ms at 25MHz).
- **Common mistake:** Students forget to synchronize before debouncing. If they see occasional double-counts even with debouncing, the synchronizer is missing.
- **For advanced students:** Have them measure actual bounce duration by feeding the raw button through a counter and logging transitions.
- **For struggling students:** Focus on Exercise 3. If they have a reliably debounced button driving a counter, they're in good shape.
"""


# =============================================================================
# DAY 7 — Finite State Machines
# =============================================================================

DAY07 = r"""# Day 7: Finite State Machines

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 7 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 7.1:** Explain the difference between Moore and Mealy state machines and choose the appropriate model for a given problem.
2. **SLO 7.2:** Implement an FSM using the 3-always-block coding style (state register, next-state logic, output logic).
3. **SLO 7.3:** Draw a state diagram and systematically translate it into Verilog using `localparam` for state encoding.
4. **SLO 7.4:** Explain state encoding strategies (binary, one-hot, gray) and their trade-offs for FPGA targets.
5. **SLO 7.5:** Write a self-checking testbench for an FSM that verifies state transitions and output timing.
6. **SLO 7.6:** Build a traffic light controller FSM on the Go Board with timed state transitions.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: FSM Theory and Architecture (~12 min)

#### The Universal Controller Pattern

Every protocol engine, every communication interface, every sequencer, every control unit is a finite state machine. This is arguably the most important design pattern in digital engineering.

**Moore machine:** Outputs depend ONLY on current state.
**Mealy machine:** Outputs depend on current state AND inputs.

```
Inputs ─→ [Next-State Logic] ─→ [State Register] ─→ [Output Logic] ─→ Outputs
              ↑                        │
              └────────────────────────┘
```

#### When to Use Each

| | Moore | Mealy |
|---|---|---|
| Output timing | Changes only on clock edge | Can change asynchronously with input |
| Output glitches | Glitch-free (registered) | May glitch during input transitions |
| State count | Usually more states | Fewer states (combines transitions) |
| Use when | Outputs drive external interfaces | Fast response needed |
| **Our default** | **Yes — safer, cleaner** | Only when Moore is too slow |

### Video Segment 2: The 3-Block Coding Style (~15 min)

The 3-block style separates concerns cleanly:

```verilog
// Block 1: State register (sequential)
always @(posedge i_clk)
    if (i_reset) r_state <= S_IDLE;
    else         r_state <= r_next_state;

// Block 2: Next-state logic (combinational)
always @(*) begin
    r_next_state = r_state;   // default: stay in current state
    case (r_state)
        S_IDLE: if (i_start)  r_next_state = S_RUN;
        S_RUN:  if (i_done)   r_next_state = S_IDLE;
        default:              r_next_state = S_IDLE;
    endcase
end

// Block 3: Output logic (combinational or registered)
always @(*) begin
    o_busy = 1'b0;   // defaults
    o_valid = 1'b0;
    case (r_state)
        S_RUN:  o_busy = 1'b1;
        S_DONE: o_valid = 1'b1;
        default: ;     // defaults cover this
    endcase
end
```

**Why 3 blocks?**
1. Clean separation of concerns — easy to modify one part without breaking others
2. No latch risk — default assignment + case covers every state
3. Industry standard — review teams expect this pattern

### Video Segment 3: State Encoding (~8 min)

| Encoding | S_IDLE | S_RUN | S_DONE | Bits | FFs | Notes |
|---|---|---|---|---|---|---|
| Binary | 2'b00 | 2'b01 | 2'b10 | 2 | 2 | Compact. Good for CPLDs. |
| One-hot | 3'b001 | 3'b010 | 3'b100 | 3 | 3 | Faster (1-LUT decode). FPGA default. |
| Gray | 2'b00 | 2'b01 | 2'b11 | 2 | 2 | Single-bit transitions. CDC-safe. |

For FPGAs: use one-hot (or let the synthesizer choose). For this course: use binary `localparam` for readability. The synthesizer often re-encodes anyway.

### Video Segment 4: FSM Design Methodology (~15 min)

**Step 1: State diagram on paper.** List states, transitions, and outputs.
**Step 2: State table.** Enumerate all (state, input) → (next_state, output) combinations.
**Step 3: Template.** Paste the 3-block template, fill in `localparam`, fill in cases.
**Step 4: Testbench.** Verify every transition and every output.
**Step 5: Synthesize.** Check state encoding, resource usage.

---

## In-Class Mini-Lecture (35 min)

### Talking Points

1. **Draw the state diagram first.** Every FSM lab starts on paper. No code until the diagram is complete.
2. **The 3-block template is non-negotiable** for this course. Students will use it every time.
3. **Default assignments prevent latches.** `r_next_state = r_state;` at the top of Block 2 ensures the FSM stays in its current state if no transition is taken.
4. **Live coding:** Traffic light controller — draw the state diagram on the board, then code it together.

### Concept Check Questions

**Q1 (SLO 7.1):** Your FSM controls a UART TX. Should outputs be Moore or Mealy? Why?

> **Expected answer:** Moore — the TX line must be stable for an entire bit period. Mealy outputs could glitch during input transitions.

**Q2 (SLO 7.2):** In the 3-block style, what type of assignment does each block use?

> **Expected answer:** Block 1 (state reg): nonblocking (`<=`). Block 2 (next-state): blocking (`=`). Block 3 (output): blocking (`=`).

---

## Lab Exercises (2 hours)

#### Exercise 1: Traffic Light Controller (40 min)

**Objective (SLO 7.2, 7.3, 7.6):** Build a timed FSM on the Go Board.

State diagram:
- **GREEN** (3 seconds) → **YELLOW** (1 second) → **RED** (3 seconds) → **GREEN**
- Use LEDs: LED1=green, LED2=yellow (both LEDs), LED3=red
- Button press = pedestrian request → immediate transition to YELLOW

```verilog
module traffic_light (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_ped_request,
    output reg  o_green,
    output reg  o_yellow,
    output reg  o_red
);
    localparam CLK_FREQ = 25_000_000;
    localparam S_GREEN  = 2'd0,
               S_YELLOW = 2'd1,
               S_RED    = 2'd2;

    reg [1:0]  r_state, r_next_state;
    reg [25:0] r_timer;
    wire       w_green_done  = (r_timer == 3 * CLK_FREQ - 1);
    wire       w_yellow_done = (r_timer == 1 * CLK_FREQ - 1);
    wire       w_red_done    = (r_timer == 3 * CLK_FREQ - 1);

    // Block 1: State register
    always @(posedge i_clk)
        if (i_reset) r_state <= S_GREEN;
        else         r_state <= r_next_state;

    // Timer: reset on state change
    always @(posedge i_clk) begin
        if (i_reset || r_state != r_next_state)
            r_timer <= 0;
        else
            r_timer <= r_timer + 1;
    end

    // Block 2: Next-state logic
    always @(*) begin
        r_next_state = r_state;
        case (r_state)
            S_GREEN:  if (w_green_done || i_ped_request) r_next_state = S_YELLOW;
            S_YELLOW: if (w_yellow_done)                 r_next_state = S_RED;
            S_RED:    if (w_red_done)                    r_next_state = S_GREEN;
            default:                                     r_next_state = S_GREEN;
        endcase
    end

    // Block 3: Output logic (Moore)
    always @(*) begin
        o_green  = 1'b0;
        o_yellow = 1'b0;
        o_red    = 1'b0;
        case (r_state)
            S_GREEN:  o_green  = 1'b1;
            S_YELLOW: o_yellow = 1'b1;
            S_RED:    o_red    = 1'b1;
            default:  ;
        endcase
    end
endmodule
```

**Student tasks:**
1. Draw the state diagram before coding
2. Implement and simulate with short timer values (CLK_FREQ=100 for simulation)
3. Program on Go Board with real timing (3s/1s/3s)
4. Test pedestrian request — verify immediate transition to YELLOW

---

#### Exercise 2: Pattern Detector FSM (30 min)

**Objective (SLO 7.2, 7.5):** Build an FSM that detects a specific input sequence.

Design an FSM that detects the sequence `1-0-1` on a serial input:
- Input: button press = 1, no press = 0 (sampled once per second)
- Output: LED lights when pattern is detected

```
States: IDLE → GOT_1 → GOT_10 → DETECTED → IDLE
```

**Student tasks:**
1. Draw the state diagram (handle all inputs in every state)
2. Code using the 3-block template
3. Write a self-checking testbench
4. Test on hardware: press buttons in the sequence 1-0-1 and verify detection

---

#### Exercise 3: Vending Machine FSM (25 min, if time)

**Objective (SLO 7.3, 7.5):** More complex FSM with multiple inputs and outputs.

A simple vending machine:
- Button 1: insert 5¢
- Button 2: insert 10¢
- Display accumulated amount on 7-seg (0, 5, 10, 15, 20, 25)
- At 25¢: LED lights, machine resets after 2 seconds

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **FSMs are the backbone of digital control** — every interface, every protocol
2. **The 3-block style** gives you clean, maintainable, latch-free FSMs
3. **Draw the state diagram first.** Always. No exceptions.
4. **Moore is the safe default** — Mealy only when you need faster response
5. **Default assignments** in every block prevent latches and handle unexpected states

#### Preview: Day 8
Tomorrow: hierarchy, parameters, and `generate`. You'll make your modules reusable and build the most complex system of Week 2 — a fully parameterized, hierarchical Go Board design.

**Homework:** Watch the Day 8 pre-class video (~45 min) on module hierarchy, parameters, and generate blocks.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Traffic Light | 7.2, 7.3, 7.6 | Correct timing; pedestrian request works; state diagram drawn |
| Ex 2: Pattern Detector | 7.2, 7.5 | Sequence detected; overlapping patterns handled; testbench passes |
| Ex 3: Vending Machine | 7.3, 7.5 | Accumulation correct; auto-reset works |
| Concept check Qs | 7.1, 7.2, 7.4 | In-class discussion responses |

---

## Instructor Notes

- **This is the most important day in the course.** FSMs are the core design pattern. If students master the 3-block style today, they can build anything.
- **State diagram on paper is mandatory.** Physically collect and check them before students start coding. Students who skip the diagram produce buggy FSMs.
- **The traffic light timer** has a subtle issue: the timer must reset on state transitions. Students often forget this, causing the FSM to stay in YELLOW too long or skip states.
- **Pattern detector:** The tricky case is overlapping patterns (e.g., input `1-0-1-0-1` should detect twice). Make sure the state diagram handles this — after DETECTED, go back to GOT_1 if the input is 1, not IDLE.
- **For advanced students:** Implement the pattern detector as both Moore and Mealy, compare state counts and output timing.
- **For struggling students:** Focus on the traffic light. If they have a working 3-state FSM with timed transitions, they have the core skill.
"""


# =============================================================================
# DAY 9 — Memory: RAM, ROM & Block RAM
# =============================================================================

DAY09 = r"""# Day 9: Memory: RAM, ROM & Block RAM

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 9 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 9.1:** Model ROM in Verilog using `case`-based and array-based approaches, and load initialization data with `$readmemh`.
2. **SLO 9.2:** Model single-port synchronous RAM with correct read/write behavior and explain read-before-write vs. write-before-read.
3. **SLO 9.3:** Explain the iCE40's Embedded Block RAM (EBR) resources and write Verilog patterns that Yosys infers as Block RAM.
4. **SLO 9.4:** Use `$readmemh`/`$readmemb` for memory initialization in both simulation and synthesis.
5. **SLO 9.5:** Write a testbench that verifies RAM read-after-write behavior.
6. **SLO 9.6:** Build a ROM-driven pattern sequencer on the Go Board.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: ROM in Verilog (~12 min)

#### Case-Based ROM
```verilog
module rom_case (
    input  wire [2:0] i_addr,
    output reg  [7:0] o_data
);
    always @(*) begin
        case (i_addr)
            3'd0: o_data = 8'h48;  // 'H'
            3'd1: o_data = 8'h45;  // 'E'
            3'd2: o_data = 8'h4C;  // 'L'
            3'd3: o_data = 8'h4C;  // 'L'
            3'd4: o_data = 8'h4F;  // 'O'
            default: o_data = 8'h00;
        endcase
    end
endmodule
```

#### Array-Based ROM with `$readmemh`
```verilog
module rom_array #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "data.hex"
)(
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output wire [DATA_WIDTH-1:0] o_data
);
    reg [DATA_WIDTH-1:0] r_mem [0:(2**ADDR_WIDTH)-1];

    initial $readmemh(MEM_FILE, r_mem);

    assign o_data = r_mem[i_addr];   // async read — won't infer block RAM
endmodule
```

### Video Segment 2: RAM in Verilog (~12 min)

#### Single-Port Synchronous RAM
```verilog
module ram_sp #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                    i_clk,
    input  wire                    i_write_en,
    input  wire [ADDR_WIDTH-1:0]  i_addr,
    input  wire [DATA_WIDTH-1:0]  i_write_data,
    output reg  [DATA_WIDTH-1:0]  o_read_data
);
    reg [DATA_WIDTH-1:0] r_mem [0:(2**ADDR_WIDTH)-1];

    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;
        o_read_data <= r_mem[i_addr];   // read-before-write: reads old value
    end
endmodule
```

**Key:** The synchronous read (`o_read_data <= r_mem[i_addr]`) is what enables Block RAM inference. An asynchronous read (`assign o_data = r_mem[addr]`) forces LUT RAM.

### Video Segment 3: iCE40 Memory Resources (~10 min)

The iCE40 HX1K has 16 EBR blocks × 4 Kbit = **64 Kbit total** (8 KB). Each can be configured as:
- 256 × 16
- 512 × 8
- 1024 × 4
- 2048 × 2

**Inference pattern:** Yosys maps to EBR when it sees synchronous read AND synchronous write on a memory array.

### Video Segment 4: Memory Applications (~11 min)

Practical uses: lookup tables (sine wave, character fonts), data buffers (UART FIFO), display framebuffers, instruction storage.

---

## In-Class Mini-Lecture (30 min)

1. **FPGA memory hierarchy:** LUT RAM (tiny, fast, combinational read) vs. Block RAM (larger, clocked read) vs. external (huge, slow)
2. **`$readmemh` works in both simulation and synthesis** — Yosys reads the `.hex` file and bakes the data into the bitstream
3. **Live demo:** ROM pattern sequencer stepping through LED patterns

---

## Lab Exercises (2 hours)

#### Exercise 1: ROM Pattern Sequencer (30 min)

Create a `.hex` file with LED/7-seg patterns. Step through them with a timed counter.

#### Exercise 2: RAM Read/Write (30 min)

Write data via button presses, read and display on 7-seg. Verify read-after-write in testbench.

#### Exercise 3: RAM Testbench (20 min)

Self-checking testbench: write random data, read back, compare.

#### Exercise 4 (Stretch): Initialized RAM (15 min)

Combine `$readmemh` with a writable RAM — initialized ROM that can be updated at runtime.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. ROM = combinational lookup; RAM = clocked read/write
2. **Synchronous read** enables Block RAM inference — one cycle of read latency
3. `$readmemh` works in both simulation and synthesis
4. The iCE40 has 8 KB of Block RAM — enough for lookup tables and small buffers

#### Preview: Day 10
Tomorrow: timing constraints, PLL clock generation, and clock domain crossing. The physics that underlies all of our sequential designs.

**Homework:** Watch the Day 10 pre-class video (~50 min).

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: ROM Sequencer | 9.1, 9.4, 9.6 | Patterns step correctly on hardware |
| Ex 2: RAM Read/Write | 9.2, 9.3 | Write and read verified on 7-seg |
| Ex 3: RAM Testbench | 9.2, 9.5 | All read-after-write checks pass |
| Ex 4: Init RAM | 9.4 | Pre-loaded values readable; writes overwrite |

---

## Instructor Notes

- **The sync vs. async read distinction** is the single most important concept today. Spend time on it.
- **`$readmemh` file format:** Students will have format errors. The file is just hex values separated by whitespace. No 0x prefix, no commas.
- **Yosys EBR inference:** Run `yosys -p "synth_ice40; stat"` and check for `SB_RAM40_4K` in the report. If it shows up, Block RAM was inferred.
- **Common mistake:** Mixing async and sync reads in the same module. Yosys can't partially infer Block RAM.
"""


# =============================================================================
# DAY 10 — Timing, Clocking & Constraints
# =============================================================================

DAY10 = r"""# Day 10: Timing, Clocking & Constraints

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 10 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 10.1:** Explain setup time, hold time, and the critical path, and define timing slack.
2. **SLO 10.2:** Add frequency constraints to a nextpnr build and interpret the timing report.
3. **SLO 10.3:** Instantiate the iCE40 `SB_PLL40_CORE` to generate clocks at frequencies other than 25 MHz.
4. **SLO 10.4:** Explain clock domain crossing hazards and implement a 2-FF synchronizer between clock domains.
5. **SLO 10.5:** Intentionally create a timing violation and observe its effects in the timing report.
6. **SLO 10.6:** Apply the principle "one clock domain when possible" to design decisions.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: Physics of Timing (~15 min)

**Setup time (tsu):** Data must be stable BEFORE the clock edge.
**Hold time (th):** Data must remain stable AFTER the clock edge.
**Propagation delay (tpd):** Time for a signal to travel through combinational logic.

**Slack = clock_period − (propagation_delay + setup_time)**
- Positive slack: timing met
- Negative slack: timing violation — design may fail unpredictably

### Video Segment 2: Timing Reports (~12 min)

```bash
nextpnr-ice40 --hx1k --package vq100 --freq 25 --pcf go_board.pcf \
              --json top.json --asc top.asc
```

The `--freq 25` flag tells nextpnr to target 25 MHz and report timing analysis.

### Video Segment 3: iCE40 PLL (~12 min)

```bash
icepll -i 25 -o 50    # calculate PLL parameters for 50 MHz output
```

Instantiate `SB_PLL40_CORE` with the computed parameters.

### Video Segment 4: Clock Domain Crossing (~11 min)

**Rule 1:** Avoid multiple clock domains whenever possible.
**Rule 2:** When crossing is unavoidable, use 2-FF synchronizer for single-bit signals.
**Rule 3:** For multi-bit values, use Gray code or async FIFO.

---

## Lab Exercises (2 hours)

#### Exercise 1: Timing Analysis (25 min)
Add `--freq 25` to builds, read the timing report, identify critical path.

#### Exercise 2: Create a Timing Violation (20 min)
Build a long combinational chain, observe negative slack.

#### Exercise 3: PLL Clock Generation (30 min)
Generate 50 MHz with `SB_PLL40_CORE`, drive a blinker at a different rate.

#### Exercise 4: Clock Domain Crossing (20 min)
Pass a signal between two clock domains, verify with/without synchronizer.

---

### Debrief & Preview (10 min)

Tomorrow: UART transmitter — your first communication interface. Everything you've built so far comes together.

**Homework:** Watch the Day 11 pre-class video (~50 min) on UART protocol and TX architecture.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Timing Analysis | 10.1, 10.2 | Timing report interpreted correctly |
| Ex 2: Timing Violation | 10.1, 10.5 | Negative slack observed and explained |
| Ex 3: PLL | 10.3 | Different clock frequency working on hardware |
| Ex 4: CDC | 10.4, 10.6 | Synchronizer prevents metastability |

---

## Instructor Notes

- **Timing analysis** is abstract for students. The "intentionally create a violation" exercise makes it concrete.
- **PLL instantiation** on iCE40 is well-documented but finicky. Have the `icepll` output ready as a reference.
- **One clock domain:** Hammer this point. 90% of student projects should use a single clock. The PLL exercise shows you CAN have multiple clocks — but reinforces that you shouldn't unless necessary.
"""


# =============================================================================
# DAY 11 — UART Transmitter
# =============================================================================

DAY11 = r"""# Day 11: UART Transmitter

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 11 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 11.1:** Describe the UART protocol frame format (start bit, 8 data bits LSB-first, stop bit) and calculate baud rate timing.
2. **SLO 11.2:** Decompose the UART TX into FSM + PISO shift register + baud rate counter.
3. **SLO 11.3:** Implement a complete, parameterized UART TX module using the 3-block FSM style.
4. **SLO 11.4:** Write a testbench that verifies correct UART framing by deserializing the TX output.
5. **SLO 11.5:** Connect the Go Board to a PC via USB-UART and transmit characters visible in a terminal program.
6. **SLO 11.6:** Implement the valid/busy handshake protocol for reliable data transfer.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: The UART Protocol (~15 min)

UART (Universal Asynchronous Receiver/Transmitter): two wires (TX, RX), no shared clock. Both sides agree on baud rate.

**Frame format (8N1):**
```
IDLE ─┐   ┌─D0─┬─D1─┬─D2─┬─D3─┬─D4─┬─D5─┬─D6─┬─D7─┬─────── IDLE
      └───┘    │    │    │    │    │    │    │    │  STOP
     START              DATA (LSB first)
```

**115200 baud at 25 MHz:** 25,000,000 / 115,200 = **217 clock cycles per bit**.

### Video Segment 2: TX Architecture (~15 min)

Three parts you already know:
1. **FSM** (Day 7): IDLE → START → DATA (×8) → STOP → IDLE
2. **PISO shift register** (Day 5): holds the byte, shifts out LSB first
3. **Modulo-N counter** (Day 5): baud rate generator, ticks every 217 cycles

### Video Segment 3: Implementation Walk-Through (~12 min)

Complete UART TX module with parameterized clock frequency and baud rate:

```verilog
module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk, i_reset,
    input  wire       i_valid,
    input  wire [7:0] i_data,
    output reg        o_tx,
    output wire       o_busy
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam S_IDLE  = 2'd0, S_START = 2'd1,
               S_DATA  = 2'd2, S_STOP  = 2'd3;

    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_baud_cnt;
    reg [7:0] r_shift;
    reg [2:0] r_bit_idx;

    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);

    assign o_busy = (r_state != S_IDLE);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state    <= S_IDLE;
            o_tx       <= 1'b1;
            r_baud_cnt <= 0;
            r_bit_idx  <= 0;
        end else begin
            case (r_state)
                S_IDLE: begin
                    o_tx <= 1'b1;
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    if (i_valid) begin
                        r_shift <= i_data;
                        r_state <= S_START;
                    end
                end
                S_START: begin
                    o_tx <= 1'b0;
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state    <= S_DATA;
                    end
                end
                S_DATA: begin
                    o_tx <= r_shift[0];
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_shift    <= {1'b0, r_shift[7:1]};
                        if (r_bit_idx == 7)
                            r_state <= S_STOP;
                        else
                            r_bit_idx <= r_bit_idx + 1;
                    end
                end
                S_STOP: begin
                    o_tx <= 1'b1;
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state    <= S_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
```

### Video Segment 4: Connecting to a PC (~8 min)

The Go Board has a built-in FTDI USB-to-UART chip. Connect via:
- Linux: `screen /dev/ttyUSB0 115200` or `minicom`
- macOS: `screen /dev/cu.usbserial-* 115200`
- Windows: PuTTY or TeraTerm on the COM port

---

## Lab Exercises (2 hours)

#### Exercise 1: UART TX Implementation (40 min)

1. Implement the complete `uart_tx` module
2. Write a testbench that sends byte 0x48 ('H') and verifies the serial output bit-by-bit
3. Check timing: each bit should be exactly CLKS_PER_BIT cycles wide

#### Exercise 2: "HELLO" on the PC (30 min)

Top module that sends "HELLO\r\n" on reset:

```verilog
module uart_hello (
    input  wire i_clk,
    output wire o_uart_tx
);
    // ROM with message characters
    reg [7:0] r_message [0:6];
    initial begin
        r_message[0] = "H";
        r_message[1] = "E";
        r_message[2] = "L";
        r_message[3] = "L";
        r_message[4] = "O";
        r_message[5] = 8'h0D;  // CR
        r_message[6] = 8'h0A;  // LF
    end

    // Sequencer FSM to send each character
    // ... (students implement)
endmodule
```

**Milestone:** Seeing "HELLO" appear on the PC terminal is one of the most satisfying moments in the course.

#### Exercise 3: Button-to-UART (20 min)

Send a character when a button is pressed: Button 1 → 'A', Button 2 → 'B', etc.

#### Exercise 4 (Stretch): Hex Display over UART (15 min)

Send the 7-seg counter value as hex ASCII over UART.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. UART TX = FSM + PISO + baud counter — modules you already know
2. **The valid/busy handshake** is a fundamental interface pattern
3. **Parameterization** makes the same module work at any baud rate
4. Your Go Board just talked to your PC — that's a real embedded system

#### Preview: Day 12
Tomorrow: UART RX (harder — requires 16× oversampling), SPI, and IP integration. After tomorrow, you have full bidirectional PC communication.

**Homework:** Watch the Day 12 pre-class video (~50 min).

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: TX Implementation | 11.2, 11.3, 11.4, 11.6 | Testbench verifies framing; all bits correct |
| Ex 2: "HELLO" | 11.5 | Text appears in terminal; students document with screenshot |
| Ex 3: Button-UART | 11.5, 11.6 | Correct character per button; no garbled output |
| Ex 4: Hex over UART | 11.3, 11.5 | Counter value streams as hex ASCII |

---

## Instructor Notes

- **"HELLO" on the terminal** is a landmark moment. Make sure every student achieves this before leaving. It's the emotional high point of Week 3.
- **Common UART bugs:** Wrong baud rate (check CLKS_PER_BIT calculation), inverted idle state (must be high), bit order (LSB first), missing stop bit.
- **Terminal setup:** Have instructions ready for all three platforms. The FTDI driver on macOS can be tricky. Test before class.
- **The testbench for UART** is non-trivial — deserializing the TX output requires a second shift register in the testbench. Walk through this if students struggle.
"""


# =============================================================================
# DAY 12 — UART RX, SPI & IP Integration
# =============================================================================

DAY12 = r"""# Day 12: UART RX, SPI & IP Integration

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 12 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 12.1:** Explain why UART RX requires oversampling and implement 16× oversampling with center-of-bit alignment.
2. **SLO 12.2:** Implement a complete UART RX module that receives bytes from a PC.
3. **SLO 12.3:** Describe the SPI protocol (SCLK, MOSI, MISO, CS_N) and explain SPI modes (CPOL/CPHA).
4. **SLO 12.4:** Apply an IP integration checklist: read docs, write wrapper, add synchronizers, test.
5. **SLO 12.5:** Build a bidirectional UART system that echoes received characters back to the PC.
6. **SLO 12.6:** Demonstrate a complete UART-based interactive system on the Go Board.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: UART RX Oversampling (~15 min)

TX controls its own timing. RX must **find** bit boundaries from an incoming signal with no clock reference.

**16× oversampling:** Sample the line 16 times per bit period. Detect the start bit's falling edge, count 7 oversample ticks to reach bit center, then sample each subsequent bit at center.

### Video Segment 2: UART RX Implementation (~15 min)

```verilog
module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk, i_reset,
    input  wire       i_rx,
    output reg  [7:0] o_data,
    output reg        o_valid
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT     = CLKS_PER_BIT / 2;

    localparam S_IDLE  = 3'd0, S_START = 3'd1,
               S_DATA  = 3'd2, S_STOP  = 3'd3;

    reg [2:0] r_state;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_baud_cnt;
    reg [7:0] r_shift;
    reg [2:0] r_bit_idx;

    // 2-FF synchronizer for async RX input
    reg r_rx_meta, r_rx_sync;
    always @(posedge i_clk) begin
        r_rx_meta <= i_rx;
        r_rx_sync <= r_rx_meta;
    end

    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);
    wire w_half_tick = (r_baud_cnt == HALF_BIT - 1);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state <= S_IDLE;
            o_valid <= 1'b0;
        end else begin
            o_valid <= 1'b0;   // default: pulse for one cycle only
            case (r_state)
                S_IDLE: begin
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    if (~r_rx_sync)     // falling edge = start bit
                        r_state <= S_START;
                end
                S_START: begin
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_half_tick) begin  // sample at center of start bit
                        r_baud_cnt <= 0;
                        if (~r_rx_sync)     // still low = valid start
                            r_state <= S_DATA;
                        else
                            r_state <= S_IDLE; // false start (noise)
                    end
                end
                S_DATA: begin
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_shift <= {r_rx_sync, r_shift[7:1]};  // LSB first
                        if (r_bit_idx == 7)
                            r_state <= S_STOP;
                        else
                            r_bit_idx <= r_bit_idx + 1;
                    end
                end
                S_STOP: begin
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        if (r_rx_sync) begin    // valid stop bit
                            o_data  <= r_shift;
                            o_valid <= 1'b1;
                        end
                        r_state <= S_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
```

### Video Segment 3: SPI Protocol (~12 min)

Four signals: SCLK (master → slave), MOSI (master → slave), MISO (slave → master), CS_N (active low chip select).

SPI is clocked — much simpler than UART for multi-byte transfers. The master generates the clock.

### Video Segment 4: IP Integration Philosophy (~8 min)

**Checklist:**
1. Read the documentation
2. Write a wrapper module
3. Add synchronizers on external async inputs
4. Write a testbench
5. Verify resource usage

---

## Lab Exercises (2 hours)

#### Exercise 1: UART Echo System (40 min)

Build a system that receives a character via UART RX and echoes it back via UART TX. This proves bidirectional communication.

```verilog
module uart_echo (
    input  wire i_clk,
    input  wire i_uart_rx,
    output wire o_uart_tx
);
    wire [7:0] w_rx_data;
    wire       w_rx_valid;
    wire       w_tx_busy;

    uart_rx rx (.i_clk(i_clk), .i_reset(1'b0), .i_rx(i_uart_rx),
                .o_data(w_rx_data), .o_valid(w_rx_valid));

    uart_tx tx (.i_clk(i_clk), .i_reset(1'b0),
                .i_valid(w_rx_valid & ~w_tx_busy),
                .i_data(w_rx_data), .o_tx(o_uart_tx), .o_busy(w_tx_busy));
endmodule
```

**Verification:** Type in a terminal, see characters echoed back.

#### Exercise 2: UART-Controlled LEDs (25 min)

Receive a character, use it to control LEDs: '1' → LED1 on, '2' → LED2 on, etc.

#### Exercise 3: UART + 7-Segment Display (20 min)

Display the received character's hex value on the 7-segment display.

#### Exercise 4 (Stretch): SPI Concept (if time)

If time permits, discuss SPI master architecture and how it differs from UART (clocked vs. asynchronous).

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. UART RX is harder than TX — oversampling and center alignment are the key techniques
2. **Always synchronize** the RX input — it's asynchronous
3. **Echo** proves bidirectional communication — a foundational system test
4. SPI is clocked and simpler for multi-byte transfers
5. IP integration is a disciplined process, not trial-and-error

#### Preview: Day 13
Week 4 begins with SystemVerilog — the modern evolution of Verilog. Same concepts, safer syntax, better verification.

**Homework:** Watch the Day 13 pre-class video (~45 min) on SystemVerilog for design.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Echo System | 12.1, 12.2, 12.5 | Characters echo correctly; terminal screenshot |
| Ex 2: UART LEDs | 12.2, 12.6 | Correct LED control from terminal |
| Ex 3: UART 7-Seg | 12.2, 12.6 | Hex value displayed for received characters |
| Ex 4: SPI Concept | 12.3, 12.4 | SPI architecture discussed |

---

## Instructor Notes

- **Echo working** is the key milestone. Every student should have bidirectional UART before leaving.
- **UART RX bugs:** The most common issue is incorrect half-bit counting for start bit alignment. The second most common is forgetting the synchronizer on the RX input.
- **Terminal confusion:** Students may have their TX and RX wired backward in the `.pcf` file. If nothing appears, swap the pin assignments.
- **SPI is conceptual** for most students — we don't have SPI peripherals on the Go Board without a PMOD. Cover the protocol theory and move on to project work.
"""


# =============================================================================
# DAY 15 — Final Project Build Day
# =============================================================================

DAY15 = r"""# Day 15: Final Project Build Day

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 15 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 15.1:** Apply a systematic integration strategy (skeleton top → heartbeat LED → one module at a time).
2. **SLO 15.2:** Debug hardware integration issues using UART printf and LED indicators.
3. **SLO 15.3:** Demonstrate a minimum viable demo of their final project on hardware.
4. **SLO 15.4:** Articulate the current state of their project, identify remaining work, and manage scope.

---

## Session Structure (no pre-class videos)

| Time | Activity |
|---|---|
| 0:00–0:15 | Integration strategy briefing |
| 0:15–0:45 | Individual check-ins (1-on-1 with instructor) |
| 0:45–2:00 | Build time with on-call support |
| 2:00–2:15 | Status round — each student: 30 seconds on status + biggest block |
| 2:15–2:30 | Buffer / overflow debugging |

---

## Integration Briefing (15 min)

### The #1 Rule: No Big Bang Integration

**Never** take all your individually-tested modules and wire them together at once. You will get errors, and you won't know which connection caused them.

### Integration Strategy

**Step 1:** Skeleton top module
```verilog
module top_project (
    input  wire i_clk,
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_uart_tx,
    input  wire i_uart_rx,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
                o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g
    // ... other pins as needed
);
    // HEARTBEAT — proves the FPGA is programmed and clock is running
    reg [23:0] r_heartbeat;
    always @(posedge i_clk) r_heartbeat <= r_heartbeat + 1;
    assign o_led4 = ~r_heartbeat[23];  // ~1.5 Hz blink

    // TODO: instantiate modules one at a time
endmodule
```

**Step 2:** Synthesize and program the skeleton. Verify heartbeat LED blinks.

**Step 3:** Add ONE module. Synthesize. Test. Repeat.

### UART Printf Debugging

When you can't see inside the FPGA, send debug values over UART:
```verilog
// Quick-and-dirty: send state value as hex ASCII
wire [7:0] w_debug_char = (r_state < 10) ? ("0" + r_state) : ("A" + r_state - 10);
```

### Scope Management

If your project is too ambitious:
- **Cut features, not quality.** A simple design that works perfectly beats a complex design that's broken.
- **Minimum viable demo:** What's the simplest version that shows your core concept?

---

## Individual Check-Ins (30 min)

For each student (2–3 min):
1. **Status:** What's working in simulation? What's working on hardware?
2. **Block diagram review:** Is the architecture sound?
3. **Scope check:** Is the project achievable by tomorrow?
4. **Action items:** What specific tasks should you focus on today?

---

## Build Time (75 min)

Students work on their projects. Instructor circulates for debugging support.

**Priority triage:**
- **Red:** Can't synthesize or program → help immediately
- **Yellow:** Synthesizes but doesn't work on hardware → UART debug, LED indicators
- **Green:** Working on features → brief check-ins

---

## Status Round (15 min)

Each student: 30 seconds.
1. What's working?
2. What's your biggest remaining challenge?
3. What will you finish tonight?

---

### Preview: Day 16

**Tomorrow: 5–7 minute demo per student.**
1. Live demo on Go Board (2 min)
2. Architecture walk-through (1–2 min)
3. Testbench/verification discussion (1 min)
4. Reflection: what worked, what you'd change (1 min)

Come prepared with everything programmed and ready to show.

---

## SLO Assessment Mapping

| Activity | SLOs Assessed | Evidence |
|---|---|---|
| Integration strategy | 15.1 | Student starts with skeleton + heartbeat |
| Check-in | 15.4 | Student articulates status and plan |
| Build time | 15.1, 15.2, 15.3 | Progress visible; debugging strategies applied |
| Status round | 15.4 | Concise status report |

---

## Instructor Notes

- **This is a support day, not a lecture day.** Your job is to unblock students and help them make scope decisions.
- **The heartbeat LED** is non-negotiable. If the heartbeat blinks, the toolchain works. If it doesn't, fix that before anything else.
- **Scope management** is the hardest conversation. Students who chose the 4-bit processor or Conway's Game of Life may need to cut features. Help them identify the minimum viable demo.
- **Common integration bugs:** Wrong `.pcf` pin names, missing modules in the Yosys command, clock not connected, reset not connected.
- **Time management:** Students who spent Days 13–14 on SystemVerilog exercises and haven't started their project are behind. Help them focus on simulation first, hardware second.
"""


# =============================================================================
# MAIN
# =============================================================================

def main():
    base = "/home/claude/hdl-course/docs"

    plans = {
        "day02_combinational_building_blocks.md": DAY02,
        "day03_procedural_combinational_logic.md": DAY03,
        "day04_sequential_logic_fundamentals.md": DAY04,
        "day05_counters_shift_registers_debouncing.md": DAY05,
        "day07_finite_state_machines.md": DAY07,
        "day09_memory_ram_rom_block_ram.md": DAY09,
        "day10_timing_clocking_constraints.md": DAY10,
        "day11_uart_transmitter.md": DAY11,
        "day12_uart_rx_spi_ip_integration.md": DAY12,
        "day15_final_project_build_day.md": DAY15,
    }

    print("Generating missing daily plan markdown files...\n")
    for filename, content in plans.items():
        write_file(f"{base}/{filename}", content)

    print(f"\nDone! Generated {len(plans)} daily plan files.")


if __name__ == "__main__":
    main()
