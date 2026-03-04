# Integration Checklist

Print this page. Check off each step. Do NOT skip ahead.

## Phase 1: Module Verification
- [ ] List every module your project needs
- [ ] For each reused module: re-run its testbench → PASS
- [ ] For each new/modified module: write a testbench → PASS
- [ ] All testbenches produce "ALL TESTS PASSED" with zero warnings

```bash
# Quick smoke test — run from your project directory
for tb in tb_*.v tb_*.sv; do
    [ -f "$tb" ] || continue
    echo "--- Testing: $tb ---"
    iverilog -g2012 -Wall -o sim.vvp "$tb" $(ls *.v *.sv 2>/dev/null | grep -v tb_) 2>&1
    vvp sim.vvp | tail -5
    echo ""
done
```

## Phase 2: Skeleton Top Module
- [ ] Create `top_project.sv` with ALL ports declared
- [ ] Stub every output to a safe default (LEDs off, UART idle high)
- [ ] Add heartbeat blinker on one LED
- [ ] `make` → synthesize succeeds with zero errors
- [ ] `make prog` → program FPGA → heartbeat LED blinks
- [ ] **STOP.** You now have a known-good baseline.

## Phase 3: Incremental Integration
For each module (one at a time!):
- [ ] Instantiate the module in top
- [ ] Connect its inputs (use switches for manual test if needed)
- [ ] Route its outputs to observable pins (LEDs, 7-seg, UART TX)
- [ ] `make` → synthesize succeeds
- [ ] `make prog` → verify the new module on hardware
- [ ] **Commit to git** before adding the next module

## Phase 4: System Test
- [ ] All modules connected
- [ ] End-to-end functionality verified
- [ ] `make stat` → record LUT/FF usage and Fmax
- [ ] Clean up warnings (multi-driven nets, unused signals)

## If Something Breaks
1. Was it working before the last module was added? → Remove that module
2. Does it work in simulation but not hardware? → Check pin assignments, debounce, CDC
3. Synthesis fails? → Read the FIRST error, not the last
4. Hardware does nothing? → Check heartbeat LED. If heartbeat died, bitstream didn't load.
