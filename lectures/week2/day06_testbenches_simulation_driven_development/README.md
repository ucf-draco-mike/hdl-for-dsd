# Day 6: Testbenches & Simulation-Driven Development

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Testbench Anatomy | ~12 min | `seg1_testbench_anatomy.html` |
| 2 | Self-Checking Testbenches | ~15 min | `seg2_self_checking_testbenches.html` |
| 3 | Tasks for Organization | ~10 min | `seg3_tasks_for_organization.html` |
| 4 | File-Driven Testing | ~13 min | `seg4_file_driven_testing.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/tb_alu_template.v` | Complete self-checking ALU testbench with tasks and reporting |

## Key Concepts
- Testbench structure: `timescale`, clock gen, `$dumpfile/$dumpvars`, `$finish`
- Self-checking: `===`/`!==`, pass/fail counting, summary report
- Tasks for reusable stimulus/check procedures
- `$readmemh`/`$readmemb` for file-driven testing
- Sequential testbench patterns: `@(posedge clk)`, `repeat`, `wait_cycles`
