# Day 5: Counters, Shift Registers & Debouncing

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 5 of 16

---

## Student Learning Objectives

1. **SLO 5.1:** Design parameterized counter variations (up, down, modulo-N, loadable) for use as reusable building blocks.
2. **SLO 5.2:** Implement shift registers in multiple configurations (SISO, SIPO, PISO) and explain their role in serial communication.
3. **SLO 5.3:** Explain metastability and implement a 2-FF synchronizer chain for asynchronous inputs.
4. **SLO 5.4:** Design a counter-based button debouncer with a parameterized threshold.
5. **SLO 5.5:** Integrate counters, shift registers, and debouncing into a complete system on the Go Board.

---

## Pre-Class Video (~45 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Counter variations: up, down, up/down, modulo-N, loadable | 12 min | `video/day05_seg1_counter_variations.mp4` |
| 2 | Shift registers: SISO, SIPO, PISO, PIPO — and why they matter for serial I/O | 12 min | `video/day05_seg2_shift_registers.mp4` |
| 3 | The button bounce problem: mechanical switches are noisy | 10 min | `video/day05_seg3_button_bounce.mp4` |
| 4 | Synchronizer chains: metastability and the 2-FF synchronizer | 11 min | `video/day05_seg4_metastability.mp4` |

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up Q&A: sequential logic review, pre-class questions | 10 min |
| 0:10 | Mini-lecture: metastability, debounce strategies, live demo | 30 min |
| 0:40 | Lab Exercise 1: Debouncer module | 25 min |
| 1:05 | Lab Exercise 2: Shift register | 20 min |
| 1:25 | Break | 5 min |
| 1:30 | Lab Exercise 3: LED chase pattern | 25 min |
| 1:55 | Lab Exercise 4: Debounced control integration | 20 min |
| 2:15 | Lab Exercise 5 (Stretch): LFSR | 10 min |
| 2:25 | Wrap-up and Day 6 preview | 5 min |

---

## In-Class Mini-Lecture (30 min)

### Metastability & Why It's Terrifying (10 min)
- What happens when a flip-flop samples during a transition
- Metastable state: neither 0 nor 1, resolves unpredictably
- The 2-FF synchronizer: why two FFs dramatically reduce the probability of failure
- Rule: **any signal crossing from an asynchronous domain must be synchronized**

### Debounce Strategies (15 min)
- Counter-based debounce: sample the input, count consecutive stable readings
- Shift-register-based debounce: shift in samples, output changes when all bits agree
- Live demo: scope or simulation view of button bounce vs. debounced output
- Design decisions: threshold value (how many clock cycles = how many ms?)
- Parameterization: `parameter DEBOUNCE_THRESHOLD = 250000` (10 ms at 25 MHz)

### LED Chase Pattern Overview (5 min)
- Shift register + counter = scrolling LED pattern
- Direction control: shift left vs. shift right
- Speed control: counter threshold determines shift rate

---

## Lab Exercises

### Exercise 1: Reusable Debouncer Module (25 min)

**Objective (SLO 5.3, 5.4):** Build a parameterized debouncer that can be reused in every future design.

**Tasks:**
1. Implement a counter-based debouncer module with:
   - Parameterized `DEBOUNCE_THRESHOLD` (default = 250000 for 10 ms at 25 MHz)
   - Input synchronizer (2-FF chain) built into the module
   - Clean output signal that only transitions after the input has been stable for the full threshold
2. Simulate with a noisy input stimulus: toggle the input rapidly for a few cycles, then hold steady. Verify the output only transitions after the threshold.
3. Synthesize and test on the Go Board: button press should produce exactly one clean transition per physical press.

**Checkpoint:** Debouncer passes simulation. Single clean transition per button press on hardware.

---

### Exercise 2: 8-Bit Shift Register (20 min)

**Objective (SLO 5.2):** Implement a shift register that will serve as the foundation for UART and SPI in Week 3.

**Tasks:**
1. Implement an 8-bit shift register with serial input, parallel output, and enable.
2. Add a parallel load capability (PISO mode) — load 8 bits, shift them out one at a time.
3. Simulate: load a known pattern, shift it out, verify each bit in sequence.

**Checkpoint:** Simulation shows correct serial output sequence after parallel load.

---

### Exercise 3: LED Chase Pattern (25 min)

**Objective (SLO 5.1, 5.2, 5.5):** Combine a counter (for speed) and a shift register (for the pattern) into a visible system.

**Tasks:**
1. Create a 4-bit shift register that drives the 4 Go Board LEDs.
2. Use a counter to control shift rate — aim for a visible sweep speed (~5–10 Hz).
3. Implement a "bounce" pattern: the lit LED sweeps left to right, then reverses direction (like a Knight Rider / Cylon eye).
4. Synthesize and program the Go Board.

**Checkpoint:** LED chase pattern running on hardware at a comfortable visible speed.

---

### Exercise 4: Debounced Button Control (20 min)

**Objective (SLO 5.4, 5.5):** Integrate the debouncer to add button-controlled behavior.

**Tasks:**
1. Instantiate the debouncer module from Exercise 1 for each button.
2. Button 0: toggle direction (left vs. right).
3. Button 1: cycle through 3 speed settings (slow, medium, fast).
4. Verify clean single-press behavior — no accidental double-triggers.

**Checkpoint:** Chase pattern on hardware with debounced direction and speed control.

---

### Exercise 5 (Stretch): LFSR Pseudo-Random Pattern (10 min)

**Objective (SLO 5.1, 5.2):** Explore an LFSR as a shift register variant.

**Tasks:**
1. Implement an 8-bit LFSR with XOR feedback taps (e.g., taps at positions 7, 5, 4, 3 for maximal length).
2. Drive the LEDs from the lower 4 bits of the LFSR.
3. Observe the pseudo-random pattern.

---

## Deliverable

Debounced button-controlled LED chase pattern on the Go Board, with simulation waveform for the debouncer module.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — Debouncer | 5.3, 5.4 | Core |
| 2 — Shift register | 5.2 | Core |
| 3 — LED chase | 5.1, 5.2, 5.5 | Core |
| 4 — Debounced control | 5.4, 5.5 | Core |
| 5 — LFSR | 5.1, 5.2 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> Day 5 introduces modules you'll reuse for the rest of the course. Getting the debouncer and counter right here saves pain later.

- **Debounce threshold too short?** A few hundred clock cycles won't cut it for real buttons. Do the math: 10 ms × 25 MHz = 250,000 cycles. Set your threshold accordingly.  For simulation, use a much smaller value (parameterize it!) so your TB runs in reasonable time.
- **"Why does metastability matter if I can't see it in simulation?"** Simulation can't reproduce metastability — it's a real-world analog phenomenon where a flip-flop output hovers between 0 and 1 for a brief time. You won't see it fail in simulation, which makes it more dangerous, not less. The 2-FF synchronizer at the input of the debouncer is your protection.
- **Shift direction confusion?** "Left shift" (`<<`) moves bits toward the MSB; "right shift" (`>>`) moves toward the LSB. If your shift register goes the wrong way, draw it on paper — label each bit position 0 through N-1 — and trace one shift before changing code.
- **Chase pattern gets stuck at one end?** The direction-reversal logic needs to detect when the lit bit reaches position 0 or position N-1. Common bug: off-by-one on the boundary check. The lit bit is at position N-1 when `pattern[N-1] == 1`, not when `pattern == N-1`.
---

## Preview: Day 6

Tomorrow we shift from *building* to *verifying*. You'll write your first proper testbenches, learn the simulation-first workflow, and get your first hands-on experience with AI-assisted testbench generation. The critical rule: you'll write testbenches by hand first, *then* use AI — because you can't evaluate what you can't write.
