# Pre-Demo Checklist

Complete this before your demo. Check every box.

## Hardware
- [ ] Go Board programmed with final bitstream
- [ ] Heartbeat LED blinking (FPGA is configured)
- [ ] USB cable connected (for UART, if used)
- [ ] Terminal emulator open and configured (if using UART)
- [ ] Know the demo sequence — what you'll show and in what order
- [ ] Tested the demo sequence end-to-end at least once today

## Code
- [ ] All source files saved and committed to git
- [ ] `make clean && make` succeeds with no errors
- [ ] No critical warnings in synthesis output
- [ ] `make stat` — know your LUT/FF count and Fmax

## Verification
- [ ] Testbench for at least one custom module → PASS
- [ ] `make sim` runs cleanly (no X/Z warnings in key signals)
- [ ] Can show testbench output (terminal or GTKWave screenshot)

## Presentation
- [ ] Block diagram ready (digital or clean hand-drawn)
- [ ] Can explain each module's purpose in one sentence
- [ ] Know which modules are reused vs. new
- [ ] Prepared one-sentence reflection: "The most interesting challenge was..."
- [ ] Timed yourself: presentation is 5–7 minutes

## Fallback Plan
- [ ] If hardware fails, have simulation waveform screenshots ready
- [ ] Can explain what you *expected* to see on hardware
- [ ] Can explain what went wrong (if you know)

---

*It's okay if not everything works. Show what does work, explain what doesn't,
and be honest about what you learned. That's engineering.*
