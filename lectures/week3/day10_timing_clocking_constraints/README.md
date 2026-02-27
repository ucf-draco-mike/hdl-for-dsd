# Day 10: Timing, Clocking & Constraints

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | The Physics of Timing | ~15 min | `seg1_physics_of_timing.html` |
| 2 | Timing Constraints & Reports | ~12 min | `seg2_timing_constraints_reports.html` |
| 3 | The iCE40 PLL | ~12 min | `seg3_ice40_pll.html` |
| 4 | Clock Domain Crossing | ~11 min | `seg4_clock_domain_crossing.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/top_pll_demo.v` | PLL instantiation: 25 MHz → 50 MHz |

## Key Concepts
- Setup time, hold time, propagation delay
- Critical path, slack (positive = pass, negative = fail)
- `--freq 25` on nextpnr for timing analysis
- `icepll` tool and `SB_PLL40_CORE` primitive
- Clock domain crossing: 2-FF sync, Gray code, avoidance
