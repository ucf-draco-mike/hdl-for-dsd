# Day 13: SystemVerilog for Design

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 13 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 13.1:** Replace `wire`/`reg` declarations with the unified `logic` type and explain how it eliminates the reg-doesn't-mean-register confusion.
2. **SLO 13.2:** Use `always_ff`, `always_comb`, and `always_latch` blocks to express designer intent, and explain how the compiler enforces correct usage for each.
3. **SLO 13.3:** Define FSM states using `enum` types, including `typedef enum`, and access state names in simulation using `.name()` for debug printing.
4. **SLO 13.4:** Group related signals into `struct` types using `typedef struct packed` and use them for cleaner module interfaces and internal signal bundling.
5. **SLO 13.5:** Create a `package` with shared type definitions and `import` it into multiple modules, establishing a single source of truth for project-wide types and constants.
6. **SLO 13.6:** Refactor an existing Verilog module into SystemVerilog, compare the two versions side by side, and verify they produce identical synthesis results.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: Why SystemVerilog? (8 min)

#### The Evolution

Verilog was standardized as IEEE 1364 in 1995, with a major update in 2001 (Verilog-2001). SystemVerilog (IEEE 1800, first standardized 2005, latest revision 2017) is a superset of Verilog that adds:

- **Design improvements:** `logic` type, intent-based `always` blocks, `enum`, `struct`, `package`, `interface`
- **Verification improvements:** classes, randomization, assertions, functional coverage, `program` blocks
- **Both are one language:** Every legal Verilog-2001 file is legal SystemVerilog. You can mix them freely.

#### Why Learn It Now?

In industry, SystemVerilog has largely replaced Verilog for new designs. The verification side (UVM, constrained random, formal) is where the bulk of engineering effort goes on any serious project. Even if you only write design RTL (not testbenches), SystemVerilog's design features catch bugs that Verilog silently accepts.

**Today:** Design features — making your RTL safer and more readable.
**Tomorrow:** Verification features — making your testbenches more powerful.

#### Toolchain Note

- **Icarus Verilog:** Partial SystemVerilog support via the `-g2012` flag. Supports `logic`, `always_ff`/`always_comb`, basic `enum`. Does NOT support `package`, `interface`, classes, or assertions.
- **Verilator:** Excellent SystemVerilog support for synthesis-oriented constructs. Free, open-source. Good for linting and simulation.
- **Yosys:** Supports many SystemVerilog constructs for synthesis via the `-sv` flag. Coverage varies by feature.
- **Commercial tools (Questa, VCS, Xcelium):** Full SystemVerilog support.

For this course, we'll use `iverilog -g2012` for simulation and `yosys read_verilog -sv` for synthesis. Some advanced SV features will be demonstration-only.

---

### Video Segment 2: `logic` — One Type to Rule Them All (10 min)

#### The Problem With `wire` and `reg`

In Verilog, you must choose between `wire` and `reg` based on **where the signal is assigned**, not what hardware it represents:

```verilog
// Verilog: Must know the assignment context to choose the type
wire [7:0] w_data;      // driven by assign or module output
reg  [7:0] r_result;    // driven inside always block

// But r_result might be combinational (always @(*)) or sequential (always @(posedge clk))
// The name 'reg' tells you nothing about the hardware
```

#### The `logic` Type

SystemVerilog's `logic` replaces both `wire` and `reg`:

```systemverilog
// SystemVerilog: one type, any context
logic [7:0] data;       // can be driven by assign, always_ff, always_comb, or port
logic [7:0] result;     // same type regardless of usage

// The HARDWARE is determined by the always block type, not the variable type
```

**`logic` can be:**
- Driven by `assign` (like `wire`)
- Driven by `always_ff` (becomes a register)
- Driven by `always_comb` (becomes combinational logic)
- Used as a module port (input, output, inout)

**One restriction:** `logic` can only have **one driver**. If you need a signal with multiple drivers (a bus with tri-state — rare in FPGA design), use `wire`. For 99% of designs, `logic` is all you need.

#### Port Declarations

```systemverilog
module my_module (
    input  logic       i_clk,
    input  logic       i_reset,
    input  logic [7:0] i_data,
    output logic [7:0] o_result,   // no more wire/reg decision!
    output logic       o_valid
);
```

No need to decide whether the output is `wire` or `reg` at the port declaration. The `always` block type determines the hardware.

---

### Video Segment 3: Intent-Based Always Blocks (12 min)

#### `always_ff` — Sequential Logic

```systemverilog
always_ff @(posedge i_clk) begin
    if (i_reset)
        r_count <= '0;
    else
        r_count <= r_count + 1;
end
```

**Compiler enforcement:**
- Must have a clock edge in the sensitivity list
- Should use nonblocking assignment (`<=`)
- The compiler will **warn or error** if you use blocking assignment (`=`) inside `always_ff`
- The compiler will **warn or error** if you drive a signal from `always_ff` and also from `assign` or another `always` block

`always_ff` tells the compiler: "I intend this to be a flip-flop. If I've written something that isn't a flip-flop, please tell me."

#### `always_comb` — Combinational Logic

```systemverilog
always_comb begin
    case (i_opcode)
        2'b00:   o_result = i_a + i_b;
        2'b01:   o_result = i_a - i_b;
        2'b10:   o_result = i_a & i_b;
        default: o_result = i_a | i_b;
    endcase
end
```

**Compiler enforcement:**
- **No sensitivity list** — `always_comb` automatically includes all read signals (like `@(*)` but stronger)
- Must use blocking assignment (`=`)
- The compiler will **error** if a latch would be inferred (incomplete assignment paths)
- The compiler checks at compile time, not at synthesis time — you find bugs earlier

**This is the biggest win of SystemVerilog for design.** In Verilog, unintentional latches are runtime/synthesis warnings that you might miss. In SystemVerilog, `always_comb` makes them **compile-time errors**. The entire category of "forgot a default assignment" bugs becomes impossible.

#### `always_latch` — When You Actually Want a Latch

```systemverilog
always_latch begin
    if (i_enable)
        o_q = i_d;
end
```

On the rare occasion when you intentionally want a latch, `always_latch` documents that intent. The compiler will not warn about latch inference. If you use `always_comb` and the compiler detects latch behavior, it's an error. If you use `always_latch`, the compiler accepts it.

#### Side-by-Side Comparison

```verilog
// ====== Verilog ======
reg [3:0] r_result;
reg       o_carry;

always @(*) begin
    r_result = 4'b0000;   // default (latch prevention — manual!)
    o_carry  = 1'b0;
    case (i_opcode)
        2'b00: {o_carry, r_result} = i_a + i_b;
        2'b01: {o_carry, r_result} = i_a - i_b;
        2'b10: r_result = i_a & i_b;
        2'b11: r_result = i_a | i_b;
    endcase
end
```

```systemverilog
// ====== SystemVerilog ======
logic [3:0] result;
logic       carry;

always_comb begin
    result = 4'b0000;   // default (still good practice)
    carry  = 1'b0;
    case (i_opcode)
        2'b00: {carry, result} = i_a + i_b;
        2'b01: {carry, result} = i_a - i_b;
        2'b10: result = i_a & i_b;
        2'b11: result = i_a | i_b;
    endcase
end
// If we FORGOT the defaults, always_comb would ERROR
// In Verilog, always @(*) would silently infer latches
```

---

### Video Segment 4: `enum`, `struct`, and `package` (15 min)

#### `enum` — Named States

```systemverilog
// Verilog FSM states
localparam S_IDLE  = 2'b00;
localparam S_START = 2'b01;
localparam S_DATA  = 2'b10;
localparam S_STOP  = 2'b11;
reg [1:0] r_state, r_next_state;

// SystemVerilog FSM states
typedef enum logic [1:0] {
    S_IDLE  = 2'b00,
    S_START = 2'b01,
    S_DATA  = 2'b10,
    S_STOP  = 2'b11
} uart_state_t;

uart_state_t state, next_state;
```

**Benefits:**
- **Type safety:** `state = 3;` is a compile warning/error — 3 isn't a valid `uart_state_t` value
- **Debug printing:** `$display("State: %s", state.name());` prints `"State: S_IDLE"` instead of `"State: 0"`
- **Automatic encoding:** You can omit the explicit values and let the compiler assign them
- **Synthesis:** Identical to `localparam` — no hardware cost

```systemverilog
// Let the compiler choose encoding
typedef enum logic [1:0] {
    S_IDLE,    // automatically 0
    S_START,   // automatically 1
    S_DATA,    // automatically 2
    S_STOP     // automatically 3
} uart_state_t;
```

#### `struct` — Grouped Signals

```systemverilog
// Instead of many separate signals:
logic [7:0] tx_data;
logic       tx_valid;
logic       tx_busy;
logic       tx_done;

// Group them:
typedef struct packed {
    logic [7:0] data;
    logic       valid;
    logic       busy;
    logic       done;
} uart_tx_ctrl_t;

uart_tx_ctrl_t tx_ctrl;

// Access fields with dot notation:
tx_ctrl.data  = 8'h41;
tx_ctrl.valid = 1'b1;
if (tx_ctrl.busy) ...
```

**`packed` keyword:** The struct is stored as a contiguous bit vector. `uart_tx_ctrl_t` is 11 bits wide (8+1+1+1). You can assign it as a whole or access individual fields. Packed structs are fully synthesizable.

**Use cases:**
- Configuration registers: group related settings
- Bus interfaces: group address, data, control signals
- Internal datapaths: group data with its metadata (valid, error, tag)

#### `package` — Shared Definitions

```systemverilog
// File: uart_pkg.sv
package uart_pkg;

    // Constants
    localparam int CLK_FREQ  = 25_000_000;
    localparam int BAUD_RATE = 115_200;

    // Types
    typedef enum logic [2:0] {
        S_IDLE,
        S_START,
        S_DATA,
        S_PARITY,
        S_STOP
    } uart_state_t;

    typedef struct packed {
        logic [7:0] data;
        logic       parity_error;
        logic       frame_error;
    } uart_rx_result_t;

endpackage
```

```systemverilog
// File: uart_tx.sv
module uart_tx
    import uart_pkg::*;   // import everything from the package
(
    input  logic       i_clk,
    input  logic       i_reset,
    // ...
);

    uart_state_t state, next_state;   // type from package
    // CLK_FREQ and BAUD_RATE are available from package

endmodule
```

**Benefits:**
- Single source of truth for shared types and constants
- Change the state encoding in one place → all modules update
- Prevents type mismatches between modules
- Clean alternative to `include` files

**Toolchain caveat:** `package` requires full SystemVerilog support. Icarus Verilog (`-g2012`) does NOT support packages. Verilator does. Yosys has partial support. For this course, we'll demonstrate the concept but may need to use `include` as a fallback.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick quiz — identify the Verilog bugs that SystemVerilog would catch:**

```verilog
reg [3:0] result;

always @(sel, a)  // missing 'b' in sensitivity list
begin
    if (sel)
        result = a;
    // missing else — latch!
end
```

> *Answer: (1) `always @(sel, a)` — manual sensitivity list missing `b`. `always_comb` would auto-include all inputs. (2) Missing `else` creates a latch on `result`. `always_comb` would detect this as an incomplete assignment and produce a compile error. Two bugs that Verilog silently accepts, both caught by SystemVerilog.*

---

### Mini-Lecture: Refactoring Verilog to SystemVerilog (30 min)

#### Live Refactoring: Traffic Light FSM (15 min)

**Before (Verilog):**
```verilog
module traffic_light (
    input  wire       i_clk,
    input  wire       i_reset,
    output reg  [2:0] o_light
);
    localparam S_GREEN  = 2'b00;
    localparam S_YELLOW = 2'b01;
    localparam S_RED    = 2'b10;

    reg [1:0] r_state, r_next_state;

    // Block 1: State register
    always @(posedge i_clk) begin
        if (i_reset) r_state <= S_GREEN;
        else         r_state <= r_next_state;
    end

    // Block 2: Next-state logic
    always @(*) begin
        r_next_state = r_state;
        case (r_state)
            S_GREEN:  if (w_timer_done) r_next_state = S_YELLOW;
            S_YELLOW: if (w_timer_done) r_next_state = S_RED;
            S_RED:    if (w_timer_done) r_next_state = S_GREEN;
            default:  r_next_state = S_GREEN;
        endcase
    end

    // Block 3: Output logic
    always @(*) begin
        case (r_state)
            S_GREEN:  o_light = 3'b001;
            S_YELLOW: o_light = 3'b010;
            S_RED:    o_light = 3'b100;
            default:  o_light = 3'b100;
        endcase
    end
endmodule
```

**After (SystemVerilog):**
```systemverilog
module traffic_light (
    input  logic       i_clk,
    input  logic       i_reset,
    output logic [2:0] o_light
);

    typedef enum logic [1:0] {
        S_GREEN,
        S_YELLOW,
        S_RED
    } state_t;

    state_t state, next_state;

    // Block 1: State register — always_ff enforces edge-triggered
    always_ff @(posedge i_clk) begin
        if (i_reset) state <= S_GREEN;
        else         state <= next_state;
    end

    // Block 2: Next-state logic — always_comb catches latches
    always_comb begin
        next_state = state;          // default: hold
        case (state)
            S_GREEN:  if (w_timer_done) next_state = S_YELLOW;
            S_YELLOW: if (w_timer_done) next_state = S_RED;
            S_RED:    if (w_timer_done) next_state = S_GREEN;
            default:  next_state = S_GREEN;
        endcase
    end

    // Block 3: Output logic — always_comb catches latches
    always_comb begin
        case (state)
            S_GREEN:  o_light = 3'b001;
            S_YELLOW: o_light = 3'b010;
            S_RED:    o_light = 3'b100;
            default:  o_light = 3'b100;
        endcase
    end

endmodule
```

**Walk through each change on the board:**

| Change | Verilog | SystemVerilog | Why Better |
|---|---|---|---|
| Port types | `wire`/`reg` | `logic` | No type decision needed |
| State encoding | `localparam` | `typedef enum` | Type-safe, debug-printable |
| State register | `always @(posedge)` | `always_ff` | Compiler enforces sequential semantics |
| Comb logic | `always @(*)` | `always_comb` | Compiler catches latches at compile time |
| Variable names | `r_state` / `r_next_state` | `state` / `next_state` | No `r_` prefix needed — `always_ff` tells you it's a register |

**Key insight:** The naming convention `r_` for registers was a Verilog workaround because `reg` doesn't mean register. In SystemVerilog, `always_ff` explicitly declares register intent, so the prefix is redundant. Many SV coding styles drop it.

#### Live Refactoring: UART TX (10 min)

Show the key changes — don't rewrite the entire module, focus on:

1. All `wire`/`reg` → `logic`
2. State encoding → `enum`
3. The combined FSM block → split into `always_ff` for state register, keep the rest as-is (since the Day 11 version was a single sequential block, which is fine for small FSMs)
4. Debug: add `$display("TX State: %s", state.name());` in testbench

#### `struct` in Practice (5 min)

Show how UART TX/RX control signals can be grouped:

```systemverilog
typedef struct packed {
    logic [7:0] data;
    logic       valid;
} uart_tx_cmd_t;

typedef struct packed {
    logic [7:0] data;
    logic       valid;
    logic       frame_error;
} uart_rx_result_t;

// Module port using struct:
module uart_controller (
    input  logic         i_clk,
    input  uart_tx_cmd_t i_tx_cmd,
    output uart_rx_result_t o_rx_result,
    // ...
);
```

**Practical note:** Struct-based ports are clean but require the types to be defined somewhere both the instantiator and the module can see — this is where `package` comes in.

---

### Concept Check Questions

**Q1 (SLO 13.1):** In SystemVerilog, can you drive a `logic` signal from both an `assign` statement and an `always_comb` block?

> **Expected answer:** No. `logic` can have only one driver (one continuous assignment or one procedural block). This is actually a feature — it catches accidental multi-driver situations that Verilog's `wire` type would silently resolve (potentially incorrectly). If you need multiple drivers, use `wire`.

**Q2 (SLO 13.2):** You write `always_comb` and the compiler says "variable 'result' is not assigned in all paths." What happened?

> **Expected answer:** You have an incomplete `case` or `if/else` — some execution path doesn't assign `result`. In Verilog `always @(*)`, this silently infers a latch. In SystemVerilog `always_comb`, it's an error. Fix: add a default assignment at the top of the block or complete the `case`/`if` chain.

**Q3 (SLO 13.3):** You define `typedef enum logic [1:0] { S_A, S_B, S_C } state_t;` and then write `state_t s = 2'b11;`. What happens?

> **Expected answer:** The value `2'b11` doesn't correspond to any named enum member (S_A=0, S_B=1, S_C=2). Behavior is tool-dependent — some tools warn, others accept it silently. This is why having a `default` case in FSMs is still important even with enums. A well-defined enum should either have a member for every possible bit pattern, or the FSM must handle the "illegal state" gracefully.

**Q4 (SLO 13.4):** What does `packed` mean in `typedef struct packed`? What happens without it?

> **Expected answer:** `packed` means the struct is stored as a contiguous bit vector — you can assign the entire struct as one value, take bit slices, and pass it through ports. Without `packed`, the struct is unpacked — members are stored independently, you can't assign the whole struct as a bit vector, and it may not be synthesizable in all tools. Always use `packed` for synthesizable structs.

**Q5 (SLO 13.6):** After refactoring from Verilog to SystemVerilog, how do you verify the refactoring didn't introduce bugs?

> **Expected answer:** Run the existing testbench on the SystemVerilog version. If all tests pass, the behavior is preserved. Also compare synthesis results in Yosys (`stat` command) — LUT count, FF count, and Fmax should be identical or very close. The refactoring should be purely cosmetic from the hardware's perspective.

---

### Lab Exercises (2 hours)

#### Exercise 1: Refactor the ALU (25 min)

**Objective (SLO 13.1, 13.2, 13.6):** Convert the Day 3 ALU to SystemVerilog.

**Step 1:** Copy `alu_4bit.v` to `alu_4bit.sv` (note the `.sv` extension — this tells tools to parse as SystemVerilog).

**Step 2:** Apply the following changes:
- All `wire`/`reg` → `logic`
- `always @(*)` → `always_comb`
- Port declarations use `logic`

**Step 3:** Simulate with the existing testbench:
```bash
iverilog -g2012 -o sim.vvp tb_alu_4bit.v alu_4bit.sv
vvp sim.vvp
```

**Step 4:** Intentionally introduce a latch by removing a default assignment. Recompile. Does `iverilog -g2012` catch it? (It may or may not — Icarus support varies. Note the result.)

**Step 5:** Compare Yosys synthesis:
```bash
# Verilog version
yosys -p "read_verilog alu_4bit.v; synth_ice40 -top alu_4bit; stat"

# SystemVerilog version
yosys -p "read_verilog -sv alu_4bit.sv; synth_ice40 -top alu_4bit; stat"
```

Record: Are the LUT/FF counts identical?

**Deliverable:** Side-by-side code comparison (SV vs. Verilog) and matching synthesis stats.

---

#### Exercise 2: Refactor the Traffic Light FSM with `enum` (25 min)

**Objective (SLO 13.2, 13.3, 13.6):** Full FSM refactoring including enum states.

Create `traffic_light.sv`:

```systemverilog
module traffic_light (
    input  logic       i_clk,
    input  logic       i_reset,
    output logic [2:0] o_light    // {red, yellow, green}
);

    typedef enum logic [1:0] {
        S_GREEN,
        S_YELLOW,
        S_RED
    } state_t;

    state_t state, next_state;

    // Timing — use ifdef for simulation
    `ifdef SIMULATION
        localparam int GREEN_TICKS  = 50;
        localparam int YELLOW_TICKS = 10;
        localparam int RED_TICKS    = 40;
    `else
        localparam int GREEN_TICKS  = 125_000_000;
        localparam int YELLOW_TICKS =  25_000_000;
        localparam int RED_TICKS    = 100_000_000;
    `endif

    localparam int MAX_TICKS = GREEN_TICKS;  // widest needed
    logic [$clog2(MAX_TICKS)-1:0] timer;
    logic timer_done;

    // ---- YOUR CODE HERE ----
    // Block 1: State register (always_ff)
    // Block 2: Next-state logic (always_comb)
    // Block 3: Output logic (always_comb)
    // Timer logic (always_ff)
    // timer_done computation (always_comb)

endmodule
```

**Testbench enhancement:** Add debug printing using `.name()`:
```systemverilog
// In testbench — note: .name() support varies by tool
initial begin
    // After each state transition:
    $display("Time %0t: State = %s", $time, uut.state.name());
end
```

**Deliverable:** FSM works identically to Day 7 version. Testbench prints state names instead of numeric values.

---

#### Exercise 3: UART TX Refactoring with `struct` (30 min)

**Objective (SLO 13.1, 13.2, 13.3, 13.4):** Apply all SV design features to the most complex module.

Create `uart_tx.sv`:

```systemverilog
module uart_tx #(
    parameter int CLK_FREQ  = 25_000_000,
    parameter int BAUD_RATE = 115_200
)(
    input  logic       i_clk,
    input  logic       i_reset,
    input  logic       i_valid,
    input  logic [7:0] i_data,
    output logic       o_tx,
    output logic       o_busy
);

    // Baud rate calculation
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // State type
    typedef enum logic [1:0] {
        S_IDLE,
        S_START,
        S_DATA,
        S_STOP
    } state_t;

    state_t state;

    // Datapath signals
    logic [$clog2(CLKS_PER_BIT)-1:0] baud_counter;
    logic                             baud_tick;
    logic [7:0]                       shift_reg;
    logic [2:0]                       bit_index;

    // Baud tick
    assign baud_tick = (baud_counter == CLKS_PER_BIT - 1);

    // ---- YOUR CODE HERE ----
    // Rewrite the UART TX using:
    //   always_ff for the baud counter
    //   always_ff for the main FSM + datapath
    //   (or separate always_ff for state register + always_comb for next-state)
    // Use the enum state type
    // Verify with the existing testbench

    assign o_busy = (state != S_IDLE);

endmodule
```

**Student tasks:**
1. Complete the implementation
2. Run the Day 11 testbench against this SV version — all tests must pass
3. Compare synthesis results with the Verilog version
4. Add `$display` statements in the testbench using `state.name()` for debug

**Stretch:** Define a `uart_config_t` struct that bundles `CLK_FREQ` and `BAUD_RATE` as a typed configuration. While you can't use a struct as a parameter directly in all tools, you can use it internally.

---

#### Exercise 4: Final Project Architecture (30 min)

**Objective:** Begin formal design of the final project.

This is structured work time, but with a specific deliverable:

**Required deliverable — project design document (on paper or digital):**

1. **Block diagram:** Top-level module with all sub-modules shown. Every wire between modules labeled with name and width.

2. **Module inventory:** For each module:
   - Name and purpose
   - Port list (inputs/outputs with widths)
   - Is it reusable from the course library, or new?
   - If new: brief description of the internal architecture (FSM? Counter? Memory?)

3. **State diagrams:** For every FSM in the design (hand-drawn is fine).

4. **Resource estimate:** How many LUTs, FFs, and EBR blocks will the design use? (Rough estimate based on module sizes.)

5. **Test plan:** For each module, what will the testbench verify? What are the critical corner cases?

6. **Risk assessment:** What's the hardest part? What's most likely to go wrong? What's your fallback if time runs short?

**Mike circulates during this exercise** for 1-on-1 design review. Each student gets a 3–5 minute consultation.

---

#### Exercise 5 (Stretch): Package-Based Type Sharing (15 min)

**Objective (SLO 13.5):** Create a shared package for a multi-module design.

Create `project_pkg.sv`:
```systemverilog
package project_pkg;

    // Shared constants
    localparam int CLK_FREQ  = 25_000_000;
    localparam int BAUD_RATE = 115_200;

    // UART state type (shared between TX and RX)
    typedef enum logic [2:0] {
        UART_IDLE,
        UART_START,
        UART_DATA,
        UART_PARITY,
        UART_STOP
    } uart_state_t;

    // Error flags
    typedef struct packed {
        logic parity_error;
        logic frame_error;
        logic overrun_error;
    } uart_errors_t;

endpackage
```

Create two modules that import this package:
```systemverilog
module uart_tx_sv
    import project_pkg::*;
(
    input  logic i_clk,
    // ...
);
    uart_state_t state;  // type from package
    // ...
endmodule

module uart_rx_sv
    import project_pkg::*;
(
    input  logic i_clk,
    // ...
);
    uart_state_t state;  // same type — guaranteed consistent
    uart_errors_t errors;
    // ...
endmodule
```

**Note:** This exercise may require Verilator or a commercial tool if Icarus Verilog doesn't support `package`. If tools aren't available, treat this as a design exercise — write the code, discuss the benefits, and note the toolchain limitation.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **`logic` replaces `wire`/`reg`** — eliminates the most confusing aspect of Verilog naming
2. **`always_ff`/`always_comb`** express intent — the compiler catches mismatches between intent and implementation
3. **`always_comb` catches latches at compile time** — the single biggest safety improvement over Verilog
4. **`enum` states** are type-safe and debug-printable — no more decoding state numbers in waveforms
5. **`struct packed`** groups related signals — cleaner interfaces, less signal sprawl
6. **`package`** provides a single source of truth for shared types and constants

#### The Safety Net Hierarchy

| Verilog Risk | SystemVerilog Protection |
|---|---|
| Latch from incomplete `always @(*)` | `always_comb` errors on incomplete assignment |
| Blocking in sequential block | `always_ff` warns on `=` usage |
| `reg` doesn't mean register | `logic` is usage-neutral |
| State encoding mismatches | `enum` is type-checked |
| Duplicate constants across modules | `package` provides single source |

#### Preview: Day 14 — SystemVerilog for Verification
Tomorrow: assertions, coverage, interfaces, and a brief taste of the class-based verification world. You'll add assertions to your UART modules that continuously check protocol correctness during simulation.

**Homework:** Watch the Day 14 pre-class video (~50 min). Also: continue final project design work. You should have a complete block diagram and module inventory before Day 15.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: ALU Refactor | 13.1, 13.2, 13.6 | SV version passes all tests; synthesis stats match Verilog |
| Ex 2: FSM Refactor | 13.2, 13.3, 13.6 | Enum states work; .name() prints state names; identical behavior |
| Ex 3: UART Refactor | 13.1, 13.2, 13.3, 13.4 | All UART tests pass; struct used for signal grouping |
| Ex 4: Project Design | — | Block diagram, module inventory, test plan completed |
| Ex 5: Package | 13.5 | Package imported by multiple modules (or design exercise) |
| Concept check Qs | 13.1, 13.2, 13.3, 13.4, 13.5 | In-class discussion responses |

---

## Instructor Notes

- **The refactoring approach is deliberate.** Students aren't learning new hardware concepts — they're learning a better language for expressing the same hardware. By refactoring modules they already understand, the SV features are learned in context rather than in the abstract.
- **Icarus Verilog SV support is limited.** Test every exercise with `iverilog -g2012` before class. `logic`, `always_ff`, `always_comb`, and basic `enum` should work. `package`, `interface`, and `struct` support varies. Have Verilator installed as a fallback for linting.
- **Yosys SV support:** Use `read_verilog -sv` for synthesis. Most design constructs work. Verify before class.
- **The `.name()` method** is extremely useful for FSM debugging but may not be supported in Icarus. If not, demonstrate the concept and note the toolchain limitation. It works in Verilator and all commercial tools.
- **Exercise 4 (project design)** is critical. The 1-on-1 consultations are your chance to catch overambitious designs, identify missing modules, and guide students toward feasible scope. Spend real time here.
- **Timing:** Exercises 1–3 are the SV skill transfer (1 hour total). Exercise 4 is the project design work (30 min). Prioritize Exercise 4 if students are behind on SV exercises — they can finish refactoring at home, but the design review needs to happen in person.
