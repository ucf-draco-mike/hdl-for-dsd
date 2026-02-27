# Day 1: Welcome to Hardware Thinking

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 1 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 1.1:** Contrast hardware description (concurrent execution) with software programming (sequential execution) and identify at least three fundamental differences.
2. **SLO 1.2:** Distinguish between synthesis and simulation, explaining the purpose and output of each in the FPGA design flow.
3. **SLO 1.3:** Write a syntactically correct Verilog module declaration with named input/output ports, including `module`, port list, and `endmodule`.
4. **SLO 1.4:** Trace the complete iCE40 open-source toolchain from Verilog source to programmed FPGA (Yosys → nextpnr → icepack → iceprog) and state the function of each tool.
5. **SLO 1.5:** Create and use a pin constraint file (`.pcf`) to map HDL signal names to physical FPGA pins on the Go Board.
6. **SLO 1.6:** Implement, synthesize, and program a simple combinational design that maps button inputs to LED outputs on the Go Board using continuous assignment (`assign`).

---

## Pre-Class Material (Flipped Video, ~40 min)

*Students watch this recorded lecture before attending class.*

### Video Segment 1: HDL ≠ Software (12 min)

#### The Central Misconception

If you know C, Python, or Java, your instinct will be to read Verilog top-to-bottom and imagine it executing line by line. **This instinct is wrong**, and unlearning it is the single most important thing you'll do in the first week.

In software:
```c
a = b + c;
d = a * 2;
```
Line 1 executes, completes, and *then* line 2 executes. There is a clear temporal ordering. The processor has one ALU and it does one thing at a time (ignoring pipelining/superscalar for now).

In Verilog:
```verilog
assign a = b + c;
assign d = a * 2;
```
These two statements describe **hardware that exists simultaneously**. There is an adder, and there is a multiplier (or shift), and they are **both always active**. When `b` or `c` change, `a` changes, and `d` changes — all propagating through physical gates with real propagation delays.

#### Three Fundamental Differences

| Concept | Software | Hardware (Verilog) |
|---|---|---|
| **Execution model** | Sequential — one instruction at a time | Concurrent — all hardware operates simultaneously |
| **Assignment meaning** | "Compute this value and store it in this variable" | "Create a permanent physical connection (wire) or describe register behavior" |
| **Time** | Implicit — program counter advances | Explicit — signals propagate with physical delay; clock edges define synchronous behavior |

#### The River Analogy

Software is like following a recipe: do step 1, then step 2, then step 3.

Hardware is like a river system: water flows through *all* tributaries simultaneously. Adding a dam (gate) here affects the flow there. Everything is happening at once. You are not writing instructions — you are **describing the geography of the river**.

#### Additional Differences Worth Noting

- **Resource mapping:** In software, `x = a + b` and `y = c + d` may reuse the same CPU adder at different times. In hardware, each `assign` typically implies its own physical adder. More code = more hardware = more resources consumed.
- **No dynamic allocation:** You cannot `malloc` a flip-flop. All hardware resources are fixed at synthesis time. Your design's resource usage is determined at compile time and does not change at runtime.
- **Parallelism is free:** In software, parallelism requires threads, synchronization, and careful design. In hardware, parallelism is the default — you have to work *harder* to make things sequential.

---

### Video Segment 2: Synthesis vs. Simulation (10 min)

#### Two Completely Different Tools, Two Different Purposes

When you write Verilog, the same source file will be consumed by two very different tools:

**Synthesis** (Yosys in our flow):
- Reads your Verilog and converts it into a netlist of actual FPGA primitives (LUTs, flip-flops, I/O buffers, block RAM)
- Ignores anything that can't be built in hardware (`$display`, `#10` delays, `initial` blocks with stimulus)
- Produces something that will become **real, physical circuitry**
- Analogy: synthesis is the architect turning blueprints into a buildable structure

**Simulation** (Icarus Verilog in our flow):
- Reads your Verilog (including testbenches) and *models* the behavior computationally
- Respects time delays (`#10`), display statements, and all behavioral constructs
- Produces waveforms and text output — a **prediction** of how the hardware will behave
- Analogy: simulation is the wind tunnel test before you build the airplane

#### What Synthesis Ignores

This is critical to understand early. The following Verilog constructs are **simulation-only** and are ignored (or cause errors) during synthesis:

- `initial` blocks (with some exceptions for memory initialization)
- `#` delay values (`#10`, `#5ns`)
- `$display`, `$monitor`, `$finish`, `$dumpfile`, `$dumpvars`
- Division and modulo by non-power-of-2 (usually)
- Real number types

This means your testbenches (full of `initial`, `#`, and `$display`) are purely simulation artifacts. Your synthesizable design modules must avoid these constructs.

#### The Golden Rule

> **Simulate first. Synthesize second. Program last.**

Debugging on hardware is orders of magnitude harder than debugging in simulation. You cannot set breakpoints on an FPGA. You cannot print from inside the chip (until we build UART in Week 3). Waveform-based simulation is your primary debugging tool.

---

### Video Segment 3: Anatomy of a Verilog Module (12 min)

#### The Module: Verilog's Fundamental Building Block

Every Verilog design is composed of **modules**. A module is a self-contained hardware block with defined inputs and outputs. Think of it as a chip on a circuit board with labeled pins.

```verilog
module led_driver (
    input  wire i_switch,
    output wire o_led
);

    assign o_led = i_switch;

endmodule
```

Let's dissect every piece:

**`module led_driver`** — Keyword `module` followed by the module's name. Names should be descriptive and use `snake_case` by convention.

**`( ... );`** — The port list, enclosed in parentheses and terminated with a semicolon.

**`input wire i_switch`** — An input port. `wire` is the default net type for inputs (and can technically be omitted, but we will always write it explicitly for clarity). The `i_` prefix is a naming convention indicating this is an input. You'll see other conventions in the wild; what matters is consistency within a project.

**`output wire o_led`** — An output port. Again, `wire` type, with `o_` prefix.

**`assign o_led = i_switch;`** — A continuous assignment. This creates a permanent, always-active connection from `i_switch` to `o_led`. It is **not** an assignment that happens once — it is a wire.

**`endmodule`** — Closes the module definition. No semicolon after `endmodule`.

#### Port Declaration Style

We will use the **ANSI-style** port declaration (ports declared within the parentheses). You may encounter the older non-ANSI style in legacy code:

```verilog
// Non-ANSI style (older, avoid in new code)
module led_driver (i_switch, o_led);
    input  wire i_switch;
    output wire o_led;
    // ...
endmodule
```

Both are valid. We use ANSI style exclusively — it's cleaner and less error-prone.

#### Naming Conventions Used in This Course

| Prefix | Meaning | Example |
|---|---|---|
| `i_` | Input port | `i_clk`, `i_reset`, `i_data` |
| `o_` | Output port | `o_led`, `o_tx`, `o_valid` |
| `r_` | Register (sequential) | `r_count`, `r_state` |
| `w_` | Wire (combinational) | `w_sum`, `w_carry` |

These prefixes are not required by the language but dramatically improve readability and reduce bugs. You can always tell at a glance whether a signal is an input, output, register, or wire.

---

### Video Segment 4: The Digital Logic Refresher You Need (8 min)

*This is a targeted refresher, not a re-teach. If any of this feels unfamiliar, review your digital logic notes before class.*

#### What You Must Have Cold

- **Logic gates:** AND, OR, NOT, NAND, NOR, XOR, XNOR — truth tables and symbols
- **Boolean algebra:** DeMorgan's theorems, distribution, complement
- **Combinational vs. sequential:**
  - Combinational: output depends only on current inputs (gates, muxes, decoders)
  - Sequential: output depends on current inputs **and stored state** (flip-flops, counters)
- **Truth tables ↔ Boolean expressions:** You should be able to go in both directions
- **Flip-flops:** The D flip-flop captures input D on the clock edge. That's the essential sequential primitive.

#### Verilog Maps Directly to These Concepts

| Digital logic concept | Verilog construct |
|---|---|
| Wire connecting two points | `assign` |
| AND gate | `assign y = a & b;` |
| OR gate | `assign y = a \| b;` |
| NOT gate | `assign y = ~a;` |
| Multiplexer | `assign y = sel ? a : b;` |
| D flip-flop | `always @(posedge clk) q <= d;` |

You already know the hardware. This course teaches you the **language to describe it**.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Prompt to class:** "You watched the pre-class video. Give me one thing about Verilog that surprised you or seemed counterintuitive compared to programming languages you've used."

*Quick round-robin or open discussion — the goal is to surface the sequential-vs-concurrent confusion early so it can be reinforced throughout the day.*

---

### Mini-Lecture: Toolchain & First Program (30 min)

#### Course Roadmap (5 min)

- 4 weeks, 16 sessions — from zero HDL to UART, SPI, SystemVerilog, and a final project
- You'll have a working communication interface talking to your PC by Week 3
- Flipped model: videos are the "lecture," class is where you **build**
- Daily deliverables — you leave class with working hardware every day

#### The Open-Source iCE40 Flow (15 min)

Draw this pipeline on the board and walk through each step:

```
  Verilog Source (.v)
        │
        ▼
  ┌──────────┐
  │  Yosys   │  ← Synthesis: Verilog → netlist of iCE40 primitives
  └────┬─────┘    Command: yosys -p "synth_ice40 -top <name> -json out.json" file.v
       │
       ▼
  ┌──────────┐
  │ nextpnr  │  ← Place & Route: assign netlist elements to physical locations
  └────┬─────┘    Command: nextpnr-ice40 --hx1k --package vq100 --pcf board.pcf
       │                    --json out.json --asc out.asc
       ▼
  ┌──────────┐
  │ icepack  │  ← Bitstream generation: convert placement into binary config
  └────┬─────┘    Command: icepack out.asc out.bin
       │
       ▼
  ┌──────────┐
  │ iceprog  │  ← Programming: load bitstream onto FPGA via USB
  └──────────┘    Command: iceprog out.bin
```

**Live demo:** Open a terminal. Show each command, explain the output. Students will replicate this in 15 minutes.

#### The Pin Constraint File (10 min)

The FPGA doesn't know what "i_switch" means. The `.pcf` file tells the toolchain which physical pin on the chip each signal in your top-level module connects to.

```
# go_board.pcf — Pin assignments for the Nandland Go Board
# Reference: Go Board schematic and pinout documentation

# Clock
set_io i_clk 15

# LEDs (active low on Go Board — active low is important, note this!)
set_io o_led1 56
set_io o_led2 57
set_io o_led3 59
set_io o_led4 60

# Push Buttons (active low, directly from schematic)
set_io i_switch1 53
set_io i_switch2 51
set_io i_switch3 54
set_io i_switch4 52

# 7-Segment Display - Accent 1 (accent segment accent accent accent)
set_io o_segment1_a 3
set_io o_segment1_b 4
set_io o_segment1_c 93
set_io o_segment1_d 91
set_io o_segment1_e 90
set_io o_segment1_f 1
set_io o_segment1_g 2

# 7-Segment Display - Accent 2
set_io o_segment2_a 100
set_io o_segment2_b 99
set_io o_segment2_c 97
set_io o_segment2_d 95
set_io o_segment2_e 94
set_io o_segment2_f 8
set_io o_segment2_g 96

# VGA
set_io o_vga_hsync 26
set_io o_vga_vsync 27
set_io o_vga_red_0 36
set_io o_vga_red_1 37
set_io o_vga_red_2 40
set_io o_vga_grn_0 29
set_io o_vga_grn_1 30
set_io o_vga_grn_2 33
set_io o_vga_blu_0 28
set_io o_vga_blu_1 41
set_io o_vga_blu_2 42

# PMOD connector (directly from schematic for reference)
set_io io_pmod_1 65
set_io io_pmod_2 64
set_io io_pmod_3 63
set_io io_pmod_4 62
set_io io_pmod_7 78
set_io io_pmod_8 79
set_io io_pmod_9 80
set_io io_pmod_10 81

# UART (directly from schematic)
set_io i_uart_rx 73
set_io o_uart_tx 74
```

**Key points:**
- `set_io <signal_name> <pin_number>` — that's the whole syntax
- Signal names **must match** your top-level module port names exactly
- Pin numbers come from the board schematic — you don't guess these
- **Active low:** The Go Board's LEDs and buttons are active low. `0` = LED on, `1` = LED off. Switch pressed = `0`. This will trip you up if you forget. We'll handle it.

---

### Concept Check Questions

*Use these during the mini-lecture to verify comprehension. These map directly to the SLOs.*

**Q1 (SLO 1.1):** Consider these two Verilog statements:
```verilog
assign x = a & b;
assign y = c | d;
```
Are these executed sequentially (x computed before y) or concurrently? Why?

> **Expected answer:** Concurrently. Both `assign` statements describe hardware that exists simultaneously. The AND gate and OR gate are both always active.

**Q2 (SLO 1.2):** A student writes `#10` in their design module (not a testbench). What happens during synthesis? What happens during simulation?

> **Expected answer:** During simulation, the `#10` introduces a 10-time-unit delay. During synthesis, the `#10` is ignored — you cannot tell hardware to "wait." If it appears where it affects logic behavior, the synthesized design will not match the simulation. This is a simulation/synthesis mismatch and a common source of bugs.

**Q3 (SLO 1.3):** What is wrong with this module declaration?
```verilog
module my_module (
    input wire a,
    input wire b,
    output wire y
)
    assign y = a ^ b;
endmodule
```

> **Expected answer:** Missing semicolon after the port list closing parenthesis. Should be `);` not `)`.

**Q4 (SLO 1.4):** Put these tools in the correct order: iceprog, nextpnr, icepack, Yosys.

> **Expected answer:** Yosys → nextpnr → icepack → iceprog. Synthesis → Place & Route → Bitstream generation → Programming.

**Q5 (SLO 1.5):** A student's LED doesn't light up. Their Verilog looks correct in simulation. What should they check first?

> **Expected answer:** The `.pcf` file. Either the signal name doesn't match the top-level port name, or the pin number is wrong for that LED. Also check: are the LEDs active low? (On the Go Board, they are.)

**Q6 (SLO 1.6):** The Go Board's buttons are active low (pressed = 0). If you write `assign o_led1 = i_switch1;` and LEDs are also active low (0 = on), what happens when you press the button?

> **Expected answer:** Button pressed → `i_switch1 = 0` → `o_led1 = 0` → LED turns ON. Button released → `i_switch1 = 1` → `o_led1 = 1` → LED turns OFF. The active-low signals "cancel out" and the behavior is intuitive: press button, LED lights up. (But this is a coincidence of the board design — you need to understand *why* it works, not just that it does.)

---

### Lab Exercises (2 hours)

#### Lab Setup Verification (15 min)

Before starting, verify the toolchain is installed and functional.

**Checklist:**
```bash
# Verify each tool is installed
yosys --version
nextpnr-ice40 --version
icepack
iceprog
iverilog -V
gtkwave --version  # may need to open GUI

# Verify USB connection to Go Board
# (on Linux) — check for the FTDI device
lsusb | grep -i ftdi
# (on macOS) — check for the device
ls /dev/cu.usbserial*
```

If any tool is missing, troubleshoot now — don't proceed with a broken toolchain.

---

#### Exercise 1: LED On — The Simplest Possible Design (20 min)

**Objective (SLO 1.3, 1.4, 1.5, 1.6):** Write, synthesize, and program the absolute minimum Verilog design. Confirm the full flow works end-to-end.

**Step 1:** Create a new directory for your work:
```bash
mkdir -p ~/hdl_course/day01/ex1
cd ~/hdl_course/day01/ex1
```

**Step 2:** Create `led_on.v`:
```verilog
// Exercise 1: The simplest possible design
// Drive LED1 permanently on
module led_on (
    output wire o_led1
);

    // Go Board LEDs are active low: 0 = on, 1 = off
    assign o_led1 = 1'b0;

endmodule
```

**Step 3:** Create a minimal `go_board.pcf` (only the pin we need):
```
set_io o_led1 56
```

**Step 4:** Build and program:
```bash
yosys -p "synth_ice40 -top led_on -json led_on.json" led_on.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json led_on.json --asc led_on.asc
icepack led_on.asc led_on.bin
iceprog led_on.bin
```

**Verification:** LED1 on the Go Board should be lit.

**Reflection question:** What did Yosys actually synthesize here? Is there any logic, or is it just a pin tied to ground?

> *Answer: There is no logic. Yosys will optimize this to a direct connection from the output pin to GND (logic 0). You can verify by running Yosys interactively and using the `show` or `stat` command — 0 LUTs used.*

---

#### Exercise 2: Buttons to LEDs — Wires in Hardware (25 min)

**Objective (SLO 1.3, 1.5, 1.6):** Use `assign` to create combinational connections between inputs and outputs.

Create `buttons_to_leds.v`:
```verilog
// Exercise 2: Direct button-to-LED mapping
module buttons_to_leds (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Direct connection: each button controls its LED
    // Both are active low, so direct connection gives intuitive behavior
    assign o_led1 = i_switch1;
    assign o_led2 = i_switch2;
    assign o_led3 = i_switch3;
    assign o_led4 = i_switch4;

endmodule
```

Update `go_board.pcf` to include all 4 buttons and 4 LEDs.

**Synthesize, program, verify:** Press each button, confirm the corresponding LED responds.

**Quick check question:** Are there any LUTs used in this design? Why or why not?

> *Answer: No LUTs — just direct routing from input pin buffers to output pin buffers. The FPGA's routing fabric connects them with no logic in between.*

---

#### Exercise 3: Logic Between Buttons and LEDs (30 min)

**Objective (SLO 1.1, 1.6):** Demonstrate concurrent combinational logic with multiple independent `assign` statements.

Create `button_logic.v`:
```verilog
// Exercise 3: Combinational logic between buttons and LEDs
module button_logic (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // LED1: ON when BOTH switch1 AND switch2 are pressed
    // Remember: active low → pressed = 0
    // We want LED on (0) when both switches are 0
    // ~(~sw1 & ~sw2) = sw1 | sw2... let's think through this carefully.
    //
    // Truth table (what we want):
    //   sw1  sw2  | led1 (0=on)
    //    0    0   |  0    (both pressed → LED on)
    //    0    1   |  1    (only sw1 → LED off)
    //    1    0   |  1    (only sw2 → LED off)
    //    1    1   |  1    (neither → LED off)
    //
    // led1 = sw1 | sw2  (OR of active-low signals = AND of the pressed conditions)
    assign o_led1 = i_switch1 | i_switch2;

    // LED2: ON when EITHER switch3 OR switch4 is pressed
    // Want LED on (0) when at least one switch is 0
    // led2 = sw3 & sw4 (AND of active-low = OR of pressed)
    assign o_led2 = i_switch3 & i_switch4;

    // LED3: XOR of switch1 and switch2 — on when exactly one is pressed
    assign o_led3 = ~(i_switch1 ^ i_switch2);

    // LED4: NOT of switch1 — inverted behavior
    assign o_led4 = ~i_switch1;

endmodule
```

**Synthesize, program, and build a truth table.**

**Student task:** For each LED, predict the behavior for all 4 button combinations involving its input switches, then verify on hardware. Fill in a truth table on paper first.

| sw1 | sw2 | LED1 expected | LED1 actual |
|-----|-----|--------------|-------------|
| not pressed | not pressed | | |
| not pressed | pressed | | |
| pressed | not pressed | | |
| pressed | pressed | | |

**Discussion point (SLO 1.1):** All four `assign` statements are active simultaneously. If you press sw1, LED1, LED3, and LED4 all change *at the same time*. There is no sequential execution.

---

#### Exercise 4: Active-Low Thinking (20 min)

**Objective (SLO 1.5, 1.6):** Confront the active-low behavior directly and develop a clean design pattern for handling it.

**The problem:** Active-low signals are a constant source of bugs. Let's develop a clean pattern.

Create `active_low_clean.v`:
```verilog
// Exercise 4: Clean active-low handling
module active_low_clean (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // PATTERN: Invert inputs at entry, invert outputs at exit
    // All internal logic uses active-high (positive logic)
    wire w_btn1 = ~i_switch1;  // 1 = pressed
    wire w_btn2 = ~i_switch2;
    wire w_btn3 = ~i_switch3;
    wire w_btn4 = ~i_switch4;

    // Internal logic — all positive/active-high, easy to reason about
    wire w_led1_active = w_btn1 & w_btn2;    // both pressed
    wire w_led2_active = w_btn3 | w_btn4;    // either pressed
    wire w_led3_active = w_btn1 ^ w_btn2;    // exactly one pressed
    wire w_led4_active = w_btn1;             // sw1 pressed

    // Output inversion: active-high logic → active-low LED pins
    assign o_led1 = ~w_led1_active;
    assign o_led2 = ~w_led2_active;
    assign o_led3 = ~w_led3_active;
    assign o_led4 = ~w_led4_active;

endmodule
```

**Discussion:** Compare with Exercise 3. The behavior is identical, but this version is much easier to reason about. The active-low "messiness" is contained to the boundary. All internal logic reads naturally.

**Key takeaway:** Always invert active-low signals at module boundaries. Think in active-high internally.

**Does the inversion cost hardware?** Ask Yosys:
```bash
yosys -p "synth_ice40 -top active_low_clean; stat" active_low_clean.v
```
Compare LUT count with the Exercise 3 version. The synthesizer will likely optimize both to the same netlist.

---

#### Exercise 5 (Stretch): Makefile & Workflow (10 min, if time permits)

**Objective (SLO 1.4):** Automate the build flow for rapid iteration.

Create a `Makefile`:
```makefile
# Makefile for iCE40 Go Board projects
PROJECT = button_logic
TOP     = button_logic
PCF     = go_board.pcf

# Synthesis
$(PROJECT).json: $(wildcard *.v)
	yosys -p "synth_ice40 -top $(TOP) -json $@" $^

# Place and Route
$(PROJECT).asc: $(PROJECT).json $(PCF)
	nextpnr-ice40 --hx1k --package vq100 --pcf $(PCF) --json $< --asc $@

# Bitstream
$(PROJECT).bin: $(PROJECT).asc
	icepack $< $@

# Program
prog: $(PROJECT).bin
	iceprog $<

# Simulation
sim: tb_$(PROJECT).v $(PROJECT).v
	iverilog -o sim.vvp $^
	vvp sim.vvp
	gtkwave dump.vcd &

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd

.PHONY: prog sim clean
```

Now the iteration cycle becomes:
```bash
make prog    # build and program in one command
```

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. Verilog describes **concurrent hardware**, not sequential instructions
2. The toolchain: Yosys → nextpnr → icepack → iceprog
3. The `.pcf` maps signal names to physical pins
4. `assign` creates a permanent wire — always active, always driving
5. Active-low signals: invert at boundaries, think in active-high internally

#### Common Mistakes Seen Today
- Forgetting the semicolon after `);` in the port list
- Signal name in `.pcf` doesn't match the port name — silent failure, LED does nothing
- Confusing active-low behavior — the inversion-at-boundary pattern fixes this

#### Preview: Day 2
Tomorrow we go wider — vectors, buses, operators, and the 7-segment display. You'll take multi-bit data and display it as hex digits. The pre-class video covers data types, bit vectors, and operators.

**Homework:** Watch the Day 2 pre-class video (~45 min) and complete the embedded checkpoint questions.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Toolchain setup | 1.4 | All tools report version, board connected |
| Ex 1: LED On | 1.3, 1.4, 1.5 | LED lit, student can explain the flow |
| Ex 2: Buttons to LEDs | 1.3, 1.5, 1.6 | All 4 buttons control corresponding LEDs |
| Ex 3: Button Logic | 1.1, 1.6 | Truth tables match predictions; student can explain concurrency |
| Ex 4: Active-Low | 1.5, 1.6 | Correct behavior; student articulates the boundary-inversion pattern |
| Ex 5: Makefile | 1.4 | `make prog` works end-to-end |
| Concept check Qs | 1.1, 1.2, 1.3, 1.4, 1.5 | In-class discussion responses |

---

## Instructor Notes

- **Pacing:** Exercises 1 and 2 should go fast (15 + 15 min for most students). Budget extra time for toolchain setup issues — USB drivers on macOS and Windows are the likely bottleneck.
- **Common setup issue:** `iceprog` needs permissions on Linux (`sudo` or udev rules). Prepare a udev rule file in advance.
- **Active-low confusion** is guaranteed. Exercise 4 exists specifically to build the right mental model early. Spend time here.
- **For advanced students:** Yosys interactive mode and `show` command are fascinating — let them explore the synthesized netlist visually.
- **For struggling students:** Exercises 1 and 2 are designed to be almost impossible to fail. Ensure everyone has at least Ex 2 working before moving on.
