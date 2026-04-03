[**:material-arrow-left: Back to Barcelona Day Plan**](../index.md){ .md-button }

# CRAFT Overlay — Build Day — Project Integration & PPA

**Date:** Tue 6/16

---

## 🌍 Contextualize

"Yesterday you walked through the Metro Control Room — real FSMs managing a real city's transit. Today you integrate your own FSMs, counters, and modules into a working system on the Go Board. The same discipline you saw at the Metro — testing before deployment, fail-safe design, structured verification — applies to your build."

## ⚠️ Reframe

"If You're Thinking Like a Programmer: coding is done when it compiles. **Reframe:** In hardware, synthesis is just the beginning. Your design isn't done until it passes assertions, meets timing (Fmax), fits the FPGA (LUTs/FFs), and works on real silicon."

## 🔑 Key Insight

"A PPA snapshot isn't busywork — it's the language engineers use to evaluate designs. When you report LUT count, FF count, and Fmax, you're speaking the same language as the teams at Semidynamics and HP."

## 🤖 Check the Machine

"Use AI to generate a constrained-random testbench for your project's core module. Give it your port list, behavioral spec, and corner cases. Run it. Then ask: what did the AI miss? Document one coverage gap."

## 🔗 Transfer

"Thursday: Demo Day. Lock your code tonight. Practice your 5-minute demo: context → live demo → testbench → trade-off → PPA → AI workflow → lessons learned."

---

## Build Day Checklist

Use today's structured build time to hit every project deliverable:

- [ ] Core module compiles and simulates
- [ ] At least 2 assertions embedded in RTL
- [ ] One AI-generated testbench with annotated corrections
- [ ] `yosys stat` PPA snapshot (LUTs, FFs, utilization %)
- [ ] `nextpnr` Fmax recorded
- [ ] Hardware deployed and tested on Go Board
- [ ] Demo flow rehearsed (5 min)

See the [Barcelona Project Spec](../../barcelona-project.md) for full deliverables and grading rubric.

---

[:material-arrow-left: Back to Barcelona Day Plan](../index.md){ .md-button }
&nbsp;
[:material-clipboard-check: Project Spec](../../barcelona-project.md){ .md-button .md-button--primary }
&nbsp;
[:material-book-open-variant: Baseline D15 Materials](../../days/day15/){ .md-button }

*This overlay supplements the baseline build day. See the [Barcelona Project Spec](../../barcelona-project.md) for project options, timeline, and rubric.*
