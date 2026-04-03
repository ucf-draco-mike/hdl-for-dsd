[**:material-arrow-left: Back to Barcelona Day Plan**](../index.md){ .md-button }

# CRAFT Overlay — Demo Day — Demos & Course Wrap

**Date:** Thu 6/18

---

## 🌍 Contextualize

"Four weeks ago you wired your first LED. Since then you've built FSMs, serial interfaces, memories, and a complete project — the same building blocks powering the Metro, the chips at Semidynamics, and the verification infrastructure at HP. Today you demonstrate what you built."

## ⚠️ Reframe

"If You're Thinking Like a Student: the demo is a test. **Reframe:** The demo is a design review. Engineers present trade-offs, not just results. Explain *why* you chose your architecture, not just *what* it does."

## 🔑 Key Insight

"A well-understood partial project demonstrates more learning than a working project you can't explain. If something broke, explain what should have happened and how you'd debug it — that's engineering."

## 🤖 Check the Machine

"In your demo, show one AI-generated testbench. Highlight the most significant correction you made. This demonstrates verification judgment — the skill that separates an engineer from a prompt user."

## 🔗 Transfer

"This course gave you RTL fluency, verification discipline, and PPA intuition. Where you go next — UVM, formal verification, ASIC tapeout, RISC-V cores — depends on you. The Go Board is yours. Keep building."

---

## Demo Day Structure

Each person: **5 minutes** + brief Q&A.

| Segment | Time | What to Show |
|---------|------|-------------|
| Context | 1 min | What does your project do? |
| Live demo | 1–2 min | Running on the Go Board |
| Testbench | 1 min | Key waveform or assertion result |
| Design trade-off | 1 min | One architectural decision and why |
| PPA + AI workflow | 30 sec | `yosys stat` snapshot + AI TB correction |
| Lessons learned | 30 sec | One surprise, one thing you'd change |

See the [Barcelona Project Spec](../../barcelona-project.md) for the full demo rubric and submission checklist.

---

## Final Submission Checklist

| Item | Required? |
|------|-----------|
| Source code (`.v` / `.sv` files) | Required |
| Constraint file (`.pcf`) | Required |
| Manual testbench (core module) | Required |
| AI-assisted testbench (prompt + output + corrections) | Required |
| PPA report (`yosys stat` + Fmax + trade-off discussion) | Required |
| README (description, block diagram, build instructions) | Required |
| Waveform screenshots | Recommended |

---

[:material-arrow-left: Back to Barcelona Day Plan](../index.md){ .md-button }
&nbsp;
[:material-clipboard-check: Project Spec](../../barcelona-project.md){ .md-button .md-button--primary }
&nbsp;
[:material-book-open-variant: Baseline D16 Materials](../../days/day16/){ .md-button }

*This overlay supplements the [baseline D16 daily plan](../../days/day16/). See the [Barcelona Project Spec](../../barcelona-project.md) for deliverables and rubric.*
