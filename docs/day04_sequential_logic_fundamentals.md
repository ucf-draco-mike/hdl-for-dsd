# Day 4: Sequential Logic Fundamentals

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 4 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 4.1:** Write `always @(posedge clk)` blocks to describe edge-triggered sequential logic and explain why the clock edge is the defining characteristic.
2. **SLO 4.2:** Correctly use nonblocking assignment (`<=`) in sequential blocks and explain, using a timing diagram, why blocking assignment (`=`) causes incorrect behavior in multi-register designs.
3. **SLO 4.3:** Implement D flip-flops with synchronous reset, asynchronous reset, and clock enable in synthesizable Verilog.
4. **SLO 4.4:** Design a counter-based clock divider that derives a human-visible frequency from the Go Board's 25 MHz oscillator, selecting the divider width based on a target frequency.
5. **SLO 4.5:** Simulate sequential logic in Icarus Verilog by generating a clock signal in a testbench and verifying register behavior at specific clock edges using GTKWave.
6. **SLO 4.6:** Construct a multi-digit display system by combining counters, clock dividers, and the 7-segment decoder from prior sessions.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: Clocks and Edge-Triggered Behavior (12 min)

#### The Clock: Heartbeat of Sequential Logic

In combinational logic (everything we've done so far), outputs change whenever inputs change. There is no concept of "when" — just "what."

Sequential logic adds **time**. A clock signal oscillates between 0 and 1, and **things happen on the edges**:

```
         ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk  ────┘   └───┘   └───┘   └───┘   └───
         ↑       ↑       ↑       ↑
     posedge  posedge  posedge  posedge
```

On each **positive edge** (rising edge, 0→1 transition), every flip-flop simultaneously captures its input. Between edges, the combinational logic computes the next values. On the next edge, those values are captured. This is **Register Transfer Level (RTL)** design — the fundamental abstraction of synchronous digital design.

#### The Go Board's Clock

The Go Board has a 25 MHz crystal oscillator connected to pin 15. This provides a stable clock:

- Period: 1 / 25,000,000 = 40 ns
- Frequency: 25 MHz
- This is **far too fast** for human observation (an LED toggling at 25 MHz looks permanently on at ~50% brightness)

To blink an LED at 1 Hz, we need to divide this clock — which is our first real sequential design.

#### The Fundamental Sequential Pattern

```verilog
always @(posedge i_clk) begin
    r_q <= r_d;
end
```

This is a D flip-flop. On every rising clock edge, `r_q` captures the value of `r_d`. Between clock edges, `r_q` holds its value — it is **state**.

**Compare with combinational:**

| | Combinational | Sequential |
|---|---|---|
| Sensitivity | `always @(*)` — all inputs | `always @(posedge clk)` — clock edge only |
| Assignment | Blocking `=` | Nonblocking `<=` |
| Output behavior | Changes whenever input changes | Changes only on clock edge |
| Synthesizes to | Gates, muxes | Flip-flops, registers |
| Has memory? | No | Yes |

---

### Video Segment 2: Nonblocking Assignment — Why It Matters (15 min)

#### The Problem with Blocking Assignment in Sequential Blocks

Consider a simple two-stage pipeline (shift register):

```verilog
// WRONG — blocking assignment in sequential block
always @(posedge clk) begin
    b = a;    // b gets a's value IMMEDIATELY
    c = b;    // c gets b's new value (which is a!) — NOT the old b!
end
```

With blocking assignment, `b = a` executes and updates `b` immediately. Then `c = b` reads the *already-updated* `b`, which is now equal to `a`. After one clock edge: `b = a`, `c = a`. The pipeline collapses — both stages get the same value.

```verilog
// CORRECT — nonblocking assignment
always @(posedge clk) begin
    b <= a;   // b is SCHEDULED to get a's value
    c <= b;   // c is SCHEDULED to get b's CURRENT value (before update)
end
```

With nonblocking assignment, both right-hand sides are evaluated **simultaneously** using the current values of all signals. Then, at the end of the time step, all left-hand sides are updated. After one clock edge: `b = a_old`, `c = b_old`. The pipeline works correctly.

#### Visualizing With a Timing Diagram

```
Clock:  ──┐  ┌──┐  ┌──┐  ┌──┐  ┌──
          └──┘  └──┘  └──┘  └──┘
a:      ──[A]──────────────────────
b(<=):  ────────[A]────────────────    (captures a on edge 1)
c(<=):  ──────────────[A]─────────    (captures old b on edge 2)

vs.

b(=):   ────────[A]────────────────    (same)
c(=):   ────────[A]────────────────    (WRONG: also captures A on edge 1!)
```

#### The Rule (Complete)

| Context | Assignment | Operator | Why |
|---|---|---|---|
| `always @(*)` | Blocking | `=` | Models combinational signal flow — order matters, and that's fine |
| `always @(posedge clk)` | Nonblocking | `<=` | Models simultaneous register capture — all flip-flops update at once |

**Never mix blocking and nonblocking in the same `always` block.** This is not just a style rule — it can cause simulation nondeterminism.

---

### Video Segment 3: Flip-Flops With Reset and Enable (10 min)

#### Basic D Flip-Flop

```verilog
always @(posedge i_clk)
    r_q <= i_d;
```

Synthesizes to a single flip-flop. No reset — powers up in an undefined state (in simulation, `x`; on FPGA, unpredictable 0 or 1).

#### Synchronous Reset

```verilog
always @(posedge i_clk) begin
    if (i_reset)
        r_q <= 1'b0;
    else
        r_q <= i_d;
end
```

The reset is checked **on the clock edge**, just like the data. The flip-flop only resets when `i_reset` is high **and** a clock edge occurs.

**Pros:** Simpler timing analysis, guaranteed to be synchronous with the clock domain.
**Cons:** If the clock isn't running, reset doesn't work.

#### Asynchronous Reset

```verilog
always @(posedge i_clk or posedge i_reset) begin
    if (i_reset)
        r_q <= 1'b0;
    else
        r_q <= i_d;
end
```

Note the sensitivity list: `posedge i_clk or posedge i_reset`. The reset takes effect **immediately** when asserted, regardless of the clock. This is common in ASIC design and required by some FPGA architectures.

**Pros:** Works even if clock is stopped. Can initialize hardware on power-up.
**Cons:** Asynchronous signals can cause metastability if not carefully managed.

**For this course:** We'll primarily use **synchronous reset** unless there's a specific reason for async. The iCE40 flip-flops natively support both.

#### Clock Enable

```verilog
always @(posedge i_clk) begin
    if (i_reset)
        r_q <= 1'b0;
    else if (i_enable)
        r_q <= i_d;
    // implicit: else r_q stays the same (hold)
end
```

When `i_enable` is low, the register holds its current value. No `else` needed — the "else" case is implicitly "keep the current value," which is exactly what a flip-flop does when not updated.

**Important:** This is one case where an incomplete `if` does **not** create a latch. In a sequential block (`posedge clk`), the flip-flop naturally holds its value. A latch is only a problem in combinational `always @(*)` blocks.

---

### Video Segment 4: Counters and Clock Division (13 min)

#### The Free-Running Counter

A counter is a register that increments itself on every clock edge:

```verilog
reg [7:0] r_count;

always @(posedge i_clk) begin
    if (i_reset)
        r_count <= 8'd0;
    else
        r_count <= r_count + 8'd1;
end
```

This 8-bit counter counts 0, 1, 2, ..., 254, 255, 0, 1, ... (rolls over naturally at 2^8 = 256).

**What does this synthesize to?**
- An 8-bit register (8 flip-flops)
- An 8-bit adder (combinational)
- A mux for the reset path
- The adder's output feeds back to the register's input

#### Clock Division by Counting

To get a 1 Hz signal from a 25 MHz clock, we need to toggle an output every 12,500,000 clock cycles (half-period):

```verilog
// 25 MHz → ~1 Hz clock divider
reg [23:0] r_counter;      // 24 bits can count up to 16,777,215
reg        r_led;

localparam COUNT_MAX = 24'd12_499_999;  // 25M/2 - 1

always @(posedge i_clk) begin
    if (i_reset) begin
        r_counter <= 24'd0;
        r_led     <= 1'b0;
    end else if (r_counter == COUNT_MAX) begin
        r_counter <= 24'd0;
        r_led     <= ~r_led;    // Toggle
    end else begin
        r_counter <= r_counter + 24'd1;
    end
end
```

**Calculating the counter width:**
- Target: 25,000,000 / 2 = 12,500,000 (half-period for symmetric waveform)
- Bits needed: ceil(log2(12,500,000)) = 24 bits (2^24 = 16,777,216 > 12,500,000 ✓)
- The `localparam` makes the count value readable and maintainable

**`localparam`:** A constant that cannot be overridden (unlike `parameter`). Use it for internal constants. The underscores in `12_499_999` are ignored by Verilog — they're visual separators for readability, like commas in "12,499,999."

#### Choosing Clock Divider Rates

| Target frequency | Half-period count | Counter bits needed |
|---|---|---|
| 1 Hz | 12,500,000 | 24 |
| 2 Hz | 6,250,000 | 23 |
| 10 Hz | 1,250,000 | 21 |
| 100 Hz | 125,000 | 17 |
| 1 kHz | 12,500 | 14 |

**Useful for debugging:** Start with a fast blink rate (10 Hz) to verify the design works, then slow it down once confirmed.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Draw a timing diagram on the board:**

Given this code, draw the values of `r_a` and `r_b` for 4 clock edges, assuming `r_a = 0`, `r_b = 0` initially, and `i_data` changes from 0 to 1 before the first clock edge.

```verilog
always @(posedge clk) begin
    r_a <= i_data;
    r_b <= r_a;
end
```

```
clk:    ___|‾‾‾|___|‾‾‾|___|‾‾‾|___|‾‾‾|___
i_data: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
r_a:    ???
r_b:    ???
```

> *Answer: After edge 1: r_a=1, r_b=0. After edge 2: r_a=1, r_b=1. The data propagates one stage per clock — this is a 2-stage shift register / synchronizer.*

---

### Mini-Lecture: From Flip-Flops to Blinking LEDs (35 min)

#### The Moment Everything Changes (5 min)

"Until now, you've been building combinational circuits — clever arrangements of gates that produce outputs instantly. Today, you add **memory** and **time**. After today, your designs will have state, they will count, they will sequence, and they will do things on their own without you pressing buttons."

#### Live Coding: D Flip-Flop (10 min)

Write, simulate, and verify a D flip-flop with synchronous reset:

```verilog
module d_ff (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= 1'b0;
        else
            o_q <= i_d;
    end
endmodule
```

**Testbench walkthrough:**
```verilog
module tb_d_ff;
    reg clk, reset, d;
    wire q;

    d_ff uut (.i_clk(clk), .i_reset(reset), .i_d(d), .o_q(q));

    // Clock generation: 10ns period (100 MHz in simulation)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("d_ff.vcd");
        $dumpvars(0, tb_d_ff);

        // Initialize
        reset = 1; d = 0;
        @(posedge clk); #1;   // wait for edge + tiny delta
        @(posedge clk); #1;   // two cycles of reset

        reset = 0;
        d = 1;
        @(posedge clk); #1;   // q should be 1 after this edge
        @(posedge clk); #1;

        d = 0;
        @(posedge clk); #1;   // q should be 0 after this edge
        @(posedge clk); #1;

        $finish;
    end
endmodule
```

**Open GTKWave, show:**
- Clock toggling
- `d` changes between edges (setup time concept)
- `q` changes only ON the edge
- Reset clears `q` regardless of `d`

**Teaching point:** The `#1` after `@(posedge clk)` is a simulation convenience — it moves past the clock edge so signal assignments in the testbench don't race with the DUT's clock edge processing.

#### Live Coding: Counter-Based Blinker (10 min)

```verilog
module led_blinker (
    input  wire i_clk,
    output wire o_led1
);

    reg [23:0] r_counter = 24'd0;  // Initial value for simulation
    reg        r_led     = 1'b0;

    localparam COUNT_1HZ = 24'd12_499_999;

    always @(posedge i_clk) begin
        if (r_counter == COUNT_1HZ) begin
            r_counter <= 24'd0;
            r_led     <= ~r_led;
        end else begin
            r_counter <= r_counter + 24'd1;
        end
    end

    assign o_led1 = ~r_led;  // Active-low output

endmodule
```

**Note on `reg ... = 24'd0;`:** This initial value syntax works in simulation and on some FPGAs (including iCE40 with Yosys, which can set initial register values). It is NOT a substitute for a proper reset in production designs, but it's convenient for simple projects on the Go Board where we don't have a dedicated reset button.

**Synthesize and program.** Watch the LED blink. The class's first sequential design running on real hardware.

#### The Blocking vs. Nonblocking Bug (10 min)

**Live demo:** Show the shift register from the warm-up. First with `<=` (correct), then change to `=` (broken). Simulate both, show waveforms side by side.

```verilog
// Version A: nonblocking (correct)
always @(posedge clk) begin
    r_stage2 <= r_stage1;
    r_stage1 <= i_data;
end

// Version B: blocking (broken)
always @(posedge clk) begin
    r_stage2 = r_stage1;   // reads OLD r_stage1
    r_stage1 = i_data;     // updates r_stage1
end
// Wait — Version B actually works due to statement ordering!
// But reverse the order:
always @(posedge clk) begin
    r_stage1 = i_data;     // updates r_stage1 FIRST
    r_stage2 = r_stage1;   // reads NEW r_stage1 — BROKEN
end
```

**Key insight:** With blocking assignment, order matters (and can break your design). With nonblocking, order doesn't matter — all RHS values are read simultaneously, all updates happen at the end. **This is why we use nonblocking in sequential blocks — it models the physical behavior of flip-flops, which all sample simultaneously on the clock edge.**

---

### Concept Check Questions

**Q1 (SLO 4.1):** What is the difference between `always @(*)` and `always @(posedge i_clk)`?

> **Expected answer:** `always @(*)` triggers whenever any input signal changes — it describes combinational logic. `always @(posedge i_clk)` triggers only on the rising edge of the clock — it describes sequential logic (flip-flops/registers).

**Q2 (SLO 4.2):** In the following code, what are the values of `r_a`, `r_b`, and `r_c` after the first clock edge if all start at 0 and `i_x = 1`?

```verilog
always @(posedge clk) begin
    r_a <= i_x;
    r_b <= r_a;
    r_c <= r_b;
end
```

> **Expected answer:** After edge 1: `r_a = 1`, `r_b = 0`, `r_c = 0`. All right-hand sides were read simultaneously before the edge (all were 0 except `i_x`). Data propagates one stage per clock.

**Q3 (SLO 4.3):** In a sequential `always @(posedge clk)` block, if you write an `if` without an `else`, does this create a latch?

> **Expected answer:** No. In a sequential block, the flip-flop naturally holds its value when not explicitly assigned. An incomplete `if` in a sequential block means "hold the current value" — which is exactly what registers do. Latches are only inferred from incomplete assignments in **combinational** `always @(*)` blocks.

**Q4 (SLO 4.4):** You want an LED to blink at approximately 5 Hz on the Go Board (25 MHz clock). What value should your counter count to?

> **Expected answer:** 5 Hz → toggle at 10 Hz → half-period = 25,000,000 / 10 = 2,500,000. Counter counts from 0 to 2,499,999, then resets and toggles. Need ceil(log2(2,500,000)) = 22 bits.

**Q5 (SLO 4.5):** In a testbench, you write:
```verilog
initial clk = 0;
always #5 clk = ~clk;
```
What is the clock period? What frequency does this model?

> **Expected answer:** The clock toggles every 5 time units, so the period is 10 time units. If we interpret the default time unit as 1 ns, this is a 10 ns period = 100 MHz. (The actual time unit depends on the `timescale` directive, which defaults to 1 ns in most simulators.)

---

### Lab Exercises (2 hours)

#### Exercise 1: D Flip-Flop — Simulate Then Synthesize (25 min)

**Objective (SLO 4.1, 4.3, 4.5):** Build confidence with the simulate-first workflow for sequential logic.

**Part A:** Create `d_ff.v` (the module from the mini-lecture) and `tb_d_ff.v` (the testbench from the mini-lecture).

Simulate:
```bash
iverilog -o sim.vvp tb_d_ff.v d_ff.v
vvp sim.vvp
gtkwave d_ff.vcd &
```

**Student task in GTKWave:**
1. Identify on the waveform: exactly which clock edge causes `o_q` to change
2. Verify that reset clears `o_q` on the next clock edge (not immediately)
3. Mark with GTKWave cursors: the moment `i_d` changes vs. the moment `o_q` changes. What's the relationship?

**Part B:** Add clock enable. Modify `d_ff.v`:
```verilog
module d_ff_en (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_enable,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= 1'b0;
        else if (i_enable)
            o_q <= i_d;
        // else: o_q holds — no latch, this is sequential!
    end
endmodule
```

Update the testbench to toggle `i_enable` and verify that `o_q` only updates when enable is high.

---

#### Exercise 2: Loadable Register (20 min)

**Objective (SLO 4.1, 4.3):** Build a 4-bit register with load enable and reset.

Create `register_4bit.v`:
```verilog
module register_4bit (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_load,      // load enable
    input  wire [3:0] i_data,      // data to load
    output reg  [3:0] o_q
);

    // ---- YOUR CODE HERE ----
    // On posedge clk:
    //   if reset: clear to 0
    //   else if load: capture i_data
    //   else: hold current value

endmodule
```

**Testbench requirements:**
1. Reset the register
2. Load the value `4'hA`, verify `o_q == 4'hA`
3. Deassert load, apply new data — verify `o_q` holds its value
4. Load `4'h5`, verify it changes
5. Reset again, verify `o_q == 0`

**Board test:** Connect switches to `i_data`, one button as `i_load`, display `o_q` on 7-segment using the decoder from Day 2/3.

---

#### Exercise 3: Free-Running Counter + LED Blinker (25 min)

**Objective (SLO 4.1, 4.4, 4.6):** Design and debug a counter-based clock divider.

**Part A:** Implement the LED blinker (from the mini-lecture). Target ~1 Hz.

```verilog
module led_blinker (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // ---- YOUR CODE HERE ----
    // Create a 24-bit counter
    // Toggle r_led on terminal count
    // Drive o_led1 from r_led (active-low)

    // BONUS: Drive o_led2, o_led3, o_led4 from different counter bits
    // for different blink rates
    // Hint: r_counter[23] toggles at ~1.5 Hz, [22] at ~3 Hz, [21] at ~6 Hz, etc.

endmodule
```

**Part B (multi-speed):** Drive each LED from a different bit of the counter:
- `o_led1` ← `~r_counter[23]` (~1.5 Hz)
- `o_led2` ← `~r_counter[22]` (~3 Hz)
- `o_led3` ← `~r_counter[21]` (~6 Hz)
- `o_led4` ← `~r_counter[20]` (~12 Hz)

Program and observe: LED1 blinks slowest, LED4 fastest. This visually demonstrates binary counting.

**Simulation tip:** You can't simulate 25M clock cycles practically. In your testbench, either use a shorter counter value or just simulate enough cycles to verify the counter increments correctly and rolls over at the expected value.

---

#### Exercise 4: Counter on 7-Segment Display (30 min)

**Objective (SLO 4.4, 4.6):** Integrate a counter, clock divider, and 7-segment decoder into a complete system.

Create `top_counter_display.v`:
```verilog
module top_counter_display (
    input  wire i_clk,
    input  wire i_switch1,    // Reset
    output wire o_led1,       // Heartbeat blinker
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // --- Clock divider: ~2-4 Hz count rate ---
    reg [23:0] r_clk_div;
    wire       w_tick;   // pulses high for one clock cycle at the divided rate

    always @(posedge i_clk) begin
        if (r_clk_div == 24'd6_249_999) begin  // ~2 Hz
            r_clk_div <= 24'd0;
        end else begin
            r_clk_div <= r_clk_div + 24'd1;
        end
    end

    assign w_tick = (r_clk_div == 24'd6_249_999);

    // --- 4-bit counter: counts 0–F, incremented by w_tick ---
    reg [3:0] r_count;
    wire w_reset = ~i_switch1;  // active-low button → active-high reset

    always @(posedge i_clk) begin
        if (w_reset)
            r_count <= 4'd0;
        else if (w_tick)
            r_count <= r_count + 4'd1;
    end

    // --- 7-segment decoder ---
    wire [6:0] w_seg;

    hex_to_7seg decoder (
        .i_hex(r_count),
        .o_seg(w_seg)
    );

    // --- Output assignments ---
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f,
            o_segment1_g} = w_seg;

    // --- Heartbeat: separate blinker on LED1 ---
    // ---- YOUR CODE HERE ----
    // Use a different counter bit to blink LED1 at ~1 Hz
    // This shows the FPGA is running even when the display counter
    // is between updates

endmodule
```

**Key design pattern:** The `w_tick` signal. Instead of creating a slow clock and using it as `posedge w_slow_clk`, we generate a one-cycle-wide pulse at the divided rate and use it as a clock enable. **Everything runs on the single 25 MHz domain.** This is the correct way to do clock division in synchronous design:

```
                     ┌─┐                         ┌─┐
w_tick: ─────────────┘ └─────────────────────────┘ └────
        |← ~0.5 sec →|
```

**Why not use a divided clock?** Creating a derived clock and using it in `always @(posedge w_slow_clk)` creates a new clock domain. This complicates timing analysis, can cause timing violations, and requires clock domain crossing logic if the two domains need to communicate. A tick/enable pulse avoids all of this.

**Student tasks:**
1. Synthesize and program
2. Verify the 7-seg counts 0 → F → 0 → ...
3. Verify that pressing switch1 resets the count to 0
4. Measure the approximate count rate (should be ~2 Hz, so 0→F takes ~8 seconds)
5. Add the heartbeat LED

---

#### Exercise 5: Up/Down Counter with Button Control (20 min)

**Objective (SLO 4.3, 4.6):** Add user interaction to sequential logic.

Modify the counter system:
- Switch1 = reset (press to reset to 0)
- Switch2 = direction control (not pressed = count up, pressed = count down)
- Switch3 = pause/run (not pressed = running, pressed = paused)
- LED shows counting direction

```verilog
// ---- YOUR CODE ----
// Modify the counter logic:
//   if reset: count = 0
//   else if tick AND not paused:
//     if direction: count = count - 1
//     else:         count = count + 1
```

**Hint:** The buttons are active-low. Apply the Day 1 boundary-inversion pattern. The debounce problem (buttons are noisy) exists here — we'll solve it properly on Day 5. For now, the clock divider naturally "debounces" by sampling only every ~0.5 seconds, so fast bounces are unlikely to cause visible issues.

---

#### Exercise 6 (Stretch): Dual 7-Segment Counter (15 min if time permits)

**Objective (SLO 4.6):** Use both 7-segment displays on the Go Board.

Extend the design:
- Lower 4 bits of an 8-bit counter → display 1 (ones digit in hex)
- Upper 4 bits → display 2 (sixteens digit in hex)
- Count from `00` to `FF` across both displays

This requires:
1. An 8-bit counter instead of 4-bit
2. Two instances of `hex_to_7seg`
3. Two sets of segment output pins in the PCF

```verilog
// 8-bit counter
reg [7:0] r_count_8;

// Two decoder instances
hex_to_7seg decoder_lo (
    .i_hex(r_count_8[3:0]),
    .o_seg(w_seg1)
);

hex_to_7seg decoder_hi (
    .i_hex(r_count_8[7:4]),
    .o_seg(w_seg2)
);
```

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. `always @(posedge clk)` + `<=` = sequential logic. This is the foundation of everything from here forward.
2. **Nonblocking assignment** models the physical reality of simultaneous flip-flop capture. Don't use blocking in sequential blocks.
3. Counters are the workhorse of sequential design — they create timing, divide clocks, and generate addresses.
4. **Clock enable (tick) pattern** is the right way to create slow events. Never create a new clock domain for simple frequency division.
5. "No latch" in sequential blocks — incomplete `if` means "hold value," which is what flip-flops do naturally.

#### Week 1 Recap
In 4 days you've gone from zero HDL to:
- Combinational logic: `assign`, `always @(*)`, `if/else`, `case`
- Sequential logic: `always @(posedge clk)`, `<=`, counters, clock dividers
- A complete system: counter → decoder → 7-segment display with button control
- Toolchain fluency: Yosys, nextpnr, iceprog, Icarus Verilog, GTKWave

#### Preview: Week 2
- Day 5: Shift registers, debouncing (proper), metastability
- Day 6: Testbench methodology — self-checking testbenches become mandatory
- Day 7: Finite State Machines — the most important design pattern you'll learn
- Day 8: Parameters, generate, and design for reuse

**Homework:** Watch the Day 5 pre-class video (~45 min) on counters, shift registers, and metastability. The debounce module we build on Day 5 will be reused in almost every design for the rest of the course.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: D Flip-Flop | 4.1, 4.3, 4.5 | Waveform shows edge-triggered behavior; enable version verified |
| Ex 2: Loadable Register | 4.1, 4.3 | Register loads, holds, and resets correctly in simulation and on board |
| Ex 3: LED Blinker | 4.1, 4.4 | LED blinks at approximately correct rate; multi-speed demo |
| Ex 4: Counter Display | 4.4, 4.6 | 7-seg counts 0–F at correct rate; reset works; heartbeat LED |
| Ex 5: Up/Down Counter | 4.3, 4.6 | Direction and pause controls work; reset works |
| Ex 6: Dual Display | 4.6 | Both 7-seg displays show 00–FF |
| Concept check Qs | 4.1, 4.2, 4.3, 4.4, 4.5 | In-class discussion responses |

---

## Instructor Notes

- **The blocking vs. nonblocking demo is the single most important teaching moment today.** Take the time to do it right — show the waveforms side by side, explain what's happening at the simulation event level.
- **Initial value syntax** (`reg [23:0] r_counter = 24'd0;`): This is convenient but students should understand it's not portable to all synthesis flows. iCE40 + Yosys supports it. Xilinx Vivado supports it. Many ASIC flows do not. Always prefer explicit resets in production code.
- **Simulation speed:** Students will realize they can't simulate 25 million cycles. Teach them to either: (a) use a smaller counter value in simulation, or (b) simulate just enough cycles to verify the counting logic and rollover, then trust it on hardware.
- **The tick/enable pattern** is worth emphasizing. Many beginners create derived clocks and use them as actual clock signals. This causes real timing closure problems. The enable pattern is the professional approach.
- **Timing:** Exercises 1–4 are the priority. Exercise 4 is the capstone of Week 1, so ensure most students get there. Exercises 5–6 are genuine stretch.
- **End of Week 1 celebration:** Students have a counter running on a display. They went from zero to sequential design in 4 days. Acknowledge this accomplishment.
- **For struggling students:** If someone is behind, the minimum viable Day 4 deliverable is the LED blinker (Exercise 3). The 7-seg counter (Exercise 4) can be provided as starter code to study.
