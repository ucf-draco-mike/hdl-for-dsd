# Day 6: Testbenches & Simulation-Driven Development

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Testbench Anatomy | ~12 min | `d06_s1_testbench_anatomy.html` |
| 2 | Self-Checking Testbenches | ~15 min | `d06_s2_self_checking_testbenches.html` |
| 3 | Tasks for Organization | ~10 min | `d06_s3_tasks_for_organization.html` |
| 4 | File-Driven & Sequential Testing | ~13 min | `d06_s4_file_driven_testing.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day06_ex01_tb_alu_template.v` | Complete self-checking ALU testbench with tasks and summary report |

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
day06_testbenches_simulation_driven_development/
├── d06_s1_testbench_anatomy.html
├── d06_s2_self_checking_testbenches.html
├── d06_s3_tasks_for_organization.html
├── d06_s4_file_driven_testing.html
├── code/
│   └── day06_ex01_tb_alu_template.v
├── diagrams/
│   ├── d06_sim_first_workflow.svg
│   └── d06_tb_architecture.svg
├── day06_quiz.md
└── day06_readme.md
```
