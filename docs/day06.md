# Day 6: Testbenches, Simulation & AI-Assisted Verification

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 6 of 16

---

> **Context shift:** During Week 1, you ran provided testbenches with `make sim` and learned to read PASS/FAIL output and VCD waveforms.  Day 6 transitions from **running** testbenches to **writing** them from scratch.  The pre-class video formalizes concepts you've already been using informally (DUT instantiation, stimulus, self-checking assertions) and introduces new techniques (tasks, file-driven testing, AI-assisted generation).

## Student Learning Objectives

1. **SLO 6.1:** Write a complete testbench from scratch: instantiate DUT, generate stimulus, dump waveforms, and terminate simulation.
2. **SLO 6.2:** Build self-checking testbenches with automated pass/fail reporting using `$display` and conditional checks.
3. **SLO 6.3:** Apply the simulation-first workflow: simulate → verify → synthesize → program.
4. **SLO 6.4:** Write effective AI prompts for testbench generation, specifying DUT interface, protocol, corner cases, and self-checking requirements.
5. **SLO 6.5:** Critically review AI-generated Verilog testbenches, identify errors, and correct them before use.

---

## Pre-Class Video (~55 min) ★ Revised lecture

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Testbench anatomy: no ports, instantiate DUT, apply stimulus | 12 min | `video/day06_seg1_testbench_anatomy.mp4` |
| 2 | Simulation mechanics: `initial`, `#` delay, `$finish`, waveform dumping | 12 min | `video/day06_seg2_simulation_mechanics.mp4` |
| 3 | Display, debug & self-checking: `$display`, `$monitor`, pass/fail patterns | 15 min | `video/day06_seg3_self_checking.mp4` |
| 4 | Stimulus strategies: exhaustive, directed, corner-case | 8 min | `video/day06_seg4_stimulus_patterns.mp4` |
| 5 | **AI for Verification — Philosophy & Ground Rules** ★ | 8 min | `video/day06_seg5_ai_verification_intro.mp4` |

**Segment 5 key points:**
- Why AI-assisted testbench generation is a professional skill (industry context)
- The "you can't evaluate what you can't write" rule: manual first, AI second
- Anatomy of a good AI prompt for TB generation (what to specify)
- What AI gets right (boilerplate, structure) vs. what it gets wrong (subtle timing, tool-specific syntax)
- The critical skill: reviewing and debugging AI-generated verification code

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: verification mindset, pre-class questions | 5 min |
| 0:05 | Mini-lecture: self-checking TBs, AI demo | 30 min |
| 0:35 | Lab Exercise 1: Hand-written ALU testbench | 30 min |
| 1:05 | Lab Exercise 2: Make it self-checking | 15 min |
| 1:20 | Break | 5 min |
| 1:25 | Lab Exercise 3: AI-assisted debouncer TB | 30 min |
| 1:55 | Lab Exercise 4: Counter testbench | 20 min |
| 2:15 | Lab Exercise 5 (Stretch): file-based stimulus | 10 min |
| 2:25 | Wrap-up and Day 7 preview | 5 min |

---

## In-Class Mini-Lecture (30 min)

### Verification Mindset — Level Up (5 min)
- Recall Week 1: you've been running `make sim` and reading PASS/FAIL output since Day 1
- Now the question changes: **who wrote those testbenches, and how?**
- Today you learn to write them yourself — the same self-checking patterns you've been relying on
- Why waveform-only verification doesn't scale — self-checking is essential for real projects

### Self-Checking Testbench Patterns (15 min)
- The basic pattern: apply inputs → wait → compare actual vs. expected → report
- `if (dut_out !== expected) $display("FAIL: ...");`
- Use `!==` (not `!=`) to catch X/Z states
- Test counter pattern: track pass/fail counts, report summary at end
- Organizing tests: directed tests for specific operations, then sweep inputs

### AI Testbench Generation — Live Demo (10 min)
- Take the Day 3 ALU module interface
- Live-prompt AI to generate a self-checking testbench
- **Critically review the output together:**
  - What did the AI get right? (Structure, boilerplate, basic stimulus)
  - What did it miss? (Edge cases, specific tool syntax, timing details)
  - What's syntactically wrong for iverilog? (Common: SystemVerilog features in a Verilog context)
- Fix the issues, run it, compare to a hand-written version
- **Key lesson:** AI generates the 80% scaffolding; you provide the 20% domain expertise

### Live Demo Code

All four Day-6 testbench-anatomy demos converge on a single example dir
(`lecture_examples/week2_day06/d06_s1_ex1/`) so the slides can talk about a
single evolving testbench. The dir ships every variant the demos reference:

| Slide  | Title                                           | Files (alongside `adder.v`)                |
|--------|-------------------------------------------------|--------------------------------------------|
| `d06_s1` | Build a Testbench from Scratch               | `tb_adder.v`                               |
| `d06_s2` | Convert "Print" Testbench to Self-Checking   | `tb_adder_before.v`, `tb_adder_after.v`    |
| `d06_s3` | Refactor a Real Testbench (tasks)            | `tb_before.v`, `tb_after.v`                |
| `d06_s4` | 1000-Vector Adder Test (file-driven)         | `gen_vectors.py`, `vectors.hex`, `tb_adder_file.v` |

Quick recipe:
```bash
cd lecture_examples/week2_day06/d06_s1_ex1/
make sim                       # default = tb_adder_after.v
make sim TB=tb_adder.v         # the s1 "from scratch" snapshot
make sim TB=tb_after.v         # the s3 task-refactored snapshot
make sim_file                  # generates vectors.hex, runs the file TB
```

For the canonical Live Demo registry covering every cue in the course, see
[`live_demos.md`](live_demos.md).

---

## Lab Exercises

### Exercise 1: Hand-Written ALU Testbench (30 min)

**Objective (SLO 6.1, 6.3):** Write a complete testbench for the Day 3 ALU from scratch. This exercise is **mandatory before using AI** in Exercise 3.

**Tasks:**
1. Create a testbench file (`alu_tb.v`) that:
   - Instantiates the ALU as DUT
   - Generates stimulus for all opcodes
   - Includes directed test cases: zero inputs, max inputs, overflow conditions
   - Dumps waveforms with `$dumpfile` / `$dumpvars`
2. Run with Icarus Verilog: `iverilog -o alu_tb alu.v alu_tb.v && vvp alu_tb`
3. View waveforms in GTKWave. Verify correctness visually for at least 3 opcodes.

**Checkpoint:** ALU testbench runs, waveforms visible in GTKWave.

---

### Exercise 2: Make It Self-Checking (15 min)

**Objective (SLO 6.2):** Transform the ALU testbench into a self-checking testbench with automated pass/fail.

**Tasks:**
1. Add expected value computation for each test case.
2. Add conditional checks: compare DUT output to expected, report PASS/FAIL with `$display`.
3. Track pass/fail counts. Print a summary at the end: "X/Y tests passed."
4. Re-run. Verify all tests pass. Then intentionally break the ALU (e.g., swap an opcode), re-run, and confirm the testbench catches the bug.

**Checkpoint:** Testbench reports PASS for correct ALU, FAIL for intentionally broken ALU.

---

### Exercise 3: AI-Assisted Debouncer Testbench (30 min)

**Objective (SLO 6.4, 6.5):** Use AI to generate a testbench, then critically review and correct it.

**Tasks:**
1. **Write a prompt** specifying:
   - Module name and interface (ports, parameters)
   - Expected behavior: noisy input → clean output after threshold clock cycles
   - Corner cases to test: rapid toggles, glitches shorter than threshold, long stable periods
   - Self-checking requirements: output must not transition during noise, must transition after stable period
2. **Generate** the testbench using AI (Claude, ChatGPT, Copilot, or other).
3. **Review** the AI output:
   - Does it handle the parameterized threshold correctly?
   - Are the timing delays appropriate for iverilog simulation?
   - Does it actually check the corner cases you specified?
   - Are there any syntax errors or unsupported constructs?
4. **Correct** any issues. Annotate your changes with brief comments explaining what you fixed and why.
5. **Run** the corrected testbench. Verify it catches a deliberately introduced bug (e.g., remove the synchronizer).

**Deliverable for this exercise:** Submit the prompt, raw AI output, and corrected testbench with annotations.

**Checkpoint:** Corrected AI-generated TB runs, catches injected bug.

---

### Exercise 4: Counter Testbench (20 min)

**Objective (SLO 6.1, 6.2):** Practice writing a testbench independently for sequential logic.

**Tasks:**
1. Write a self-checking testbench for the parameterized counter from Day 4/5.
2. Test: reset behavior, count-up sequence, rollover at max value, enable functionality.
3. Run and verify all tests pass.

**Checkpoint:** Counter TB passes all directed tests including rollover.

---

### Exercise 5 (Stretch): File-Based Stimulus (10 min)

**Objective (SLO 6.1):** Load test vectors from a file for organized, repeatable testing.

**Tasks:**
1. Create a `.hex` file with test vectors (input values + expected outputs).
2. Use `$readmemh` to load vectors into an array.
3. Loop through vectors, apply each, check output.

---

## Deliverable

1. **Hand-written self-checking ALU testbench** with pass/fail report (Exercises 1–2).
2. **AI-generated debouncer testbench** with annotated corrections (Exercise 3): submit the prompt, raw AI output, and corrected version.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — ALU TB (hand-written) | 6.1, 6.3 | Core |
| 2 — Self-checking | 6.2 | Core |
| 3 — AI-assisted debouncer TB | 6.4, 6.5 | Core |
| 4 — Counter TB | 6.1, 6.2 | Core |
| 5 — File-based stimulus | 6.1 | Stretch (bonus) |

**Assessment note:** Grading for Exercise 3 distinguishes between "prompt quality" and "review quality." Someone who writes a vague prompt and accepts broken output scores lower than one who writes a precise prompt and catches the AI's errors.

---

## ⚠️ Common Pitfalls & FAQ

> Day 6 is your transition from running testbenches to writing them. These are the gotchas that catch most people.

- **Don't skip the hand-written TB.** Exercise 1 (manual ALU testbench) must be completed before Exercise 3 (AI-assisted). You can't evaluate AI-generated code if you haven't written a TB yourself first — you won't know what's wrong.
- **Using `!=` instead of `!==` in checks?** `!=` treats X as "maybe equal" and can silently pass when it shouldn't. `!==` (identity not-equal) treats X as a definite mismatch. Always use `===` / `!==` in testbench assertions.
- **AI generates SystemVerilog in a Verilog project?** Very common. You'll see `logic` instead of `reg`/`wire`, `always_comb` instead of `always @(*)`, etc. This is a real tool-compatibility issue — Icarus with `-g2012` supports some SV but not all. When reviewing AI output, watch for language-version mismatches.
- **AI-generated testbench misses edge cases?** This is often the most valuable discovery in Exercise 3. If you asked the AI to test "all opcodes" and it only tested ADD and SUB, that's a prompt specificity problem. If it tested all opcodes but missed overflow, that's a coverage gap. Document both.

### 🔗 Bigger Picture

Day 6 establishes the foundation of the AI verification thread that runs through the rest of the course. Today: prompt + review. Day 8: parameterized modules. Day 12: protocol-level TBs. Day 14: constraint-based testing. Each day builds on the judgment you develop here.
---

## Preview: Day 7

Finite State Machines — the design pattern that ties everything together. You'll translate state diagrams to HDL using the 3-always-block style, build a traffic light controller and a pattern detector, and write thorough testbenches to verify every state transition.
