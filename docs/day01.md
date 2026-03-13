# Day 1: Welcome to Hardware Thinking

## Course: Accelerated HDL for Digital System Design
## Week 1, Session 1 of 16

---

## Student Learning Objectives

By the end of this session, you will be able to:

1. **SLO 1.1:** Distinguish between the hardware description (concurrent) and software programming (sequential) mental models.
2. **SLO 1.2:** Explain the difference between synthesis and simulation, and identify which constructs are synthesizable.
3. **SLO 1.3:** Write a minimal Verilog module with ports and continuous assignment.
4. **SLO 1.4:** Use the open-source iCE40 toolchain (Yosys → nextpnr → iceprog) to synthesize and program the Go Board.
5. **SLO 1.5:** Map HDL signals to physical FPGA pins using a `.pcf` constraint file.

---

## Pre-Class Video (~45 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | HDL ≠ Software: concurrent vs. sequential mental models | 12 min | `video/day01_seg1_hdl_not_software.mp4` |
| 2 | Synthesis, Simulation & Your First Testbench: two paths from one source, reading and running a TB | 15 min | `video/day01_seg2_synthesis_simulation_testbench.mp4` |
| 3 | Anatomy of a Module: ports, `assign`, wires | 12 min | `video/day01_seg3_anatomy_of_a_module.mp4` |
| 4 | Digital Logic Refresher: gates, truth tables, Boolean algebra | 8 min | `video/day01_seg4_digital_logic_refresher.mp4` |

### Key Concepts from Video
- HDL describes hardware that runs concurrently — every `assign` and `always` block is "running" simultaneously
- Synthesis transforms HDL into a netlist of gates/LUTs; simulation executes HDL as a software model
- A **testbench** is a port-less module that instantiates, drives, and checks your design — run it with `make sim`
- A Verilog module has a name, port declarations (`input`, `output`), and a body
- `assign` creates combinational logic — the output continuously reflects the inputs

### Pre-Class Quiz
See `quiz.md` — 4 questions covering all 4 segments.

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00–0:05 | Quiz review and Q&A | 5 min |
| 0:05–0:35 | Mini-lecture: course roadmap, toolchain demo, `.pcf` files | 30 min |
| 0:35–0:45 | **Simulation live demo:** run `make sim` on `tb_button_logic`, walk through output | 10 min |
| 0:45–0:55 | Lab kickoff: objectives, deliverables, environment setup guidance | 10 min |
| 0:55–2:15 | Hands-on lab | 80 min |
| 2:15–2:25 | Debrief: common pitfalls, share someone's work | 10 min |
| 2:25–2:30 | Preview Day 2, assign pre-class video | 5 min |

---

## In-Class Mini-Lecture (30 min)

### Topics
1. **Course roadmap and expectations** (5 min)
   - 4-week arc: foundations → verification → communication → project
   - Flipped format: you learn the concepts at home, you build in class
   - Assessment breakdown: labs (40%), testbenches (15%), AI portfolio (5%), PPA (5%), project (25%), participation (10%)

2. **Toolchain walkthrough** (15 min)
   - The open-source iCE40 flow: Verilog → Yosys → nextpnr → icepack → iceprog
   - Live demo: from source to blinking LED in under 2 minutes
   - Show each tool's role: synthesis (Yosys), place-and-route (nextpnr), bitstream (icepack), programming (iceprog)

3. **`.pcf` pin constraint file** (10 min)
   - Mapping HDL signal names to physical pins on the Go Board
   - Walk through `go_board.pcf`: LED pins, button pins, clock pin
   - "The `.pcf` file is the bridge between your abstract design and the real world"

### Live Demo Code
```verilog
// led_on.v — simplest possible design
module led_on (
    output wire o_LED_1
);
    assign o_LED_1 = 1'b1;
endmodule
```

---

## Simulation Live Demo (10 min)

> **Goal:** Students see `make sim` produce PASS/FAIL output before they ever touch `make prog`.

### Walk-Through

1. **Open `labs/week1_day01/ex3_button_logic/starter/`** — show two files side by side:
   - `ex3_button_logic.v` (the design — has ports, `assign` statements)
   - `tb_button_logic.v` (the testbench — no ports, drives inputs, checks outputs)

2. **Annotate the testbench** (projector, 3 min):
   - "No ports — this is the top of the simulation world"
   - "The `dut` instance plugs in your design — same named-port syntax from the video"
   - "`reg` signals are inputs you control; `wire` signals are outputs you observe"
   - "`#1` — one time unit of propagation delay (sim-only, remember the `#10` trap?)"
   - "`===` vs `==` — triple-equals catches X and Z, double-equals silently ignores them"
   - "PASS/FAIL with `$display` — if all pass, you're safe to program the board"

3. **Run it live** (terminal, 2 min):
   ```bash
   cd labs/week1_day01/ex3_button_logic/starter
   make sim
   ```
   Point out the PASS/FAIL output and the summary line.

4. **Show waveforms** (2 min):
   ```bash
   make wave
   ```
   Open GTKWave, add `sw1`, `sw2`, `led1`, `led3`. Show how input changes propagate instantly (combinational).

5. **Key message** (1 min):
   > "Every lab exercise from today forward has a testbench. Your workflow is: edit → `make sim` → fix until all pass → `make prog` to go to hardware. Simulation is where you find bugs. Hardware is where you celebrate."

---

## Lab Exercises (~90 min)

### Exercise 1: Environment Setup & Toolchain Verification (20 min)

**Objective (SLO 1.4):** Verify that all tools are installed and working.

Run the following commands and confirm output:
```bash
yosys -V                    # Should print version
nextpnr-ice40 --version     # Should print version
iverilog -V                 # Should print version
iceprog                     # Should print usage (or error if no board connected)
```

Connect the Go Board via USB. Verify it's recognized.

---

### Exercise 2: LED On (15 min)

**Objective (SLO 1.3, 1.4, 1.5):** Write, synthesize, and program the simplest design.

1. Create `led_on.v` — hardwire `o_LED_1` high
2. Synthesize: `yosys -p "synth_ice40 -top led_on -json led_on.json" led_on.v`
3. Place and route: `nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json led_on.json --asc led_on.asc`
4. Pack and program: `icepack led_on.asc led_on.bin && iceprog led_on.bin`
5. Verify: LED 1 should be on

**Checkpoint:** First hardware success. If this works, the toolchain is fully operational.

---

### Exercise 3: Buttons to LEDs (25 min)

**Objective (SLO 1.3, 1.5):** Use `assign` to create combinational connections.

```verilog
module buttons_to_leds (
    input  wire i_Switch_1,
    input  wire i_Switch_2,
    input  wire i_Switch_3,
    input  wire i_Switch_4,
    output wire o_LED_1,
    output wire o_LED_2,
    output wire o_LED_3,
    output wire o_LED_4
);
    assign o_LED_1 = i_Switch_1;
    assign o_LED_2 = i_Switch_2;
    assign o_LED_3 = i_Switch_3;
    assign o_LED_4 = i_Switch_4;
endmodule
```

Synthesize, program, verify: each button controls its corresponding LED.

---

### Exercise 4: Logic Modifications (20 min)

**Objective (SLO 1.1, 1.3):** Modify combinational logic and observe hardware behavior.

Starting from the buttons-to-LEDs design, make these modifications:
1. Invert one LED: `assign o_LED_1 = ~i_Switch_1;`
2. AND two buttons: `assign o_LED_3 = i_Switch_1 & i_Switch_2;`
3. OR two buttons: `assign o_LED_4 = i_Switch_3 | i_Switch_4;`

**Simulation checkpoint:** Before programming the board, run the provided testbench:
```bash
cd labs/week1_day01/ex3_button_logic/starter
make sim     # should print "16 passed, 0 failed"
```
If any tests fail, fix your logic before going to hardware.

Then: synthesize, program, verify on hardware.

**Discussion question:** How fast do the LEDs respond when you press a button? Why?

---

### Exercise 5 — Stretch: XOR Pattern + Makefile (10 min)

**Objective (SLO 1.3):** Explore additional operators; automate the build.

1. Create an XOR pattern: `assign o_LED_1 = i_Switch_1 ^ i_Switch_2;`
2. Create a simple Makefile that automates the build flow:

```makefile
TOP = buttons_to_leds
PCF = ../../shared/pcf/go_board.pcf

all: $(TOP).bin

$(TOP).json: $(TOP).v
	yosys -p "synth_ice40 -top $(TOP) -json $@" $<

$(TOP).asc: $(TOP).json
	nextpnr-ice40 --hx1k --package vq100 --pcf $(PCF) --json $< --asc $@

$(TOP).bin: $(TOP).asc
	icepack $< $@

prog: $(TOP).bin
	iceprog $<

clean:
	rm -f *.json *.asc *.bin

.PHONY: all prog clean
```

---

## Deliverable

Buttons-to-LEDs design with at least one logic modification (inversion, AND, OR, or XOR), successfully programmed on the Go Board.

**Submit:** Verilog source file(s) + `.pcf` file used.

---

## Assessment Mapping

| Exercise | SLOs | Weight |
|----------|------|--------|
| Environment setup | 1.4 | Core |
| LED on | 1.3, 1.4, 1.5 | Core |
| Buttons to LEDs | 1.3, 1.5 | Core |
| Logic modifications | 1.1, 1.3 | Core — graded deliverable |
| XOR + Makefile | 1.3 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> These are the issues that that come up most often on Day 1. Read them before lab — knowing what to watch for saves debugging time.

- **USB driver not working?** Linux usually works out of the box. On macOS/Windows, check the troubleshooting section in `docs/course_setup_guide.md` — USB passthrough on WSL2 requires `usbipd-win`.
- **"Nothing happened" after programming?** Usually a connection issue, not a code issue. Verify your board is recognized with `iceprog -t` (test mode) before you try to program.
- **`.pcf` pin name mismatch?** If `nextpnr` gives an error about unconstrained ports, double-check that the port names in your Verilog module *exactly* match the names in `go_board.pcf`. Spelling matters — even capitalization.
- **Finished the required exercises early?** Try the stretch exercise (Ex 5: XOR pattern) and help a neighbor debug. Explaining your design to someone else is one of the best ways to solidify your understanding.
---

## Preview: Day 2

Tomorrow we'll build combinational circuits with real data — multiplexers, adders, and a hex-to-7-segment decoder that lights up the Go Board's displays. Watch the Day 2 pre-class video (~45 min) on data types, vectors, operators, and continuous assignment.
