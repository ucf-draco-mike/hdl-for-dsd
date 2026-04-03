[**:material-arrow-left: Back to Barcelona Day Plan**](../index.md){ .md-button }

# CRAFT Overlay — D8 — Hierarchy, Parameters & Generate

**Date:** Wed 6/3

---

## 🌍 Contextualize

"Parameterized design is how companies build IP libraries. Semidynamics doesn't redesign their RISC-V core for each customer — they parameterize it."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: copy-paste is reuse. **Reframe:** Parameterized modules + `generate` create hardware at elaboration time, not at runtime. `generate for` unrolls into parallel hardware."

## 🔑 Key Insight

"`generate` doesn't loop at runtime — it creates hardware at synthesis time. A `generate for` with N=4 creates 4 physical instances, not one instance used 4 times."

## 🤖 Check the Machine

"Prompt AI to generate a parameterized N-bit comparator with `generate`. Does it use `generate` correctly? Synthesize at WIDTH=8, 16, 32 and compare `yosys stat` — is area scaling linear?"

## 🔗 Transfer

"Tomorrow: memory — where your data lives. ROM, RAM, and the coding patterns that make Yosys infer block RAM instead of burning all your LUTs."

---

## Visit/Activity Connection

**Evening: Cooking Workshop** — A recipe is sequential (step by step). A kitchen with multiple cooks is parallel — like HDL.

---

---

[:material-arrow-left: Back to Barcelona Day Plan](../index.md){ .md-button }
&nbsp;
[:material-book-open-variant: Baseline D8 Materials](../../days/day08/plan.md){ .md-button .md-button--primary }

*This overlay supplements the [baseline D8 daily plan](../../days/day08/plan.md). All lab exercises and lecture content come from the baseline D8 materials.*
