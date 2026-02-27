# Day 3: Procedural Combinational Logic

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The `always @(*)` Block | ~12 min | `seg1_always_star_block.html` |
| 2 | `if/else` and `case` | ~15 min | `seg2_if_else_and_case.html` |
| 3 | The Latch Problem | ~12 min | `seg3_the_latch_problem.html` |
| 4 | Blocking vs. Nonblocking | ~6 min | `seg4_blocking_vs_nonblocking.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/latch_demo.v` | Intentional latch — synthesize and see Yosys warning |
| `code/latch_fixed.v` | Fixed version using default assignment pattern |
| `code/alu_4bit.v` | 4-bit ALU demonstrating case statement pattern |

## Key Concepts

- `always @(*)` for combinational procedural blocks — **never** use manual sensitivity lists
- `if/else` → priority mux chain; `case` → parallel mux; `casez` → don't-care matching
- **Latch prevention:** default assignment, complete else chains, default case
- Blocking `=` for combinational, nonblocking `<=` for sequential (rule preview)

## Pre-Class Quiz

See `quiz.md` — 4 questions covering all 4 segments.
