# Final Project — Week 4

Choose one project (or propose your own with instructor approval by Day 13).
All projects must include verification, PPA analysis, and a live demo.

## Project Options

| Project | Key Concepts | Difficulty |
|---------|-------------|------------|
| **Reaction Timer** | FSM, counters, RNG (LFSR), 7-seg display, UART reporting | ★★☆ |
| **Digital Lock** | FSM-based combination lock, button input, 7-seg feedback, lockout timer | ★★☆ |
| **Digital Clock** | Counters, 7-seg multiplexing, UART time-set | ★★☆ |
| **Music / Tone Generator** | Counters, frequency dividers, PWM, ROM sequencer | ★★☆ |
| **Stopwatch / Lap Timer** | Precision counters, debounce, 7-seg, UART log | ★★☆ |
| **Serial Calculator** | UART RX/TX, FSM, expression parsing, ALU | ★★★ |
| **VGA Pattern Generator** | VGA timing, counters, ROM, pixel addressing, button control | ★★★ |
| **UART Command Parser** | UART RX/TX, FSM, string matching, LED/7-seg control | ★★★ |
| **SPI Sensor Interface** | SPI master, data formatting, 7-seg/UART display | ★★★ |
| **Numerical Compute Engine** | Parameterized ALU + sequential multiplier + fixed-point + UART I/O | ★★★ |
| **Simple 4-bit Processor** | ALU + register file + sequencer + ROM program | ★★★ |
| **Conway's Game of Life** | Block RAM grid, FSM update logic, LED or VGA output | ★★★ |
| **Custom Proposal** | Your own project, approved by instructor by Day 13 | Varies |

## Requirements

All projects must include:

1. **Functional demonstration** on the Go Board (live demo on Day 16)
2. **Clean module hierarchy** — no monolithic designs; parameterized where appropriate
3. **Self-checking testbench** — at least one manually written TB for a core module
4. **AI-assisted testbench** — at least one AI-generated TB with prompt + annotated corrections
5. **PPA report** — `yosys stat` resource summary, Fmax from `nextpnr`, % iCE40 HX1K utilization, and a brief design trade-off discussion (1 paragraph per module comparison)
6. **5–7 minute presentation**: live demo + block diagram + design trade-off + lessons learned

## Grading Rubric

| Component | Weight | Description |
|-----------|--------|-------------|
| Working demo | 30% | Does the project run on hardware as specified? |
| Code quality | 15% | Clean hierarchy, consistent style, comments, reusable modules |
| Testbenches | 20% | Manual + AI-assisted TBs, self-checking, coverage |
| PPA analysis | 15% | Resource table, Fmax, utilization, trade-off discussion |
| Presentation | 10% | Clear, concise, within time, addresses all demo elements |
| AI workflow | 10% | Quality of AI prompts, annotated corrections, coverage analysis |

## Timeline

| Day | Milestone |
|-----|-----------|
| Day 13 | Project design document due (block diagram + module list) |
| Day 14 | Assertions + AI TB + PPA analysis applied to project modules |
| Day 15 | Build day — working prototype or demonstrable progress |
| Day 16 | Final demo and presentation |

## Project Templates

Starter templates with Makefiles and module stubs are available in:
`labs/week4_day15/project_templates/`
