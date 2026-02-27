# Day 2: Combinational Building Blocks

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 2 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 2.1:** Declare and manipulate multi-bit vectors using `[MSB:LSB]` notation, bit slicing, concatenation (`{}`), and replication (`{N{...}}`).
2. **SLO 2.2:** Apply Verilog operators (bitwise, arithmetic, relational, logical, conditional) and predict their synthesized hardware cost.
3. **SLO 2.3:** Implement multiplexers of varying sizes using the conditional operator (`? :`) and nested conditionals.
4. **SLO 2.4:** Construct a hierarchical design by instantiating sub-modules using named port connections.
5. **SLO 2.5:** Design a hexadecimal-to-7-segment decoder and verify it on the Go Board's displays.
6. **SLO 2.6:** Use `1'b0`, `4'hF`, `8'd255`, and other sized literals correctly and explain why unsized literals cause bugs.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: Data Types and Vectors (15 min)

#### `wire` vs. `reg` — The Most Misleading Names in Verilog

This is a source of enormous confusion, so let's address it directly.

**`wire`:** Represents a combinational connection. It must be **continuously driven** — either by an `assign` statement or by a module output port. A `wire` cannot "hold" a value; it's like an actual copper wire.

**`reg`:** Despite the name, `reg` **does not always synthesize to a register (flip-flop)**. The keyword `reg` simply means "a variable that can be assigned inside a procedural block (`always`, `initial`)." Whether it becomes a flip-flop or a combinational signal depends on **how you use it**.

```verilog
// This 'reg' becomes a flip-flop (sequential — assigned on clock edge)
reg [7:0] r_counter;
always @(posedge clk)
    r_counter <= r_counter + 1;

// This 'reg' becomes combinational logic (no clock, no storage)
reg [3:0] r_mux_out;
always @(*)
    if (sel)
        r_mux_out = a;
    else
        r_mux_out = b;
```

**Rule of thumb for now:**
- Use `wire` with `assign` statements
- Use `reg` inside `always` blocks
- Whether it becomes a register depends on whether there's a clock edge in the sensitivity list

(SystemVerilog fixes this confusion with the `logic` type — we'll get there in Week 4.)

#### Vectors (Buses)

Signals are often multi-bit. A vector declaration:

```verilog
wire [7:0] w_data;   // 8-bit bus, bit 7 is MSB, bit 0 is LSB
wire [3:0] w_nibble;  // 4-bit bus
```

Bit indexing and slicing:
```verilog
w_data[7]      // single bit — the MSB
w_data[3:0]    // lower nibble — bits 3 down to 0
w_data[7:4]    // upper nibble — bits 7 down to 4
```

**Convention:** We always use `[MSB:LSB]` with MSB > LSB and LSB = 0. You *can* declare `[0:7]` (ascending), but this causes confusion and we won't use it.

#### Concatenation and Replication

```verilog
// Concatenation: join signals together
wire [7:0] w_byte = {w_nibble_hi, w_nibble_lo};  // two 4-bit → one 8-bit

// The width must match! This is an 8-bit bus, and {4-bit, 4-bit} = 8 bits. ✓

// Replication: repeat a pattern
wire [7:0] w_all_ones = {8{1'b1}};    // 8'b11111111
wire [7:0] w_sign_ext = {{4{w_nibble[3]}}, w_nibble};  // sign-extend 4→8 bits
```

**Sign extension** is a common pattern: replicate the MSB (sign bit) to fill the upper bits. The double curly braces `{{N{bit}}, signal}` are not special syntax — it's a concatenation of a replication with a signal.

---

### Video Segment 2: Operators (12 min)

#### Operator Reference Table

| Category | Operator | Example | Notes |
|---|---|---|---|
| **Bitwise** | `&` `\|` `^` `~` `~^` | `y = a & b;` | Operates on each bit independently |
| **Logical** | `&&` `\|\|` `!` | `if (a && b)` | Result is 1-bit: true (1) or false (0) |
| **Arithmetic** | `+` `-` `*` | `sum = a + b;` | Watch widths! 4-bit + 4-bit can overflow |
| **Relational** | `<` `>` `<=` `>=` | `if (a > b)` | Result is 1-bit |
| **Equality** | `==` `!=` | `if (a == b)` | Use `===`/`!==` only in simulation (handles x/z) |
| **Shift** | `<<` `>>` `<<<` `>>>` | `y = a << 2;` | `<<`/`>>` = logical, `<<<`/`>>>` = arithmetic |
| **Conditional** | `? :` | `y = s ? a : b;` | The MUX operator — your most-used tool |
| **Reduction** | `&` `\|` `^` (unary) | `y = &a;` | AND/OR/XOR all bits of a vector into one bit |
| **Concatenation** | `{ }` | `{a, b}` | Join signals together |

#### Bitwise vs. Logical — A Critical Distinction

```verilog
wire [3:0] a = 4'b1010;
wire [3:0] b = 4'b0101;

wire [3:0] w_bitwise_and = a & b;   // = 4'b0000 (bit-by-bit AND)
wire        w_logical_and = a && b;   // = 1'b1    (both nonzero → true)
```

Bitwise operators produce a result the same width as the operands. Logical operators always produce a 1-bit result.

#### The Conditional Operator: Your Multiplexer

```verilog
assign y = sel ? a : b;
```

This is a 2:1 multiplexer. When `sel = 1`, `y = a`. When `sel = 0`, `y = b`. It synthesizes directly to a mux — no gates to diagram, no truth table to derive. Just think: "if sel, then a, else b."

Nested conditionals build larger muxes:
```verilog
assign y = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);
// 4:1 mux: sel=00→a, sel=01→b, sel=10→c, sel=11→d
```

#### Reduction Operators (Unary)

Reduction operators collapse a vector into a single bit:
```verilog
wire [7:0] w_data = 8'b10110010;
wire w_any   = |w_data;   // OR reduction: 1 (at least one bit is 1)
wire w_all   = &w_data;   // AND reduction: 0 (not all bits are 1)
wire w_parity = ^w_data;  // XOR reduction: 0 (even number of 1s)
```

These are extremely useful for checking conditions: "are any flags set?" (`|flags`), "are all bits valid?" (`&valid`), "what's the parity?" (`^data`).

---

### Video Segment 3: Sized Literals and Width Matching (8 min)

#### Literal Syntax

```verilog
4'b1010      // 4-bit binary: decimal 10
4'd10        // 4-bit decimal: same value
4'hA         // 4-bit hex: same value
8'hFF        // 8-bit hex: decimal 255
16'h0000     // 16-bit hex: zero

1'b0         // 1-bit zero — use this instead of bare 0 for single-bit signals
1'b1         // 1-bit one
```

Format: `<width>'<base><value>` where base is `b` (binary), `d` (decimal), `h` (hex), or `o` (octal).

#### Why Unsized Literals Are Dangerous

```verilog
wire [3:0] a = 4'b1010;
wire [3:0] result = a + 1;   // 1 is 32-bit by default! Width mismatch.
wire [3:0] result = a + 4'd1; // Explicit 4-bit literal. Clean.
```

Unsized integers (`1`, `0`, `42`) default to **32 bits** in Verilog. This doesn't always cause bugs because Verilog performs implicit width extension, but it can cause unexpected behavior and synthesis warnings. **Always size your literals.** It costs you a few extra characters and saves hours of debugging.

The one common exception: `0` and `1` used as boolean conditions in `if` statements, where width doesn't matter because any nonzero value is true.

---

### Video Segment 4: The 7-Segment Display (10 min)

#### How a 7-Segment Display Works

A 7-segment display has seven LEDs arranged in a figure-8 pattern, labeled `a` through `g`:

```
 ___
|   |     Segment map:
| a |       aaa
|___|      f   b
|   |      f   b
| d |       ggg
|___|      e   c
|   |      e   c
| g |       ddd
|___|
```

Wait, let me draw this properly:

```
  ──a──
 |     |
 f     b
 |     |
  ──g──
 |     |
 e     c
 |     |
  ──d──
```

Each segment is an individual LED. To display a digit, you turn on the appropriate combination of segments.

**On the Go Board:** The 7-segment displays are active low (0 = segment on, 1 = segment off), matching the LEDs and buttons.

#### Hex-to-7-Segment Mapping

| Hex | Display | a | b | c | d | e | f | g |
|-----|---------|---|---|---|---|---|---|---|
| 0   | `0` | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| 1   | `1` | 1 | 0 | 0 | 1 | 1 | 1 | 1 |
| 2   | `2` | 0 | 0 | 1 | 0 | 0 | 1 | 0 |
| 3   | `3` | 0 | 0 | 0 | 0 | 1 | 1 | 0 |
| 4   | `4` | 1 | 0 | 0 | 1 | 1 | 0 | 0 |
| 5   | `5` | 0 | 1 | 0 | 0 | 1 | 0 | 0 |
| 6   | `6` | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| 7   | `7` | 0 | 0 | 0 | 1 | 1 | 1 | 1 |
| 8   | `8` | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 9   | `9` | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| A   | `A` | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| B   | `b` | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| C   | `C` | 0 | 1 | 1 | 0 | 0 | 0 | 1 |
| D   | `d` | 1 | 0 | 0 | 0 | 0 | 1 | 0 |
| E   | `E` | 0 | 1 | 1 | 0 | 0 | 0 | 0 |
| F   | `F` | 0 | 1 | 1 | 1 | 0 | 0 | 0 |

*(0 = segment on for active-low displays)*

Note: `b` and `d` are shown in lowercase to distinguish from `8` and `0` respectively. This is the standard convention for hex 7-segment displays.

**Design task:** Given a 4-bit input, output the 7 segment signals. This is a pure combinational function — no clock, no state. It's a lookup table.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick quiz on the board:**

```verilog
wire [7:0] a = 8'b10110011;
```

1. What is `a[0]`?
2. What is `a[7:4]`?
3. What is `|a`?
4. What is `&a`?

> Answers: (1) `1'b1`, (2) `4'b1011`, (3) `1'b1` (at least one bit is 1), (4) `1'b0` (not all bits are 1)

---

### Mini-Lecture: Muxes, Hierarchy & the 7-Seg Decoder (30 min)

#### The Multiplexer as Universal Building Block (10 min)

Every combinational function can be built from muxes. In FPGAs, the LUT (Look-Up Table) is essentially a mux.

**2:1 mux — already know this:**
```verilog
assign y = sel ? a : b;
```

**4:1 mux — nested conditional:**
```verilog
assign y = sel[1] ? (sel[0] ? d3 : d2)
                  : (sel[0] ? d1 : d0);
```

**Draw this on the board as a mux tree:** two levels of 2:1 muxes. `sel[0]` selects within pairs, `sel[1]` selects between pairs.

**Alternative — using a `case` equivalent via concatenation and conditional chain:**
```verilog
assign y = (sel == 2'b00) ? d0 :
           (sel == 2'b01) ? d1 :
           (sel == 2'b10) ? d2 :
                            d3;
```

Both synthesize to equivalent hardware. The nested version is often more efficient to write; the chained version is more readable for larger muxes.

#### Module Hierarchy (10 min)

Real designs are built from smaller modules composed into larger ones. This is the hardware equivalent of function calls, but with a critical difference: every module instance is **physical hardware** that exists simultaneously.

```verilog
module full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_a & i_cin) | (i_b & i_cin);
endmodule
```

**Instantiation** — creating an instance of a module inside another:
```verilog
module ripple_adder_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire       i_cin,
    output wire [3:0] o_sum,
    output wire       o_cout
);
    wire [3:1] w_carry;  // internal carry chain

    //                 Module name   Instance name   Port connections (named)
    full_adder fa0 (.i_a(i_a[0]), .i_b(i_b[0]), .i_cin(i_cin),       .o_sum(o_sum[0]), .o_cout(w_carry[1]));
    full_adder fa1 (.i_a(i_a[1]), .i_b(i_b[1]), .i_cin(w_carry[1]),  .o_sum(o_sum[1]), .o_cout(w_carry[2]));
    full_adder fa2 (.i_a(i_a[2]), .i_b(i_b[2]), .i_cin(w_carry[2]),  .o_sum(o_sum[2]), .o_cout(w_carry[3]));
    full_adder fa3 (.i_a(i_a[3]), .i_b(i_b[3]), .i_cin(w_carry[3]),  .o_sum(o_sum[3]), .o_cout(o_cout));
endmodule
```

**Key points:**
- **Always use named port connections** (`.port_name(signal_name)`). Positional connections exist but are error-prone.
- Every `full_adder` instance gets a unique instance name (`fa0`, `fa1`, ...).
- Internal wires (`w_carry`) connect the instances together.
- This creates 4 copies of the `full_adder` hardware — 4 physical adder cells.

#### 7-Segment Decoder Design Approach (10 min)

The hex-to-7-seg decoder is a pure combinational function. Given a 4-bit input, it produces 7 output signals.

**Design approach:** We *could* use 7 separate Boolean equations (one per segment), but that's tedious and error-prone. Instead, we'll use a **case-based approach** in an `always @(*)` block — which we'll cover properly tomorrow. For today, we can use a nested conditional approach:

```verilog
// Preview: this is how we'd do it with assign (ugly but works)
// Tomorrow's always/case approach will be much cleaner
assign o_seg = (i_hex == 4'h0) ? 7'b0000001 :
               (i_hex == 4'h1) ? 7'b1001111 :
               // ... etc for all 16 values
                                 7'b1111111; // default: all off
```

In the lab, you'll implement this. Tomorrow we'll refactor it using `always @(*)` and `case`, which is the more natural way to express it.

---

### Concept Check Questions

**Q1 (SLO 2.1):** What is the value of `y`?
```verilog
wire [7:0] a = 8'hA5;
wire [3:0] y = a[7:4];
```

> **Expected answer:** `y = 4'hA = 4'b1010`

**Q2 (SLO 2.1):** What does this produce?
```verilog
wire [7:0] y = {4'b1100, 4'b0011};
```

> **Expected answer:** `y = 8'b11000011 = 8'hC3`

**Q3 (SLO 2.2):** What's the difference between `a & b` and `a && b` when `a = 4'b1010` and `b = 4'b0101`?

> **Expected answer:** `a & b = 4'b0000` (bitwise AND, each bit independently). `a && b = 1'b1` (logical AND — both are nonzero, so result is true/1).

**Q4 (SLO 2.3):** Draw the hardware that `assign y = sel ? a : b;` synthesizes to.

> **Expected answer:** A 2:1 multiplexer with `sel` as the select input, `a` on the `1` input, and `b` on the `0` input, output `y`.

**Q5 (SLO 2.4):** A student instantiates a module like this:
```verilog
full_adder fa0 (a[0], b[0], cin, sum[0], carry);
```
What's wrong? It might work, but why is it bad practice?

> **Expected answer:** Positional port connections. If the module's port order ever changes, or if someone misremembers the order, this silently connects signals to the wrong ports. Always use named connections: `.i_a(a[0]), .i_b(b[0]), ...`

**Q6 (SLO 2.6):** What happens here?
```verilog
wire [3:0] a = 4'b1010;
wire [3:0] y = a + 1;
```
What is the literal `1`? Why might this be problematic?

> **Expected answer:** The literal `1` is 32 bits wide by default. Verilog will perform the addition in 32-bit context, then truncate to 4 bits for `y`. In this case it works (gives `4'b1011`), but the implicit widening is a bad habit. Use `4'd1` explicitly.

---

### Lab Exercises (2 hours)

#### Exercise 1: Vector Operations Warm-Up (20 min)

**Objective (SLO 2.1, 2.2, 2.6):** Practice vector manipulation and verify understanding of operators by driving LEDs from computed values.

Create `vector_ops.v`:
```verilog
// Exercise 1: Vector operations
// Use the 4 switches as a 4-bit input, display results on LEDs
module vector_ops (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // First, collect switches into a vector and make active-high
    wire [3:0] w_sw;
    assign w_sw = ~{i_switch1, i_switch2, i_switch3, i_switch4};
    // NOTE: i_switch1 is MSB (bit 3), i_switch4 is LSB (bit 0)

    // Task: implement the following
    // LED1 = OR reduction of all switches (any switch pressed)
    // LED2 = AND reduction (all switches pressed)
    // LED3 = XOR reduction (odd number of switches pressed = odd parity)
    // LED4 = MSB of the 4-bit value (switch1)

    // ---- YOUR CODE HERE ----
    //
    // Remember: LEDs are active-low on the Go Board
    // Use the ~() inversion-at-output pattern from Day 1

endmodule
```

**Student task:** Fill in the four LED assignments. Synthesize, program, and verify with the following test cases:

| sw1 | sw2 | sw3 | sw4 | Expected LED1 | LED2 | LED3 | LED4 |
|-----|-----|-----|-----|--------------|------|------|------|
| 0 | 0 | 0 | 0 | OFF | OFF | OFF | OFF |
| 0 | 0 | 0 | 1 | ON | OFF | ON | OFF |
| 1 | 0 | 1 | 0 | ON | OFF | OFF | ON |
| 1 | 1 | 1 | 1 | ON | ON | OFF | ON |

---

#### Exercise 2: 2:1 → 4:1 Multiplexer (25 min)

**Objective (SLO 2.3, 2.4):** Build multiplexers and practice hierarchy.

**Part A:** Create `mux2to1.v`:
```verilog
module mux2to1 (
    input  wire i_a,
    input  wire i_b,
    input  wire i_sel,
    output wire o_y
);
    assign o_y = i_sel ? i_b : i_a;
endmodule
```

**Part B:** Build a 4:1 mux by instantiating three 2:1 muxes hierarchically. Create `mux4to1.v`:
```verilog
module mux4to1 (
    input  wire i_d0,
    input  wire i_d1,
    input  wire i_d2,
    input  wire i_d3,
    input  wire [1:0] i_sel,
    output wire o_y
);

    wire w_mux_lo, w_mux_hi;

    // ---- YOUR CODE HERE ----
    // Instantiate three mux2to1 modules:
    //   mux_lo: selects between d0 and d1 using sel[0]
    //   mux_hi: selects between d2 and d3 using sel[0]
    //   mux_final: selects between mux_lo and mux_hi using sel[1]

endmodule
```

**Part C:** Create a top module that uses two switches as select, two switches as data (or hardcoded data), and displays the result on an LED. Program and verify.

**Reflection question:** Open Yosys interactively and run `show` on the synthesized 4:1 mux. Does the structure match your three-mux-instance design, or did Yosys optimize it?

---

#### Exercise 3: 4-Bit Ripple-Carry Adder (25 min)

**Objective (SLO 2.2, 2.4):** Build a hierarchical arithmetic circuit and practice multi-bit design.

**Part A:** Implement `full_adder.v` (provided in the mini-lecture).

**Part B:** Implement `ripple_adder_4bit.v` using four `full_adder` instances (provided in the mini-lecture as a template).

**Part C:** Create a top module:
```verilog
module top_adder (
    input  wire i_switch1,  // a[1]
    input  wire i_switch2,  // a[0]
    input  wire i_switch3,  // b[1]
    input  wire i_switch4,  // b[0]
    output wire o_led1,     // sum[2] (carry into bit 2)
    output wire o_led2,     // sum[1]
    output wire o_led3,     // sum[0]
    output wire o_led4      // (unused or carry out)
);
    // Invert switches (active-low)
    // Use only 2-bit values since we have 4 switches (2 + 2)
    // Instantiate ripple_adder_4bit with upper 2 bits tied to 0
    // Display result on LEDs (remember active-low)

    // ---- YOUR CODE HERE ----

endmodule
```

**Test cases (fill in and verify):**

| a (sw1,sw2) | b (sw3,sw4) | Expected sum (LED1,2,3) |
|---|---|---|
| 00 | 00 | 000 |
| 01 | 01 | 010 |
| 10 | 01 | 011 |
| 11 | 11 | 110 |

---

#### Exercise 4: Hex-to-7-Segment Decoder (30 min)

**Objective (SLO 2.1, 2.5, 2.6):** Design the decoder and display button inputs as a hex digit.

Create `hex_to_7seg.v`:
```verilog
// Hex-to-7-segment decoder
// Input: 4-bit hex value
// Output: 7 segment signals (active low for Go Board)
//         o_seg = {a, b, c, d, e, f, g}
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output wire [6:0] o_seg   // {a, b, c, d, e, f, g} — active low
);

    // Using nested conditional (we'll refactor with case tomorrow)
    assign o_seg = (i_hex == 4'h0) ? 7'b0000001 :  // 0
                   (i_hex == 4'h1) ? 7'b1001111 :  // 1
                   (i_hex == 4'h2) ? 7'b0010010 :  // 2
                   (i_hex == 4'h3) ? 7'b0000110 :  // 3
                   (i_hex == 4'h4) ? 7'b1001100 :  // 4
                   (i_hex == 4'h5) ? 7'b0100100 :  // 5
                   (i_hex == 4'h6) ? 7'b0100000 :  // 6
                   (i_hex == 4'h7) ? 7'b0001111 :  // 7
                   (i_hex == 4'h8) ? 7'b0000000 :  // 8
                   (i_hex == 4'h9) ? 7'b0000100 :  // 9
                   (i_hex == 4'hA) ? 7'b0001000 :  // A
                   (i_hex == 4'hB) ? 7'b1100000 :  // b
                   (i_hex == 4'hC) ? 7'b0110001 :  // C
                   (i_hex == 4'hD) ? 7'b1000010 :  // d
                   (i_hex == 4'hE) ? 7'b0110000 :  // E
                                     7'b0111000 ;  // F

endmodule
```

> **NOTE:** The exact segment encoding above assumes the Go Board's segment pin ordering maps `o_seg[6]` = segment `a` through `o_seg[0]` = segment `g`. **Students must verify this against the actual board schematic and PCF mapping.** Getting the segment order wrong is the #1 source of "my display shows garbage" bugs.

Create `top_7seg.v`:
```verilog
module top_7seg (
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

    // Collect switches into a 4-bit hex value (active-high internally)
    wire [3:0] w_hex = ~{i_switch1, i_switch2, i_switch3, i_switch4};

    // Decoder output
    wire [6:0] w_seg;

    // Instantiate the decoder
    hex_to_7seg decoder (
        .i_hex(w_hex),
        .o_seg(w_seg)
    );

    // Map decoder output to individual segment pins
    assign o_segment1_a = w_seg[6];
    assign o_segment1_b = w_seg[5];
    assign o_segment1_c = w_seg[4];
    assign o_segment1_d = w_seg[3];
    assign o_segment1_e = w_seg[2];
    assign o_segment1_f = w_seg[1];
    assign o_segment1_g = w_seg[0];

endmodule
```

**Verify:** Cycle through all 16 button combinations and confirm 0-F displays correctly.

**Common bugs to watch for:**
- Segment mapping order is wrong (a and g swapped, etc.) — fix by checking the schematic
- Forgot to invert switches at entry
- Decimal point of the 7-seg is floating (might light randomly) — tie it to a known value

---

#### Exercise 5 (Stretch): Adder + Display Integration (20 min)

**Objective (SLO 2.2, 2.4, 2.5):** Combine the adder with the 7-seg decoder to display the sum.

Create a top-level module that:
1. Takes two 2-bit inputs from the 4 switches
2. Adds them using the ripple-carry adder
3. Displays the 4-bit result (0–6 maximum) on the 7-segment display

This integrates three modules: the adder, the decoder, and the top-level glue. Draw the block diagram before writing any code.

**Test:** `3 + 3 = 6` should display `6` on the 7-segment.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. Vectors (`[7:0]`) represent multi-bit buses — always `[MSB:LSB]`
2. Concatenation `{}` and replication `{N{...}}` are fundamental operations
3. Conditional operator `? :` is the mux — your most-used combinational construct
4. Hierarchy through module instantiation — always use named ports
5. The 7-seg decoder is a pure combinational lookup — one of many ways to express it
6. **Always size your literals**: `4'd1`, not `1`

#### Tomorrow: Procedural Combinational Logic
- `always @(*)` blocks and `case` statements — the clean way to write that 7-seg decoder
- `if/else` chains and priority encoding
- The infamous latch inference problem
- You'll refactor today's decoder and build a mini ALU

**Homework:** Watch the Day 3 pre-class video (~45 min). Pay special attention to the section on latch inference — this is where many students hit their first major Verilog bug.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Vector Ops | 2.1, 2.2, 2.6 | Correct LED behavior for reduction operators |
| Ex 2: Mux Hierarchy | 2.3, 2.4 | 4:1 mux works; Yosys `show` matches expected structure |
| Ex 3: Ripple Adder | 2.2, 2.4 | Correct sums on LEDs for all test cases |
| Ex 4: 7-Seg Decoder | 2.1, 2.5, 2.6 | All 16 hex digits display correctly on Go Board |
| Ex 5: Adder + Display | 2.2, 2.4, 2.5 | Addition result shown on 7-seg display |
| Concept check Qs | 2.1, 2.2, 2.3, 2.4, 2.6 | In-class discussion responses |

---

## Instructor Notes

- **Segment encoding bugs** are the #1 time sink on 7-seg day. Have a "known-good" bitstream ready so students can verify their board works before debugging their own code.
- **The adder exercise** may be ambitious for some students on Day 2. It's okay if they don't finish part C — the goal is hierarchy exposure, not adder mastery.
- **Yosys `show`** is highly motivating — students love seeing the actual hardware their code creates. Encourage them to use it freely.
- **Width warnings:** Turn on Yosys/iverilog warnings and teach students to read them. `iverilog -Wall` is your friend.
- **For the hex_to_7seg:** The nested conditional approach is intentionally a little ugly. This sets up tomorrow's `case` statement as a clear improvement. Let students feel the pain today so the payoff lands tomorrow.
- **Time management:** Exercises 1–4 are the priority. Exercise 5 is genuinely stretch. If most students are still on Ex 4 at the 1:45 mark, call them over for the debrief and let them finish Ex 4 as their deliverable.
