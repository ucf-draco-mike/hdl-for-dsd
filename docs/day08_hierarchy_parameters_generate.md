# Day 8: Hierarchy, Parameters & Generate

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 8 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 8.1:** Design a multi-level module hierarchy with at least 3 levels of instantiation, using named port connections and deliberate signal naming.
2. **SLO 8.2:** Parameterize modules using `parameter` for configurable values (widths, counts, thresholds) and `localparam` for derived/internal constants, applying the `#(.PARAM(value))` override syntax at instantiation.
3. **SLO 8.3:** Use `$clog2()` to derive bit widths from parameters automatically, ensuring modules scale correctly when parameters change.
4. **SLO 8.4:** Apply `generate` blocks (`for`-generate, `if`-generate) to replicate hardware structures and conditionally include logic at elaboration time.
5. **SLO 8.5:** Refactor an existing non-parameterized design into a parameterized, reusable module and verify that the parameterized version produces identical behavior at multiple configurations.
6. **SLO 8.6:** Assemble a complete hierarchical system on the Go Board that integrates at least four distinct reusable modules.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: Module Hierarchy Deep Dive (12 min)

#### Hierarchy Is How You Manage Complexity

By Day 8, your designs are getting complex enough that putting everything in one module is untenable. Consider the button counter from Day 5:

```
top_button_counter
├── debounce (switch 1 — reset)
│   └── (internal: 2-FF synchronizer, counter)
├── debounce (switch 2 — count)
│   └── (internal: 2-FF synchronizer, counter)
├── edge_detector (count press)
├── counter_mod_n (4-bit hex counter)
├── hex_to_7seg (display decoder)
└── heartbeat_blinker (LED1)
```

That's already 6+ modules in a relatively simple design. A UART controller will have twice as many. **Good hierarchy is not about saving lines of code — it's about making each module small enough to understand, test, and reuse independently.**

#### Naming Conventions for Hierarchical Designs

Consistent naming dramatically reduces bugs in complex hierarchies:

```verilog
module top_uart_demo (
    // Top-level I/O — matches PCF
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_led1,
    output wire o_uart_tx
);

    // Internal wires between modules — prefix with source module
    wire w_debounce_clean;
    wire w_edge_press;
    wire [7:0] w_counter_value;
    wire w_uart_tx_busy;
    wire w_uart_tx_serial;

    // Module instances — descriptive names
    debounce #(.CLKS_TO_STABLE(250_000)) debounce_sw1 (
        .i_clk     (i_clk),
        .i_bouncy  (i_switch1),
        .o_clean   (w_debounce_clean)
    );

    // ...
endmodule
```

**Rules we'll follow:**
- Instance names describe the specific role: `debounce_sw1`, `debounce_sw2`, not `u1`, `u2`
- Internal wires are prefixed by the driving module or describe the signal's purpose
- Every port connection is named (no positional connections, ever)
- One instance per line for small modules; port-per-line for complex modules

#### Top-Down vs. Bottom-Up Design

**Bottom-up:** Build and test small modules first, then compose them. This is what we've been doing — building `hex_to_7seg`, `debounce`, counters, and now connecting them.

**Top-down:** Design the top-level block diagram first, identify the sub-modules needed, define their interfaces, then implement each one. This is how industry projects typically start.

In practice, you use both: top-down to plan the architecture, bottom-up to implement and test. The key deliverable at the architectural stage is the **interface specification** — the port list and behavior contract for each module.

---

### Video Segment 2: Parameters and Parameterization (15 min)

#### `parameter` — Configurable at Instantiation

```verilog
module counter #(
    parameter WIDTH = 8,
    parameter MAX_COUNT = 255  // default: counts 0 to 255
)(
    input  wire                  i_clk,
    input  wire                  i_reset,
    input  wire                  i_enable,
    output reg  [WIDTH-1:0]      o_count,
    output wire                  o_done
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == MAX_COUNT)
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end

    assign o_done = (o_count == MAX_COUNT);

endmodule
```

**Instantiation with parameter override:**
```verilog
// 16-bit counter, counts to 49999
counter #(
    .WIDTH(16),
    .MAX_COUNT(49_999)
) baud_counter (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_enable(1'b1),
    .o_count(w_baud_count),
    .o_done(w_baud_tick)
);

// 4-bit counter, default MAX_COUNT (255 is wrong — it wraps at 15 for 4-bit!)
// This is a design bug: MAX_COUNT should be derived from WIDTH
counter #(.WIDTH(4)) hex_counter (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_enable(w_tick),
    .o_count(w_hex_value),
    .o_done()                // unconnected — legal, signals intentionally unused
);
```

**The bug in the 4-bit instantiation:** `MAX_COUNT` defaults to 255, but a 4-bit counter can only represent 0–15. The counter will never reach 255, so `o_done` will never assert. This is why **derived parameters** matter.

#### `localparam` — Internal/Derived Constants

`localparam` cannot be overridden at instantiation. Use it for:
- Constants derived from `parameter` values
- Internal thresholds or magic numbers
- State encodings

```verilog
module counter #(
    parameter WIDTH = 8
)(
    // ...
);

    localparam MAX_COUNT = (1 << WIDTH) - 1;  // Derived: 2^WIDTH - 1
    // For WIDTH=8: MAX_COUNT = 255
    // For WIDTH=4: MAX_COUNT = 15
    // Always correct!

endmodule
```

#### `$clog2` — Automatic Width Calculation

`$clog2(N)` returns ceil(log2(N)) — the number of bits needed to represent values 0 through N−1.

```verilog
module timer #(
    parameter TICKS = 1_000_000
)(
    input  wire i_clk,
    input  wire i_start,
    output reg  o_done
);

    localparam CNT_WIDTH = $clog2(TICKS);  // automatically sized

    reg [CNT_WIDTH-1:0] r_count;

    // ... counter logic ...

endmodule
```

**Why this matters:** If you change `TICKS` from 1,000,000 to 10,000, the counter width automatically adjusts from 20 bits to 14 bits. No manual recalculation. No wasted flip-flops. No overflow bugs.

#### Parameterization Guidelines

**Parameterize:**
- Bit widths
- Counter thresholds / timing values
- Number of instances
- Clock frequency (so baud rate calculations are portable)

**Don't parameterize:**
- Everything. Over-parameterization makes code hard to read. If a value is always the same in every use case, make it a `localparam`.
- State encodings (these are internal to the module — use `localparam`)

---

### Video Segment 3: Generate Blocks (12 min)

#### `for`-Generate: Hardware Replication

A `generate for` loop creates multiple instances of hardware at **elaboration time** (before simulation or synthesis). It is not a runtime loop — it's a compile-time macro.

```verilog
module parallel_debounce #(
    parameter N_BUTTONS = 4,
    parameter CLKS_TO_STABLE = 250_000
)(
    input  wire              i_clk,
    input  wire [N_BUTTONS-1:0] i_buttons,
    output wire [N_BUTTONS-1:0] o_clean
);

    genvar g;
    generate
        for (g = 0; g < N_BUTTONS; g = g + 1) begin : gen_debounce
            debounce #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) db_inst (
                .i_clk    (i_clk),
                .i_bouncy (i_buttons[g]),
                .o_clean  (o_clean[g])
            );
        end
    endgenerate

endmodule
```

**Key syntax:**
- `genvar g;` — the loop variable (exists only at elaboration, not at runtime)
- `begin : gen_debounce` — the label is **required** for generate loops (names the scope)
- Each iteration creates a separate instance: `gen_debounce[0].db_inst`, `gen_debounce[1].db_inst`, etc.

**What this expands to:**
```verilog
// Equivalent to writing:
debounce #(.CLKS_TO_STABLE(250_000)) gen_debounce[0].db_inst (.i_clk(i_clk), .i_bouncy(i_buttons[0]), .o_clean(o_clean[0]));
debounce #(.CLKS_TO_STABLE(250_000)) gen_debounce[1].db_inst (.i_clk(i_clk), .i_bouncy(i_buttons[1]), .o_clean(o_clean[1]));
debounce #(.CLKS_TO_STABLE(250_000)) gen_debounce[2].db_inst (.i_clk(i_clk), .i_bouncy(i_buttons[2]), .o_clean(o_clean[2]));
debounce #(.CLKS_TO_STABLE(250_000)) gen_debounce[3].db_inst (.i_clk(i_clk), .i_bouncy(i_buttons[3]), .o_clean(o_clean[3]));
```

#### `if`-Generate: Conditional Hardware

Include or exclude hardware based on a parameter value:

```verilog
module uart_tx #(
    parameter PARITY_ENABLE = 0  // 0 = no parity, 1 = even parity
)(
    // ...
);

    generate
        if (PARITY_ENABLE) begin : gen_parity
            // Parity computation logic (only synthesized if enabled)
            wire w_parity = ^i_data;  // XOR reduction = even parity
            // ... parity insertion into serial stream ...
        end
    endgenerate

endmodule
```

**The hardware inside the `if`-generate is physically absent when the condition is false.** It doesn't consume LUTs or flip-flops. This is fundamentally different from a runtime `if` — there's no mux selecting between two paths. Only one path exists.

#### Generate vs. Runtime Constructs

| | `generate for` | `always` for loop |
|---|---|---|
| When it runs | Elaboration (compile time) | Simulation / synthesis time |
| Creates | Multiple module instances | Iterative combinational/sequential logic |
| Can instantiate modules? | Yes | No |
| Loop variable | `genvar` | `integer` or `reg` |
| Use case | Replicating hardware structures | Bit-by-bit operations within a module |

---

### Video Segment 4: Design for Reuse (6 min)

#### Your Personal Module Library

By the end of this course, you should have a collection of well-tested, parameterized modules ready for reuse:

| Module | Key Parameters | Status |
|---|---|---|
| `debounce` | `CLKS_TO_STABLE` | Done (Day 5) |
| `hex_to_7seg` | (none needed — always 4→7) | Done (Day 2/3) |
| `counter` | `WIDTH`, `MAX_COUNT` | Today |
| `shift_reg` | `WIDTH`, direction | Done (Day 5) |
| `lfsr` | `WIDTH`, taps | Done (Day 5) |
| `edge_detect` | (none) | Today |
| `synchronizer` | `WIDTH` | Today |
| `uart_tx` | `CLK_FREQ`, `BAUD_RATE` | Week 3 |
| `uart_rx` | `CLK_FREQ`, `BAUD_RATE` | Week 3 |

#### Reuse Checklist

Before adding a module to your library:
- [ ] Parameterized for common variation points
- [ ] Self-checking testbench passes at 2+ parameter configurations
- [ ] Port names follow consistent naming conventions
- [ ] No hardcoded magic numbers — use `localparam` with descriptive names
- [ ] Default parameter values are sensible (someone can instantiate it without overrides)
- [ ] Module header comment: purpose, interface description, parameter guide

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick question:** You have a module with `parameter WIDTH = 8`. Inside, you write `reg [WIDTH-1:0] r_data;`. A colleague instantiates your module with `.WIDTH(0)`. What happens?

> *Answer: `reg [-1:0] r_data` — a negative range. This is either a synthesis error or creates a zero-width signal (tool-dependent). Defensive design: add a comment or assertion that WIDTH must be ≥ 1. In SystemVerilog, you could add `initial assert(WIDTH > 0)`. In Verilog, you rely on documentation.*

---

### Mini-Lecture: Parameterization Patterns and Generate (30 min)

#### Live Refactoring: Parameterizing the Counter (10 min)

Start with the Day 4 fixed-width counter. Refactor to parameterized version:

**Before (hardcoded):**
```verilog
module hex_counter (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_enable,
    output reg  [3:0] o_count,
    output wire       o_wrap
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 4'd0;
        else if (i_enable) begin
            if (o_count == 4'd15)
                o_count <= 4'd0;
            else
                o_count <= o_count + 4'd1;
        end
    end
    assign o_wrap = i_enable && (o_count == 4'd15);
endmodule
```

**After (parameterized):**
```verilog
module counter_mod_n #(
    parameter N = 16   // counts 0 to N-1, default: hex counter
)(
    input  wire                      i_clk,
    input  wire                      i_reset,
    input  wire                      i_enable,
    output reg  [$clog2(N)-1:0]      o_count,
    output wire                      o_wrap
);

    localparam MAX = N - 1;

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == MAX[$clog2(N)-1:0])
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end

    assign o_wrap = i_enable && (o_count == MAX[$clog2(N)-1:0]);

endmodule
```

**What changed:**
- `4` → `$clog2(N)` everywhere
- `15` → `MAX` (derived from parameter)
- Works for N=10 (decimal counter), N=16 (hex), N=60 (seconds), N=256 (byte counter)

**Verify:** Instantiate as `counter_mod_n #(.N(10))` — does `$clog2(10) = 4` work? Yes, 4 bits represent 0–9. Does it wrap at 9? Yes, because MAX = 9.

#### Generate Block Demo (10 min)

**Problem:** Create an N-channel LED blinker where each LED blinks at a different rate.

```verilog
module multi_blinker #(
    parameter N_LEDS    = 4,
    parameter CLK_FREQ  = 25_000_000,
    parameter BASE_RATE = 1            // Hz — slowest LED
)(
    input  wire              i_clk,
    output wire [N_LEDS-1:0] o_leds
);

    genvar g;
    generate
        for (g = 0; g < N_LEDS; g = g + 1) begin : gen_blink

            // Each LED blinks at BASE_RATE * 2^g Hz
            localparam THIS_HALF_PERIOD = CLK_FREQ / (BASE_RATE * (2 ** (g + 1)));
            localparam CNT_WIDTH = $clog2(THIS_HALF_PERIOD);

            reg [CNT_WIDTH-1:0] r_count;
            reg                 r_led;

            always @(posedge i_clk) begin
                if (r_count == THIS_HALF_PERIOD - 1) begin
                    r_count <= 0;
                    r_led   <= ~r_led;
                end else begin
                    r_count <= r_count + 1;
                end
            end

            assign o_leds[g] = ~r_led;  // active-low

        end
    endgenerate

endmodule
```

**Show in Yosys:** Use `stat` to show that 4 separate counters were created, each with different widths. Use `show` to visualize the replicated structure.

#### Design Pattern: Conditional Feature Inclusion (10 min)

```verilog
module configurable_counter #(
    parameter WIDTH       = 8,
    parameter HAS_ENABLE  = 1,
    parameter HAS_LOAD    = 0,
    parameter UP_DOWN     = 0   // 0 = up only, 1 = bidirectional
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_enable,    // only used if HAS_ENABLE
    input  wire              i_load,      // only used if HAS_LOAD
    input  wire              i_direction, // only used if UP_DOWN
    input  wire [WIDTH-1:0]  i_data,      // only used if HAS_LOAD
    output reg  [WIDTH-1:0]  o_count
);

    always @(posedge i_clk) begin
        if (i_reset) begin
            o_count <= 0;
        end else begin
            // Load takes priority if enabled
            if (HAS_LOAD && i_load) begin
                o_count <= i_data;
            end
            // Count if enabled (or always count if no enable feature)
            else if (!HAS_ENABLE || i_enable) begin
                if (UP_DOWN && i_direction)
                    o_count <= o_count - 1;
                else
                    o_count <= o_count + 1;
            end
        end
    end

endmodule
```

**Note:** The `if (HAS_LOAD && i_load)` condition — when `HAS_LOAD = 0`, the synthesis tool evaluates `0 && i_load` as always false and optimizes away the entire load path. The `i_load` and `i_data` inputs become unconnected and are removed. This is constant propagation at synthesis time, not runtime logic.

---

### Concept Check Questions

**Q1 (SLO 8.2):** What's the difference between `parameter` and `localparam`?

> **Expected answer:** `parameter` can be overridden at instantiation using `#(.PARAM(value))`. `localparam` cannot be overridden — it's fixed within the module. Use `parameter` for values the user should configure, `localparam` for internal constants and values derived from parameters.

**Q2 (SLO 8.3):** A student writes `parameter N = 12` and then `reg [$clog2(N)-1:0] r_count;`. How many bits is `r_count`?

> **Expected answer:** `$clog2(12) = 4` (since 2^3 = 8 < 12 ≤ 16 = 2^4). So `r_count` is 4 bits: `[3:0]`. It can represent 0–15, which covers the needed range of 0–11.

**Q3 (SLO 8.4):** A student writes a `for` loop inside an `always @(*)` block to compute the OR-reduction of a bus. Is this a `generate` loop?

> **Expected answer:** No. A `for` loop inside `always` is a behavioral loop that computes at simulation/synthesis time within a single module. A `generate for` uses `genvar` and creates multiple instances of hardware structures (modules, `always` blocks, `assign` statements). The behavioral loop creates combinational logic; the generate loop creates replicated structural hierarchy.

**Q4 (SLO 8.4):** Why does a `generate for` block require a label (`begin : name`)?

> **Expected answer:** The label creates a named scope for each iteration, so internal signals and instances have unique hierarchical names (e.g., `gen_debounce[0].db_inst`, `gen_debounce[1].db_inst`). Without the label, the simulator/synthesizer can't uniquely reference each generated instance, which is needed for debugging, waveform viewing, and synthesis.

**Q5 (SLO 8.5):** You parameterize a module and test it with `WIDTH=8`. A colleague instantiates it with `WIDTH=1`. What kinds of bugs might appear?

> **Expected answer:** Edge cases at width boundaries: `$clog2(1) = 0` in some tools (which creates a zero-width signal — error), `[WIDTH-2:0]` becomes `[-1:0]` (negative range), addition overflow behavior changes, reduction operators on 1-bit signals may behave unexpectedly. Always test at minimum, maximum, and boundary widths.

---

### Lab Exercises (2 hours)

#### Exercise 1: Parameterized Counter Module (25 min)

**Objective (SLO 8.2, 8.3, 8.5):** Build the universal counter and test it at multiple configurations.

Create `counter_mod_n.v` — the parameterized counter from the mini-lecture.

Create `tb_counter_mod_n.v`:

```verilog
`timescale 1ns / 1ps

module tb_counter_mod_n;

    // ========== Test Configuration 1: N=10 (decimal) ==========
    reg clk, reset, enable;
    wire [3:0] count_10;      // $clog2(10) = 4
    wire wrap_10;

    counter_mod_n #(.N(10)) uut_10 (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count_10), .o_wrap(wrap_10)
    );

    // ========== Test Configuration 2: N=16 (hex) ==========
    wire [3:0] count_16;
    wire wrap_16;

    counter_mod_n #(.N(16)) uut_16 (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count_16), .o_wrap(wrap_16)
    );

    // ========== Test Configuration 3: N=60 (seconds) ==========
    wire [5:0] count_60;      // $clog2(60) = 6
    wire wrap_60;

    counter_mod_n #(.N(60)) uut_60 (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count_60), .o_wrap(wrap_60)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // ---- YOUR CODE HERE ----
    // Task: verify_counter_wrap
    //   Parameters: expected max value, actual count signal, wrap signal, label
    //   Run the counter until wrap asserts
    //   Verify wrap asserts at exactly the expected count
    //   Verify count returns to 0 after wrap

    initial begin
        $dumpfile("tb_counter.vcd");
        $dumpvars(0, tb_counter_mod_n);

        reset = 1; enable = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // Test all three configurations
        // ---- YOUR TESTS HERE ----

        $display("Counter tests: %0d passed, %0d failed",
                 test_count - fail_count, fail_count);
        $finish;
    end

endmodule
```

**Required tests per configuration:**
1. Reset → count is 0
2. Count to max, verify wrap signal
3. Verify count returns to 0 after wrap
4. Enable test: disable for 5 cycles, verify count holds

---

#### Exercise 2: Generate-Based Multi-Debounce (25 min)

**Objective (SLO 8.4):** Use `generate` to create parameterized multi-channel infrastructure.

Create `go_board_input.v` — a single module that debounces all 4 Go Board buttons:

```verilog
module go_board_input #(
    parameter N_BUTTONS     = 4,
    parameter CLK_FREQ      = 25_000_000,
    parameter DEBOUNCE_MS   = 10
)(
    input  wire                  i_clk,
    input  wire [N_BUTTONS-1:0]  i_buttons_n,  // active-low raw inputs
    output wire [N_BUTTONS-1:0]  o_buttons,     // active-high, debounced
    output wire [N_BUTTONS-1:0]  o_press_edge,  // one-cycle pulse on press
    output wire [N_BUTTONS-1:0]  o_release_edge // one-cycle pulse on release
);

    localparam CLKS_TO_STABLE = (CLK_FREQ / 1000) * DEBOUNCE_MS;

    genvar g;
    generate
        for (g = 0; g < N_BUTTONS; g = g + 1) begin : gen_btn

            // Debounce
            wire w_clean;
            debounce #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) db (
                .i_clk(i_clk),
                .i_bouncy(i_buttons_n[g]),
                .o_clean(w_clean)
            );

            // Invert (active-low → active-high)
            assign o_buttons[g] = ~w_clean;

            // Edge detection
            reg r_prev;
            always @(posedge i_clk)
                r_prev <= o_buttons[g];

            assign o_press_edge[g]   = o_buttons[g] & ~r_prev;
            assign o_release_edge[g] = ~o_buttons[g] & r_prev;

        end
    endgenerate

endmodule
```

**Student tasks:**
1. Implement this module (filling in any gaps)
2. Create a top module that uses it to drive a 4-button counter system:
   - Button 1: reset
   - Button 2: count up
   - Button 3: count down
   - Button 4: load a preset value
   - Display count on 7-segment
3. Write a testbench with short debounce parameters that verifies all 4 channels produce clean edge pulses

---

#### Exercise 3: Hierarchical System Integration (30 min)

**Objective (SLO 8.1, 8.6):** Build the most complex system of the course so far.

Create a "digital lab instrument" top-level that integrates everything:

```
top_lab_instrument
├── go_board_input (4-channel debounce + edge detect)
│   └── debounce [×4] (via generate)
├── counter_mod_n #(.N(256)) (8-bit main counter)
├── counter_mod_n #(.N(16))  (4-bit display select counter)
├── hex_to_7seg (display 1 — lower nibble)
├── hex_to_7seg (display 2 — upper nibble)
├── lfsr_8bit (random number generator)
└── multi_blinker (heartbeat LEDs)
```

Behavior:
- Button 1: reset everything
- Button 2: increment the 8-bit counter
- Button 3: load the LFSR value into the counter
- Button 4: step the LFSR (generate next random number)
- Display 1: lower 4 bits of counter (hex)
- Display 2: upper 4 bits of counter (hex)
- LEDs: heartbeat at different rates

```verilog
module top_lab_instrument (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_segment2_a, o_segment2_b, o_segment2_c,
    output wire o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);

    // --- Input Processing ---
    wire [3:0] w_buttons, w_press;

    go_board_input #(
        .N_BUTTONS(4),
        .CLK_FREQ(25_000_000),
        .DEBOUNCE_MS(10)
    ) inputs (
        .i_clk(i_clk),
        .i_buttons_n({i_switch1, i_switch2, i_switch3, i_switch4}),
        .o_buttons(w_buttons),
        .o_press_edge(w_press),
        .o_release_edge()        // unused
    );

    wire w_reset  = w_buttons[3];   // sw1 held = reset
    wire w_inc    = w_press[2];     // sw2 press = increment
    wire w_load   = w_press[1];     // sw3 press = load from LFSR
    wire w_lfsr   = w_press[0];     // sw4 press = step LFSR

    // --- LFSR ---
    // ---- YOUR CODE HERE ----

    // --- Main Counter (8-bit, loadable) ---
    // ---- YOUR CODE HERE ----

    // --- Displays ---
    // ---- YOUR CODE HERE ----

    // --- LEDs ---
    // ---- YOUR CODE HERE ----

endmodule
```

**Deliverable:** Working system on the Go Board. Both 7-seg displays showing the counter value. All 4 buttons functional. Testbench for at least the counter + load interaction.

---

#### Exercise 4 (Stretch): Parameterized LFSR (20 min)

**Objective (SLO 8.2, 8.4, 8.5):** Generalize the LFSR to arbitrary widths.

Create `lfsr_generic.v`:

```verilog
module lfsr_generic #(
    parameter WIDTH = 8,
    parameter SEED  = 1
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_enable,
    output reg [WIDTH-1:0]   o_lfsr
);

    // Tap lookup — maximal-length taps for common widths
    // (Not all widths are supported — add as needed)
    wire w_feedback;

    generate
        if (WIDTH == 4)
            assign w_feedback = o_lfsr[3] ^ o_lfsr[2];
        else if (WIDTH == 8)
            assign w_feedback = o_lfsr[7] ^ o_lfsr[5] ^ o_lfsr[4] ^ o_lfsr[3];
        else if (WIDTH == 16)
            assign w_feedback = o_lfsr[15] ^ o_lfsr[14] ^ o_lfsr[12] ^ o_lfsr[3];
        else if (WIDTH == 32)
            assign w_feedback = o_lfsr[31] ^ o_lfsr[21] ^ o_lfsr[1] ^ o_lfsr[0];
        else
            // Unsupported width — will produce a synthesis warning
            assign w_feedback = ^o_lfsr;  // XOR reduction (not maximal-length)
    endgenerate

    always @(posedge i_clk) begin
        if (i_reset)
            o_lfsr <= SEED[WIDTH-1:0];
        else if (i_enable)
            o_lfsr <= {o_lfsr[WIDTH-2:0], w_feedback};
    end

endmodule
```

**Testbench challenge:** Verify maximal-length property at WIDTH=4, 8, and 16. For WIDTH=4, verify the sequence is exactly 15 states long. For WIDTH=8, verify 255. For WIDTH=16, verify... well, 65535 cycles is feasible in simulation.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **Hierarchy** manages complexity — each module should be independently understandable and testable
2. **`parameter`** makes modules reusable across projects; `localparam` keeps internal constants clean
3. **`$clog2()`** derives widths automatically — eliminates a whole class of manual-calculation bugs
4. **`generate`** replicates hardware at compile time — `for`-generate for arrays, `if`-generate for conditional features
5. **Test at multiple configurations** — a module that works at WIDTH=8 might break at WIDTH=1 or WIDTH=32

#### Week 2 Recap

In 4 days you've added:
- Debouncing and metastability protection (real-world robustness)
- Formal testbench methodology (professional verification practice)
- FSMs (the core design pattern for all controllers)
- Parameterization and generate (reusable, scalable designs)

Your module library now has ~10 tested, reusable modules. This is the foundation for Week 3, where we build real communication interfaces.

#### Preview: Week 3 — Interfaces, Memory & Communication
- Day 9: Memory — ROM, RAM, block RAM, `$readmemh`
- Day 10: Timing constraints, PLLs, clock domain crossing
- Day 11: UART TX — your first communication interface
- Day 12: UART RX, SPI, IP integration

**This is where everything comes together.** Your UART TX will be an FSM + shift register + parameterized baud generator. Everything you've built so far is a prerequisite.

**Homework:** Watch the Day 9 pre-class video (~45 min) on memory modeling in Verilog.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Parameterized Counter | 8.2, 8.3, 8.5 | Counter works at N=10, 16, 60; testbench passes all configurations |
| Ex 2: Generate Multi-Debounce | 8.4 | 4-channel debounce works; testbench verifies all channels |
| Ex 3: System Integration | 8.1, 8.6 | 3+ level hierarchy; all buttons functional; both displays working |
| Ex 4: Generic LFSR | 8.2, 8.4, 8.5 | Maximal-length verified at multiple widths |
| Concept check Qs | 8.2, 8.3, 8.4, 8.5 | In-class discussion responses |

---

## Instructor Notes

- **Exercise 3 is the capstone of Week 2** — it ties together everything from the past 8 days. It's ambitious. Students who get it working should feel a real sense of accomplishment. Students who don't finish can complete it for homework.
- **The `$clog2` edge case** at N=1 is a real gotcha. Icarus Verilog returns 0 for `$clog2(1)`, which creates `reg [-1:0]` — some tools handle this, others don't. Mention it but don't dwell on it. Professional practice: add a note "N must be ≥ 2" in the module header.
- **Generate blocks confuse students** because they look like runtime code but execute at compile time. The key analogy: "It's like a C preprocessor macro or a template expansion. The hardware that exists after synthesis is fixed — there are no loops running on the FPGA."
- **Unconnected ports** (`.o_release_edge()`) — explain that empty parentheses mean "intentionally unconnected." This is clean and explicit. Leaving the port out entirely is legal but generates a warning in some tools.
- **Timing:** Exercise 1 is quick (25 min). Exercise 2 is moderate (25 min). Exercise 3 is the main event (30 min). Exercise 4 is stretch. If students are behind, let them skip Exercise 2 and go to Exercise 3, using the `go_board_input` module as provided code.
- **End of Week 2 milestone:** Students should be able to design, parameterize, test, and compose modules fluently. If a student is still struggling with basic sequential logic or testbenches at this point, they need extra support before Week 3's communication interfaces.
