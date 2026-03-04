# Day 16: Final Project Demos & Course Wrap

## Course: Accelerated HDL for Digital System Design
## Week 4, Session 16 of 16

---

## Student Learning Objectives

1. **SLO 16.1:** Deliver a clear, concise technical demonstration of a working FPGA-based system.
2. **SLO 16.2:** Articulate design decisions, trade-offs, and lessons learned during the project.
3. **SLO 16.3:** Present PPA analysis results and explain their implications for the design.
4. **SLO 16.4:** Demonstrate the AI-assisted verification workflow: prompt, generate, review, correct.
5. **SLO 16.5:** Identify pathways for continued learning in digital design, verification, and ASIC development.

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Setup and final preparations | 5 min |
| 0:05 | Student demos (5–7 min each, ~12–15 students) | 90 min |
| 1:35 | Break | 5 min |
| 1:40 | Mini-lecture: where to go from here | 30 min |
| 2:10 | Course retrospective and feedback | 15 min |
| 2:25 | Wrap-up | 5 min |

> **Demo timing note:** For a class of 12–15 students, 90 minutes allows 6–7 minutes per demo including Q&A. If the class is larger, consider reducing to 5 minutes each or splitting into parallel tracks.

---

## Demo Format

Each student presents for **5–7 minutes**, followed by brief Q&A:

### Demo Structure (5–7 min per student)

1. **Context (1 min):** What does your project do? What problem does it solve or demonstrate?

2. **Live hardware demo (1–2 min):** Show the project running on the Go Board. Walk the audience through the inputs and outputs.

3. **Key testbench/waveforms (1 min):** Show a simulation waveform for a critical module. Highlight what the testbench verified.

4. **Design trade-off (1 min):** Discuss one architectural decision:
   - "I chose sequential multiplication over combinational to save LUTs."
   - "I parameterized the baud rate so the same module works at 9600 and 115200."
   - "I used a ROM-based approach instead of combinational logic for the state decoder."

5. **PPA snapshot (30 sec):** Show `yosys stat` resource utilization:
   - "My design uses X LUTs, Y FFs, Z% of the iCE40 HX1K."
   - Fmax from `nextpnr`.

6. **AI-assisted testbench (30 sec):** Briefly show one AI-generated testbench and explain the most significant correction you made.

7. **Lessons learned (30 sec):** One thing you'd do differently. One thing that surprised you.

---

## Demo Rubric

| Criterion | Weight | Excellent | Adequate | Needs Improvement |
|-----------|--------|-----------|----------|-------------------|
| **Working demo** | 30% | Fully functional on hardware, all features demonstrated | Core functionality works, minor issues | Does not run on hardware, simulation only |
| **Code quality** | 15% | Clean hierarchy, consistent style, well-commented, reusable modules | Functional but disorganized | Monolithic, uncommented, difficult to follow |
| **Testbenches** | 20% | Manual + AI-assisted TBs, self-checking, good coverage | At least one TB, basic checks | No testbench or non-functional TB |
| **PPA analysis** | 15% | Comparison table + written trade-off discussion | Resource counts reported, minimal analysis | No PPA data |
| **Presentation** | 10% | Clear, concise, within time, addresses all 7 points | Covers most points, slightly over/under time | Unfocused, missing key elements |
| **AI workflow** | 10% | Quality prompt, annotated corrections, coverage analysis | Prompt + corrections shown | No AI component or uncritical acceptance |

---

## Mini-Lecture: Where to Go From Here (30 min)

### ASIC vs. FPGA Career Paths (5 min)
- FPGA: rapid prototyping, embedded systems, defense, telecommunications, data centers
- ASIC: high-volume consumer electronics, mobile SoCs, custom accelerators
- Both need the same RTL skills — the difference is in the backend flow
- PPA analysis habits from this course transfer directly to ASIC design

### Advanced SystemVerilog & UVM (5 min)
- How today's constraint-based testing maps to UVM concepts:
  - Your constraint specs → UVM sequences
  - Your AI-generated TBs → UVM test library
  - Your assertions → SVA property specifications
  - Your coverage analysis → functional coverage models
- The department's Verification & Validation course — how this course feeds into it

### AI in Professional Verification Workflows (5 min)
- Industry uses AI for:
  - Testbench scaffolding (what you've practiced)
  - Regression debugging: "Why did this test start failing?"
  - Coverage analysis: "What scenarios haven't been tested?"
  - Assertion generation: "What properties should hold for this module?"
- The prompt/generate/review/correct workflow you've practiced is the same loop verification engineers use on production chip projects — the difference is scale, the evaluation skill is identical

### Formal Verification & Beyond (5 min)
- Model checking: mathematically prove properties hold for all possible inputs
- Equivalence checking: prove two designs produce identical outputs
- When formal beats simulation: exhaustive state space exploration
- Tools: commercial (JasperGold, VC Formal) and open-source (SymbiYosys)

### The Open-Source FPGA Ecosystem (5 min)
- SymbiFlow / F4PGA: open-source FPGA toolchains beyond iCE40
- Amaranth HDL: Python-based hardware description
- LiteX: build SoCs from Python, integrating RISC-V cores, memory controllers, peripherals
- OpenROAD/OpenLane: open-source RTL-to-GDSII ASIC flow (the next step from `yosys stat` to real chip tape-out)
- Google/Efabless shuttle program: fabricate real chips from open-source designs

### Immediate Next Steps (5 min)
- Keep the Go Board — keep building
- Suggested projects: VGA display driver, I²C controller, simple CPU, audio synthesizer
- Resources: FPGA4Fun, Nandland tutorials, Lattice documentation
- Open-source community: join the YosysHQ and SymbiFlow communities

---

## Course Retrospective and Feedback (15 min)

### Structured Retrospective (10 min)
- **What worked well?** What teaching methods, labs, or topics were most effective?
- **What was challenging?** Where did you feel lost or overwhelmed?
- **What would you change?** Suggestions for future iterations.
- **AI integration feedback:** Was the AI verification thread helpful? How could it be improved?

### Feedback Collection (5 min)
- Formal course evaluation (if applicable)
- Anonymous feedback form for course improvement

---

## Wrap-Up (5 min)

- Final submissions deadline reminder
- Office hours for remaining questions
- **You keep the Go Board** — it's yours. Build something amazing.

---

## Final Project Submission Checklist

Students should submit (per course_syllabus requirements):

| Item | Description | Required? |
|------|-------------|-----------|
| Source code | All `.v` / `.sv` files, organized in directories | Required |
| Constraint file | `.pcf` for the Go Board | Required |
| Manual testbench | Hand-written TB for at least one core module | Required |
| AI-assisted testbench | Prompt + raw output + corrected version with annotations | Required |
| PPA report | `yosys stat` output + Fmax + utilization + trade-off discussion | Required |
| README | Project description, block diagram, build/test instructions | Required |
| Waveform screenshots | GTKWave captures showing key simulation results | Recommended |
| Makefile | Build automation for simulation and synthesis | Recommended |

---

## Assessment Mapping

| Activity | SLOs Assessed | Weight |
|----------|---------------|--------|
| Live demo | 16.1, 16.2 | Final project (25% of course) |
| Code + testbenches | 16.4 | Final project |
| PPA analysis | 16.3 | Final project |
| Presentation quality | 16.1, 16.2, 16.5 | Final project |
| Retrospective participation | — | Participation (10% of course) |

---

## Common Issues & Instructor Notes

- **Demo anxiety:** Some students will be nervous about live demos. Reassure them that bugs during demos are normal and expected — how they respond to the bug (debugging strategy, explanation of what should happen) is as valuable as a clean demo.
- **Last-minute fixes:** Students may try to make changes right before their demo. Advise against it — "Demo what works, not what you just broke."
- **Time management:** Strictly enforce the 5–7 minute window. Use a visible timer. Students who run over should be gently cut off — this is a professional skill.
- **Peer learning during demos:** Encourage students to take notes on interesting approaches they see in other projects. The Q&A after each demo should be substantive.
- **Incomplete projects:** Some students won't have fully working hardware. This is OK. Grade based on the rubric — a well-documented, well-tested partial implementation with good PPA analysis can score well.
- **Course feedback:** Take the retrospective seriously. Student feedback on the AI integration, pacing, and lab difficulty directly informs the next iteration of the course.
