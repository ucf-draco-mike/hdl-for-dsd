# Day 7: Finite State Machines

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | FSM Theory & Architecture | ~12 min | `d07_s1_fsm_theory_architecture.html` |
| 2 | The 3-Always-Block Template | ~15 min | `d07_s2_three_block_template.html` |
| 3 | State Encoding | ~8 min | `d07_s3_state_encoding.html` |
| 4 | FSM Design Methodology | ~15 min | `d07_s4_fsm_design_methodology.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day07_ex01_fsm_template.v` | Complete 3-block traffic light FSM with self-checking testbench |
| `code/day07_ex02_pattern_detector.v` | "101" sequence detector (Moore) with overlap support, self-test |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d07_fsm_block_diagram.svg` | 3-block FSM architecture: state register, next-state, output logic |
| `diagrams/d07_traffic_light_states.svg` | Traffic light state diagram: GREEN → YELLOW → RED → GREEN |

## Key Concepts
- FSM = states + transitions + outputs
- Moore (outputs = f(state)) vs. Mealy (outputs = f(state, inputs))
- 3-block template: state register, next-state logic, output logic
- State encoding: binary (default), one-hot (FPGAs), Gray (CDC)
- Design methodology: states → transitions → outputs → diagram → code → test

## Directory Structure

```
day07_finite_state_machines/
├── d07_s1_fsm_theory_architecture.html
├── d07_s2_three_block_template.html
├── d07_s3_state_encoding.html
├── d07_s4_fsm_design_methodology.html
├── code/
│   ├── day07_ex01_fsm_template.v
│   └── day07_ex02_pattern_detector.v
├── diagrams/
│   ├── d07_fsm_block_diagram.svg
│   └── d07_traffic_light_states.svg
├── day07_quiz.md
└── day07_readme.md
```
