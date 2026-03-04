# Day 14: Verification Techniques, AI-Driven Testing & PPA Analysis

## Pre-Class Videos (~55 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Assertions — Executable Specifications | ~12 min | `d14_s1_assertions.html` |
| 2 | AI-Driven Verification Workflows | ~15 min | `d14_s2_ai_verification_workflows.html` |
| 3 | PPA Analysis Methodology | ~12 min | `d14_s3_ppa_methodology.html` |
| 4 | Coverage & the Road Ahead | ~11 min | `d14_s4_coverage_road_ahead.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day14_ex01_uart_tx_assertions.sv` | UART TX with immediate assertions (retained from v1) |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d14_verification_pyramid.svg` | Verification maturity scale (retained from v1) |

## Key Concepts
- Immediate assertions: `assert (condition) else $error(...)` — inline design checks
- Concurrent assertions (brief): `assert property`, `|->`, `|=>` implication operators
- Verification productivity stack: manual → self-checking → AI-scaffolded → assertion-enhanced → coverage-driven
- Constraint-based stimulus: `$urandom_range()`, bounded random, constraint specs for AI
- PPA report template: resource table + Fmax + analysis paragraph per comparison
- Design-space exploration: sweep parameters, plot area/timing curves
- ASIC PPA context: gate count, Liberty files, OpenROAD/OpenLane
- Functional coverage: covergroup, coverpoint, bins (conceptual — not supported in iverilog)
- Industry verification landscape: UVM, formal, AI-assisted workflows

## Changes from Previous Version

Segments 2 and 3 replaced. Previously covered concurrent assertions and functional
coverage as full segments. Now covers AI-driven verification workflows and PPA
analysis methodology, matching the curriculum doc plan. Concurrent assertion details
merged into Segment 1; coverage concepts merged into Segment 4.

## Directory Structure

```
lectures/week4_day14/
├── d14_s1_assertions.html                  (retained, breadcrumbs updated)
├── d14_s2_ai_verification_workflows.html   (NEW)
├── d14_s3_ppa_methodology.html             (NEW)
├── d14_s4_coverage_road_ahead.html         (NEW)
├── code/
│   └── day14_ex01_uart_tx_assertions.sv    (retained)
├── diagrams/
│   └── d14_verification_pyramid.svg        (retained)
├── day14_quiz.md                           (updated)
└── day14_readme.md                         (this file)
```
