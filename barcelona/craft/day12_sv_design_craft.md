# CRAFT Overlay — D12 — SystemVerilog for Design

**Date:** Wed 6/10

---

## 🌍 Contextualize

"SystemVerilog is what you'll write in your first hardware job. Every major EDA tool, every ASIC flow, every FPGA vendor supports it. Today you upgrade your toolkit."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: SV is a different language I have to learn from scratch. **Reframe:** SV is Verilog with guardrails. `always_ff` doesn't change what the hardware does — it catches mistakes sooner. `logic` replaces both `wire` and `reg` and eliminates a whole class of confusion."

## 🔑 Key Insight

"`always_comb` and `always_ff` are not just style — they're *intent declarations*. The tool checks that your code matches your intent. A latch in `always_comb` is an error, not a warning."

## 🤖 Check the Machine

"Refactor your traffic light FSM to SystemVerilog. Then prompt AI to refactor a different module. Compare: did the AI use `enum` for states? Did it add `default` cases? Did it use `always_ff` correctly?"

## 🔗 Transfer

"Tomorrow: SV for verification — assertions, coverage, and the tools that tell you when you're done testing."

---

## Visit/Activity Connection

**PM: Park Güell** — Gaudí's modular tile system = parameterized design. Repeating patterns with variation = `generate` blocks.

---

*This overlay supplements the baseline daily plan. All lab exercises
and lecture content come from the baseline D-day materials.*
