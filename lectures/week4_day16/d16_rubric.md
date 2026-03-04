# Final Project Demo Rubric
## Day 16 — Accelerated HDL for Digital System Design

---

## Demo Format (5–7 minutes per student)

1. **Introduction** (30 sec): Project name, one-sentence description
2. **Live demo** (2 min): Show it working on the Go Board
3. **Architecture** (1–2 min): Block diagram, data path, module reuse
4. **Verification** (1 min): Testbench output, assertions, what's tested
5. **Reflection** (1 min): Most interesting challenge? What would you change?
6. **Q&A** (remaining time)

---

## Evaluation Criteria

### Functionality (30%)

| Level | Criteria |
|---|---|
| **Excellent** | Full scope on hardware. All features. Handles edge cases. |
| **Good** | Core functionality on hardware. Most features present. Minor edge issues. |
| **Adequate** | Minimum viable demo on hardware. Core idea demonstrated. |
| **Developing** | Simulation works but hardware issues. Or: partial hardware functionality. |
| **Incomplete** | Neither simulation nor hardware demonstrates intended functionality. |

### Design Quality (25%)

| Level | Criteria |
|---|---|
| **Excellent** | Clean hierarchy. Appropriate FSMs, parameterization, module reuse. SV features used well. |
| **Good** | Clear architecture. Most modules well-structured. Minor code quality issues. |
| **Adequate** | Works but has structural issues (monolithic module, magic numbers). |
| **Developing** | Hardcoded values, no hierarchy, copy-paste code. |

### Verification (20%)

| Level | Criteria |
|---|---|
| **Excellent** | Self-checking TBs for all custom modules. Assertions present. Coverage awareness. |
| **Good** | Self-checking TBs for core modules. Basic assertions or clear test strategy. |
| **Adequate** | Testbenches exist but not fully self-checking. Some manual verification. |
| **Developing** | Minimal testbenching. Relies primarily on hardware testing. |

### Integration (15%)

| Level | Criteria |
|---|---|
| **Excellent** | Clean top module. Proper debouncing. Correct CDC handling. No synthesis warnings. |
| **Good** | Organized top module. Most integration clean. Minor warnings acceptable. |
| **Adequate** | Working integration but messy (unnecessary signals, workarounds). |
| **Developing** | Integration incomplete or has fundamental issues. |

### Presentation (10%)

| Level | Criteria |
|---|---|
| **Excellent** | Clear, confident explanation. Honest reflection. Good use of time. |
| **Good** | Solid explanation. Reasonable reflection. Within time. |
| **Adequate** | Gets the point across. Some difficulty explaining decisions. |
| **Developing** | Unclear explanation. No reflection. Over/under time. |

---

## Questions You May Be Asked

**Design:** Why this architecture? What's on the critical path? How many LUTs/FFs? Where would feature X go?

**Verification:** Most subtle bug found? Hardest thing to test? What would you add with more time?

**Reflection:** Most surprising thing learned? What would you redo? What's the one thing from this course you'll use most?

---

## Backup Plan

If hardware fails during the demo: show simulation waveforms, explain the architecture, and articulate why hardware didn't work. Partial credit is full credit for verified simulation with a clear explanation.
