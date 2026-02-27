# Day 5: Counters, Shift Registers & Debouncing

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 5 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 5.1:** Implement counter variations (modulo-N, up/down, loadable) and select the appropriate counter type for a given timing or sequencing task.
2. **SLO 5.2:** Design shift registers in all four configurations (SISO, SIPO, PISO, PIPO) and explain their role in serial-to-parallel and parallel-to-serial conversion.
3. **SLO 5.3:** Explain metastability, identify when it can occur (asynchronous input crossing into a synchronous domain), and implement a 2-FF synchronizer as the standard mitigation.
4. **SLO 5.4:** Design a reusable, parameterized debounce module that filters mechanical switch noise using a counter-based approach.
5. **SLO 5.5:** Integrate the debounce module with sequential designs and verify correct debounced behavior on the Go Board.
6. **SLO 5.6:** Generate an LFSR (Linear Feedback Shift Register) and explain why it produces a pseudo-random sequence.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: Counter Variations (10 min)

#### Beyond the Free-Running Counter

On Day 4 you built a simple incrementing counter. Real designs need many variations.

#### Modulo-N Counter

Counts from 0 to N−1, then wraps:

```verilog
module counter_mod_n #(
    parameter N = 10
)(
    input  wire                  i_clk,
    input  wire                  i_reset,
    output reg  [$clog2(N)-1:0]  o_count,
    output wire                  o_wrap     // pulses on wrap-around
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (o_count == N - 1)
            o_count <= 0;
        else
            o_count <= o_count + 1;
    end

    assign o_wrap = (o_count == N - 1);

endmodule
```

**`$clog2(N)`:** A system function that returns ceil(log2(N)) — the number of bits needed to represent values 0 through N−1. This makes the counter width automatically match the modulus.

#### Up/Down Counter

```verilog
module counter_updown #(
    parameter WIDTH = 8
)(
    input  wire             i_clk,
    input  wire             i_reset,
    input  wire             i_enable,
    input  wire             i_direction,  // 0 = up, 1 = down
    output reg [WIDTH-1:0]  o_count
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (i_direction)
                o_count <= o_count - 1;
            else
                o_count <= o_count + 1;
        end
    end

endmodule
```

#### Loadable Counter

```verilog
always @(posedge i_clk) begin
    if (i_reset)
        o_count <= 0;
    else if (i_load)
        o_count <= i_data;       // parallel load
    else if (i_enable)
        o_count <= o_count + 1;
end
```

Load takes priority over counting (because it's checked first in the `if/else` chain). This is useful for timer presets, address generators, and baud rate dividers.

---

### Video Segment 2: Shift Registers (12 min)

#### What Is a Shift Register?

A chain of flip-flops where each stage passes its value to the next on every clock edge. Data moves one position per clock cycle.

```verilog
// 8-bit shift register, shift right, serial in / parallel out (SIPO)
module shift_reg_sipo #(
    parameter WIDTH = 8
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_serial_in,
    input  wire              i_shift_en,
    output wire [WIDTH-1:0]  o_parallel_out
);

    reg [WIDTH-1:0] r_shift;

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= 0;
        else if (i_shift_en)
            r_shift <= {i_serial_in, r_shift[WIDTH-1:1]};
            // New bit enters at MSB, everything shifts right
            // Bit 0 falls off the end
    end

    assign o_parallel_out = r_shift;

endmodule
```

#### The Four Configurations

| Type | Input | Output | Use Case |
|---|---|---|---|
| **SISO** (Serial In, Serial Out) | 1 bit/clock | 1 bit/clock | Delay line, pipeline |
| **SIPO** (Serial In, Parallel Out) | 1 bit/clock | N bits at once | Serial receiver (UART RX) |
| **PISO** (Parallel In, Serial Out) | N bits at once | 1 bit/clock | Serial transmitter (UART TX) |
| **PIPO** (Parallel In, Parallel Out) | N bits at once | N bits at once | Register with shift capability |

**Why shift registers matter for this course:** UART and SPI (Week 3) are fundamentally shift-register-based protocols. UART TX loads a byte and shifts it out one bit at a time (PISO). UART RX shifts bits in and presents the complete byte (SIPO). Understanding shift registers now directly prepares you for communication interfaces.

#### PISO — Parallel In, Serial Out

```verilog
module shift_reg_piso #(
    parameter WIDTH = 8
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_load,        // load parallel data
    input  wire              i_shift_en,    // shift out one bit
    input  wire [WIDTH-1:0]  i_parallel_in,
    output wire              o_serial_out
);

    reg [WIDTH-1:0] r_shift;

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= 0;
        else if (i_load)
            r_shift <= i_parallel_in;
        else if (i_shift_en)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};  // shift right, fill with 0
    end

    assign o_serial_out = r_shift[0];  // LSB shifts out first

endmodule
```

**Design note:** `i_load` has priority over `i_shift_en`. If both are asserted simultaneously, the load wins. This is intentional — you load fresh data, then shift it out.

---

### Video Segment 3: Metastability and Synchronizers (12 min)

#### The Metastability Problem

Every flip-flop has **setup time** (data must be stable *before* the clock edge) and **hold time** (data must remain stable *after* the clock edge). If these timing requirements are violated, the flip-flop enters a **metastable state** — its output is neither 0 nor 1, but somewhere in between, and it can stay there for an unpredictable amount of time before resolving to 0 or 1.

```
Normal:      ____|‾‾‾‾    Output cleanly transitions

Metastable:  ____/‾‾‾‾    Output hovers at ~Vdd/2 for some time
                 ↑
           metastable zone — output is undefined
```

#### When Does This Happen?

Metastability occurs when an **asynchronous signal** (one not synchronized to the clock) is sampled by a flip-flop. The asynchronous signal can change at any time, including during the setup/hold window.

**In our designs, the most common source is button inputs.** A human pressing a button has no relationship to the 25 MHz clock. The button signal can transition at the exact moment of a clock edge.

#### The 2-FF Synchronizer

The standard mitigation is to pass the asynchronous signal through two flip-flops in series:

```verilog
module synchronizer (
    input  wire i_clk,
    input  wire i_async_in,
    output wire o_sync_out
);

    reg r_meta;   // first FF — may go metastable
    reg r_sync;   // second FF — extremely unlikely to be metastable

    always @(posedge i_clk) begin
        r_meta <= i_async_in;    // Stage 1: might go metastable
        r_sync <= r_meta;        // Stage 2: gives stage 1 a full cycle to resolve
    end

    assign o_sync_out = r_sync;

endmodule
```

**Why two stages?**
- The first flip-flop may go metastable, but it has an entire clock period to resolve before the second flip-flop samples it.
- The probability of the second flip-flop also going metastable is astronomically low (probability compounds multiplicatively).
- At 25 MHz (40 ns period), the Mean Time Between Failures (MTBF) with a 2-FF synchronizer is typically measured in *centuries*.

**Key point:** Synchronization adds **2 clock cycles of latency**. The synchronized output is always 2 cycles behind the raw input. This latency is the price of reliability.

#### When To Synchronize

Every signal that enters your clock domain from the outside world must be synchronized:
- Button/switch inputs
- External serial data lines (before any processing)
- Signals from other clock domains

You do **not** synchronize signals that are already in your clock domain (outputs of registers driven by the same clock).

---

### Video Segment 4: Button Debouncing (11 min)

#### The Bounce Problem

Mechanical switches don't make clean transitions. When a button is pressed or released, the contacts physically bounce, creating multiple rapid transitions:

```
Physical press:
               ┌─────────────────────
        ───────┘

What the FPGA sees:
               ┌┐ ┌┐┌──┐  ┌─────────
        ───────┘└─┘└┘└──┘──┘
               |← bounce →|← stable →
               ~1-10 ms
```

A counter incrementing on button press might count 5, 10, or 20 instead of 1, because each bounce looks like a separate press/release event.

#### Counter-Based Debounce

The idea: require the input to be stable for a minimum time period before accepting the new value. If the input bounces, the counter resets and the timer starts over.

```verilog
module debounce #(
    parameter CLKS_TO_STABLE = 250_000  // 10ms at 25 MHz
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
    reg r_bouncy_sync_0, r_bouncy_sync_1;  // 2-FF synchronizer

    // Synchronize the async input first
    always @(posedge i_clk) begin
        r_bouncy_sync_0 <= i_bouncy;
        r_bouncy_sync_1 <= r_bouncy_sync_0;
    end

    // Debounce logic
    always @(posedge i_clk) begin
        if (r_bouncy_sync_1 != o_clean) begin
            // Input differs from accepted state — start counting
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_bouncy_sync_1;  // Accept the new state
                r_count <= 0;
            end else begin
                r_count <= r_count + 1;
            end
        end else begin
            // Input matches accepted state — reset counter
            r_count <= 0;
        end
    end

endmodule
```

**How it works:**
1. The input is first synchronized (2-FF synchronizer — addresses metastability)
2. If the synchronized input differs from the current clean output, a counter starts
3. If the input stays different for `CLKS_TO_STABLE` consecutive cycles, accept the new value
4. If the input bounces back before the counter finishes, the counter resets
5. Result: only stable transitions longer than 10 ms pass through

**Parameter choice:** 10 ms (250,000 clocks at 25 MHz) is a good starting point. Most mechanical switches settle within 5 ms. Some particularly bouncy switches may need 20 ms.

#### The Debounce Module Is Reusable

This module will be used in nearly every design for the rest of the course. Build it well, test it thoroughly, and keep it in your personal Verilog library.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick question:** You have a button connected directly to a counter's increment input (no synchronizer, no debounce). The counter is supposed to count by 1 each time the button is pressed. Instead, it sometimes counts by 3, 7, or 12. What are the two separate problems, and which must be solved first?

> *Answer: (1) Metastability — the button is asynchronous and can violate setup/hold timing. Must be solved first with a 2-FF synchronizer, because metastable outputs can propagate unpredictably through downstream logic. (2) Bounce — multiple transitions per press. Solved with a debounce filter. The synchronizer goes first in the signal chain because the debounce counter itself is synchronous logic and needs a clean, stable input to work correctly.*

---

### Mini-Lecture: Practical Debouncing and Shift Register Patterns (30 min)

#### The Synchronizer-Then-Debounce Pipeline (10 min)

Draw the signal chain on the board:

```
Button (async) → [2-FF Sync] → [Debounce Counter] → Clean signal
                  ↑ solves         ↑ solves
              metastability      bounce noise
```

**Live walkthrough** of the debounce module from the pre-class video:
- Trace through the counter behavior with a timing diagram
- Show a bounce scenario: input toggles 5 times in 2 ms, counter never reaches threshold, output stays stable
- Show a real press: input stabilizes for >10 ms, counter reaches threshold, output transitions once

#### Edge Detection (5 min)

Often we need to detect the *moment* a button is pressed (the rising edge of the debounced signal), not just its level. This is a one-clock-cycle pulse generator:

```verilog
reg r_clean_prev;

always @(posedge i_clk) begin
    r_clean_prev <= o_clean;
end

wire w_press_edge = o_clean & ~r_clean_prev;   // rising edge of clean signal
wire w_release_edge = ~o_clean & r_clean_prev;  // falling edge
```

**Why this pattern?** `r_clean_prev` holds last cycle's value. When `o_clean` is high and `r_clean_prev` is low, we know the signal just transitioned — one clock cycle pulse. This is the standard edge detector.

#### Shift Register as LED Chase (10 min)

The "Knight Rider" / Cylon chase pattern: a lit LED sweeps back and forth across the 4 LEDs.

**Approach:** Use a shift register with a direction bit:

```verilog
reg [3:0] r_led_pattern;
reg       r_direction;   // 0 = shift left, 1 = shift right

always @(posedge i_clk) begin
    if (i_reset) begin
        r_led_pattern <= 4'b0001;
        r_direction   <= 1'b0;
    end else if (w_tick) begin
        if (r_direction == 1'b0) begin
            // Shift left
            if (r_led_pattern == 4'b1000)
                r_direction <= 1'b1;        // hit the left wall, reverse
            else
                r_led_pattern <= r_led_pattern << 1;
        end else begin
            // Shift right
            if (r_led_pattern == 4'b0001)
                r_direction <= 1'b0;        // hit the right wall, reverse
            else
                r_led_pattern <= r_led_pattern >> 1;
        end
    end
end
```

**Alternative approach using a shift register with feedback:**
```verilog
// A rotating pattern: shift left, MSB wraps to LSB
always @(posedge i_clk) begin
    if (i_reset)
        r_led_pattern <= 4'b0001;
    else if (w_tick)
        r_led_pattern <= {r_led_pattern[2:0], r_led_pattern[3]};
end
```

This creates a circular rotation rather than a bounce. Both are useful patterns.

#### LFSR Preview (5 min)

An LFSR is a shift register where the serial input is an XOR of specific tap positions:

```verilog
// 8-bit LFSR (taps at positions 8, 6, 5, 4 for maximal length)
always @(posedge i_clk) begin
    if (i_reset)
        r_lfsr <= 8'h01;  // any nonzero seed
    else if (i_enable)
        r_lfsr <= {r_lfsr[6:0], r_lfsr[7] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3]};
end
```

- An N-bit LFSR with properly chosen taps cycles through 2^N − 1 unique states before repeating (all states except all-zeros)
- The sequence *appears* random but is completely deterministic
- Uses: pseudo-random test patterns, noise generation, CRC computation
- Much cheaper than a true random number generator — just a shift register and a few XOR gates

---

### Concept Check Questions

**Q1 (SLO 5.2):** You need to receive an 8-bit value one bit at a time from a serial line. Which shift register type do you need?

> **Expected answer:** SIPO (Serial In, Parallel Out). Bits arrive serially, and after 8 shifts you read out the complete 8-bit word in parallel.

**Q2 (SLO 5.3):** Why is a 1-FF synchronizer insufficient? Why not 3 or 4 FFs?

> **Expected answer:** 1-FF: the single flip-flop can go metastable and propagate the undefined value directly to downstream logic. 2-FF: the first FF may go metastable but has a full clock period to resolve before the second FF samples it — probability of both being metastable is ~squared, astronomically low. 3-FF or 4-FF: even lower probability, but 2-FF is already sufficient for most frequencies. Extra stages add latency for negligible benefit. Some safety-critical or very high-speed designs use 3-FF.

**Q3 (SLO 5.4):** Your debounce module uses a 250,000-count threshold at 25 MHz (10 ms). A new project runs at 100 MHz. What parameter value gives the same 10 ms debounce time?

> **Expected answer:** 100,000,000 × 0.010 = 1,000,000. Set `CLKS_TO_STABLE = 1_000_000`. This is exactly why the module is parameterized — the same RTL works at any clock frequency by changing the parameter.

**Q4 (SLO 5.1):** You need a counter that counts 0, 1, 2, ..., 59, 0, 1, ... (for a seconds counter in a clock). What type of counter is this? How many bits wide must it be?

> **Expected answer:** A modulo-60 counter. Width: `$clog2(60) = 6` bits (2^6 = 64 ≥ 60). The counter compares against 59 and wraps to 0.

**Q5 (SLO 5.6):** An 8-bit LFSR is initialized to `8'h01`. After many clock cycles, it returns to `8'h01`. How many unique states did it visit?

> **Expected answer:** 2^8 − 1 = 255 (assuming maximal-length taps). The all-zeros state is excluded because XOR feedback from all zeros produces zero — it would be a stuck state.

**Q6 (SLO 5.3):** A designer puts the debounce module *before* the synchronizer, arguing "clean up the bounce first, then synchronize." Why is this wrong?

> **Expected answer:** The debounce module contains sequential logic (counters, comparators) that runs in the clock domain. Feeding an unsynchronized asynchronous signal directly into this logic risks metastability on the debounce counter's flip-flops. The synchronizer must come first to make the signal safe for all downstream synchronous logic.

---

### Lab Exercises (2 hours)

#### Exercise 1: Debounce Module — Build and Simulate (30 min)

**Objective (SLO 5.3, 5.4):** Build the reusable debounce module and verify it handles noisy inputs correctly.

**Part A:** Create `debounce.v` using the design from the pre-class video. Include the 2-FF synchronizer inside the module.

**Part B:** Create `tb_debounce.v`:

```verilog
`timescale 1ns / 1ps

module tb_debounce;

    reg  clk;
    reg  bouncy;
    wire clean;

    // Use a small threshold for simulation (10ms would be too many cycles)
    debounce #(.CLKS_TO_STABLE(10)) uut (
        .i_clk(clk),
        .i_bouncy(bouncy),
        .o_clean(clean)
    );

    // 25 MHz clock
    initial clk = 0;
    always #20 clk = ~clk;  // 40ns period

    initial begin
        $dumpfile("debounce.vcd");
        $dumpvars(0, tb_debounce);

        bouncy = 1;  // not pressed (active-low)
        #500;

        // Simulate a bouncy press: toggle rapidly 5 times, then settle
        bouncy = 0; #60;   // press
        bouncy = 1; #40;   // bounce
        bouncy = 0; #80;   // press
        bouncy = 1; #30;   // bounce
        bouncy = 0; #50;   // press
        bouncy = 1; #20;   // bounce
        bouncy = 0;        // final press — stays low
        #2000;             // wait well beyond threshold

        // Simulate a bouncy release
        bouncy = 1; #40;
        bouncy = 0; #30;
        bouncy = 1; #60;
        bouncy = 0; #20;
        bouncy = 1;        // final release — stays high
        #2000;

        // Verify: clean signal should have transitioned exactly twice
        // (one press, one release)

        $finish;
    end

endmodule
```

**Student tasks:**
1. Simulate and open GTKWave
2. Count transitions on `clean` — should be exactly 2 (one falling, one rising)
3. Measure the delay from when `bouncy` stabilizes to when `clean` transitions
4. Change `CLKS_TO_STABLE` to 5 — does the bounce sneak through? Why or why not?

---

#### Exercise 2: Shift Register LED Chase (25 min)

**Objective (SLO 5.2, 5.5):** Build a visible shift-register-based pattern on the Go Board.

Create `led_chase.v`:

```verilog
module led_chase (
    input  wire i_clk,
    input  wire i_switch1,   // reset
    input  wire i_switch2,   // direction control
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // --- Clock divider for visible speed (~4 Hz) ---
    reg [22:0] r_clk_div;
    wire w_tick = (r_clk_div == 23'd3_124_999);

    always @(posedge i_clk) begin
        if (w_tick)
            r_clk_div <= 0;
        else
            r_clk_div <= r_clk_div + 1;
    end

    // --- Debounce the reset and direction switches ---
    wire w_reset, w_direction;

    debounce #(.CLKS_TO_STABLE(250_000)) db_reset (
        .i_clk(i_clk),
        .i_bouncy(i_switch1),
        .o_clean(w_reset)
    );

    debounce #(.CLKS_TO_STABLE(250_000)) db_dir (
        .i_clk(i_clk),
        .i_bouncy(i_switch2),
        .o_clean(w_direction)
    );

    // --- Shift register with bounce-back ---
    reg [3:0] r_pattern;
    reg       r_dir;  // 0 = left, 1 = right

    // ---- YOUR CODE HERE ----
    // Implement the bounce-back shift pattern:
    //   Reset: r_pattern = 4'b0001, r_dir = 0
    //   On tick:
    //     If w_direction override is active, use it to set direction
    //     If pattern hits the left wall (4'b1000), reverse to right
    //     If pattern hits the right wall (4'b0001), reverse to left
    //     Shift in the current direction

    // Active-low LED outputs
    assign o_led1 = ~r_pattern[3];
    assign o_led2 = ~r_pattern[2];
    assign o_led3 = ~r_pattern[1];
    assign o_led4 = ~r_pattern[0];

endmodule
```

**Student tasks:**
1. Implement the chase logic
2. Synthesize and program — verify the light sweeps back and forth
3. Verify that the debounced switch2 controls direction cleanly (no glitches)
4. Experiment with the tick rate — make it faster, slower

**Extension:** Make the pattern 2 bits wide (two adjacent LEDs lit) instead of 1.

---

#### Exercise 3: Debounced Button Counter (25 min)

**Objective (SLO 5.4, 5.5):** Prove the debounce module works by building a reliable single-press counter.

Create `button_counter.v`:

```verilog
module button_counter (
    input  wire i_clk,
    input  wire i_switch1,   // reset
    input  wire i_switch2,   // count button
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g,
    output wire o_led1       // heartbeat
);

    // --- Debounce both buttons ---
    wire w_reset_clean, w_count_clean;

    debounce #(.CLKS_TO_STABLE(250_000)) db_reset (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_reset_clean)
    );

    debounce #(.CLKS_TO_STABLE(250_000)) db_count (
        .i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(w_count_clean)
    );

    // --- Edge detector: detect the press edge (falling edge of active-low) ---
    reg r_count_prev;
    always @(posedge i_clk)
        r_count_prev <= w_count_clean;

    wire w_count_press = ~w_count_clean & r_count_prev;
    // Active-low: pressed=0, so falling edge of clean signal = press
    // ~clean & prev_clean = was 1 (not pressed), now 0 (pressed)

    // --- 4-bit counter ---
    wire w_reset = ~w_reset_clean;  // Active-low button → active-high reset
    reg [3:0] r_count;

    always @(posedge i_clk) begin
        if (w_reset)
            r_count <= 4'd0;
        else if (w_count_press)
            r_count <= r_count + 4'd1;
    end

    // --- 7-segment display ---
    wire [6:0] w_seg;

    hex_to_7seg decoder (
        .i_hex(r_count),
        .o_seg(w_seg)
    );

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f,
            o_segment1_g} = w_seg;

    // --- Heartbeat ---
    reg [23:0] r_hb_count;
    always @(posedge i_clk)
        r_hb_count <= r_hb_count + 1;
    assign o_led1 = ~r_hb_count[23];

endmodule
```

**The definitive test:** Press the button 16 times slowly, watching the display. It should count cleanly: 0, 1, 2, 3, ..., F, 0. If it ever skips a number, the debounce threshold may need adjustment.

**Then try without debounce:** Replace the debounce module with a direct synchronizer (just the 2-FF) and repeat. Students should see erratic counting — sometimes incrementing by 2, 3, or more per press. This is the motivating demonstration for why debounce matters.

**Student tasks:**
1. Verify clean counting with debounce
2. Verify erratic counting without debounce
3. Record: "With debounce, I pressed 16 times and the count went from 0 to F to 0 perfectly." / "Without debounce, I pressed 16 times and the count reached [some number > 16]."

---

#### Exercise 4: LFSR Pattern Generator (20 min)

**Objective (SLO 5.6):** Build and observe a pseudo-random sequence generator.

Create `lfsr_8bit.v`:

```verilog
module lfsr_8bit (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_enable,
    output reg  [7:0] o_lfsr,
    output wire       o_valid   // 0 when in all-zeros state (stuck)
);

    // Taps for maximal-length 8-bit LFSR: x^8 + x^6 + x^5 + x^4 + 1
    wire w_feedback = o_lfsr[7] ^ o_lfsr[5] ^ o_lfsr[4] ^ o_lfsr[3];

    always @(posedge i_clk) begin
        if (i_reset)
            o_lfsr <= 8'h01;  // nonzero seed
        else if (i_enable)
            o_lfsr <= {o_lfsr[6:0], w_feedback};
    end

    assign o_valid = |o_lfsr;  // 0 only if all bits are 0

endmodule
```

**Student tasks:**

1. Create a top module that:
   - Clocks the LFSR at a visible rate (~4 Hz) using a tick
   - Displays the lower 4 bits on 7-segment as hex
   - Displays the upper 4 bits on LEDs
   - Uses a button to pause/resume

2. Observe: the pattern looks random but repeats every 255 steps

3. **Simulation verification:** Write a testbench that:
   - Enables the LFSR for 256 clock cycles
   - Verifies that the LFSR returns to its initial state after exactly 255 cycles
   - Verifies that the all-zeros state is never reached

---

#### Exercise 5 (Stretch): Shift Register Alternative Debounce (20 min)

**Objective (SLO 5.2, 5.4):** Explore an alternative debounce architecture using a shift register.

The idea: shift the sampled input into an N-bit shift register at a slow sample rate. If all N bits are the same, the input is stable.

```verilog
module debounce_shift #(
    parameter SAMPLE_CLKS = 25_000,  // sample every 1ms at 25 MHz
    parameter N_SAMPLES   = 8        // require 8 consistent samples (8ms)
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    // Synchronizer
    reg r_sync_0, r_sync_1;
    always @(posedge i_clk) begin
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;
    end

    // Sample rate divider
    reg [$clog2(SAMPLE_CLKS)-1:0] r_sample_count;
    wire w_sample_tick = (r_sample_count == SAMPLE_CLKS - 1);

    always @(posedge i_clk) begin
        if (w_sample_tick)
            r_sample_count <= 0;
        else
            r_sample_count <= r_sample_count + 1;
    end

    // Shift register
    reg [N_SAMPLES-1:0] r_shift;

    always @(posedge i_clk) begin
        if (w_sample_tick)
            r_shift <= {r_shift[N_SAMPLES-2:0], r_sync_1};
    end

    // Output: stable if all samples agree
    always @(posedge i_clk) begin
        if (&r_shift)         // all 1s → stable high
            o_clean <= 1'b1;
        else if (~|r_shift)   // all 0s → stable low
            o_clean <= 1'b0;
        // else: hold previous value (disagreement → not yet stable)
    end

endmodule
```

**Comparison task:** How does this compare to the counter-based approach? Which uses more resources? Which is easier to tune? Which responds faster to a clean transition?

> *Counter approach: Responds as soon as the signal is stable for the threshold duration. Shift register approach: Must fill the entire register with consistent samples — response time is N × sample period regardless of input quality. Counter is more resource-efficient for long debounce times; shift register is conceptually simpler.*

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. Synchronize first, then debounce — always in that order
2. Metastability is real and dangerous — the 2-FF synchronizer is your standard protection
3. The debounce module is a reusable building block — parameterize it and keep it in your library
4. Shift registers are the foundation of serial communication (UART, SPI coming in Week 3)
5. Edge detection (`clean & ~clean_prev`) gives you one-cycle pulses from level signals
6. LFSRs are cheap pseudo-random generators — shift register + XOR feedback

#### Your Growing Module Library
After 5 days, you should have these reusable modules:
- `hex_to_7seg` — combinational hex display decoder
- `debounce` — synchronizer + counter-based debounce
- `lfsr_8bit` — pseudo-random number generator
- Various counters and shift registers

#### Preview: Day 6 — Testbenches Become Mandatory
Starting tomorrow, **every lab requires a testbench before hardware**. We'll formalize the testbench methodology: self-checking tests, structured stimulus, automated pass/fail reporting. You already wrote testbenches in exercises — now we make them rigorous.

**Homework:** Watch the Day 6 pre-class video (~50 min) on testbench anatomy and self-checking methodology.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Debounce Module | 5.3, 5.4 | Simulation shows clean output from noisy input; transition count correct |
| Ex 2: LED Chase | 5.2, 5.5 | Smooth bounce-back pattern on LEDs; direction control works |
| Ex 3: Button Counter | 5.4, 5.5 | Clean single-increment per press; erratic behavior demonstrated without debounce |
| Ex 4: LFSR | 5.6 | 255-cycle period verified in simulation; pseudo-random display on board |
| Ex 5: Shift Debounce | 5.2, 5.4 | Alternative architecture works; comparison analysis articulated |
| Concept check Qs | 5.1, 5.2, 5.3, 5.4, 5.6 | In-class discussion responses |

---

## Instructor Notes

- **The without-debounce demonstration** in Exercise 3 is critical. Students won't truly believe bounce is a problem until they see it. Have them count carefully and record their results — "I pressed 16 times, the counter reached 23" is a memorable data point.
- **Metastability is abstract** — students will nod along but not really feel the danger. Emphasize: "You cannot test for metastability. It's probabilistic. Your design will work 99.999% of the time and fail silently the other 0.001%. The synchronizer makes that failure rate unmeasurably small."
- **The debounce module** will be reused in almost every lab going forward. Insist on clean, parameterized code. Students who take shortcuts here will pay for it later.
- **LFSR tap selection** is a deep topic — don't go down the rabbit hole of polynomial theory. Just tell students: "These taps have been mathematically proven to give maximal length. Look up the table for other widths." A reference table of maximal-length LFSR taps is available at many sources online.
- **Timing:** Exercises 1–3 are the priority. Exercise 3 is the most important (the debounce proof). Exercise 4 is fun and educational but lower priority. Exercise 5 is genuine stretch.
- **If students finish early:** Challenge them to make the LED chase pattern 2 bits wide, or to add a speed control from a second button (press to cycle through 3 speeds).
