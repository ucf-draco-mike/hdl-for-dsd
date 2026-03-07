# Day 11: UART TX — Your First Communication Interface

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 11 of 16

---

## Student Learning Objectives

1. **SLO 11.1:** Explain the UART protocol: start bit, 8 data bits, stop bit, baud rate, and framing.
2. **SLO 11.2:** Derive baud rate timing from the 25 MHz Go Board clock and implement a baud rate generator.
3. **SLO 11.3:** Implement a UART TX module using FSM + PISO shift register + baud generator architecture.
4. **SLO 11.4:** Integrate UART TX into a top module that transmits data from the Go Board to a PC terminal.
5. **SLO 11.5:** Verify UART TX behavior in simulation before programming hardware.

---

## Pre-Class Video (~50 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | UART protocol: start bit, 8 data bits, stop bit, baud rate | 14 min | `video/day11_seg1_uart_protocol.mp4` |
| 2 | Baud rate generation: deriving precise timing from a fast clock | 10 min | `video/day11_seg2_baud_rate.mp4` |
| 3 | TX architecture: FSM + PISO shift register + baud generator | 16 min | `video/day11_seg3_tx_architecture.mp4` |
| 4 | Connecting to a PC: USB-to-serial, terminal emulator setup | 10 min | `video/day11_seg4_pc_connection.mp4` |

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: UART protocol quiz, pre-class questions | 5 min |
| 0:05 | Mini-lecture: UART as FSM+datapath, baud math, live build | 30 min |
| 0:35 | Lab Exercise 1: UART TX implementation | 40 min |
| 1:15 | Break | 5 min |
| 1:20 | Lab Exercise 2: Single character on button press | 20 min |
| 1:40 | Lab Exercise 3: Transmit "HELLO" | 25 min |
| 2:05 | Lab Exercise 4 (Stretch): Hex-to-ASCII | 15 min |
| 2:20 | Wrap-up and Day 12 preview | 10 min |

---

## In-Class Mini-Lecture (30 min)

### UART as an FSM + Datapath Design Exercise (10 min)
- Everything from Weeks 1–2 comes together: FSMs, counters, shift registers, testbenches
- Block diagram: baud generator (counter), bit counter, shift register, FSM controller, TX output
- The FSM states: IDLE (TX high), START (TX low for 1 bit period), DATA (shift out 8 bits LSB first), STOP (TX high for 1 bit period)

### Baud Rate Math (10 min)
- 25 MHz / 115200 = 217.01... ≈ 217 clocks per bit
- Rounding considerations: 217 gives actual baud = 115,207 Hz, error = 0.006% — well within tolerance
- Other baud rates: 9600 → 2604 clocks; 19200 → 1302 clocks
- **Design decision:** Parameterize `CLKS_PER_BIT` so the module works at any baud rate

### Live Build (10 min)
- Walk through the UART TX code structure together
- Highlight the critical details: LSB first, start bit = 0, stop bit = 1, idle = 1
- Show the provided architecture diagram (distributed as a handout or on screen)
- Terminal setup: 115200 baud, 8N1, no flow control

---

## Lab Exercises

### Exercise 1: UART TX Implementation (40 min)

**Objective (SLO 11.1, 11.2, 11.3, 11.5):** Build a working UART transmitter from the architecture diagram.

**Tasks:**
1. Implement the UART TX module with:
   - `parameter CLKS_PER_BIT = 217` (115200 baud at 25 MHz)
   - Inputs: `clk`, `rst`, `tx_start`, `tx_data[7:0]`
   - Outputs: `tx_out`, `tx_busy`
   - FSM: IDLE → START → DATA (8 bits) → STOP → IDLE
   - Baud rate counter for bit-period timing
   - Bit counter (0–7) for tracking which data bit to send
2. **Simulate first:** Write a testbench that:
   - Sends the byte `8'h41` (ASCII 'A')
   - Verifies the TX line goes: IDLE(1) → START(0) → D0 D1 D2 D3 D4 D5 D6 D7 → STOP(1)
   - Verify `tx_busy` is asserted during transmission
   - Use a short `CLKS_PER_BIT` value (e.g., 4) for fast simulation
3. View waveforms in GTKWave. Verify the bit timing.

**Checkpoint:** Simulation shows correct UART TX waveform for 'A' (0x41).

---

### Exercise 2: Single Character on Button Press (20 min)

**Objective (SLO 11.4):** Get the first character from the Go Board to the PC.

**Tasks:**
1. Create a top module that:
   - Debounces a button (reuse Day 5 module)
   - On button press, loads ASCII 'A' (or any character) and asserts `tx_start`
   - Connects `tx_out` to the UART TX pin via `.pcf`
2. Synthesize and program.
3. Open a terminal emulator (e.g., `screen`, `minicom`, `picocom`, or PuTTY) at 115200 8N1.
4. Press the button — see 'A' appear on your PC terminal.

**Checkpoint:** Character appears on the PC terminal on button press.

---

### Exercise 3: Transmit "HELLO" (25 min)

**Objective (SLO 11.3, 11.4):** Build a multi-byte transmitter using a ROM + sequencer.

**Tasks:**
1. Store the string "HELLO\r\n" in a ROM (7 bytes).
2. Build a sequencer FSM that:
   - On trigger (button press or reset), starts at ROM address 0
   - Sends each byte via UART TX, waiting for `tx_busy` to deassert before advancing
   - Stops after the last byte
3. Synthesize and program. Verify "HELLO" appears on the terminal, followed by a newline.

**Checkpoint:** "HELLO" prints on the PC terminal from the Go Board.

---

### Exercise 4 (Stretch): Hex-to-ASCII Converter (15 min)

**Objective (SLO 11.4):** Transmit human-readable data.

**Tasks:**
1. Implement a module that converts a 4-bit value to its ASCII hex character ('0'–'9', 'A'–'F').
2. Use it to transmit the counter value as readable hex text: e.g., "0A\r\n", "0B\r\n", ...
3. Transmit a new value every ~1 second.

---

## Deliverable

"HELLO" appearing on the PC terminal from the Go Board, with a simulation waveform showing correct UART TX framing.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — UART TX implementation | 11.1, 11.2, 11.3, 11.5 | Core |
| 2 — Single character TX | 11.4 | Core |
| 3 — "HELLO" string TX | 11.3, 11.4 | Core |
| 4 — Hex-to-ASCII | 11.4 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> Day 11 is your first communication interface. UART is unforgiving about timing — one wrong clock count and every byte is garbled.

- **Characters show as garbage in the terminal?** The most common cause is a baud rate mismatch. Double-check your `CLKS_PER_BIT` calculation: for 115200 baud at 25 MHz, it should be `25000000 / 115200 = 217`. Also verify your terminal emulator is set to 115200 baud, 8N1.
- **UART sends LSB first.** This catches everyone at least once. Bit 0 of your data byte goes out on the wire first, then bit 1, etc. If you're seeing characters that are "almost right but wrong," check your bit ordering.
- **Sending multiple bytes and getting corruption?** You must wait for `o_busy` to go low (or `o_done` to pulse) before sending the next byte. The "HELLO" sequencer in Exercise 3 forces you to handle this — don't shortcut it.
- **Terminal emulator won't connect?** Common causes: wrong COM port (try them all), hardware flow control enabled (disable it), or another program has the port open. On Linux, check `ls /dev/ttyUSB*`; on macOS, `ls /dev/cu.*`.
- **Which pin is TX on the Go Board?** Check `go_board.pcf` for the UART TX pin. It must match the pin connected to the USB-to-serial chip on the board. If you get this wrong, the terminal will show nothing at all.
---

## Preview: Day 12

UART RX completes the communication loop — type on your PC, see it on the Go Board. You'll also build an SPI master and get hands-on with AI-generated protocol testbenches, learning to prompt for timing-aware verification.
