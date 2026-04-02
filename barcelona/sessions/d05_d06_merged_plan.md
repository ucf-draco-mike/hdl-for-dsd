# Day 5+6 (Merged): Counters, Testbenches & AI Verification

**Date:** Monday, June 1, 2026 · 10:00–12:30
**Baseline days:** D5 (Counters, Shift Registers & Debounce) + D6 (Testbenches & AI-Assisted Verification)
**Pre-class videos:** V5 (Counters/Debounce, 45 min) + V6 (Testbench Anatomy, 55 min) — assigned over weekend
**Afternoon:** Academic visit to Semidynamics (RISC-V processor design), 4:00–5:30 PM

---

## 🌍 Contextualize (10 min)

**"Where This Lives":** "Every digital system counts, shifts, and debounces.
The processor pipelines at Semidynamics — the company you'll visit this
afternoon — are built from the same counters and shift registers you're about
to design. And the testbenches you'll write today? That's how they know their
silicon actually works before they tape out."

**📊 Industry Alignment:** Verification consumes 60–70% of chip development effort.
The AI-assisted approach we introduce today is how the industry is evolving.

---

## ⚠️ Reframe (15 min)

**"If You're Thinking Like a Programmer..."**

1. "Buttons just work → Mechanical contacts bounce for milliseconds.
   You need a saturating counter, not a `delay()` call."
2. "If it simulates, it works → Simulation proves correctness for tested
   cases only. It cannot prove the absence of bugs."

**🔑 Key Insight:** "A testbench is not optional — it's how you know your
design works. Writing it *after* the design is common; writing it *before*
is better."

**❓ No Dumb Questions** (3 min): "What's the dumbest question about
counters or testing you're afraid to ask?"

---

## 👁️🤝🧪 Assemble — Part 1: Sequential Building Blocks (50 min)

### 👁️ I Do (15 min)
Live-code a modular counter (`counter_mod_n`) and debounce circuit.
Show synthesis output — point out flip-flops in the schematic.

**💡 Pattern:** "Parameterized counter" — `parameter MOD = 10` makes this
reusable at any modulus.

### 🤝 We Do (15 min)
Together: add LFSR (linear feedback shift register), wire debounced
buttons to control the counter. Deploy to Go Board — verify count on
7-segment display.

### 🧪 You Do (20 min)
- **Exercise 1:** Design a mod-N counter with configurable modulus.
  Simulate with provided testbench, then deploy to Go Board.
- **Exercise 2:** Build a configurable shift register (serial-in,
  parallel-out). Simulate.
- **Stretch:** LFSR-based pseudo-random number generator on LEDs.

---

## 👁️🤝🧪 Assemble — Part 2: Testbenches & AI Verification (45 min)

### 👁️ I Do (10 min)
Write a self-checking testbench for the mod-N counter:
- `$dumpvars` setup, clock generation
- Expected-vs-actual comparison with pass/fail counters
- Summary message: "X/Y tests passed"

**💡 Pattern:** "Self-checking testbench" — the testbench tells you
pass/fail without you reading waveforms.

### 🤝 We Do (15 min)
Together: prompt an AI to generate a testbench for the debounce module.
- Structured prompt: module interface, expected behavior, edge cases
- Evaluate the AI output: Does it handle bounce timing? Reset?
- Annotate corrections directly in the generated code

**🔑 Key Insight:** "The AI doesn't know your design intent. Your prompt
must specify what 'correct' means."

### 🧪 You Do (20 min)
- **Exercise 3:** Write a manual self-checking TB for your mod-N counter.
- **Exercise 4:** Prompt AI to generate a second TB for the same module.
  Compare: which found more issues? What did each miss? Annotate.
- **Stretch:** AI-generate a TB for the LFSR. Does it check the
  polynomial correctly?

---

## 🔧🤖 Fortify (15 min)

**🔧 What Did the Tool Build?**
Open both TBs in GTKWave side by side. Compare coverage — which
exercised more input combinations?

**🤖 Check the Machine:** "Which TB caught more bugs — yours or the AI's?
Why? What did each miss?" Brief written reflection (3 sentences).

**🧠 How You Learn:** "You wrote the TB *after* building the module.
What would change if you wrote it *before*? That's called test-driven
development — and it works in hardware too."

---

## 🔗 Transfer (10 min)

"You can now build sequential circuits AND verify them — both manually
and with AI assistance. Tomorrow: Finite State Machines — the design
pattern that ties everything together."

**📊 Industry Alignment:** "This afternoon at Semidynamics, ask them:
how much of their RISC-V development time is verification?"

**Homework:** Watch D7 pre-class video (FSM theory, Moore/Mealy, 3-block
pattern, ~50 min).

---

## Lab Exercises Summary

| # | Exercise | Source | Type | Time |
|---|----------|--------|------|------|
| 1 | Mod-N counter | D5 Ex 1 | 🧪 You Do | 10 min |
| 2 | Shift register | D5 Ex 2 | 🧪 You Do | 10 min |
| 3 | Manual TB for counter | D6 Ex 1 | 🧪 You Do | 10 min |
| 4 | AI TB + comparison | D6 Ex 2 | 🧪 You Do | 10 min |
| S1 | LFSR on LEDs | D5 stretch | Stretch | — |
| S2 | AI TB for LFSR | D6 stretch | Stretch | — |

**Starter code:** Use baseline D5 + D6 lab packages. No new starter code needed.
**Deliverable:** Mod-N counter + manual TB + AI-generated TB with annotations.
