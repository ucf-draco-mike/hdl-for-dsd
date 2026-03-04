# Day 15: Final Project — Build Day

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 15 of 16

---

## Student Learning Objectives

1. **SLO 15.1:** Integrate multiple modules into a complete, working system on the Go Board.
2. **SLO 15.2:** Apply the simulation-first workflow to debug integration issues before programming hardware.
3. **SLO 15.3:** Produce at least one testbench (manual or AI-assisted) for a core project module.
4. **SLO 15.4:** Generate a PPA snapshot (`yosys stat` + Fmax) and assess resource utilization.
5. **SLO 15.5:** Prepare a concise demonstration of the project's functionality and design decisions.

---

## Pre-Class Preparation (no video)

There is no pre-class video for Day 15. Instead, students should arrive prepared with:

1. **Project plan status:** Which modules are complete? Which still need work?
2. **Integration plan:** What is the top-module structure? Which modules connect to which?
3. **Testing strategy:** Which modules have testbenches? Which still need verification?
4. **Known blockers:** Any unresolved bugs or design questions?

> Students should have their development environment set up and ready before class. All toolchain issues should have been resolved by now.

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Project check-in: quick stand-up (each student: progress, plan, blockers) | 15 min |
| 0:15 | Focused project work — Block 1 | 60 min |
| 1:15 | Break | 5 min |
| 1:20 | Focused project work — Block 2 | 55 min |
| 2:15 | Wrap-up: deliverable check, Day 16 demo format review | 15 min |

---

## Mini-Lecture: Project Check-In & Debugging Strategies (15 min)

### Quick Stand-Up (10 min)
- Each student briefly states (30–45 seconds each):
  - What's working
  - What they're working on today
  - Any blockers
- Instructor triages: common issues addressed to the group, individual issues noted for 1-on-1 help

### Debugging Strategies Reminder (5 min)
- **Divide and conquer:** Simulate each module independently before integrating
- **Simulation first, always:** If it doesn't work in simulation, don't waste time programming the board
- **Use assertions:** Add `assert` statements to catch integration bugs at the source
- **Check pin assignments:** The `.pcf` file is the most common source of "works in simulation, fails on hardware"
- **Integration tip:** Test each module with a minimal top-level wrapper before building the full system

### Final Project Deliverables Reminder
The final project submission (due Day 16) must include:

1. **Working hardware demo** — live demonstration during class
2. **Source code** — all Verilog/SystemVerilog source files, organized and commented
3. **Manual testbench** — for at least one core module, hand-written
4. **AI-assisted testbench** — for at least one module, with prompt + annotated corrections
5. **PPA report** — `yosys stat` resource summary, Fmax from `nextpnr`, and a brief design trade-off discussion (see Day 14 Exercise 4 for the format)
6. **Brief README** — project description, block diagram, instructions to build and test

---

## Lab: Dedicated Project Work Time (~2 hrs 15 min)

### Work Block 1 (60 min)

Focus areas (suggested priorities):
1. **Complete any unfinished modules.** If a module isn't passing simulation, fix it before integrating.
2. **Integration:** Wire modules together in the top-level file. Use named port connections.
3. **Testbench completion:** Ensure at least one manual and one AI-assisted testbench are done.

**Instructor circulates** for 1-on-1 debugging and design review.

### Work Block 2 (55 min)

Focus areas (suggested priorities):
1. **Hardware testing:** Program the board. Verify the system works on hardware.
2. **PPA snapshot:** Run `yosys stat` on the final design. Record LUTs, FFs, EBRs. Run `nextpnr` and note Fmax and utilization percentage.
3. **Polish:** Comment your code. Write the project README. Prepare your demo talking points.

**Peer collaboration encouraged** — students can help each other debug. Hardware debugging is often faster with a second pair of eyes.

---

## Deliverable

By end of Day 15, submit (or be prepared to submit on Day 16):

1. **Working prototype** — demonstrable on the Go Board, or demonstrable progress with a clear plan for completion
2. **Testbench** — at least one core module verified (manual or AI-assisted)
3. **PPA snapshot** — `yosys stat` output + Fmax from `nextpnr`

> Students who are not yet at a working prototype should have a clear plan and have completed simulation of all individual modules.

---

## Assessment Mapping

| Activity | SLOs Assessed | Weight |
|----------|---------------|--------|
| Module integration | 15.1, 15.2 | Part of final project (25%) |
| Testbench completion | 15.3 | Part of final project |
| PPA snapshot | 15.4 | Part of final project |
| Demo preparation | 15.5 | Part of final project |
| Participation & collaboration | — | Participation (10%) |

---

## Common Issues & Instructor Notes

- **Scope creep:** Students who chose ambitious projects may be behind. Help them identify a "minimum viable demo" — what's the simplest version that demonstrates the core concept? They can describe planned extensions during the demo.
- **Pin assignment errors:** The most common "works in sim, fails on board" issue. Have students double-check every pin in the `.pcf` against the Go Board schematic.
- **Clock domain issues:** Students integrating UART with other logic may hit timing issues if they haven't synchronized external signals. Remind them: any signal from outside the FPGA (buttons, UART RX) must pass through a synchronizer.
- **Students who are stuck:** If a student has a fundamental design flaw, help them simplify. A working simple project is better than a broken complex one.
- **PPA report shortcuts:** Some students will just paste `yosys stat` output without analysis. Remind them: the numbers alone are worth partial credit, but the discussion of trade-offs is what demonstrates understanding.
- **Peer help dynamics:** Encourage students who finish early to help others. Debugging someone else's design is excellent learning.

---

## Preview: Day 16

Demo day. Each student presents their project in 5–7 minutes: 1 minute of context, live hardware demo, show key testbench/waveforms, discuss one design trade-off, show AI-assisted testbench with corrections, and share `yosys stat` utilization. Followed by course wrap-up and "where to go from here."
