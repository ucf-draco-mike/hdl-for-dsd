# Day 7: Finite State Machines

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 7 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 7.1:** Distinguish between Moore and Mealy FSMs, explaining when each is appropriate and how their output timing differs.
2. **SLO 7.2:** Translate a state diagram (drawn on paper) into synthesizable Verilog using the 3-always-block coding style (state register, next-state logic, output logic).
3. **SLO 7.3:** Define FSM states using `localparam` with explicit encoding and explain the trade-offs between binary, one-hot, and gray encoding.
4. **SLO 7.4:** Write a self-checking testbench that verifies all state transitions and outputs of an FSM by applying input sequences and checking the state/output trajectory.
5. **SLO 7.5:** Design and implement a timed FSM (traffic light controller) that uses counters to control state dwell times.
6. **SLO 7.6:** Implement a pattern detector FSM that recognizes a specific input sequence and signals detection with an output pulse.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: FSM Theory and Architecture (12 min)

#### What Is a Finite State Machine?

An FSM is a sequential circuit whose behavior is defined by:
- A finite set of **states** (the machine is always in exactly one state)
- **Transitions** between states, governed by input conditions
- **Outputs**, which depend on the current state (and possibly current inputs)

Every digital controller is fundamentally an FSM: traffic light controllers, protocol engines, vending machines, CPU control units, elevator controllers, game logic.

#### Moore vs. Mealy

**Moore machine:** Outputs depend only on the current state.
- Output = f(state)
- Outputs change only when state changes (on clock edge)
- Outputs are stable for the entire state duration
- Typically requires more states to achieve the same behavior as Mealy

**Mealy machine:** Outputs depend on the current state AND current inputs.
- Output = f(state, inputs)
- Outputs can change mid-state if inputs change (between clock edges)
- Can react faster to inputs (within the same cycle)
- May produce glitches if inputs are noisy

**When to use which:**
- **Moore** is the default choice — safer, easier to debug, cleaner timing
- **Mealy** when you need the output to react within the same clock cycle as the input (e.g., acknowledgment signals in handshake protocols)
- In this course, we'll primarily use Moore machines

#### FSM Block Diagram

```
                    ┌──────────────────────────────┐
                    │           FSM                 │
  inputs ──────────►│                               │
                    │  ┌───────────┐                │
                    │  │ Next-State│  next_state     │
                    │  │  Logic    │────────┐       │
                    │  │ (comb.)   │        │       │
                    │  └───────────┘        ▼       │
                    │                ┌──────────┐   │
                    │                │  State   │   │
                    │    clk ───────►│ Register │   │
                    │    reset ─────►│ (seq.)   │   │
                    │                └────┬─────┘   │
                    │                     │ state   │
                    │              ┌──────┴──────┐  │
                    │              │   Output    │  │──────► outputs
                    │              │   Logic     │  │
                    │              │   (comb.)   │  │
                    │              └─────────────┘  │
                    └──────────────────────────────┘
```

Three distinct blocks:
1. **State Register** — sequential: holds the current state, updates on clock edge
2. **Next-State Logic** — combinational: computes the next state from current state + inputs
3. **Output Logic** — combinational: computes outputs from current state (Moore) or state + inputs (Mealy)

---

### Video Segment 2: The 3-Always-Block Coding Style (15 min)

#### Why Three Blocks?

You *can* write an FSM in a single `always` block. But the 3-block style is strongly preferred because:
- Each block has a single responsibility — easier to reason about
- The state register is trivially correct (it's just a flip-flop)
- Next-state and output logic are separated — easier to modify independently
- Latch prevention is obvious (default assignments in combinational blocks)
- It maps directly to the block diagram

#### Template

```verilog
module fsm_example (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_input_x,
    output reg  o_output_y,
    output reg  o_output_z
);

    // ========== State Encoding ==========
    localparam S_IDLE  = 2'b00;
    localparam S_RUN   = 2'b01;
    localparam S_DONE  = 2'b10;
    // 2'b11 unused — handled by default

    reg [1:0] r_state, r_next_state;

    // ========== Block 1: State Register (Sequential) ==========
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_IDLE;
        else
            r_state <= r_next_state;
    end

    // ========== Block 2: Next-State Logic (Combinational) ==========
    always @(*) begin
        r_next_state = r_state;  // DEFAULT: stay in current state

        case (r_state)
            S_IDLE: begin
                if (i_input_x)
                    r_next_state = S_RUN;
            end

            S_RUN: begin
                if (!i_input_x)
                    r_next_state = S_DONE;
            end

            S_DONE: begin
                r_next_state = S_IDLE;  // unconditional transition
            end

            default: r_next_state = S_IDLE;  // safety catch
        endcase
    end

    // ========== Block 3: Output Logic (Combinational — Moore) ==========
    always @(*) begin
        // Defaults
        o_output_y = 1'b0;
        o_output_z = 1'b0;

        case (r_state)
            S_IDLE: begin
                o_output_y = 1'b0;
                o_output_z = 1'b0;
            end

            S_RUN: begin
                o_output_y = 1'b1;
            end

            S_DONE: begin
                o_output_z = 1'b1;
            end

            default: begin
                o_output_y = 1'b0;
                o_output_z = 1'b0;
            end
        endcase
    end

endmodule
```

#### Critical Details

**Default assignment in Block 2:** `r_next_state = r_state;` as the first line. This means "if no transition condition is met, stay in the current state." This prevents latches and handles unexpected cases.

**Default assignments in Block 3:** Set all outputs to their default/safe values before the `case`. This prevents latches on outputs.

**The `default` case:** Always include it in both Block 2 and Block 3. If the FSM somehow enters an undefined state (e.g., due to a bit flip from radiation, which is real in space applications), the `default` sends it back to a safe state.

**Variable naming:** `r_state` is the current state (registered), `r_next_state` is the next state (combinational despite the `reg` declaration — assigned in `always @(*)`).

---

### Video Segment 3: State Encoding (8 min)

#### Binary Encoding

```verilog
localparam S_IDLE  = 2'b00;
localparam S_RUN   = 2'b01;
localparam S_DONE  = 2'b10;
```

- Uses minimum bits: ceil(log2(num_states))
- Saves flip-flops
- Next-state logic may be more complex (more levels of logic)
- **Default for this course**

#### One-Hot Encoding

```verilog
localparam S_IDLE  = 4'b0001;
localparam S_RUN   = 4'b0010;
localparam S_DONE  = 4'b0100;
localparam S_ERROR = 4'b1000;
```

- One flip-flop per state — only one bit is ever high
- Uses more flip-flops but simpler next-state logic (often just one gate to check)
- Faster for FPGAs (LUT-based architectures are good at wide, shallow logic)
- FPGA synthesis tools (including Yosys) can automatically recode to one-hot

#### Gray Encoding

```verilog
localparam S_A = 2'b00;
localparam S_B = 2'b01;
localparam S_C = 2'b11;
localparam S_D = 2'b10;
```

- Adjacent states differ by only one bit
- Useful when state transitions drive external signals that cross clock domains
- Prevents glitches during transition (only one bit changes at a time)

#### Practical Advice

Use binary encoding with `localparam` names. Let the synthesis tool optimize. If timing is critical, explicitly use one-hot and tell the synthesizer. For this course, binary encoding with named constants is sufficient.

---

### Video Segment 4: FSM Design Methodology (15 min)

#### Step-by-Step Process

1. **Understand the problem.** What are the inputs? What are the outputs? What behaviors are required?

2. **Identify the states.** Each distinct mode of operation is a state. Name them descriptively.

3. **Draw the state diagram.**
   - Circles for states, labeled with outputs (Moore) or on transitions (Mealy)
   - Arrows for transitions, labeled with conditions
   - Verify: every state has a transition for every possible input (no dead ends)

4. **Create the state transition table.** Enumerate all current state + input combinations and their next states. This is a systematic check of the diagram.

5. **Code it.** Translate directly from the diagram using the 3-block template.

6. **Simulate it.** Write a testbench that exercises every transition.

#### Example: Vending Machine

A simplified vending machine:
- Accepts nickels (5¢) and dimes (10¢)
- Dispenses when 15¢ or more is deposited
- Returns to idle after dispensing

**States:** IDLE (0¢), FIVE (5¢), TEN (10¢), FIFTEEN (15¢ — dispense), TWENTY (20¢ — dispense + change)

**Inputs:** `i_nickel`, `i_dime` (one-cycle pulses)

**Outputs:** `o_dispense`, `o_change`

```
                  nickel
      ┌─────────────────────────┐
      │         ┌───┐  nickel   │
      │    ────►│IDLE├─────────►│
      │    reset└───┘           │
      │           │dime      ┌──▼──┐  nickel  ┌────────┐
      │           │          │FIVE ├─────────►│  TEN   │
      │           │          └──┬──┘          └──┬──┬──┘
      │           │     dime    │        dime    │  │nickel
      │           ▼             ▼                │  │
      │        ┌──────┐     ┌──────────┐        │  │
      │        │ TEN  │     │FIFTEEN   │◄───────┘  │
      │        └──┬───┘     │dispense=1│           │
      │   dime    │         └────┬─────┘           │
      │           ▼              │                  ▼
      │      ┌──────────┐       │           ┌──────────┐
      │      │ FIFTEEN  │       │           │ TWENTY   │
      │      │dispense=1│       │           │disp=1    │
      │      └────┬─────┘       │           │change=1  │
      │           │              │           └────┬─────┘
      └───────────┴──────────────┴────────────────┘
                    (all → IDLE after dispensing)
```

*(The exact state diagram will be drawn on the whiteboard. The ASCII art above is approximate.)*

The key insight: **draw the diagram first, then code it.** Never go directly from problem description to Verilog. The diagram is your design document.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Question:** You're designing an FSM for an elevator. What are the states? What are the inputs? What are the outputs?

*Open discussion — no single right answer. The goal is to practice the "identify states" step. Typical answers: states = {IDLE, GOING_UP, GOING_DOWN, DOOR_OPEN, DOOR_CLOSING}; inputs = {floor_request[N:0], door_sensor, floor_sensor}; outputs = {motor_up, motor_down, door_open, floor_indicator}.*

---

### Mini-Lecture: FSM Design in Practice (30 min)

#### Live Design: Traffic Light Controller (20 min)

**Problem:** Design a traffic light controller for a single intersection.

**States:**
- `S_GREEN` — green light on (stay for 5 seconds)
- `S_YELLOW` — yellow light on (stay for 1 second)
- `S_RED` — red light on (stay for 4 seconds)

**State diagram (draw on board):**
```
         ┌──────────────────────────────────┐
         │                                  │
         ▼           timer done             │
     ┌───────┐  ──────────────►  ┌────────┐│
     │S_GREEN│                   │S_YELLOW││
     │ 5 sec │                   │ 1 sec  ││
     └───────┘                   └───┬────┘│
                                     │      │
                              timer  │      │
                              done   │      │
                                     ▼      │
                                 ┌───────┐  │
                                 │ S_RED │  │
                                 │ 4 sec ├──┘
                                 └───────┘
                                  timer done
```

**Implementation — timed FSM pattern:**

The FSM needs a counter for timing. There are two approaches:
1. **External counter, FSM reads it:** A free-running counter external to the FSM; the FSM checks the count value
2. **Internal counter, FSM resets it:** The FSM resets a counter on each state entry; a terminal count signal triggers the transition

We'll use approach 2 — it's cleaner:

```verilog
module traffic_light (
    input  wire       i_clk,
    input  wire       i_reset,
    output reg  [2:0] o_light    // {red, yellow, green}
);

    // ========== State Encoding ==========
    localparam S_GREEN  = 2'b00;
    localparam S_YELLOW = 2'b01;
    localparam S_RED    = 2'b10;

    // ========== Timing Parameters ==========
    // For simulation: use small values. For hardware: use real values.
    `ifdef SIMULATION
        localparam GREEN_TIME  = 50;   // short for simulation
        localparam YELLOW_TIME = 10;
        localparam RED_TIME    = 40;
    `else
        localparam GREEN_TIME  = 125_000_000;  // 5 sec at 25 MHz
        localparam YELLOW_TIME =  25_000_000;  // 1 sec
        localparam RED_TIME    = 100_000_000;  // 4 sec
    `endif

    localparam COUNTER_WIDTH = $clog2(GREEN_TIME);  // widest needed

    reg [1:0]                r_state, r_next_state;
    reg [COUNTER_WIDTH-1:0]  r_timer;
    wire                     w_timer_done;

    // ========== Timer ==========
    always @(posedge i_clk) begin
        if (i_reset || r_state != r_next_state)
            r_timer <= 0;         // reset timer on state change
        else
            r_timer <= r_timer + 1;
    end

    assign w_timer_done = (r_state == S_GREEN  && r_timer == GREEN_TIME  - 1) ||
                          (r_state == S_YELLOW && r_timer == YELLOW_TIME - 1) ||
                          (r_state == S_RED    && r_timer == RED_TIME    - 1);

    // ========== Block 1: State Register ==========
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_GREEN;
        else
            r_state <= r_next_state;
    end

    // ========== Block 2: Next-State Logic ==========
    always @(*) begin
        r_next_state = r_state;

        case (r_state)
            S_GREEN:  if (w_timer_done) r_next_state = S_YELLOW;
            S_YELLOW: if (w_timer_done) r_next_state = S_RED;
            S_RED:    if (w_timer_done) r_next_state = S_GREEN;
            default:  r_next_state = S_GREEN;
        endcase
    end

    // ========== Block 3: Output Logic (Moore) ==========
    always @(*) begin
        case (r_state)
            S_GREEN:  o_light = 3'b001;  // green
            S_YELLOW: o_light = 3'b010;  // yellow
            S_RED:    o_light = 3'b100;  // red
            default:  o_light = 3'b100;  // safe default: red
        endcase
    end

endmodule
```

**Key teaching points during the walkthrough:**
- Timer resets when state changes (`r_state != r_next_state`) — automatic re-arm
- `ifdef SIMULATION` lets us use short timers in simulation, real timers on hardware
- The `default` in the output logic sends us to RED (safe failure mode for a traffic light)
- The 3-block structure is immediately readable: "state register is trivial, next-state is the transition table, outputs are the state-to-output map"

#### Common FSM Mistakes (10 min)

Walk through on the board:

1. **Missing `default` in next-state logic → latch on `r_next_state`**
   - Fix: always include `default: r_next_state = S_IDLE;`

2. **Missing default assignment → latch on outputs**
   - Fix: default assignments at top of output block OR `default` case

3. **Using `<=` in the next-state/output combinational blocks**
   - Fix: use `=` in `always @(*)`, `<=` only in `always @(posedge clk)`

4. **Forgetting to handle all states in every `case`**
   - The `r_next_state = r_state;` default assignment at the top of Block 2 handles this elegantly

5. **Timer reset logic that doesn't account for the 1-cycle state transition delay**
   - The `r_state != r_next_state` comparison catches the transition edge

---

### Concept Check Questions

**Q1 (SLO 7.1):** In a Moore machine, the output changes only when the state changes. In a Mealy machine, the output can change when? Give a concrete example.

> **Expected answer:** A Mealy output changes when inputs change, even if the state hasn't changed. Example: a handshake protocol where `o_ack` goes high the same cycle that `i_req` is detected, without waiting for a state transition. This is faster (one cycle less latency) but the output may glitch if the input is noisy.

**Q2 (SLO 7.2):** In the 3-block style, which block uses `<=` and which uses `=`?

> **Expected answer:** Block 1 (state register) uses `<=` because it's sequential (`always @(posedge clk)`). Blocks 2 and 3 (next-state and output logic) use `=` because they're combinational (`always @(*)`).

**Q3 (SLO 7.3):** You have an FSM with 5 states. How many bits do you need for binary encoding? For one-hot?

> **Expected answer:** Binary: ceil(log2(5)) = 3 bits (can represent 0–7, using only 5). One-hot: 5 bits (one per state).

**Q4 (SLO 7.2):** Why do we set `r_next_state = r_state;` as the first line in Block 2?

> **Expected answer:** It's the default assignment that prevents latches. If no transition condition is met (e.g., in a state that's waiting for an event), the next state defaults to the current state — the machine stays put. This ensures `r_next_state` is assigned in every possible execution path.

**Q5 (SLO 7.4):** How do you verify that an FSM correctly handles the transition from S_GREEN to S_YELLOW?

> **Expected answer:** Put the FSM in S_GREEN (via reset, then wait). Apply the condition that should trigger the transition (timer expires). On the next clock edge, check that the state is S_YELLOW and the outputs match S_YELLOW's expected outputs. Verify the timer has reset. Also verify that S_GREEN does NOT transition when the timer hasn't expired.

---

### Lab Exercises (2 hours)

#### Exercise 1: Traffic Light Controller (40 min)

**Objective (SLO 7.2, 7.3, 7.5):** Implement, simulate, and deploy the traffic light FSM.

**Part A:** Create `traffic_light.v` using the mini-lecture code as a starting point.

Map to the Go Board:
- LED1 = Red
- LED2 = Yellow
- LED3 = Green
- LED4 = Heartbeat
- 7-segment display: show the state name (`r` for red, `g` for green, `y` for yellow) or a countdown

**Part B:** Create `tb_traffic_light.v`:

```verilog
`timescale 1ns / 1ps
`define SIMULATION

module tb_traffic_light;

    reg  clk, reset;
    wire [2:0] light;

    traffic_light uut (
        .i_clk(clk),
        .i_reset(reset),
        .o_light(light)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // ---- YOUR CODE HERE ----
    // Task: check_state
    //   - Input: expected light pattern, expected state name (string)
    //   - Compare actual light output against expected
    //   - Report PASS/FAIL

    initial begin
        $dumpfile("traffic.vcd");
        $dumpvars(0, tb_traffic_light);

        // Reset
        reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;
        @(posedge clk); #1;

        // Verify initial state is GREEN
        // ---- YOUR CHECK HERE ----

        // Run through GREEN timer, verify transition to YELLOW
        // ---- YOUR CODE HERE ----
        // Wait GREEN_TIME cycles, then check state is YELLOW

        // Run through YELLOW timer, verify transition to RED
        // ---- YOUR CODE HERE ----

        // Run through RED timer, verify return to GREEN
        // ---- YOUR CODE HERE ----

        // Verify: apply reset mid-state, confirm return to GREEN
        // ---- YOUR CODE HERE ----

        // Report
        $display("\n========================================");
        $display("Traffic Light: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");

        $finish;
    end

endmodule
```

**Required verifications:**
1. Reset → GREEN
2. GREEN → YELLOW transition (after GREEN_TIME cycles, not before)
3. YELLOW → RED transition
4. RED → GREEN transition (full cycle)
5. Mid-state reset → GREEN

**Part C:** Synthesize with real timer values (remove `SIMULATION` define). Program the Go Board. Watch the traffic light cycle.

---

#### Exercise 2: Button Pattern Detector (35 min)

**Objective (SLO 7.2, 7.6):** Design an FSM that detects a specific button press sequence.

**Problem:** Detect the button sequence: Switch1, Switch2, Switch3 (in order). When the sequence is detected, light LED4 for 1 second. If a wrong button is pressed at any point, reset to the beginning.

**State diagram (draw on paper first!):**

```
States: WAIT_1, WAIT_2, WAIT_3, DETECTED

WAIT_1: Waiting for Switch1 press
  - Switch1 pressed → WAIT_2
  - Any other switch → WAIT_1

WAIT_2: Received Switch1, waiting for Switch2
  - Switch2 pressed → WAIT_3
  - Switch1 pressed → WAIT_2 (restart from valid first press)
  - Other switch → WAIT_1

WAIT_3: Received Switch1+2, waiting for Switch3
  - Switch3 pressed → DETECTED
  - Switch1 pressed → WAIT_2
  - Other switch → WAIT_1

DETECTED: Sequence complete!
  - Output: LED4 on
  - After 1 second → WAIT_1
```

Create `pattern_detector.v`:

```verilog
module pattern_detector (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_btn1,    // debounced, active-high press edges
    input  wire i_btn2,
    input  wire i_btn3,
    output reg  o_detected,
    output reg  [1:0] o_progress  // 00=waiting, 01=got 1, 10=got 1+2, 11=detected
);

    // ---- YOUR CODE HERE ----
    // State encoding
    // 3-always-block FSM
    // Timer for the DETECTED state (1 second display)
    // Use debounced edge signals as inputs

endmodule
```

Create `top_pattern.v`:
```verilog
module top_pattern (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,  // reset
    output wire o_led1,     // progress bit 1
    output wire o_led2,     // progress bit 0
    output wire o_led3,     // heartbeat
    output wire o_led4      // DETECTED!
);

    // Debounce all 4 buttons
    // Edge detect on buttons 1-3
    // Instantiate pattern_detector
    // ---- YOUR CODE HERE ----

endmodule
```

**Testbench requirements:**
1. Correct sequence: btn1 → btn2 → btn3 → verify detected pulse
2. Wrong sequence: btn2 → btn1 → verify no detection, FSM resets
3. Partial correct then wrong: btn1 → btn2 → btn1 → verify reset to WAIT_2 (not WAIT_1)
4. Double press: btn1 → btn1 → btn2 → btn3 → verify detection (first extra btn1 should transition WAIT_2 → WAIT_2, not fail)
5. Reset mid-sequence: btn1 → btn2 → reset → verify FSM goes to WAIT_1

---

#### Exercise 3: Testbench Deep Dive (25 min)

**Objective (SLO 7.4):** Write a rigorous testbench for the traffic light that tests every transition.

If not already done thoroughly in Exercise 1, extend `tb_traffic_light.v`:

**Additional verifications:**
1. **Negative test:** During GREEN, verify the state does NOT change after GREEN_TIME − 1 cycles (it should change only at exactly GREEN_TIME)
2. **Stability test:** During each state, verify the output stays constant for the entire duration (sample at multiple points)
3. **Full cycle test:** Run through 3 complete GREEN→YELLOW→RED→GREEN cycles; verify timing is consistent
4. **State encoding check:** Verify that `r_state` never contains an undefined/illegal value (access via hierarchical reference: `uut.r_state`)

**Hierarchical access in testbenches:**
```verilog
// You can read internal DUT signals using dot notation
if (uut.r_state === 2'bxx) begin
    $display("ERROR: State is undefined at time %0t", $time);
    fail_count = fail_count + 1;
end
```

This is simulation-only and doesn't affect synthesis, but it's invaluable for verifying internal FSM behavior.

---

#### Exercise 4 (Stretch): Mealy Pattern Detector Comparison (20 min)

**Objective (SLO 7.1):** Compare Moore and Mealy implementations side by side.

Implement a simple 2-bit sequence detector (detect "10" on a serial input):

**Moore version:** States = IDLE, GOT_1, GOT_10. Detection output is high in GOT_10 state.

**Mealy version:** States = IDLE, GOT_1. Detection output is high when in GOT_1 AND input is 0.

```verilog
// Mealy: output depends on state AND input
// Block 3 becomes:
always @(*) begin
    o_detected = 1'b0;
    case (r_state)
        S_GOT_1: begin
            if (!i_serial_in)
                o_detected = 1'b1;  // Mealy: responds same cycle
        end
    endcase
end
```

**Testbench comparison:** Apply the same input sequence to both. Show in GTKWave that the Mealy output appears 1 clock cycle earlier than the Moore output. Annotate this in a screenshot.

**Discussion:** When does this 1-cycle advantage matter? When is it dangerous?

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **FSMs are the most important design pattern** in digital logic — every controller is an FSM
2. The **3-always-block style** gives you clean separation: register, next-state, output
3. **Draw the state diagram first** — always. Coding directly from a problem description is error-prone.
4. **Default assignments** in combinational blocks prevent latches — `r_next_state = r_state;` and output defaults
5. **Timed FSMs** combine counters with state machines — reset the timer on state transitions
6. Every FSM testbench must verify **every transition**, not just the happy path

#### FSM Design Checklist
Before you code any FSM, verify on paper:
- [ ] All states identified and named
- [ ] Every state has at least one exit transition (no dead states)
- [ ] Every input condition is handled in every state
- [ ] Outputs defined for every state (Moore) or every state+input (Mealy)
- [ ] Reset state is defined and reachable
- [ ] Illegal/unused states have a `default` handler

#### Preview: Day 8 — Hierarchy, Parameters & Generate
Tomorrow we make everything reusable. You'll parameterize your counters, decoders, and FSMs so they work at any width. The `generate` construct lets you replicate hardware programmatically — creating N instances with a loop.

**Homework:** Watch the Day 8 pre-class video (~45 min) on `parameter`, `localparam`, `generate`, and design-for-reuse philosophy.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Traffic Light | 7.2, 7.3, 7.5 | FSM cycles correctly on board; testbench verifies all transitions and timing |
| Ex 2: Pattern Detector | 7.2, 7.6 | Correct sequence detected; wrong sequences rejected; testbench covers 5 scenarios |
| Ex 3: TB Deep Dive | 7.4 | Negative tests, stability tests, multi-cycle, internal state checks all pass |
| Ex 4: Moore vs. Mealy | 7.1 | Side-by-side waveform comparison showing 1-cycle output timing difference |
| Concept check Qs | 7.1, 7.2, 7.3, 7.4 | In-class discussion responses |

---

## Instructor Notes

- **The state diagram step is non-negotiable.** If a student starts coding without drawing the diagram, stop them. Make them draw it on paper or whiteboard. This habit prevents at least half of all FSM bugs.
- **The traffic light is satisfying** — students see colored LEDs cycling through a familiar pattern they designed from scratch. Let them enjoy the moment.
- **The pattern detector** is harder than it looks. The tricky cases are: (a) what to do when btn1 is pressed in WAIT_2 or WAIT_3 (should go to WAIT_2, not WAIT_1), and (b) handling multiple button edge pulses properly. Expect questions here.
- **Timer reset logic:** The `r_state != r_next_state` comparison is elegant but can confuse students. An alternative is to have each state's entry explicitly reset the timer via a signal. Both work; choose whichever your students find more intuitive.
- **`ifdef SIMULATION`:** This is a practical necessity for timed FSMs. In simulation, you can't run 125 million cycles just to get through one GREEN phase. Teach students to always parameterize timing values with a simulation override.
- **For the Mealy exercise:** Some students may produce Mealy outputs that glitch (change briefly when inputs change asynchronously). This is a good teaching moment about why Moore is generally safer.
- **Timing:** Exercises 1 and 2 are the priority. Exercise 1 should take about 40 minutes with testbench. Exercise 2 is harder and may need the full 35 minutes. Exercise 3 extends exercise 1. Exercise 4 is genuine stretch.
