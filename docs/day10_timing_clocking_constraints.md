# Day 10: Timing, Clocking & Constraints

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 10 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 10.1:** Explain setup time, hold time, and the critical path, and relate these concepts to a design's maximum operating frequency (Fmax).
2. **SLO 10.2:** Add timing constraints to a design and read a nextpnr timing report to determine whether timing is met, identifying the critical path and its slack.
3. **SLO 10.3:** Configure the iCE40 PLL (`SB_PLL40_CORE`) to generate a derived clock frequency from the 25 MHz input oscillator.
4. **SLO 10.4:** Identify clock domain crossing (CDC) scenarios and implement a safe data transfer between two clock domains using a 2-FF synchronizer for single-bit signals.
5. **SLO 10.5:** Intentionally create and resolve a timing violation by restructuring combinational logic or adding pipeline registers.
6. **SLO 10.6:** Annotate a design's `.pcf` file with complete I/O constraints and interpret Yosys and nextpnr warnings related to timing and placement.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: The Physics of Timing (15 min)

#### Why Timing Matters

Until now, we've treated clock edges as instantaneous and signal propagation as immediate. In reality:
- Gates have propagation delays (typically 0.1–1 ns on modern FPGAs)
- Wires have delay based on length (routing delay)
- Flip-flops require data to be stable before (**setup time**) and after (**hold time**) the clock edge
- If these requirements are violated, the flip-flop may go metastable or capture the wrong value

**The fundamental timing constraint:** Between two clock edges, the combinational logic connecting two registers must complete before the next clock edge arrives.

```
            ┌────────┐    Combinational    ┌────────┐
   clk ────►│ FF A   │───────Logic────────►│ FF B   │◄──── clk
            │(source)│    (delay = Tcomb)   │(dest)  │
            └────────┘                      └────────┘

   Timing requirement:
     Tclk-to-q(A) + Tcomb + Trouting + Tsetup(B) < Tclk_period
```

Where:
- **Tclk-to-q:** Delay from clock edge to output appearing at FF A's output
- **Tcomb:** Propagation delay through combinational logic
- **Trouting:** Wire delay through FPGA routing
- **Tsetup:** Time data must be stable before FF B's clock edge
- **Tclk_period:** Clock period (40 ns at 25 MHz)

#### Setup Time and Hold Time

```
               Tsetup      Thold
              ◄──────►    ◄──────►
              │        │          │
   data: ─────────────STABLE───────────────
              │        │          │
   clk:  ────────────┐ │
                      └───────────────
                      ↑
                  clock edge
```

**Setup time violation:** Data changes too close before the clock edge. The flip-flop may capture the old or new value unpredictably. Fix: reduce combinational delay or slow the clock.

**Hold time violation:** Data changes too soon after the clock edge. Rare in FPGAs because routing delays naturally provide hold margin. The place-and-route tool handles this.

#### Critical Path

The **critical path** is the longest combinational delay between any two registers (or from input to register, or register to output). It determines your design's maximum frequency:

```
Fmax = 1 / (Tclk-to-q + Tcritical_path + Tsetup)
```

If your design's critical path gives Fmax = 30 MHz and you're running at 25 MHz, timing is met (you have **positive slack** of 1/25MHz − 1/30MHz in time). If Fmax = 20 MHz and you're running at 25 MHz, timing fails (negative slack — the design won't work reliably).

#### Slack

**Slack = (Required time) − (Arrival time)**

- **Positive slack:** Data arrives before the deadline. Design works.
- **Zero slack:** Data arrives exactly at the deadline. Marginal — temperature or voltage changes could cause failure.
- **Negative slack:** Data arrives after the deadline. **Design is broken.** Must fix.

---

### Video Segment 2: Timing Constraints and nextpnr Reports (12 min)

#### Adding Timing Constraints

nextpnr needs to know your clock frequency to perform timing analysis. Without constraints, it assumes no timing requirements and may produce a slow design.

For the iCE40 flow, constraints are passed via command-line options or a `.pcf` file extension:

```bash
# Tell nextpnr the clock is 25 MHz (40 ns period)
nextpnr-ice40 --hx1k --package vq100 \
    --pcf go_board.pcf \
    --json top.json \
    --asc top.asc \
    --freq 25
```

The `--freq 25` flag tells nextpnr to target 25 MHz for all clocks. nextpnr will try to meet this constraint during placement and routing.

#### Reading the Timing Report

nextpnr prints timing information at the end of its run:

```
Info: Max frequency for clock 'i_clk': 31.25 MHz (PASS at 25.00 MHz)

Info: Critical path report for clock 'i_clk':
Info: curr total
Info:  0.8  0.8  Source r_counter_SB_CARRY_CO$COUT
Info:  0.5  1.3  Net r_counter_23__SB_CARRY_CO_CI[0] budget 2.2 ns slack 0.9 ns
Info:  0.8  2.1  Dest r_counter_SB_CARRY_I3[1]
...
Info:  0.0 32.0  Arrival at destination
Info: 40.0 ns required (at 25.00 MHz)
Info: 32.0 ns arrival
Info:  8.0 ns slack (PASS)
```

**How to read this:**
- **Max frequency: 31.25 MHz** — the fastest this design can run
- **PASS at 25.00 MHz** — your constraint (25 MHz) is met
- **Slack: 8.0 ns** — 8 ns of margin. Comfortable.
- **Critical path:** The carry chain through a counter — the longest combinational path

#### What If Timing Fails?

```
Info: Max frequency for clock 'i_clk': 18.75 MHz (FAIL at 25.00 MHz)
Info: -6.7 ns slack (FAIL)
```

Options:
1. **Reduce clock frequency** — if your design doesn't need 25 MHz
2. **Pipeline the critical path** — break long combinational chains with registers
3. **Restructure logic** — simplify the expressions, reduce mux depth
4. **Use the PLL** — generate a slower derived clock for the logic that can't meet timing

---

### Video Segment 3: The iCE40 PLL (12 min)

#### What Is a PLL?

A Phase-Locked Loop (PLL) is a dedicated hardware block that generates new clock frequencies from an input reference clock. On the iCE40, it's called `SB_PLL40_CORE`.

Capabilities:
- Multiply the input frequency (up)
- Divide the input frequency (down)
- Phase shift the output clock
- Generate multiple output frequencies (some iCE40 variants)

#### PLL Configuration

The iCE40 PLL uses feedback divider (`DIVF`), reference divider (`DIVR`), and output divider (`DIVQ`) parameters:

```
Fout = Fin × (DIVF + 1) / ((DIVR + 1) × 2^DIVQ)
```

For common frequencies from 25 MHz:

| Target Fout | DIVR | DIVF | DIVQ | Actual Fout |
|---|---|---|---|---|
| 50 MHz | 0 | 1 | 0 (÷1) | Doesn't work directly — need different params |
| 12.5 MHz | 0 | 0 | 1 (÷2) | 12.5 MHz |
| 100 MHz | 0 | 3 | 0 | 100 MHz |
| 48 MHz | 0 | 63 | 5 | ~48.828 MHz |

Use the `icepll` tool to calculate parameters:
```bash
icepll -i 25 -o 50
# Output:
# F_PLLIN:    25.000 MHz (given)
# F_PLLOUT:   50.000 MHz (requested)
# F_PLLOUT:   50.000 MHz (achieved)
# FEEDBACK: SIMPLE
# F_PFD:   25.000 MHz
# F_VCO:  800.000 MHz
# DIVR:  0 (4'b0000)
# DIVF: 31 (7'b0011111)
# DIVQ:  4 (3'b100)
# FILTER_RANGE: 2 (3'b010)
```

#### PLL Instantiation

```verilog
module top_pll (
    input  wire i_clk,       // 25 MHz from crystal
    output wire o_led1
);

    wire w_pll_clk;          // PLL output clock
    wire w_pll_locked;       // PLL lock indicator

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),         // DIVR = 0
        .DIVF(7'b0011111),      // DIVF = 31
        .DIVQ(3'b100),          // DIVQ = 4
        .FILTER_RANGE(3'b010)   // from icepll
    ) pll_inst (
        .REFERENCECLK(i_clk),   // 25 MHz input
        .PLLOUTCORE(w_pll_clk), // PLL output (to fabric)
        .LOCK(w_pll_locked),    // high when PLL is locked
        .RESETB(1'b1),          // active-low reset (1 = not reset)
        .BYPASS(1'b0)           // 0 = use PLL, 1 = bypass
    );

    // Use the PLL clock for your design
    reg [25:0] r_counter;

    always @(posedge w_pll_clk) begin
        if (!w_pll_locked)
            r_counter <= 0;
        else
            r_counter <= r_counter + 1;
    end

    assign o_led1 = ~r_counter[25];  // blink at different rate

endmodule
```

**Key points:**
- `LOCK` signal: wait for this to go high before using the PLL clock. The PLL needs time to stabilize after power-up.
- `PLLOUTCORE` vs `PLLOUTGLOBAL`: `CORE` routes through general fabric; `GLOBAL` routes to a dedicated global clock network (lower skew, preferred).
- The PLL is a **hard macro** — it's not synthesized from LUTs. It's a dedicated silicon block.

---

### Video Segment 4: Clock Domain Crossing (11 min)

#### The Problem

When two parts of a design run on different clocks, passing data between them is dangerous. The receiving clock can sample the data at any time relative to the sending clock — violating setup/hold times.

**Single-bit CDC: 2-FF synchronizer** (reviewed from Day 5, now in a clock-crossing context):

```verilog
module cdc_single_bit (
    input  wire i_clk_dst,     // destination clock domain
    input  wire i_signal_src,  // signal from source clock domain
    output wire o_signal_dst   // synchronized to destination domain
);

    reg r_meta, r_sync;

    always @(posedge i_clk_dst) begin
        r_meta <= i_signal_src;
        r_sync <= r_meta;
    end

    assign o_signal_dst = r_sync;

endmodule
```

This is the **same synchronizer from Day 5**, but now applied specifically to clock domain crossing rather than just asynchronous external inputs.

#### Multi-Bit CDC: The Gray Code Approach

Passing a multi-bit bus across clock domains is trickier — different bits may arrive at different times, causing the receiver to see corrupted intermediate values.

**Safe approach for counters/pointers:** Convert to Gray code before crossing (only one bit changes per increment):

```verilog
// Binary to Gray conversion
assign gray = binary ^ (binary >> 1);

// Gray to Binary conversion
assign binary[N-1] = gray[N-1];
generate
    for (g = N-2; g >= 0; g = g - 1) begin : gray2bin
        assign binary[g] = binary[g+1] ^ gray[g];
    end
endgenerate
```

**For arbitrary multi-bit data:** Use an asynchronous FIFO (dual-clock FIFO) with Gray-coded read/write pointers. This is a standard design pattern we won't fully implement in this course, but it's important to know it exists.

#### When To Worry About CDC

- Signal from PLL clock domain to raw 25 MHz domain (or vice versa)
- External asynchronous inputs (buttons — already handled)
- Data from another chip that uses a different clock
- Any time you use more than one clock in your design

**Rule of thumb:** If you have one clock, you have zero CDC problems. Every additional clock multiplies verification complexity. Avoid unnecessary clock domains.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick question:** Your design has a critical path of 35 ns. You're running at 25 MHz (40 ns period). What's the slack? Is timing met? What's the Fmax?

> *Answer: Slack = 40 ns − 35 ns = 5 ns (positive). Timing is met. Fmax ≈ 1/35 ns ≈ 28.6 MHz. You have some margin, but not a lot — a temperature increase or voltage drop could eat into it.*

---

### Mini-Lecture: Reading Timing Reports and Using PLLs (35 min)

#### Live Timing Analysis Walk-Through (15 min)

**Step 1:** Take an existing design (the Day 8 lab instrument or the counter + 7-seg) and synthesize with timing constraints:

```bash
yosys -p "synth_ice40 -top top_lab_instrument -json top.json" *.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
    --json top.json --asc top.asc --freq 25 2>&1 | tee timing.log
```

**Step 2:** Open `timing.log` and walk through:
- Find "Max frequency for clock" — is it above 25 MHz?
- Find the critical path report — what module/signal is it?
- Find the slack value — how much margin?
- Look for warnings — unrecognized clocks, unconstrained paths

**Step 3:** Show `yosys stat` — resource usage. How many LUTs, FFs, EBRs?

#### Intentional Timing Violation Demo (10 min)

Create a deliberately slow combinational chain:

```verilog
// Intentionally bad: long combinational chain
module slow_adder (
    input  wire        i_clk,
    input  wire [31:0] i_a, i_b, i_c, i_d,
    output reg  [31:0] o_result
);

    // All four additions in one combinational path
    wire [31:0] w_sum1 = i_a + i_b;
    wire [31:0] w_sum2 = w_sum1 + i_c;
    wire [31:0] w_sum3 = w_sum2 + i_d;

    always @(posedge i_clk)
        o_result <= w_sum3;

endmodule
```

Synthesize with `--freq 25`. If timing fails (it may on 32-bit chained adds), show the negative slack.

**Fix by pipelining:**

```verilog
module pipelined_adder (
    input  wire        i_clk,
    input  wire [31:0] i_a, i_b, i_c, i_d,
    output reg  [31:0] o_result
);

    reg [31:0] r_sum1, r_sum2;

    // Pipeline stage 1
    always @(posedge i_clk) begin
        r_sum1 <= i_a + i_b;
        r_sum2 <= i_c + i_d;
    end

    // Pipeline stage 2
    always @(posedge i_clk)
        o_result <= r_sum1 + r_sum2;

endmodule
```

Re-synthesize. Show that:
- Fmax increased (shorter critical path)
- The design uses more flip-flops (pipeline registers)
- The output is now 2 cycles delayed instead of 1 (latency vs. throughput trade-off)

#### PLL Live Demo (10 min)

**Step 1:** Use `icepll` to calculate parameters:
```bash
icepll -i 25 -o 50
```

**Step 2:** Instantiate `SB_PLL40_CORE` in a simple blinker design. The LED should blink at a different rate than the 25 MHz version.

**Step 3:** Synthesize and program. Verify the blink rate changed.

**Step 4:** Add the `LOCK` signal — drive an LED with it. Show that it goes high shortly after programming (PLL lock-up time).

---

### Concept Check Questions

**Q1 (SLO 10.1):** Your design has Fmax = 50 MHz. Can you run it at (a) 25 MHz? (b) 50 MHz? (c) 55 MHz?

> **Expected answer:** (a) Yes — 25 ns slack per cycle, very comfortable. (b) Theoretically yes — zero slack, but risky due to process/voltage/temperature variations. (c) No — negative slack, timing violation, unreliable operation.

**Q2 (SLO 10.2):** nextpnr reports "Max frequency: 22.5 MHz (FAIL at 25 MHz)". What are your three options?

> **Expected answer:** (1) Pipeline the critical path — add a register stage to break the long combinational chain. (2) Simplify the logic — reduce the number of levels in the critical path. (3) Reduce the clock frequency — use a PLL to generate a slower clock, or reduce the `--freq` constraint if 22.5 MHz is sufficient.

**Q3 (SLO 10.3):** You want to generate a 100 MHz clock from 25 MHz using the PLL. What's the multiplication factor? Would you use this to clock your whole design?

> **Expected answer:** Multiplication factor = 4× (25 MHz × 4 = 100 MHz). Whether to use it depends on whether your design meets timing at 100 MHz. You'd need to check Fmax after synthesis. If Fmax < 100 MHz, the design won't work at that speed. Only use the faster clock for parts of the design that need it.

**Q4 (SLO 10.4):** You pass a 4-bit counter value from a 50 MHz domain to a 25 MHz domain using a 2-FF synchronizer on each bit independently. Why might this fail?

> **Expected answer:** The 4 bits may arrive at the destination domain at slightly different times. If the counter transitions from `0111` to `1000`, some bits might be sampled at the old value and others at the new value, producing a corrupted value like `1111` or `0000`. Single-bit synchronizers only work for single-bit signals. Multi-bit transfers need Gray coding or a FIFO.

**Q5 (SLO 10.5):** Pipelining adds latency. In what applications is this acceptable, and when is it not?

> **Expected answer:** Acceptable: throughput-oriented designs (data streaming, signal processing, image pipelines) where data flows continuously and latency of a few cycles doesn't matter. Not acceptable: low-latency feedback loops (real-time control systems, cache hit detection) where the result is needed within the same cycle or the next cycle. In UART and SPI at 115200 baud, multi-cycle latency at 25 MHz is completely irrelevant — the bit period is ~217 clock cycles.

---

### Lab Exercises (2 hours)

#### Exercise 1: Timing Analysis Practice (25 min)

**Objective (SLO 10.1, 10.2, 10.6):** Read and interpret real timing reports.

**Part A:** Take your Day 8 lab instrument design (or the traffic light FSM). Synthesize with `--freq 25`:

```bash
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
    --json top.json --asc top.asc --freq 25 2>&1 | tee timing_report.txt
```

**Student tasks:**
1. What is the reported Fmax?
2. What is the slack?
3. What signal/module is on the critical path?
4. How many LUTs, FFs, and EBR blocks are used?
5. Are there any timing warnings?

**Part B:** Try `--freq 100`. Does timing still pass? What changed in the report?

**Part C:** Try `--freq 200`. This should fail. Record the negative slack.

**Fill in the table:**

| Constraint | Fmax | Slack | Pass/Fail |
|---|---|---|---|
| 25 MHz | | | |
| 100 MHz | | | |
| 200 MHz | | | |

---

#### Exercise 2: PLL Clock Generation (25 min)

**Objective (SLO 10.3):** Configure and use the iCE40 PLL.

**Part A:** Use `icepll` to find parameters for 50 MHz output from 25 MHz input.

**Part B:** Create `top_pll_demo.v`:

```verilog
module top_pll_demo (
    input  wire i_clk,       // 25 MHz
    output wire o_led1,      // blinks from 25 MHz domain
    output wire o_led2,      // blinks from PLL domain
    output wire o_led3,      // PLL lock indicator
    output wire o_led4       // heartbeat (25 MHz domain)
);

    // --- PLL ---
    wire w_pll_clk, w_pll_locked;

    SB_PLL40_CORE #(
        // ---- YOUR PARAMETERS from icepll ----
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0000000),    // FILL IN
        .DIVQ(3'b000),        // FILL IN
        .FILTER_RANGE(3'b000) // FILL IN
    ) pll (
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // --- 25 MHz domain blinker ---
    reg [23:0] r_count_25;
    always @(posedge i_clk)
        r_count_25 <= r_count_25 + 1;
    assign o_led1 = ~r_count_25[23];   // ~1.5 Hz

    // --- PLL domain blinker ---
    reg [24:0] r_count_pll;
    always @(posedge w_pll_clk) begin
        if (!w_pll_locked)
            r_count_pll <= 0;
        else
            r_count_pll <= r_count_pll + 1;
    end
    assign o_led2 = ~r_count_pll[24];  // should be ~1.5 Hz if PLL is 50 MHz

    // --- Lock indicator ---
    assign o_led3 = ~w_pll_locked;     // LED on when locked

    // --- Heartbeat ---
    assign o_led4 = ~r_count_25[22];

endmodule
```

**Student tasks:**
1. Fill in the PLL parameters from `icepll` output
2. Synthesize and program
3. Verify: LED1 and LED2 should blink at similar rates (both targeting ~1.5 Hz). LED3 should light up shortly after programming.
4. Try a different PLL frequency (e.g., 100 MHz) — adjust the counter width to maintain ~1.5 Hz blink rate

---

#### Exercise 3: Clock Domain Crossing (25 min)

**Objective (SLO 10.4):** Pass a signal safely between clock domains.

**Scenario:** A button (debounced in the 25 MHz domain) needs to trigger a counter in the PLL 50 MHz domain.

Create `top_cdc_demo.v`:

```verilog
module top_cdc_demo (
    input  wire i_clk,       // 25 MHz
    input  wire i_switch1,   // button
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_led1, o_led2, o_led3, o_led4
);

    // --- PLL: 50 MHz ---
    wire w_pll_clk, w_pll_locked;
    // ---- PLL instantiation (from Exercise 2) ----

    // --- 25 MHz domain: debounce the button ---
    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk),
        .i_bouncy(i_switch1),
        .o_clean(w_btn_clean)
    );

    wire w_btn_active = ~w_btn_clean;  // active-high

    // --- CDC: 25 MHz → 50 MHz ---
    // ---- YOUR CODE HERE ----
    // 2-FF synchronizer for w_btn_active into PLL domain

    // --- 50 MHz domain: edge detect and count ---
    // ---- YOUR CODE HERE ----
    // Edge detector on the synchronized button signal
    // 4-bit counter incremented on button press edge
    // Use w_pll_locked as reset

    // --- Display: cross count back to 25 MHz domain ---
    // For a 4-bit counter, even without a synchronizer,
    // the risk is low. But for correctness:
    // ---- YOUR CODE HERE ----
    // Synchronize the 4-bit count back to 25 MHz domain
    // (Accept the risk of multi-bit CDC for this exercise,
    //  or use a Gray code approach)

    // --- hex_to_7seg decoder (25 MHz domain) ---
    // ---- YOUR CODE HERE ----

endmodule
```

**Student tasks:**
1. Implement the 2-FF synchronizer for the button signal crossing into the PLL domain
2. Build the counter in the PLL domain
3. Display the count on the 7-segment (in the 25 MHz domain)
4. Discuss: what could go wrong with the 4-bit count crossing back? (This motivates Gray coding and FIFOs)

---

#### Exercise 4: Pipeline Timing Fix (20 min)

**Objective (SLO 10.5):** Resolve a timing violation through pipelining.

Create a design with an intentionally long combinational path:

```verilog
module long_chain (
    input  wire        i_clk,
    input  wire [7:0]  i_data,
    output reg  [7:0]  o_result
);

    // 4 chained multiply-adds (intentionally deep)
    wire [15:0] w_stage1 = i_data * 8'd3;
    wire [15:0] w_stage2 = w_stage1[7:0] * 8'd5;
    wire [15:0] w_stage3 = w_stage2[7:0] * 8'd7;
    wire [15:0] w_stage4 = w_stage3[7:0] + w_stage2[7:0] + w_stage1[7:0];

    always @(posedge i_clk)
        o_result <= w_stage4[7:0];

endmodule
```

**Student tasks:**
1. Synthesize and check timing at `--freq 25`. What's the Fmax?
2. If timing fails (or is marginal), add pipeline registers between stages
3. Re-synthesize — show the improved Fmax
4. Record: unpipelined Fmax vs. pipelined Fmax. How many extra FFs were used? What's the new latency?

---

#### Exercise 5 (Stretch): PLL Frequency Sweep (15 min)

**Objective (SLO 10.3):** Use the PLL and a configurable counter to generate different LED blink rates dynamically.

Use the PLL at a high frequency (e.g., 100 MHz). Use a parameterized counter with a button-selectable divisor to cycle through different blink rates: 1 Hz, 2 Hz, 5 Hz, 10 Hz.

The divisor values are stored in a small ROM:
```
// blink_rates.hex — half-period counts at 100 MHz
02FAF080   // 1 Hz:  50,000,000
017D7840   // 2 Hz:  25,000,000
00989680   // 5 Hz:  10,000,000
004C4B40   // 10 Hz:  5,000,000
```

Each button press cycles to the next rate. Display the current rate selection on the 7-seg.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **Timing is not free** — combinational logic has delay, and it must complete within one clock period
2. **Always constrain your design** (`--freq` flag) and **read the timing report**
3. **The PLL is a versatile tool** — multiply, divide, or shift the clock phase
4. **Clock domain crossing is dangerous** — use 2-FF synchronizers for single bits, Gray coding for counters, FIFOs for data buses
5. **Pipelining trades latency for throughput** — add registers to break long combinational chains
6. **One clock domain is ideal** — every additional clock multiplies your verification burden

#### Preview: Day 11 — UART Transmitter
Tomorrow is the payoff. You'll build a UART TX module — an FSM + shift register + baud generator — and send characters from the Go Board to your PC. Everything we've built (FSMs, shift registers, counters, parameterization, testbenches) converges into one design.

**Homework:** Watch the Day 11 pre-class video (~50 min) on the UART protocol and TX architecture. Understand the bit timing: 1 start bit, 8 data bits, 1 stop bit, at 115200 baud.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Timing Analysis | 10.1, 10.2, 10.6 | Table filled with Fmax, slack, pass/fail at 3 frequencies |
| Ex 2: PLL Demo | 10.3 | PLL output verified by blink rate; lock indicator works |
| Ex 3: CDC Demo | 10.4 | Button counter works across clock domains; CDC risks discussed |
| Ex 4: Pipeline Fix | 10.5 | Before/after Fmax comparison; pipeline registers identified |
| Ex 5: Freq Sweep | 10.3 | Dynamic rate selection works from PLL-derived clock |
| Concept check Qs | 10.1, 10.2, 10.3, 10.4, 10.5 | In-class discussion responses |

---

## Instructor Notes

- **Timing reports can be intimidating.** Walk through one line by line, slowly. Students need to know where to find Fmax, the critical path, and slack. Everything else they can learn to read over time.
- **The PLL may not simulate in Icarus Verilog.** The `SB_PLL40_CORE` primitive is a Lattice-specific macro. For simulation, use a `ifdef SIMULATION` block that substitutes a simple `assign w_pll_clk = i_clk;` or a clock multiplier model.
- **Clock domain crossing** is the deepest topic today. For this course, the 2-FF synchronizer for single bits is the essential takeaway. Multi-bit CDC and FIFOs are "awareness-level" — students should know the problems exist and the solutions exist, without necessarily implementing them from scratch.
- **The pipelining exercise** may need a wide enough datapath or deep enough logic to actually fail timing at 25 MHz on the iCE40. If the simple adder chain passes timing, increase the chain depth or use multiplication (which creates deep combinational logic on the iCE40 since there are no hardware multipliers).
- **Timing:** Exercises 1 and 2 are priority. Exercise 3 is important conceptually. Exercise 4 is a valuable hands-on experience. Exercise 5 is stretch.
- **Connection to UART:** Explicitly preview that UART baud rate generation uses the same counter-based timing we studied today, and that the UART TX timing constraint is trivially met (bit period of ~217 clocks at 25 MHz/115200 baud = tons of slack).
