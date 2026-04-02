# CRAFT Overlay — D9 — Memory: RAM, ROM & Block RAM

**Date:** Thu 6/4

---

## 🌍 Contextualize

"Memory is in every system you interact with. Your phone's frame buffer, the Metro's schedule lookup tables, the airport's flight display. Today you learn how to describe memory in HDL."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: memory is just an array. **Reframe:** Memory has physical constraints — read latency (synchronous vs async), port count (single vs dual), initialization (`$readmemh`). And coding patterns determine whether Yosys infers efficient block RAM (EBR) or wastes all your LUTs on distributed RAM."

## 🔑 Key Insight

"The iCE40 has 16 EBR blocks — that's 64 Kbits of free, fast memory. But only if your code matches the inference pattern: synchronous read, registered address."

## 🤖 Check the Machine

"Prompt AI: 'Write a dual-port RAM in Verilog for Lattice iCE40.' Does it produce code that Yosys will infer as EBR? Synthesize and check `yosys stat` for `SB_RAM40_4K` instances."

## 🔗 Transfer

"This weekend: watch the D10 video on timing and numerical architectures. Monday: the constraints that make real systems work — setup, hold, Fmax, and PPA."

---

*This overlay supplements the baseline daily plan. All lab exercises
and lecture content come from the baseline D-day materials.*
