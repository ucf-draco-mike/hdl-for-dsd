# Day 10: Timing, Clocking & Constraints

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The Physics of Timing | ~15 min | `d10_s1_physics_of_timing.html` |
| 2 | Timing Constraints & Reports | ~12 min | `d10_s2_timing_constraints_reports.html` |
| 3 | The iCE40 PLL | ~12 min | `d10_s3_ice40_pll.html` |
| 4 | Clock Domain Crossing | ~11 min | `d10_s4_clock_domain_crossing.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day10_ex01_top_pll_demo.v` | PLL instantiation: 25 MHz → 50 MHz, LOCK indicator |
| `code/day10_ex02_pipeline_demo.v` | Intentional timing violation + pipelined fix (side-by-side) |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d10_critical_path.svg` | Critical path: FF A → combinational logic → FF B with timing equation |
| `diagrams/d10_pipeline_fix.svg` | Before/after pipelining: long chain → parallel stages |
| `diagrams/d10_pll_block.svg` | PLL block diagram: DIVR → PFD → VCO → DIVQ → output |

## Key Concepts
- Setup time, hold time, propagation delay
- Critical path = longest FF-to-FF delay → limits Fmax
- Slack = clock_period − total_delay (positive = pass)
- `--freq 25` on nextpnr enables timing analysis
- `icepll` tool and `SB_PLL40_CORE` primitive
- Clock domain crossing: 2-FF sync (single-bit), Gray code (multi-bit)
- Pipelining: trade latency for throughput (higher Fmax)

## Directory Structure

```
day10_timing_clocking_constraints/
├── d10_s1_physics_of_timing.html
├── d10_s2_timing_constraints_reports.html
├── d10_s3_ice40_pll.html
├── d10_s4_clock_domain_crossing.html
├── code/
│   ├── day10_ex01_top_pll_demo.v
│   └── day10_ex02_pipeline_demo.v
├── diagrams/
│   ├── d10_critical_path.svg
│   ├── d10_pipeline_fix.svg
│   └── d10_pll_block.svg
├── day10_quiz.md
└── day10_readme.md
```
