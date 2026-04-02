# Day 11 (Condensed): UART — Protocol Design & Implementation

**Date:** Tuesday, June 9, 2026 · 10:00–12:30
**Baseline days:** D11 (UART TX) + D12 (UART RX — conceptual only)
**Pre-class videos:** V11 (UART TX, 50 min) + V12 (UART RX conceptual, 40 min)
**Evening:** Flamenco show at Los Tarantos, 7:10 PM

---

## 🌍 Contextualize (10 min)

**"Where This Lives":** "Serial communication is everywhere — your Go Board's
USB-to-UART bridge, the debug ports on the RISC-V chips at Semidynamics,
the telemetry links in the Metro control room you'll visit next week."

---

## ⚠️ Reframe (15 min)

**"If You're Thinking Like a Programmer..."**
"You send a string with `print()`. Reframe: you're building a state machine
that shifts out one bit at a time at a precise baud rate. There's no `print`
— there's a shift register, a baud counter, and an FSM."

UART protocol walkthrough: start bit, 8 data bits, optional parity, stop bit.
Baud rate = bit period. 115200 baud → ~8.68 µs per bit.

**🔑 Key Insight:** "UART TX is an FSM that shifts bits out at a fixed rate.
That's it. The protocol complexity is in the *timing*, not the logic."

---

## 👁️🤝🧪 Assemble (80 min)

### 👁️ I Do (20 min)
Build UART TX live:
- 3-block FSM: IDLE → START → DATA → STOP
- Baud rate counter (parameterized)
- Shift register for data bits
- Show synthesis: "This is just an FSM + counter + shift register —
  modules you already know."

### 🤝 We Do (15 min)
Together: add configurable baud rate parameter. Simulate with the
baseline D11 testbench. Verify timing in GTKWave.

### 🧪 You Do (25 min)
- **Exercise 1:** Parameterize UART TX for different baud rates
  (9600, 19200, 115200). Simulate each — verify bit timing.
- **Exercise 2:** Deploy to Go Board. Send your name to PC terminal
  via USB-UART bridge. See characters appear.
- **Exercise 3 (Stretch):** Implement UART RX from pre-class video
  spec — 16× oversampling, center sampling, frame detection.

### 🤖 AI Protocol Verification (20 min)
- Prompt AI for a protocol-aware UART TB: "Generate a testbench for
  a UART transmitter with parameterized baud rate. It should verify
  start bit timing, data bit values, and stop bit."
- Evaluate: Does the AI check baud timing precisely? Does it verify
  all 8 data bits? What about back-to-back transmissions?
- Annotate corrections.

---

## 🔧 Fortify (15 min)

**🔧 What Did the Tool Build?**
Synthesize UART TX at 9600 baud vs 115200 baud. Compare `yosys stat`:
LUTs, FFs. What changes? (The baud counter width.) What doesn't?
(The FSM and shift register.)

**🧠 How You Learn:** "You just built a complete serial transmitter from
scratch. Three weeks ago you couldn't write a module. What changed in
your mental model of hardware?"

---

## 🔗 Transfer (10 min)

"You've designed a communication interface from the ground up — FSM,
timing, verification. Tomorrow: SystemVerilog gives you sharper tools
for everything you've learned so far."

**Homework:** Watch D13 pre-class video (SV Design, 45 min).

---

## What's Different from Baseline

| Baseline D11+D12 Content | Barcelona Status |
|--------------------------|------------------|
| UART TX design + lab | ✅ Full coverage |
| UART TX testbench (AI) | ✅ Full coverage |
| UART TX Go Board deploy | ✅ Full coverage |
| UART RX (16× oversampling) | 📹 Pre-class video + stretch exercise |
| UART loopback (TX→RX echo) | ❌ Dropped |
| SPI Master | ❌ Dropped |

**Starter code:** Use baseline D11 lab package. D12 UART RX starter is
available as stretch material but not required.
