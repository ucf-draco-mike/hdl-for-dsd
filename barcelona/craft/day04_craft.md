# CRAFT Overlay — D4 — Clocked Logic & RTL Thinking

**Date:** Fri 5/29

---

## 🌍 Contextualize

"Clocked systems are everywhere in Barcelona: the traffic lights you cross, the Metro schedule, the airport departure boards. Every one runs on a clock edge."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: code executes top to bottom. **Reframe:** Everything inside an `always @(posedge clk)` block describes what happens on a single clock edge — simultaneously. The order of nonblocking assignments doesn't matter."

## 🔑 Key Insight

"Blocking (`=`) vs. nonblocking (`<=`) is not a style choice. Use `=` in combinational, `<=` in sequential. Mixing them causes simulation-synthesis mismatch."

## 🤖 Check the Machine

"Ask an AI to explain the difference between blocking and nonblocking assignments. Does its explanation match what you just learned? Where is it imprecise?"

## 🔗 Transfer

"You can now build anything that happens on a clock edge. This weekend, watch the D5+D6 pre-class videos (counters + testbenches). Monday: build sequential circuits AND verify them."

---

*This overlay supplements the baseline daily plan. All lab exercises
and lecture content come from the baseline D-day materials.*
