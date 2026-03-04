# AI Constraint-Based Testbench — Day 14, Exercise 3

## Objective (SLO 14.3, 14.6)
Write a constraint specification for your **final project's core module**, use AI to
generate a testbench from the spec, then critically review and correct the output.

## Time: ~25 minutes

## Instructions

### Step 1: Write the Constraint Specification (10 min)

Use the template below. Fill in every section for your project's core module.
**The quality of your spec determines the quality of the AI output.**

```
MODULE SPECIFICATION
====================
Module name:
File:
Port list (name, direction, width):
  -
  -
  -
Parameters (name, default, meaning):
  -

BEHAVIORAL SPECIFICATION
========================
What does this module do? (2-3 sentences)


STIMULUS CONSTRAINTS
====================
Input ranges:
  - signal_name: [min, max] or {legal values}
  -

Signal relationships:
  - "If X is asserted, Y must be stable for N cycles before..."
  -

Timing requirements:
  - "Clock period: N ns"
  - "Reset held for N cycles before first stimulus"

CORNER CASES TO TEST
====================
(List at least 5 specific scenarios)
1.
2.
3.
4.
5.

COVERAGE GOALS
==============
  - "Test at least N cases of [scenario]"
  - "All opcodes/states must be exercised"
  - "Boundary values: 0, 1, max-1, max"

SELF-CHECKING REQUIREMENTS
==========================
  - How to compute expected output in the testbench
  - Pass/fail reporting format
  - Summary statistics at end (pass_count, fail_count)

TOOL REQUIREMENTS
=================
  - Language: Verilog or SystemVerilog (specify)
  - Simulator: iverilog -g2012
  - Waveform dump: $dumpfile / $dumpvars
```

### Step 2: Generate with AI (5 min)

Submit your constraint spec to an AI tool (Claude, ChatGPT, Copilot, etc.).
Prompt: "Generate a self-checking testbench from this constraint specification.
Use iverilog-compatible syntax with -g2012 flag."

### Step 3: Review, Correct, and Annotate (10 min)

Evaluate the AI output against your spec:

| Check | Pass? | Notes |
|-------|-------|-------|
| Correct module instantiation? | | |
| All parameters handled? | | |
| Uses $urandom_range() for constrained random? | | |
| Tests the 5+ corner cases you specified? | | |
| Self-checking with expected vs actual? | | |
| Reports pass/fail counts? | | |
| Compiles with iverilog -g2012? | | |
| Waveform dump included? | | |

Fix any issues. Add comments explaining each correction:
```verilog
// FIXED: AI used 'logic' in module-level scope, changed to 'reg' for iverilog
// FIXED: AI hardcoded WIDTH=8 instead of using parameter override
// FIXED: AI didn't test corner case #3 (reset during operation)
```

### Step 4: Run and Evaluate

```bash
iverilog -g2012 -o sim.vvp tb_your_module.sv your_module.sv
vvp sim.vvp
```

Document coverage gaps: after running, which scenarios from your spec were
tested well? Which were missed or tested incorrectly?

## Deliverable

Submit all four artifacts:
1. **Constraint specification** (filled-in template above)
2. **Raw AI output** (unmodified)
3. **Corrected testbench** with annotations explaining every change
4. **Coverage analysis** (2-3 sentences): what was tested, what was missed

## Grading Note

Grading distinguishes **prompt quality** from **review quality**.
A precise spec + thorough corrections > vague spec + uncritical acceptance.
