# Day 10: Numerical Architectures & Design Trade-offs

## Pre-Class Videos (~55 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Timing & Constraints Essentials | ~15 min | `d10_s1_timing_essentials.html` |
| 2 | Numerical Architecture Trade-offs | ~20 min | `d10_s2_numerical_architectures.html` |
| 3 | PPA — Performance, Power, Area | ~15 min | `d10_s3_ppa_intro.html` |
| 4 | Open-Source ASIC PPA (Aspirational) | ~5 min | `d10_s4_asic_ppa_context.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/day10_adder_widths.v` | Behavioral adder at 4/8/16/32-bit widths for LUT scaling demo |
| `code/day10_mult_widths.v` | Combinational multiplier at 4/8/16-bit widths for LUT explosion demo |

## Diagrams

| File | Description |
|------|-------------|
| `diagrams/d10_critical_path.svg` | Critical path: FF A → combinational logic → FF B with timing equation |
| `diagrams/d10_pipeline_fix.svg` | Before/after pipelining: long chain → parallel stages |
| `diagrams/d10_ppa_triangle.svg` | PPA trade-off triangle: Performance ↔ Power ↔ Area |

## Key Concepts
- Setup time, hold time, critical path, slack (positive = pass, negative = fail)
- `--freq 25` on nextpnr enables timing analysis
- Adder architectures: ripple-carry (O(N)) vs CLA (O(log N)) vs behavioral `+` (tool-chosen)
- Multiplier: combinational `*` = O(N²) LUTs on iCE40 (no DSP blocks!)
- Sequential shift-and-add: O(N) LUTs, N cycles latency — area vs. latency trade-off
- Fixed-point Q-format: Q4.4 × Q4.4 = Q8.8, extract bits carefully
- PPA proxies: Fmax (performance), LUT/FF count (area), toggle rate (power)
- Structured PPA reporting: comparison tables + written analysis
- Design-space exploration: synthesize at multiple parameters, plot curves
- OpenROAD/OpenLane: same Verilog, real ASIC PPA metrics

## Directory Structure

```
lectures/week3_day10/
├── d10_s1_timing_essentials.html
├── d10_s2_numerical_architectures.html
├── d10_s3_ppa_intro.html
├── d10_s4_asic_ppa_context.html
├── code/
│   ├── day10_adder_widths.v
│   └── day10_mult_widths.v
├── diagrams/
│   ├── d10_critical_path.svg
│   ├── d10_pipeline_fix.svg
│   └── d10_ppa_triangle.svg
├── day10_quiz.md
└── day10_readme.md
```

## Changes from Previous Version

This is a **major content realignment**. The previous version of Day 10 lectures
covered Timing, Clocking & Constraints (PLLs, CDC) as 4 full segments. That content
has been condensed into Segment 1 (~15 min), and the remaining 3 segments now cover
the curriculum-specified topics: numerical architectures, PPA introduction, and ASIC
context. PLL and CDC exercises are available as stretch content in the lab.
