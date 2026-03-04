# Final Project Demo Rubric

## Demo Format (5–7 min)
1. Introduction (30 sec) — project name, one sentence
2. Live demo (2 min) — show it working on the Go Board
3. Architecture (1–2 min) — block diagram, design decisions
4. Verification (1 min) — testbench results, assertions
5. Reflection (1 min) — challenges, what you'd change
6. Q&A (remaining)

---

## Functionality (30%)

| Level | Criteria |
|-------|---------|
| **Excellent (27–30)** | Full scope on hardware. All features work. Handles edge cases. |
| **Good (21–26)** | Core functionality on hardware. Most features present. Minor edge issues. |
| **Adequate (15–20)** | Minimum viable demo on hardware. Some features incomplete. |
| **Developing (9–14)** | Simulation works but hardware has issues. Partial functionality. |
| **Incomplete (0–8)** | Neither simulation nor hardware demonstrates intended function. |

## Design Quality (25%)

| Level | Criteria |
|-------|---------|
| **Excellent (23–25)** | Clean hierarchy. Appropriate FSMs, parameters, module reuse. SV features used where helpful. |
| **Good (17–22)** | Clear architecture. Most modules well-structured. Minor code quality issues. |
| **Adequate (13–16)** | Works but has structural issues (monolithic module, magic numbers). |
| **Developing (7–12)** | Significant problems: hardcoded values, no hierarchy, copy-paste code. |
| **Incomplete (0–6)** | No clear design structure. |

## Verification (20%)

| Level | Criteria |
|-------|---------|
| **Excellent (18–20)** | Self-checking TBs for all custom modules. Assertions present. Coverage awareness. |
| **Good (14–17)** | Self-checking TBs for core modules. Basic assertions or clear test plan. |
| **Adequate (10–13)** | Testbenches exist but not fully self-checking. Some manual verification. |
| **Developing (6–9)** | Minimal testbenching. Primarily hardware testing. |
| **Incomplete (0–5)** | No testbenches. |

## Integration (15%)

| Level | Criteria |
|-------|---------|
| **Excellent (14–15)** | Clean top module. Proper debounce. Correct CDC. No synthesis warnings. |
| **Good (11–13)** | Organized top module. Minor warnings acceptable. |
| **Adequate (8–10)** | Working but messy (unnecessary signals, workarounds, commented-out code). |
| **Developing (4–7)** | Integration incomplete or has fundamental issues (multi-driven nets). |
| **Incomplete (0–3)** | Not integrated. |

## Presentation (10%)

| Level | Criteria |
|-------|---------|
| **Excellent (9–10)** | Clear, confident explanation. Honest reflection. Good time management. |
| **Good (7–8)** | Solid explanation. Reasonable reflection. Within time. |
| **Adequate (5–6)** | Gets point across. Some difficulty explaining decisions. |
| **Developing (3–4)** | Unclear explanation. No reflection. Over/under time significantly. |
| **Incomplete (0–2)** | Did not present. |

---

## Questions for the Instructor to Ask

**Design:** Why this architecture over alternatives? What's your critical path?
How many LUTs/FFs? Where would feature X go?

**Verification:** Most subtle bug found? Hardest thing to test? What would you
add with more time?

**Reflection:** Most surprising thing learned? What would you redo?

---

## Backup Plan

If hardware fails during the demo: show simulation waveforms, explain the
architecture, and articulate *why* the hardware didn't work. The failure itself
is often instructive. Partial credit is full credit for verified simulation
with clear explanation.
