# Timing Constraint Exercise — Day 10, Exercise 4

## Objective (SLO 10.5)
Read a nextpnr timing report and identify whether timing constraints are met.

## Instructions

Use one of your designs from Exercises 1-2 (e.g., the behavioral 16-bit adder
wrapped in a registered module, or the shift-and-add multiplier).

### Step 1: Synthesize
```bash
yosys -p "read_verilog shift_add_mult.v; synth_ice40 -top shift_add_mult -json mult.json"
```

### Step 2: Run nextpnr at different frequency constraints
```bash
# 25 MHz (the Go Board clock)
nextpnr-ice40 --hx1k --package vq100 --json mult.json --asc mult.asc \
    --freq 25 2>&1 | grep "Max frequency"

# 50 MHz
nextpnr-ice40 --hx1k --package vq100 --json mult.json --asc mult.asc \
    --freq 50 2>&1 | grep "Max frequency"

# 100 MHz
nextpnr-ice40 --hx1k --package vq100 --json mult.json --asc mult.asc \
    --freq 100 2>&1 | grep "Max frequency"
```

### Step 3: Record results

| Constraint (MHz) | Reported Fmax (MHz) | Pass/Fail |
|:-:|:-:|:-:|
| 25  | _____ | _____ |
| 50  | _____ | _____ |
| 100 | _____ | _____ |

### Questions
1. At what constraint does timing first fail?
2. What limits Fmax in your design (which module/path)?
3. How does the shift-and-add multiplier's Fmax compare to the combinational `*`?

## Time estimate: ~10 minutes
