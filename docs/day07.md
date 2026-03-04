# Day 7: Finite State Machines

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 7 of 16

---

## Student Learning Objectives

1. **SLO 7.1:** Distinguish Moore and Mealy machines and select the appropriate model for a given design problem.
2. **SLO 7.2:** Translate a state diagram into synthesizable Verilog using the 3-always-block coding style.
3. **SLO 7.3:** Use `localparam` or `parameter` for named state encoding and evaluate binary vs. one-hot trade-offs.
4. **SLO 7.4:** Design and implement a multi-state FSM with timed transitions (counters as timers).
5. **SLO 7.5:** Write a thorough testbench that verifies every state transition and timing constraint.

---

## Pre-Class Video (~50 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Moore vs. Mealy: outputs on state only vs. state + input | 12 min | `video/day07_seg1_moore_vs_mealy.mp4` |
| 2 | State diagrams to HDL: a systematic translation process | 12 min | `video/day07_seg2_state_to_hdl.mp4` |
| 3 | 3-always-block FSM coding style: state register, next-state, output | 14 min | `video/day07_seg3_three_block_style.mp4` |
| 4 | State encoding: binary, one-hot, gray — trade-offs | 12 min | `video/day07_seg4_state_encoding.mp4` |

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: testbench review, pre-class questions | 5 min |
| 0:05 | Mini-lecture: FSM design methodology, live design | 30 min |
| 0:35 | Lab Exercise 1: Traffic light controller | 35 min |
| 1:10 | Lab Exercise 2: Traffic light testbench | 20 min |
| 1:30 | Break | 5 min |
| 1:35 | Lab Exercise 3: Pattern detector | 30 min |
| 2:05 | Lab Exercise 4 (Stretch): Mealy pattern detector | 15 min |
| 2:20 | Wrap-up and Day 8 preview | 10 min |

---

## In-Class Mini-Lecture (30 min)

### FSM Design Methodology (10 min)
1. **Draw** the state diagram — on paper first, always
2. **Enumerate** states and transitions — build a state table
3. **Code** it using the 3-always-block pattern
4. **Simulate** it — verify every transition
- Why three always blocks? Separation of concerns: the state register is trivial and never changes, next-state logic is purely combinational, output logic is isolated for easy modification.

### Why Three Always Blocks? (5 min)
- Block 1 — State register: `always @(posedge clk)` — just loads `next_state` into `state`
- Block 2 — Next-state logic: `always @(*)` — combinational, uses `case(state)` with `if` on inputs
- Block 3 — Output logic: `always @(*)` — combinational, `case(state)` determines outputs
- Benefit: clean separation makes debugging straightforward, modifications are localized

### Live Design: Paper to Code (15 min)
- Design a simple vending machine or pattern detector on the whiteboard
- Draw the state diagram together
- Walk through the 3-block translation step by step
- Discuss: where do counters fit? (They become enable signals or transition conditions)

---

## Lab Exercises

### Exercise 1: Traffic Light Controller (35 min)

**Objective (SLO 7.2, 7.3, 7.4):** Build a classic FSM with timed state transitions.

**Tasks:**
1. Design a traffic light controller with states: GREEN, YELLOW, RED.
   - GREEN → YELLOW after ~3 seconds (75,000,000 cycles at 25 MHz, or use a shorter count for simulation)
   - YELLOW → RED after ~1 second
   - RED → GREEN after ~4 seconds
2. Use `localparam` for state names: `localparam GREEN = 2'b00, YELLOW = 2'b01, RED = 2'b10;`
3. Implement using the 3-always-block style.
4. Drive LEDs on the Go Board to represent the traffic light (e.g., LED 0 = green, LED 1 = yellow, LED 2 = red).
5. Use a counter for timing. **Tip:** Use a parameterized counter limit so you can use short values for simulation and long values for hardware.

**Checkpoint:** Traffic light cycles through states at visible speed on hardware.

---

### Exercise 2: Traffic Light Testbench (20 min)

**Objective (SLO 7.5):** Write a testbench that verifies all state transitions and timing.

**Tasks:**
1. Instantiate the traffic light with short timer values (e.g., GREEN_TIME = 10, YELLOW_TIME = 5, RED_TIME = 15) for fast simulation.
2. Verify the complete state sequence: GREEN → YELLOW → RED → GREEN → ...
3. Check timing: verify each state lasts the correct number of cycles.
4. Check reset: assert reset mid-cycle, verify return to GREEN.
5. Self-checking: compare `state` output against expected state at each transition.

**Checkpoint:** Testbench verifies at least 2 full cycles through all states.

---

### Exercise 3: Pushbutton Pattern Detector (30 min)

**Objective (SLO 7.1, 7.2, 7.4):** Build a Moore FSM that recognizes a specific input sequence.

**Tasks:**
1. Design a Moore FSM that detects a 3-button sequence (e.g., Button 0, Button 1, Button 0).
2. Draw the state diagram first (on paper or whiteboard). States: IDLE, GOT_B0, GOT_B0_B1, MATCH.
3. On successful match, light an LED for ~1 second, then return to IDLE.
4. On wrong button at any point, return to IDLE.
5. Use debounced button inputs (reuse the debouncer from Day 5).
6. Simulate with a testbench that verifies: correct sequence → match, incorrect sequence → no match, partial correct then wrong → reset to IDLE.
7. Program on the Go Board.

**Checkpoint:** Pattern detector working on hardware with debounced buttons.

---

### Exercise 4 (Stretch): Mealy Pattern Detector (15 min)

**Objective (SLO 7.1):** Compare Moore and Mealy implementations of the same specification.

**Tasks:**
1. Implement a Mealy version of the pattern detector: output goes high on the **same clock edge** as the final matching input (one cycle earlier than Moore).
2. Simulate both versions side by side. Observe the one-cycle output difference.
3. Discuss: when does this timing difference matter? (Hint: think about downstream logic that uses the match signal.)

---

## Deliverable

Traffic light FSM running on the Go Board with a waveform-verified testbench showing all state transitions.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — Traffic light FSM | 7.2, 7.3, 7.4 | Core |
| 2 — Traffic light TB | 7.5 | Core |
| 3 — Pattern detector | 7.1, 7.2, 7.4 | Core |
| 4 — Mealy detector | 7.1 | Stretch (bonus) |

---

## Common Issues & Instructor Notes

- **Missing `default` in next-state `case`:** Students often forget a default assignment, leading to latches. Emphasize: every `case` in combinational logic needs a `default`.
- **Counter inside the FSM vs. external:** Some students try to embed the counter directly in the state register block. Recommend a separate counter module or separate logic — keeps the FSM clean.
- **Simulation timer values:** Remind students to parameterize timer values so they can simulate quickly (10s of cycles) and synthesize with real values (millions of cycles).
- **One-hot encoding confusion:** Students may try to manually assign one-hot values. Explain that the synthesis tool handles encoding optimization — `localparam` with simple binary values is fine for learning. The tool can remap to one-hot if beneficial.
- **Debouncer integration:** If students haven't finished the Day 5 debouncer, provide a working debouncer module so they can focus on FSM design.

---

## Preview: Day 8

Hierarchy, parameters, and `generate` — the tools for building reusable, scalable designs. You'll parameterize modules, use `generate` blocks for hardware replication, and get your second hands-on experience with AI-assisted testbench generation — this time for parameterized modules.
