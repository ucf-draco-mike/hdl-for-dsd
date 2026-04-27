# Day 7 Lab: Finite State Machines

!!! abstract "Starter Code"
    [:material-folder-download: Download All Starter Code (.zip)](../../downloads/day07/day07_all_starter.zip){ .md-button .md-button--primary }

    Individual exercise downloads and file links are below each exercise.


## Course: Accelerated HDL for Digital System Design — Week 2, Session 7

---

## Objectives

By the end of this lab, you will:
- Implement a timed FSM (traffic light controller) using the 3-always-block style
- Write a self-checking FSM testbench verifying all state transitions
- Design a button pattern detector FSM
- (Stretch) Compare Moore vs. Mealy implementations side by side

## Prerequisites

- Watched Day 7 pre-class video (~50 min): Moore/Mealy, state diagrams, 3-block template
- `debounce.v` and `hex_to_7seg.v` from previous labs (provided in `starter/`)

## Critical Habit: Draw the State Diagram FIRST

**Do not start coding until you have drawn the state diagram on paper.** This is non-negotiable. The diagram is your design document.

## Deliverables

| # | Exercise | Time | What to Submit |
|---|----------|------|----------------|
| 1 | Traffic Light Controller | 40 min | `traffic_light.v` + `tb_traffic_light.v` — all transitions verified |
| 2 | Button Pattern Detector | 35 min | `pattern_detector.v` + `top_pattern.v` + testbench |
| 3 | Testbench Deep Dive | 25 min | Extended `tb_traffic_light.v` with negative/stability tests |
| 4 | Moore vs. Mealy (stretch) | 20 min | Side-by-side waveform comparison screenshot |

**Primary deliverable:** Traffic light FSM running on board with waveform-verified testbench.

---

## Exercise 1: Traffic Light Controller (40 min)

!!! code "Exercise 1 — Code"
    [:material-download: Starter .zip](../../downloads/day07/ex1_traffic_light_fsm_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day07/ex1_traffic_light_fsm_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex1_traffic_light_fsm/starter/Makefile){ target=_blank } [:material-github: `hex_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex1_traffic_light_fsm/starter/hex_to_7seg.v){ target=_blank } [:material-github: `tb_traffic_light.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex1_traffic_light_fsm/starter/tb_traffic_light.v){ target=_blank } [:material-github: `traffic_light.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex1_traffic_light_fsm/starter/traffic_light.v){ target=_blank }



**SLOs: 7.2, 7.3, 7.5**

### Part A: Implement `traffic_light.v`

Use the starter file — the state encoding and timing parameters are provided. You implement the 3-always-block FSM and the timer.

**States:** GREEN (5s) → YELLOW (1s) → RED (4s) → repeat

**Go Board mapping:** LED1=Red, LED2=Yellow, LED3=Green, LED4=Heartbeat

### Part B: Self-Checking Testbench

Use `tb_traffic_light.v` starter. Implement the `check_state` task and verify:
1. Reset → GREEN
2. GREEN → YELLOW after GREEN_TIME cycles
3. YELLOW → RED after YELLOW_TIME cycles
4. RED → GREEN (full cycle)
5. Mid-state reset → GREEN

### Part C: Hardware Demo

Synthesize with real timer values (remove `SIMULATION` define). Watch the LEDs cycle.

```bash
make sim TB=tb_traffic_light.v SRCS="traffic_light.v"
make PROJECT=traffic_light
make prog PROJECT=traffic_light
```

---

## Exercise 2: Button Pattern Detector (35 min)

!!! code "Exercise 2 — Code"
    [:material-download: Starter .zip](../../downloads/day07/ex2_pattern_detector_starter.zip){ .md-button } [:material-check-circle: Solution .zip](../../downloads/day07/ex2_pattern_detector_solution.zip){ .md-button } [:material-github: `Makefile`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex2_pattern_detector/starter/Makefile){ target=_blank } [:material-github: `debounce.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex2_pattern_detector/starter/debounce.v){ target=_blank } [:material-github: `hex_to_7seg.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex2_pattern_detector/starter/hex_to_7seg.v){ target=_blank } [:material-github: `pattern_detector.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex2_pattern_detector/starter/pattern_detector.v){ target=_blank } [:material-github: `tb_pattern_detector.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex2_pattern_detector/starter/tb_pattern_detector.v){ target=_blank } [:material-github: `top_pattern.v`](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/labs/week2_day07/ex2_pattern_detector/starter/top_pattern.v){ target=_blank }



**SLOs: 7.2, 7.6**

Detect the sequence: Switch1 → Switch2 → Switch3. Light LED4 for 1 second on detection. Wrong button resets to beginning.

**Draw the state diagram first!** States: WAIT_1, WAIT_2, WAIT_3, DETECTED

Use `starter/pattern_detector.v` and `starter/top_pattern.v`.

**Testbench scenarios (required):**
1. Correct sequence → detection
2. Wrong sequence → no detection
3. Partial correct then wrong: btn1→btn2→btn1 → resets to WAIT_2
4. Double press: btn1→btn1→btn2→btn3 → still detects
5. Reset mid-sequence

---

## Exercise 3: Testbench Deep Dive (25 min)

**SLO: 7.4**

Extend the traffic light testbench with:
1. **Negative test:** Verify GREEN doesn't transition at GREEN_TIME-1
2. **Stability test:** Sample outputs multiple times during each state
3. **Full cycle test:** Run 3 complete cycles, verify consistent timing
4. **State check:** Use hierarchical access (`uut.r_state`) to verify no illegal states

---

## Exercise 4 (Stretch): Moore vs. Mealy Comparison (20 min)

**SLO: 7.1**

Implement a "10" sequence detector in both Moore and Mealy styles. Show in GTKWave that the Mealy output appears 1 clock cycle earlier.
