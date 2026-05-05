# Day 6: Testbenches & Simulation-Driven Development

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Testbench Anatomy | ~12 min | `d06_s1_testbench_anatomy.html` |
| 2 | Self-Checking Testbenches | ~15 min | `d06_s2_self_checking_testbenches.html` |
| 3 | Tasks for Organization | ~10 min | `d06_s3_tasks_for_organization.html` |
| 4 | File-Driven & Sequential Testing | ~13 min | `d06_s4_file_driven_testing.html` |

## Code Examples

All four Day-6 Live Demos converge on a single example directory
(`lecture_examples/week2_day06/d06_s1_ex1/`) — the demo *is* the
testbench, evolving across the four slide segments.

| Slide  | File(s) | Description |
|--------|---------|-------------|
| `d06_s1` | `adder.v`, `tb_adder.v`                          | DUT plus the bare-bones, print-only testbench built from scratch |
| `d06_s2` | `tb_adder_before.v`, `tb_adder_after.v`          | Print-only "before" and self-checking "after" snapshots |
| `d06_s3` | `tb_before.v`, `tb_after.v`                      | Monolithic 12-case TB and the task-refactored equivalent |
| `d06_s4` | `gen_vectors.py`, `vectors.hex`, `tb_adder_file.v` | 1000-vector file-driven test (`vectors.hex` is generated) |
| Lab     | `day06_ex01_tb_alu_template.v`                    | Self-checking ALU testbench template — seed for the lab deliverable |

Quick recipe (from inside the example dir):
```bash
make sim                      # default = tb_adder_after.v (s2 result)
make sim TB=tb_adder.v        # the s1 "from scratch" snapshot
make sim TB=tb_before.v       # the s3 monolith
make sim TB=tb_after.v        # the s3 task-based refactor
make sim_file                 # generates vectors.hex, runs tb_adder_file.v
make sim_alu                  # runs the ALU template testbench
```

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d06_sim_first_workflow.svg` | Simulate → Pass? → Synthesize → Program flowchart |
| `diagrams/d06_tb_architecture.svg` | Testbench architecture: stimulus gen → DUT → self-check → VCD |

## Key Concepts
- Testbench structure: `timescale`, clock gen, `$dumpfile/$dumpvars`, `$finish`
- Self-checking: `===`/`!==`, pass/fail counting, summary report
- Tasks for reusable stimulus/check procedures
- `$readmemh`/`$readmemb` for file-driven testing
- Sequential testbench patterns: `@(posedge clk)`, `repeat`, `wait_cycles`

## Directory Structure

```
lectures/week2_day06/                      # slide decks + day docs
├── d06_s1_testbench_anatomy.html
├── d06_s2_self_checking_testbenches.html
├── d06_s3_tasks_for_organization.html
├── d06_s4_file_driven_testing.html
├── diagrams/
│   ├── d06_sim_first_workflow.svg
│   └── d06_tb_architecture.svg
├── day06_quiz.md
└── day06_readme.md

lecture_examples/week2_day06/              # runnable code for every Live Demo
├── Makefile                               # day-level dispatcher
├── go_board.pcf
└── d06_s1_ex1/                            # all four section TBs live here
    ├── Makefile
    ├── adder.v                            # shared DUT for every Day-6 demo
    ├── tb_adder.v                         # d06_s1
    ├── tb_adder_before.v                  # d06_s2 (before)
    ├── tb_adder_after.v                   # d06_s2 (after, default sim TB)
    ├── tb_before.v                        # d06_s3 (monolith)
    ├── tb_after.v                         # d06_s3 (task-refactored)
    ├── tb_adder_file.v                    # d06_s4 (file-driven)
    ├── gen_vectors.py                     # produces vectors.hex
    └── day06_ex01_tb_alu_template.v       # lab seed (not a Live Demo)
```
