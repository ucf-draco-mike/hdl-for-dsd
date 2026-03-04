# Timing Analysis Worksheet — Day 10, Exercise 1

## Instructions
Synthesize `top_timing_demo.v` with different `--freq` constraints.
Record the results below.

```bash
# Example command:
nextpnr-ice40 --hx1k --package vq100 --pcf ../go_board.pcf \
    --json top_timing_demo.json --asc top_timing_demo.asc \
    --freq 25 2>&1 | tee timing_25.txt
```

## Results Table

| Constraint (MHz) | Reported Fmax (MHz) | Slack (ns) | Pass/Fail | Critical Path Module |
|:-:|:-:|:-:|:-:|:--|
| 25 | _____ | _____ | _____ | _____ |
| 100 | _____ | _____ | _____ | _____ |
| 200 | _____ | _____ | _____ | _____ |

## Questions
1. What signal/module is on the critical path?
2. How many LUTs, FFs, and EBR blocks are used?
3. Are there any timing warnings at 25 MHz?
4. At what constraint does timing first fail?
