# Day 16: Final Project Demo Rubric

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
| **Excellent** | Full project scope working on hardware. All features functional. Handles edge cases. |
| **Good** | Core functionality on hardware. Most features present. Minor edge-case issues. |
| **Adequate** | Minimum viable demo on hardware. Some features incomplete but core idea demonstrated. |
| **Developing** | Simulation works but hardware has issues. Or: partial functionality on hardware. |
| **Incomplete** | Neither simulation nor hardware demonstrates the intended functionality. |

### Design Quality (25%)

| Level | Criteria |
|---|---|
| **Excellent** | Clean hierarchy. Appropriate FSMs, parameterization, module reuse. SystemVerilog features used. |
| **Good** | Clear architecture. Most modules well-structured. Minor code quality issues. |
| **Adequate** | Design works but has structural issues (everything in one module, magic numbers). |
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

## Questions to Ask During Demos

**Design:** Why this architecture? What's on the critical path? How many LUTs/FFs? Where would feature X go?

**Verification:** Most subtle bug found? Hardest thing to test? What would you add with more time?

**Reflection:** Most surprising thing learned? What would you redo? Most useful technique going forward?
