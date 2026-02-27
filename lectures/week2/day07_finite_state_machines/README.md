# Day 7: Finite State Machines

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | FSM Theory & Architecture | ~12 min | `seg1_fsm_theory_architecture.html` |
| 2 | The 3-Always-Block Template | ~15 min | `seg2_three_block_template.html` |
| 3 | State Encoding | ~8 min | `seg3_state_encoding.html` |
| 4 | FSM Design Methodology | ~15 min | `seg4_fsm_design_methodology.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/fsm_template.v` | Complete 3-block FSM template — copy as starting point |

## Key Concepts
- FSM = states + transitions + outputs
- Moore (outputs = f(state)) vs. Mealy (outputs = f(state, inputs))
- 3-block template: state register, next-state logic, output logic
- State encoding: binary (default), one-hot (FPGAs), Gray (CDC)
- Design methodology: states → transitions → outputs → diagram → code → test
