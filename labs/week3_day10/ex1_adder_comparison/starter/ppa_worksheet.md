# PPA Comparison Worksheet — Day 10, Exercise 1

## Step 0 — Predict First (do this **before** you synthesize)

Use the LUT cost cheat sheet from the Day 10.2 lecture to fill in the
**Predicted LUTs** column below *before* running any tool. Quick reminders for
iCE40 LUT4:

- N-bit adder with `SB_CARRY` chain (`a + b`) → ≈ N LUT4s
- N-bit hand-rolled ripple-carry → ≈ 2N LUT4s (sum bit + carry bit each cost a LUT)
- N×N parallel multiplier (no DSP block) → ≈ N² LUT4s
- A k-input function (k > 4) cascades into ⌈(k−1)/3⌉ LUT4s

Write the number you expect *before* you peek at `yosys stat`. The point is
calibration — even a wrong guess is useful as long as it's written down.

## Step 1 — Measure
Synthesize each adder variant and record the results below.

```bash
# Example: synthesize and get stats for ripple-carry 8-bit
yosys -p "read_verilog adder_comparison.v; synth_ice40 -top ripple_carry_8; stat"

# Example: get Fmax (wrap in a registered module first, or use the provided wrapper)
yosys -p "synth_ice40 -top ripple_carry_8 -json rc8.json" adder_comparison.v
nextpnr-ice40 --hx1k --package vq100 --json rc8.json --asc rc8.asc --freq 25 2>&1 | grep "Max frequency"
```

## Adder Results Table

| Variant | Width | Predicted LUTs | Actual LUTs | FFs | Fmax (MHz) |
|:--------|:-----:|:--------------:|:-----------:|:---:|:----------:|
| Ripple-carry (manual) | 8  | _____ | _____ | _____ | _____ |
| Ripple-carry (manual) | 16 | _____ | _____ | _____ | _____ |
| Behavioral `+`        | 8  | _____ | _____ | _____ | _____ |
| Behavioral `+`        | 16 | _____ | _____ | _____ | _____ |

## Multiplier Results (Exercise 2 — fill in after completing)

| Variant | Width | Predicted LUTs | Actual LUTs | FFs | Fmax (MHz) | Latency |
|:--------|:-----:|:--------------:|:-----------:|:---:|:----------:|:-------:|
| Combinational `*` | 8 | _____ | _____ | _____ | _____ | 1 cycle |
| Shift-and-add     | 8 | _____ | _____ | _____ | _____ | 8 cycles |

## Analysis Questions

1. Does the behavioral `+` produce the same circuit as the ripple-carry chain? Compare `yosys show` output.

   _Your answer:_

2. How does LUT count scale with width for the adder? Is it linear?

   _Your answer:_

3. How does the multiplier LUT count compare to the adder at the same width? Why?

   _Your answer:_

4. When would you choose the sequential multiplier over combinational? Explain in terms of PPA.

   _Your answer:_

5. **Prediction post-mortem.** For each row where your predicted LUT count
   differed from the measured count by more than ~20%, explain *why*. Did the
   carry chain get inferred (or not)? Did a constant get folded? Did the
   synthesizer share logic across outputs? What rule of thumb would you add to
   the cheat sheet for next time?

   _Your answer:_
