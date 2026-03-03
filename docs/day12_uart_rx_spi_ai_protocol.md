# Day 12: UART RX, SPI & AI-Assisted Protocol Verification

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 12 of 16

---

## Student Learning Objectives

1. **SLO 12.1:** Implement a UART RX module with 16× oversampling and center-bit sampling.
2. **SLO 12.2:** Build a UART loopback system (RX → TX) and verify bidirectional communication with a PC.
3. **SLO 12.3:** Write effective AI prompts for protocol-aware testbenches that specify timing constraints, frame structure, and error conditions.
4. **SLO 12.4:** Implement an SPI master (Mode 0) using FSM + shift register architecture.
5. **SLO 12.5:** Explain the constraint-based design concept: using `generate if` and parameters to conditionally include protocol features.

---

## Pre-Class Video (~55 min) ★ Revised lecture

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | UART RX — the oversampling challenge: 16×, start detection, bit centering | 15 min | `video/day12_seg1_uart_rx.mp4` |
| 2 | AI for protocol verification: prompting for timing-aware TBs ★ | 8 min | `video/day12_seg2_ai_protocol_tbs.mp4` |
| 3 | SPI protocol: SCLK, MOSI, MISO, CS_N, CPOL/CPHA modes | 12 min | `video/day12_seg3_spi_protocol.mp4` |
| 4 | Constraint-based design + IP integration: `generate if`, parameterized protocols ★ | 10 min | `video/day12_seg4_constraint_design.mp4` |

**Segment 2 key points:**
- Prompting for protocol-aware TBs: specifying baud rate, clock frequency, frame format (8N1), expected sequences
- What AI needs to know vs. what it gets wrong: baud-rate timing, center-sampling verification
- Note on tool comparison: "Try the same prompt with two different AI tools — which produces better Verilog?"

**Segment 4 key points:**
- Constraint-based design concept: `generate if` for optional features (parity, configurable stop bits)
- Example: UART TX with `parameter PARITY_EN` — how `generate if` conditionally includes parity logic
- Concept introduced here; lab implementation on Day 14
- IP integration checklist: read docs → wrapper → synchronizers → testbench → resource check

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: UART protocol review, pre-class questions | 5 min |
| 0:05 | Mini-lecture: UART RX, SPI overview, AI protocol TB demo | 30 min |
| 0:35 | Lab Exercise 1: UART RX implementation | 35 min |
| 1:10 | Lab Exercise 2: UART loopback on hardware | 15 min |
| 1:25 | Break | 5 min |
| 1:30 | Lab Exercise 3: AI-generated protocol testbench | 20 min |
| 1:50 | Lab Exercise 4: SPI master | 25 min |
| 2:15 | Debrief: AI tool comparison discussion | 10 min |
| 2:25 | Wrap-up and Day 13 preview | 5 min |

---

## In-Class Mini-Lecture (30 min)

### UART RX Walkthrough (10 min)
- 16× oversampling: sample the line 16 times per bit period
- Start-bit detection: line goes low → start counting
- Center-sampling: sample at count 7–8 (middle of the bit) for maximum noise margin
- RX FSM: IDLE → DETECT_START → SAMPLE_BITS → STOP → VALID
- Output: `rx_data[7:0]` and `rx_valid` pulse

### SPI Master Overview (5 min)
- Block diagram: FSM + shift register + clock divider
- Mode 0 (CPOL=0, CPHA=0): data sampled on rising SCLK edge, shifted on falling
- CS_N: active low, asserted for entire transaction
- Students implement from scratch (recommended) or integrate open-source IP

### AI Protocol TB Demo (10 min)
- Live-prompt AI to generate a UART loopback testbench: TX drives RX, verify data integrity
- Review together:
  - Does it handle baud timing correctly? (Often the most common AI error)
  - Does it check all 8 data bits?
  - Does it verify start/stop framing?
  - Does it include timeout detection for a hung RX?
- Fix the issues, run it
- **Key lesson:** Protocol testbenches require domain expertise that AI approximates but doesn't guarantee

### IP Integration Quick Note (5 min)
- For SPI: students choose to implement from scratch (recommended) or integrate open-source IP with a wrapper
- Either approach: verify one complete SPI transaction in simulation

---

## Lab Exercises

### Exercise 1: UART RX Implementation (35 min)

**Objective (SLO 12.1):** Build a UART receiver with oversampling.

**Tasks:**
1. Implement UART RX with 16× oversampling:
   - `parameter CLKS_PER_BIT = 217` (matching TX)
   - Oversample counter: counts to `CLKS_PER_BIT / 16` per sample
   - Start-bit detection: wait for RX line to go low, sample at center to confirm
   - Bit sampling: capture each data bit at the center of the bit period
   - Outputs: `rx_data[7:0]`, `rx_valid` (one-cycle pulse when byte received)
2. **Simulate first:** Write a testbench where the UART TX module (from Day 11) drives the RX input.
   - Send byte `8'h41` ('A') from TX → verify RX captures `8'h41`
   - Send `8'h00` and `8'hFF` — verify edge cases
   - Use short `CLKS_PER_BIT` for simulation speed

**Checkpoint:** Simulation shows correct byte capture from TX → RX.

---

### Exercise 2: UART Loopback on Hardware (15 min)

**Objective (SLO 12.2):** Verify bidirectional communication with the PC.

**Tasks:**
1. Create a top module: RX receives a byte → immediately echoes it via TX.
2. Display the hex value of the last received byte on the 7-seg display.
3. Synthesize and program.
4. Open the terminal emulator. Type characters — they should echo back. The 7-seg shows the hex code.

**Checkpoint:** Characters typed in the terminal echo back. 7-seg displays hex value of each received byte.

---

### Exercise 3: AI-Generated Protocol Testbench (20 min)

**Objective (SLO 12.3):** Generate and critically evaluate a protocol-level testbench.

**Tasks:**
1. **Write a prompt** for an AI-generated UART loopback testbench. Requirements:
   - Test at least 10 byte values including `0x00` and `0xFF`
   - Verify frame timing (start bit, 8 data bits, stop bit — correct duration for each)
   - Include timeout detection: if RX doesn't produce `rx_valid` within expected time, report failure
   - Self-checking: compare TX input byte to RX output byte
2. **Generate** the testbench using AI.
3. **Review, correct, and annotate:**
   - Does the AI handle baud-rate timing correctly? (Calculate expected cycle counts)
   - Does it properly check the center-sampling timing?
   - Are there syntax issues for iverilog?
4. **Run** the corrected testbench. Verify all 10+ bytes pass.
5. **Submit:** Prompt, raw AI output, corrected version with annotations.

**Optional bonus:** Run the same prompt through a second AI tool. In 2–3 sentences, note which produced better Verilog and why.

**Checkpoint:** Corrected AI TB passes all byte tests. Annotations explain at least 2 corrections.

---

### Exercise 4: SPI Master (25 min)

**Objective (SLO 12.4):** Implement a serial communication protocol using familiar building blocks.

**Option A — Implement from scratch (recommended):**
1. Build a Mode 0 SPI master:
   - FSM: IDLE → TRANSFER (8 bits) → DONE
   - Generate SCLK from a clock divider
   - Shift out data on MOSI on falling SCLK edge
   - Shift in data from MISO on rising SCLK edge
   - Assert CS_N (active low) during the entire transaction
2. Write a testbench with a simple SPI loopback (tie MOSI to MISO, or implement a basic SPI slave model).
3. Verify one complete 8-bit transaction in simulation.

**Option B — Integrate open-source IP:**
1. Find or use a provided simple SPI master module.
2. Write a wrapper with your module's naming conventions and port interface.
3. Write a testbench. Verify one complete transaction.
4. Check `yosys stat` — note resource usage.

**Checkpoint:** SPI master simulated with one verified transaction.

---

### Exercise 5 (Stretch): UART-to-SPI Bridge (time permitting)

**Objective (SLO 12.2, 12.4):** Bridge two protocols.

**Tasks:**
1. Receive a command byte via UART, forward it via SPI, return the SPI response via UART.

---

## Deliverable

1. UART loopback working on hardware (echo + 7-seg display).
2. AI-generated protocol testbench with annotated corrections.
3. SPI master simulated with testbench.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — UART RX | 12.1 | Core |
| 2 — UART loopback | 12.2 | Core |
| 3 — AI protocol TB | 12.3 | Core |
| 4 — SPI master | 12.4 | Core |
| 5 — UART-to-SPI bridge | 12.2, 12.4 | Stretch (bonus) |

**Instructor note on AI tool comparison:** If time permits during debrief (2:15–2:25), ask 2–3 students to share their tool comparison findings. Five minutes of peer discussion here is high-value.

---

## Common Issues & Instructor Notes

- **Oversampling math:** Students may confuse "16× oversampling" with "sample 16 times per bit." Clarify: the sample clock runs 16× faster than the baud rate. You sample once per bit at sample count ~7–8.
- **Start-bit false detection:** Noise on the RX line can trigger false start bits. The center-sample confirmation in the start-bit state helps reject these — make sure students implement this check.
- **SPI clock polarity:** Mode 0 means idle clock is low, data sampled on rising edge. Students often flip this. Have them draw the timing diagram.
- **Time pressure:** This is a full day. If students are behind on UART RX, prioritize Exercises 1–3 and defer SPI to homework or stretch. The AI TB exercise (Exercise 3) should not be skipped — it's part of the progressive AI verification thread.

### Cross-Cutting Threads

- **AI Verification (Day 3 of thread):** Students now prompt for protocol-level testbenches. The new challenge is timing-aware verification — AI must handle baud rate math and frame structure.
- **Constraint-Based Design:** Concept introduced in pre-class Segment 4. Lab implementation deferred to Day 14 (parity extension of UART TX using `generate if`).

---

## Preview: Day 13

SystemVerilog for design — cleaner syntax, stronger safety, same hardware. You'll learn `logic`, `always_ff`, `always_comb`, `enum` states, and refactor existing modules to see how SV improves designer productivity without changing the synthesized hardware.
