# PLL & Clock Domain Crossing — Day 10, Exercise 5 (Stretch)

## Objective (SLO 10.5)
Explore clock generation with `SB_PLL40_CORE` and safe clock domain crossing.

> **This is stretch content.** Complete Exercises 1-4 first. If you finish early,
> this exercise gives hands-on experience with PLLs and CDC — concepts covered
> briefly in the pre-class video and essential for advanced FPGA work.

## Part A: PLL Clock Generation (~10 min)

1. Use `icepll -i 25 -o 50` to calculate PLL parameters for 50 MHz output.
2. Instantiate `SB_PLL40_CORE` with those parameters.
3. Create blinkers in both clock domains — 25 MHz on LED1, 50 MHz on LED2.
4. Display `LOCK` status on LED3.
5. Synthesize and verify the blink rates differ as expected.

```bash
# Calculate PLL parameters
icepll -i 25 -o 50
```

## Part B: Clock Domain Crossing (~10 min)

1. Debounce a button in the 25 MHz domain.
2. Synchronize the debounced signal into the 50 MHz PLL domain using a 2-FF chain.
3. Detect rising edges in the PLL domain and increment a 4-bit counter.
4. Synchronize the counter back to 25 MHz for display on 7-seg.

**Key concept:** Any signal crossing clock domains must pass through a synchronizer.
For single bits, a 2-FF synchronizer is sufficient. For multi-bit values, consider
Gray code encoding.

## Starter files

See `top_pll_demo.v` (PLL blinker) and `top_cdc_demo.v` (CDC counter).
These are the same designs covered in the extended timing lectures.

## Time estimate: ~15 minutes (stretch)
