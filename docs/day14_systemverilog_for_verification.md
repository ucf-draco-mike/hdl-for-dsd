# Day 14: SystemVerilog for Verification

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 14 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 14.1:** Write immediate assertions (`assert`, `$error`, `$fatal`) to check design invariants inline and explain how they differ from `if`-based checks.
2. **SLO 14.2:** Write basic concurrent assertions using `assert property` with simple sequence syntax to verify multi-cycle protocol behavior.
3. **SLO 14.3:** Define a `covergroup` with `coverpoint` and `bins` to measure functional coverage, and interpret a coverage report to identify untested scenarios.
4. **SLO 14.4:** Define a SystemVerilog `interface` with `modport` and use it to create cleaner, less error-prone connections between a DUT and its testbench.
5. **SLO 14.5:** Describe the role of classes, constrained randomization, and UVM in industrial verification methodology, and explain where this course's techniques fit in the broader verification landscape.
6. **SLO 14.6:** Add assertions and coverage to an existing testbench and demonstrate that they catch bugs and measure test completeness.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: Assertions — Executable Specifications (15 min)

#### What Are Assertions?

An assertion is a statement that must always be true. If it's ever false during simulation, the simulator reports an error. Assertions are:
- **Executable documentation:** They describe design rules in a way the simulator can check automatically
- **Always-on monitors:** Unlike directed tests that check specific moments, assertions run continuously throughout simulation
- **Bug locators:** When an assertion fires, it points to the exact signal and time of the violation

#### Immediate Assertions

Immediate assertions are checked at a specific point in procedural code, like an `if` check but with standardized severity reporting:

```systemverilog
// In a procedural block (always, initial, task):
always_ff @(posedge i_clk) begin
    if (i_reset) begin
        state <= S_IDLE;
    end else begin
        state <= next_state;

        // Assert: state should never be undefined
        assert (state !== 'x)
            else $error("State is undefined at time %0t", $time);

        // Assert: if busy, valid should not be asserted
        assert (!(o_busy && i_valid))
            else $warning("Valid asserted while busy — data may be lost");
    end
end
```

**Severity levels:**
- `$info(...)` — informational, doesn't indicate a problem
- `$warning(...)` — potential issue, simulation continues
- `$error(...)` — definite problem, simulation continues (for collecting multiple failures)
- `$fatal(...)` — critical failure, simulation stops immediately

#### Immediate Assertions in Testbenches

```systemverilog
// Testbench assertion: check a specific condition at a specific time
task send_byte;
    input [7:0] data;
begin
    @(posedge clk);
    i_valid = 1;
    i_data  = data;
    @(posedge clk);
    i_valid = 0;

    // Assert: busy should go high within 1 cycle of valid
    @(posedge clk);
    assert (o_busy)
        else $error("TX did not assert busy after valid");
end
endtask
```

#### Immediate Assertions in Design Modules

You can embed assertions directly in your design RTL. They are ignored by synthesis but active during simulation:

```systemverilog
module counter_mod_n #(parameter int N = 16) (
    input  logic                     i_clk,
    input  logic                     i_reset,
    input  logic                     i_enable,
    output logic [$clog2(N)-1:0]     o_count
);

    always_ff @(posedge i_clk) begin
        if (i_reset)
            o_count <= '0;
        else if (i_enable) begin
            if (o_count == N - 1)
                o_count <= '0;
            else
                o_count <= o_count + 1;
        end
    end

    // Design assertion: count should never exceed N-1
    always_ff @(posedge i_clk) begin
        assert (o_count < N)
            else $fatal(1, "Counter exceeded max value: %0d >= %0d", o_count, N);
    end

endmodule
```

**This assertion runs every clock cycle.** If a bug ever causes `o_count` to reach or exceed `N`, the simulation stops immediately with a clear error message. Compare this to manually inspecting waveforms — the assertion is always watching.

---

### Video Segment 2: Concurrent Assertions (12 min)

#### Beyond Instant Checks: Multi-Cycle Behavior

Immediate assertions check a condition at one point in time. **Concurrent assertions** check sequences of events over multiple clock cycles. This is perfect for protocol verification.

```systemverilog
// UART TX protocol assertion:
// After valid is asserted, busy must go high on the next clock
property p_valid_then_busy;
    @(posedge i_clk) disable iff (i_reset)
    i_valid |-> ##1 o_busy;
endproperty

assert property (p_valid_then_busy)
    else $error("Busy did not assert one cycle after valid");
```

**Syntax breakdown:**
- `property p_valid_then_busy;` — names the property
- `@(posedge i_clk)` — checked on every rising clock edge
- `disable iff (i_reset)` — don't check during reset
- `i_valid |->` — "if `i_valid` is true, then..." (implication operator)
- `##1 o_busy` — "one clock cycle later, `o_busy` must be true"

#### Common Sequence Operators

| Operator | Meaning | Example |
|---|---|---|
| `##1` | One cycle delay | `a ##1 b` — a, then b next cycle |
| `##[1:3]` | 1 to 3 cycle delay | `a ##[1:3] b` — a, then b within 1-3 cycles |
| `\|->` | Overlapping implication | `a \|-> b` — if a, then b (same cycle) |
| `\|=>` | Non-overlapping implication | `a \|=> b` — if a, then b (next cycle) |
| `[*N]` | Repetition | `a[*3]` — a true for 3 consecutive cycles |

#### UART Protocol Assertions

```systemverilog
// Property: TX line is high when idle
property p_idle_high;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_IDLE) |-> (o_tx == 1'b1);
endproperty
assert property (p_idle_high)
    else $error("TX not high during idle");

// Property: Start bit is low
property p_start_low;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_START) |-> (o_tx == 1'b0);
endproperty
assert property (p_start_low)
    else $error("TX not low during start bit");

// Property: Stop bit is high
property p_stop_high;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_STOP) |-> (o_tx == 1'b1);
endproperty
assert property (p_stop_high)
    else $error("TX not high during stop bit");

// Property: After transmission, must return to idle
property p_stop_then_idle;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_STOP && baud_tick) |=> (state == S_IDLE);
endproperty
assert property (p_stop_then_idle)
    else $error("Did not return to idle after stop bit");
```

**These assertions continuously monitor the UART TX module.** During any simulation — whether it's a directed test, a random test, or a loopback test — the assertions are checking protocol compliance on every clock cycle. If any state ever produces the wrong output, the assertion fires immediately.

**Toolchain note:** Concurrent assertions require strong SV support. Icarus Verilog does NOT support them. Verilator has partial support. Commercial tools have full support. For this course, we'll write them and run them where tools allow, or treat them as design documentation.

---

### Video Segment 3: Functional Coverage (12 min)

#### The Question Coverage Answers

Your testbench passes all its tests. Great. But **how do you know you've tested enough?** Your directed tests might exercise the common cases but miss edge cases entirely.

**Functional coverage** measures what your testbench actually exercised — what input combinations, state transitions, and output conditions were observed during simulation.

#### `covergroup` and `coverpoint`

```systemverilog
// Coverage for the ALU
covergroup alu_coverage @(posedge clk);

    // Cover all opcodes
    cp_opcode: coverpoint i_opcode {
        bins add = {2'b00};
        bins sub = {2'b01};
        bins and_op = {2'b10};
        bins or_op  = {2'b11};
    }

    // Cover interesting input ranges for operand A
    cp_a_value: coverpoint i_a {
        bins zero    = {4'h0};
        bins low     = {[4'h1:4'h7]};
        bins high    = {[4'h8:4'hE]};
        bins max     = {4'hF};
    }

    // Cover interesting input ranges for operand B
    cp_b_value: coverpoint i_b {
        bins zero    = {4'h0};
        bins low     = {[4'h1:4'h7]};
        bins high    = {[4'h8:4'hE]};
        bins max     = {4'hF};
    }

    // Cross coverage: opcode × a_range × b_range
    cx_op_a_b: cross cp_opcode, cp_a_value, cp_b_value;

endgroup
```

**What this measures:**
- `cp_opcode`: Were all 4 opcodes exercised? (4 bins)
- `cp_a_value`: Were the boundary values of `i_a` tested? (4 bins)
- `cp_b_value`: Same for `i_b` (4 bins)
- `cx_op_a_b`: Were all combinations of opcode × a_range × b_range exercised? (4 × 4 × 4 = 64 bins)

After simulation, the coverage report shows which bins were hit and which were missed. A coverage of 100% means every bin was observed at least once.

#### Using Coverage

```systemverilog
module tb_alu_coverage;

    // ... DUT instantiation, clock, etc ...

    // Instantiate the covergroup
    alu_coverage cov;

    initial begin
        cov = new();

        // Run your tests...
        // The covergroup samples automatically on posedge clk

        // At the end, print coverage
        $display("Coverage: %0.1f%%", cov.get_coverage());
    end

endmodule
```

#### Coverage-Driven Verification Workflow

1. **Define coverage goals** — what combinations matter?
2. **Write initial tests** — directed tests for known scenarios
3. **Run and check coverage** — what's missing?
4. **Add tests for uncovered bins** — fill the gaps
5. **Repeat until 100%** (or your coverage goal is met)

This is the industry-standard verification workflow. It answers the question "are we done testing?" with data, not intuition.

---

### Video Segment 4: Interfaces, Classes & the Road to UVM (11 min)

#### `interface` — Bundled Connections

An `interface` groups related signals and provides different views via `modport`:

```systemverilog
interface uart_if (input logic clk);
    logic       tx;
    logic       rx;
    logic [7:0] data;
    logic       valid;
    logic       busy;

    modport tx_port (
        input  clk, data, valid,
        output tx, busy
    );

    modport rx_port (
        input  clk, rx,
        output data, valid
    );

    modport tb (
        input  clk, tx, busy, data, valid,
        output rx
    );
endinterface
```

```systemverilog
// Module using interface
module uart_tx_if (uart_if.tx_port intf);
    always_ff @(posedge intf.clk) begin
        // Access signals via intf.data, intf.valid, etc.
    end
endmodule

// Testbench using interface
module tb;
    logic clk;
    uart_if uif (.clk(clk));

    uart_tx_if dut (.intf(uif.tx_port));

    initial begin
        uif.valid = 1;
        uif.data  = 8'h41;
        // ...
    end
endmodule
```

**Benefits:** One connection instead of many individual port mappings. Adding a signal to the interface automatically propagates to all connected modules. Reduces port-mapping bugs.

#### The Road to UVM (Conceptual Overview)

Where the techniques in this course fit in the verification landscape:

```
         This Course
    ┌──────────────────────┐
    │ Directed tests       │ ← You write specific inputs and expected outputs
    │ Self-checking TBs    │ ← Tasks automate stimulus and checking
    │ Immediate assertions │ ← Point-in-time checks
    │ Basic coverage       │ ← Measuring what was tested
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Intermediate          │
    │ Concurrent assertions │ ← Protocol checking over time
    │ Interfaces + modports │ ← Clean DUT-TB connections
    │ Coverage-driven flow  │ ← Systematic gap filling
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Industrial (UVM)      │
    │ Class-based testbench │ ← Object-oriented stimulus generation
    │ Constrained random    │ ← Automatic interesting-input generation
    │ Functional coverage   │ ← Coverage goals drive test generation
    │ Scoreboards/monitors  │ ← Automated checking infrastructure
    │ Formal verification   │ ← Mathematical proof of properties
    └──────────────────────┘
```

**Key concepts to know exist:**

- **Classes:** SV has object-oriented programming (inheritance, polymorphism, encapsulation) specifically for building reusable testbench components. Classes are simulation-only — not synthesizable.

- **Constrained randomization:** Instead of writing every test vector, you define constraints (`value inside {[0:15]}; value != 0;`) and the simulator generates random values that satisfy the constraints. This finds bugs you'd never think to test for.

- **UVM (Universal Verification Methodology):** A standardized class library and methodology for building industrial testbenches. It defines agent, driver, monitor, scoreboard, and sequencer components in a standard architecture. It's the default methodology for ASIC verification worldwide.

- **Formal verification:** Instead of simulating with test vectors, formal tools mathematically prove that an assertion holds for ALL possible inputs and ALL possible execution sequences. If a counterexample exists, the tool finds it. Extremely powerful for protocol and safety-critical verification.

**You don't need to know UVM to be effective.** But knowing it exists, and knowing that directed tests + assertions + coverage are the building blocks, puts you on the path.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Question:** Your UART TX testbench sends 10 test bytes and all pass. You're confident the design works. Then a colleague runs a random stress test sending 10,000 bytes, and byte #4,287 is corrupted. What likely happened?

> *Answer: The directed tests didn't exercise the specific condition that causes the bug. Possibilities: a baud counter off-by-one that only manifests after a specific number of consecutive transmissions, a subtle interaction between the valid/busy handshake and specific data patterns, or a race condition that only occurs with specific timing between the end of one frame and the start of the next. Coverage analysis would have revealed untested scenarios. Assertions would have caught the protocol violation when it occurred, pointing to the exact cycle.*

---

### Mini-Lecture: Assertions and Coverage in Practice (30 min)

#### Live Demo: Adding Assertions to UART TX (15 min)

Open the SystemVerilog UART TX from Day 13. Add assertions:

**Inside the design module:**
```systemverilog
// Add at the bottom of uart_tx.sv

// Assert: TX line is high when idle
always_comb begin
    if (state == S_IDLE)
        assert (o_tx == 1'b1)
            else $error("TX not high in IDLE state");
end

// Assert: busy matches non-idle state
always_comb begin
    assert (o_busy == (state != S_IDLE))
        else $error("Busy signal mismatch: busy=%b, state=%s",
                     o_busy, state.name());
end

// Assert: bit_index never exceeds 7
always_ff @(posedge i_clk) begin
    assert (bit_index <= 3'd7)
        else $error("Bit index overflow: %0d", bit_index);
end
```

**In the testbench — a protocol checker:**
```systemverilog
// Count the total bits in each frame
integer frame_bit_count;
logic in_frame;

always_ff @(posedge clk) begin
    if (uut.state == S_IDLE && !in_frame) begin
        frame_bit_count <= 0;
    end
    if (uut.state != S_IDLE) begin
        in_frame <= 1;
        if (uut.baud_tick)
            frame_bit_count <= frame_bit_count + 1;
    end else if (in_frame) begin
        // Frame just ended — verify 10 bits (1 start + 8 data + 1 stop)
        assert (frame_bit_count == 10)
            else $error("Frame had %0d bits, expected 10", frame_bit_count);
        in_frame <= 0;
    end
end
```

Run the testbench. No assertions fire → the design is correct for these tests. Now intentionally break something (e.g., change the stop bit to 0) and re-run. The assertion fires immediately.

#### Live Demo: Coverage for the ALU (10 min)

Show the covergroup from the pre-class video. Run the existing directed test suite. Check coverage:

```
Coverage: 62.5%
Missing bins:
  cx_op_a_b: ADD × max × max   (never tested 0xF + 0xF)
  cx_op_a_b: SUB × zero × max  (never tested 0x0 - 0xF)
  ...
```

The directed tests missed several edge cases! Add tests for the uncovered bins. Re-run. Coverage improves.

**Teaching point:** "100% code coverage doesn't mean 100% bug coverage. But 60% functional coverage definitely means 40% of interesting scenarios are untested."

#### Interface Demo (5 min)

Show the `uart_if` interface definition. Demonstrate how it reduces the port map from 6 individual signals to one interface connection. Note the toolchain limitations (Icarus may not support this).

---

### Concept Check Questions

**Q1 (SLO 14.1):** What's the difference between `assert (condition) else $error(...)` and `if (!condition) $display("Error...")`?

> **Expected answer:** Functionally similar, but assertions are: (1) standardized — tools can count, filter, and report on them uniformly, (2) have built-in severity levels ($info, $warning, $error, $fatal), (3) can be globally disabled or enabled without modifying code, (4) are recognized by formal verification tools (if-statements are not), (5) signal intent — an assertion says "this must always be true," not just "check this here."

**Q2 (SLO 14.2):** Write a concurrent assertion that checks: "After reset deasserts, the TX line must be high within 2 clock cycles."

> **Expected answer:**
> ```systemverilog
> property p_post_reset_idle;
>     @(posedge i_clk)
>     $fell(i_reset) |-> ##[1:2] (o_tx == 1'b1);
> endproperty
> assert property (p_post_reset_idle);
> ```

**Q3 (SLO 14.3):** Your coverage report shows 85% coverage. Should you ship the design?

> **Expected answer:** It depends on the coverage goals and what's in the missing 15%. If the missing bins are unreachable states or don't-care conditions, 85% may be acceptable. If the missing bins include critical edge cases (overflow, underflow, error conditions), you need more tests. In practice, coverage goals vary: 95%+ for safety-critical, 80-90% for general designs. The key is understanding *what* is uncovered and making an informed decision.

**Q4 (SLO 14.4):** A module has 12 ports. You add a 13th port. With traditional Verilog port mapping, how many files do you need to modify? With a SystemVerilog interface?

> **Expected answer:** Verilog: every file that instantiates the module needs its port map updated — potentially many files. With an interface: you modify the interface definition (one file) and the module internals. Instantiation sites that connect via the interface automatically get the new signal without changes. This is similar to the benefit of a struct versus individual variables.

**Q5 (SLO 14.5):** A verification engineer says they use "constrained random" testing. What does this mean, and why is it more powerful than directed testing?

> **Expected answer:** Constrained random generates random stimulus that satisfies specified constraints (e.g., "data is 8-bit, baud rate is one of {9600, 115200, 230400}, valid is asserted for 1-3 cycles"). The simulator automatically explores a vast input space, finding corner cases that a human tester wouldn't think to write directed tests for. Combined with coverage, it systematically reveals untested scenarios. It's more powerful because it can exercise millions of input combinations automatically, catching bugs in unexpected interactions.

---

### Lab Exercises (2 hours)

#### Exercise 1: Assertion-Enhanced UART TX (30 min)

**Objective (SLO 14.1, 14.6):** Add comprehensive immediate assertions to the UART TX.

Add the following assertions to `uart_tx.sv`:

```systemverilog
// ---- Required Assertions ----

// 1. TX idle = high (already shown in mini-lecture)

// 2. Busy signal consistency
//    busy must equal (state != S_IDLE) on every cycle

// 3. Bit index range
//    bit_index must be in range [0, 7]

// 4. Baud counter range
//    baud_counter must be in range [0, CLKS_PER_BIT-1]

// 5. Start bit value
//    When state is S_START, o_tx must be 0

// 6. Stop bit value
//    When state is S_STOP, o_tx must be 1

// 7. No valid during busy
//    If o_busy is high, i_valid should not be asserted
//    (this is a protocol rule — use $warning, not $error,
//     since it's the caller's responsibility)
```

**Student tasks:**
1. Add all 7 assertions
2. Run the existing testbench — all assertions should pass
3. Intentionally introduce bugs (one at a time), verify the corresponding assertion catches each:
   - Bug A: Change start bit output to `1'b1` → assertion 5 fires
   - Bug B: Allow bit_index to reach 8 → assertion 3 fires
   - Bug C: Set o_tx to 0 during idle → assertion 1 fires
4. Restore the correct design

**Deliverable:** Screenshot showing (a) clean run with no assertion failures, (b) targeted failure when each bug is injected.

---

#### Exercise 2: FSM Transition Assertions (25 min)

**Objective (SLO 14.1, 14.2, 14.6):** Assert that the FSM never makes illegal transitions.

For the traffic light FSM (or the UART TX FSM), add assertions that verify:

1. **Legal transitions only:**
```systemverilog
// Assert: GREEN can only transition to YELLOW (not RED or any other state)
always_ff @(posedge i_clk) begin
    if (!i_reset && state == S_GREEN && next_state != S_GREEN) begin
        assert (next_state == S_YELLOW)
            else $error("Illegal transition from GREEN to %s",
                        next_state.name());
    end
end

// Similar assertions for YELLOW → RED and RED → GREEN
```

2. **No illegal states:**
```systemverilog
// Assert: state is always a valid enum value
// (catches corruption, bit flips, uninitialized states)
always_ff @(posedge i_clk) begin
    if (!i_reset) begin
        assert (state inside {S_GREEN, S_YELLOW, S_RED})
            else $error("Illegal state detected: %b", state);
    end
end
```

3. **Timer bounds:**
```systemverilog
// Assert: timer never exceeds the maximum for the current state
always_comb begin
    case (state)
        S_GREEN:  assert (timer < GREEN_TICKS)
                      else $error("GREEN timer overflow");
        S_YELLOW: assert (timer < YELLOW_TICKS)
                      else $error("YELLOW timer overflow");
        S_RED:    assert (timer < RED_TICKS)
                      else $error("RED timer overflow");
        default:  ; // no assertion for default
    endcase
end
```

**Student tasks:**
1. Add all transition and bound assertions
2. Run the testbench — verify no assertions fire
3. Inject a bug: change the GREEN→YELLOW transition to GREEN→RED. Verify assertion 1 catches it.

---

#### Exercise 3: Coverage Analysis (25 min)

**Objective (SLO 14.3, 14.6):** Add functional coverage to the ALU testbench and identify gaps.

**Note:** This exercise requires a tool that supports covergroups (Verilator, Questa, VCS). If only Icarus is available, treat this as a **design and analysis exercise** — write the covergroup code, reason about what it would measure, and manually determine which bins your existing tests cover.

**Part A:** Define a covergroup for the ALU:

```systemverilog
covergroup alu_cov @(posedge clk);
    // Opcode coverage
    cp_op: coverpoint opcode {
        bins add   = {2'b00};
        bins sub   = {2'b01};
        bins bw_and = {2'b10};
        bins bw_or  = {2'b11};
    }

    // Operand A boundary conditions
    cp_a: coverpoint a {
        bins zero     = {4'h0};
        bins mid_low  = {[4'h1:4'h7]};
        bins mid_high = {[4'h8:4'hE]};
        bins max      = {4'hF};
    }

    // Operand B boundary conditions
    cp_b: coverpoint b {
        bins zero     = {4'h0};
        bins mid_low  = {[4'h1:4'h7]};
        bins mid_high = {[4'h8:4'hE]};
        bins max      = {4'hF};
    }

    // Result flags
    cp_zero: coverpoint zero_flag {
        bins is_zero   = {1'b1};
        bins not_zero  = {1'b0};
    }

    cp_carry: coverpoint carry_flag {
        bins has_carry = {1'b1};
        bins no_carry  = {1'b0};
    }

    // Cross coverage: every opcode with every operand range combination
    cx_full: cross cp_op, cp_a, cp_b;

    // Cross coverage: every opcode with zero result
    cx_op_zero: cross cp_op, cp_zero;

    // Cross coverage: every opcode with carry
    cx_op_carry: cross cp_op, cp_carry;

endgroup
```

**Part B (manual analysis if tool unavailable):** For each bin in the covergroup, check whether your existing Day 6 testbench hits it. Fill in a coverage table:

| Bin | Covered? | Test that covers it |
|---|---|---|
| ADD × zero × zero | Yes | "ADD 0+0" test |
| ADD × max × max | ? | |
| SUB × zero × max | ? | |
| SUB + carry flag | ? | |
| ... | | |

**Part C:** Add tests for any uncovered bins. Re-run analysis.

**Deliverable:** Coverage table (manual or tool-generated) showing gaps identified and filled.

---

#### Exercise 4: Final Project Work (30 min)

**Objective:** Dedicated project build time with assertion-enhanced verification.

**Requirements for this work session:**

1. Have at least one module coded and simulated
2. Add at least 3 assertions to your most critical module
3. Write or update the testbench for that module

**Mike circulates** for design review and debugging assistance.

**Priority order for project work:**
1. Get the critical-path module (usually the main FSM or protocol engine) working in simulation
2. Add assertions to that module
3. Build and test supporting modules (counters, decoders, memory)
4. Integrate modules into the top level
5. Synthesize and check resource usage / timing

---

#### Exercise 5 (Stretch): Interface-Based Testbench (15 min)

**Objective (SLO 14.4):** Refactor a testbench to use a SystemVerilog interface.

Create `uart_if.sv`:
```systemverilog
interface uart_if (input logic clk);
    logic       tx;
    logic       rx;
    logic [7:0] tx_data;
    logic       tx_valid;
    logic       tx_busy;
    logic [7:0] rx_data;
    logic       rx_valid;

    modport dut_tx (
        input  clk, tx_data, tx_valid,
        output tx, tx_busy
    );

    modport dut_rx (
        input  clk, rx,
        output rx_data, rx_valid
    );

    modport testbench (
        input  clk, tx, tx_busy, rx_data, rx_valid,
        output rx, tx_data, tx_valid
    );
endinterface
```

Refactor the UART loopback testbench to use this interface. Compare the port-mapping code before and after.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **Assertions are executable specifications** — they continuously verify design rules without manual waveform inspection
2. **Immediate assertions** check conditions at specific times; **concurrent assertions** check sequences over multiple cycles
3. **Functional coverage** answers "what have I tested?" — it measures completeness, not correctness
4. **Interfaces** bundle related signals — cleaner connections, fewer port-mapping bugs
5. **UVM and constrained random** are where industry verification goes — what we've learned is the foundation

#### The Verification Maturity Scale

After this course, you're at level 2. That's a solid foundation.

| Level | Technique | Where You Are |
|---|---|---|
| 0 | "It works on the board" | Week 1 |
| 1 | Directed self-checking testbenches | Day 6 onward |
| **2** | **Assertions + coverage analysis** | **After today** |
| 3 | Coverage-driven directed testing | Next course |
| 4 | Constrained random + UVM | Industry / grad course |
| 5 | Formal verification | Advanced / specialized |

#### Preview: Day 15 — Final Project Build Day
Tomorrow is 2.5 hours of dedicated project work. Come prepared with:
- A working simulation of your core module(s)
- A plan for what you'll build during the session
- Questions ready for your 1-on-1 check-in with Mike

#### Preview: Day 16 — Demos & Course Wrap
Monday: 5-7 minute demo per student. Live hardware demo, show testbench/waveforms, discuss what worked and what you'd do differently.

**Homework:** Maximize project progress tonight. The goal for Day 15 is integration and debugging, not starting from scratch.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: UART Assertions | 14.1, 14.6 | 7 assertions added; clean pass; targeted failures on bug injection |
| Ex 2: FSM Assertions | 14.1, 14.2, 14.6 | Transition and bound assertions; illegal transition caught |
| Ex 3: Coverage | 14.3, 14.6 | Coverage table completed; gaps identified and filled |
| Ex 4: Project Work | — | Core module simulated with assertions |
| Ex 5: Interface | 14.4 | Interface-based testbench compiles and runs |
| Concept check Qs | 14.1, 14.2, 14.3, 14.4, 14.5 | In-class discussion responses |

---

## Instructor Notes

- **Toolchain is the biggest challenge today.** Icarus Verilog supports immediate assertions with `-g2012` but NOT concurrent assertions, covergroups, or interfaces. Have Verilator installed for linting and basic simulation. If no tool supports a feature, treat the exercise as a code-writing and reasoning exercise.
- **Assertions in design code** are powerful but some teams resist them ("assertions belong in testbenches only"). Emphasize: design-embedded assertions catch bugs immediately at the source, during any simulation. They're stripped during synthesis, so there's zero hardware cost.
- **Coverage without tools:** The manual analysis exercise (3B) is genuinely useful even without tool support. Having students manually trace which bins their tests hit builds the same analytical thinking that tool-generated reports provide.
- **The UVM overview** should be brief and aspirational, not intimidating. Students should leave knowing: "There's a whole methodology out there for large-scale verification, and what I've learned is the foundation it builds on."
- **Project work time** (Exercise 4) is critical. Every minute saved from the SV exercises should go to project work. The SV exercises can be completed at home; the 1-on-1 check-ins during project work cannot.
- **Timing:** Exercises 1 and 2 are the SV verification core (55 min total). Exercise 3 is important conceptually (25 min). Exercise 4 is project time (30 min). Exercise 5 is stretch. If students need more project time, cut Exercise 3 short and let them do the manual analysis at home.
