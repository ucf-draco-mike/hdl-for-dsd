[**:material-arrow-left: Back to Barcelona Day Plan**](../index.md){ .md-button }

# CRAFT Overlay — D10 — Timing, Numerical Architectures & PPA

**Date:** Mon 6/8

---

## 🌍 Contextualize

"Every interface you'll build this week depends on timing. The Barcelona Metro you'll visit next week runs on precisely timed digital control — a missed deadline means a safety stop."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: faster clock = better. **Reframe:** Your design has a maximum clock frequency (Fmax) determined by the longest combinational path. Timing closure means every path must meet setup and hold constraints."

## 🔑 Key Insight

"PPA — Power, Performance, Area — is the fundamental trade-off in all digital design. You can always trade area for speed (pipeline) or speed for area (resource sharing). `yosys stat` + `nextpnr` Fmax give you the numbers."

## 🤖 Check the Machine

"Synthesize two versions of a multiplier: combinational (`a * b`) and shift-and-add (sequential FSM). Compare PPA. Which wins on area? Which on Fmax? When would you choose each?"

## 🔗 Transfer

"Tomorrow: UART — your first communication interface. You'll use everything: FSMs, counters, shift registers, and timing."

---

---

[:material-arrow-left: Back to Barcelona Day Plan](../index.md){ .md-button }
&nbsp;
[:material-book-open-variant: Baseline D10 Materials](../../days/day10/){ .md-button .md-button--primary }

*This overlay supplements the [baseline D10 daily plan](../../days/day10/). All lab exercises and lecture content come from the baseline D10 materials.*
