# Accelerated HDL for Digital System Design — Syllabus

## University of Central Florida · Department of Electrical & Computer Engineering

---

## Course Information

| | |
|---|---|
| **Course** | Accelerated HDL for Digital System Design |
| **Format** | 4 weeks · 4 sessions/week · 2.5 hours/session |
| **Delivery** | Flipped classroom — recorded video lectures before class; class time = mini-lecture + hands-on lab |
| **Platform** | Nandland Go Board (Lattice iCE40 HX1K FPGA) |
| **Prerequisites** | Digital logic fundamentals (or concurrent enrollment); programming experience in any language |

---

## Course Description

This accelerated course teaches students to design, simulate, and implement digital systems using the Verilog hardware description language (HDL). Students will progress from basic combinational logic through sequential design, finite state machines, and serial communication interfaces, culminating in an independent project demonstrated on FPGA hardware.

The course uses a fully open-source toolchain (Yosys, nextpnr, Icarus Verilog, GTKWave) and the low-cost Nandland Go Board, ensuring students can continue exploring digital design beyond the classroom.

---

## Learning Outcomes

By the end of this course, students will be able to:

1. Write synthesizable Verilog modules for combinational and sequential logic
2. Apply the hardware design mindset — concurrency, hierarchy, and RTL thinking
3. Use simulation-driven development with self-checking testbenches
4. Design and implement finite state machines using the 3-block coding style
5. Build parameterized, reusable modules with proper hierarchy
6. Implement serial communication interfaces (UART TX/RX)
7. Apply basic SystemVerilog features for improved design and verification
8. Complete an independent digital system project on FPGA hardware

---

## Weekly Schedule

| Week | Theme | Key Topics |
|------|-------|------------|
| **1** | Verilog Foundations | Module syntax, wire/reg, combinational logic, sequential basics |
| **2** | Sequential Design & Verification | Counters, FSMs, testbenches, hierarchy, parameters |
| **3** | Interfaces & Communication | Memory, timing, UART TX/RX, IP integration |
| **4** | SystemVerilog & Project | SV design/verification features, final project |

---

## Flipped Classroom Format

**Before each class:** Watch the pre-class video lecture (40–50 minutes). Complete the embedded self-check quiz. Come to class prepared with questions.

**During class:**
- 0:00–0:05 — Warm-up: clarify video concepts
- 0:05–0:35 — Mini-lecture: key concepts, live coding demos
- 0:35–0:45 — Lab kickoff: objectives, deliverables, hints
- 0:45–2:15 — Hands-on lab: work individually or in pairs, instructor circulates
- 2:15–2:30 — Debrief: common mistakes, preview next session

---

## Required Materials

| Item | Notes |
|------|-------|
| **Nandland Go Board** | ~$65 from nandland.com. You keep it after the course. |
| **USB cable** | Micro-USB (included with Go Board) |
| **Laptop** | Linux, macOS, or Windows with WSL2 |
| **Toolchain** | See `setup_guide.md` — all tools are free and open-source |

---

## Grading

| Component | Weight | Description |
|-----------|--------|-------------|
| Daily lab deliverables | 50% | 12 lab sessions, completion + demonstrated understanding |
| Testbench quality | 15% | Self-checking testbenches with edge-case coverage |
| Final project | 25% | Functionality, design quality, verification, presentation |
| Participation | 10% | Engagement, questions, video preparation, helping peers |

**Grading Scale:** A (90–100), B (80–89), C (70–79), D (60–69), F (<60)

---

## Course Policies

### Attendance
Attendance is expected for all sessions. The hands-on lab component requires in-class participation. If you must miss a session, notify the instructor in advance and arrange to complete the lab independently.

### Collaboration
You are encouraged to discuss concepts and debug together. All submitted Verilog code must be your own work. Sharing code files is not permitted. Cite any external references or resources you use.

### Late Work
Lab deliverables are due at the end of each class session. Late submissions accepted within 24 hours for 80% credit. Beyond 24 hours, arrange with the instructor.

### Academic Integrity
Students are expected to follow UCF's academic integrity policies. Violations will be reported to the Office of Student Conduct.

---

## Resources

- [Nandland.com](https://nandland.com) — Go Board tutorials and FPGA resources
- [fpga4fun.com](https://fpga4fun.com) — FPGA project ideas
- [ZipCPU Blog](https://zipcpu.com) — Advanced FPGA design topics
- [ASIC World Verilog](http://www.asic-world.com/verilog/) — Language reference
- Stuart Sutherland, *Verilog and SystemVerilog Gotchas* — Common pitfalls
