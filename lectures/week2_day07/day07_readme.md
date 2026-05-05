# Day 7: Finite State Machines

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | FSM Theory & Architecture | ~12 min | `d07_s1_fsm_theory_architecture.html` |
| 2 | The 3-Always-Block Template | ~15 min | `d07_s2_three_block_template.html` |
| 3 | State Encoding | ~8 min | `d07_s3_state_encoding.html` |
| 4 | FSM Design Methodology | ~15 min | `d07_s4_fsm_design_methodology.html` |

## Live-Demo Code Examples

All examples live under `lecture_examples/week2_day07/`.

### `d07_s2_ex1/` — Traffic-Light FSM (used by Videos 1, 2, 3)

| File | Description |
|------|-------------|
| `day07_ex01_fsm_template.v`   | 3-block traffic light (binary encoding, module `traffic_light`) |
| `day07_ex01_traffic_onehot.v` | One-hot variant (module `traffic_light_onehot`) |
| `day07_ex01_traffic_gray.v`   | Gray-code variant (module `traffic_light_gray`) |
| `tb_traffic_light.v`          | Self-checking testbench (5 PASS lines) |
| `Makefile`                    | `sim`, `wave`, `stat`, `prog`, plus `stat_binary`/`onehot`/`gray`/`all` |

### `d07_s4_ex2/` — "1011" Pattern Detector (used by Video 4)

| File | Description |
|------|-------------|
| `day07_ex02_pattern_detector.v` | Moore detector for `1011` with overlap support, 5 states (S0/S1/S10/S101/SMATCH), module `pattern_detector` |
| `tb_pattern_detector.v`         | Self-checking testbench (18 PASS lines incl. overlap + near-miss) |
| `Makefile`                      | `sim`, `wave`, `stat`, `synth`, `prog` |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d07_fsm_block_diagram.svg` | 3-block FSM architecture: state register, next-state, output logic |
| `diagrams/d07_traffic_light_states.svg` | Traffic-light state diagram: GREEN → YELLOW → RED → GREEN |

## Key Concepts
- FSM = states + transitions + outputs
- Moore (outputs = f(state)) vs. Mealy (outputs = f(state, inputs))
- 3-block template: state register, next-state logic, output logic
- State encoding: binary (default), one-hot (FPGAs), Gray (CDC)
- Design methodology: states → transitions → outputs → diagram → code → test

## Directory Structure

```
lectures/week2_day07/
├── d07_s1_fsm_theory_architecture.html
├── d07_s2_three_block_template.html
├── d07_s3_state_encoding.html
├── d07_s4_fsm_design_methodology.html
├── diagrams/
│   ├── d07_fsm_block_diagram.svg
│   └── d07_traffic_light_states.svg
├── day07_quiz.md
└── day07_readme.md

lecture_examples/week2_day07/
├── Makefile                # dispatcher
├── go_board.pcf
├── d07_s2_ex1/             # traffic light + encoding variants
│   ├── Makefile
│   ├── day07_ex01_fsm_template.v
│   ├── day07_ex01_traffic_onehot.v
│   ├── day07_ex01_traffic_gray.v
│   └── tb_traffic_light.v
└── d07_s4_ex2/             # 1011 pattern detector
    ├── Makefile
    ├── day07_ex02_pattern_detector.v
    └── tb_pattern_detector.v
```
