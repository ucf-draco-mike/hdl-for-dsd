[**:material-arrow-left: Back to Barcelona Day Plan**](../index.md){ .md-button }

# CRAFT Overlay — D11 — UART: Protocol Design & Implementation

**Date:** Tue 6/9

---

## 🌍 Contextualize

"Serial communication is everywhere — your Go Board's USB-to-UART bridge, the debug ports on the RISC-V chips at Semidynamics, the telemetry links in the Metro control room."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: you send a string with `print()`. **Reframe:** You're building a state machine that shifts out one bit at a time at a precise baud rate. There's no `print` — there's a shift register, a baud counter, and an FSM."

## 🔑 Key Insight

"UART TX is an FSM that shifts bits out at a fixed rate. The protocol complexity is in the timing, not the logic."

## 🤖 Check the Machine

"Prompt AI for a protocol-aware UART testbench. Does it check baud timing precisely? Does it verify all 8 data bits? What about back-to-back transmissions? Annotate corrections."

## 🔗 Transfer

"You've designed a communication interface from the ground up — FSM, timing, verification. Tomorrow: SystemVerilog gives you sharper tools for everything you've learned so far."

---

## Visit/Activity Connection

**Evening: Flamenco at Los Tarantos** — Flamenco rhythm is precisely timed parallel coordination — hands, feet, guitar, voice — like synchronized hardware signals on a clock.

---

---

[:material-arrow-left: Back to Barcelona Day Plan](../index.md){ .md-button }
&nbsp;
[:material-book-open-variant: Baseline D11 Materials](../../days/day11/){ .md-button .md-button--primary }
&nbsp;
[:material-book-open-variant: Baseline D12 Materials](../../days/day12/){ .md-button .md-button--primary }

*This overlay supplements the baseline daily plan. All lab exercises and lecture content come from the baseline [D11](../../days/day11/) + [D12](../../days/day12/) materials.*
