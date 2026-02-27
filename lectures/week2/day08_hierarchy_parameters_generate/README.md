# Day 8: Hierarchy, Parameters & Generate

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Module Hierarchy Deep Dive | ~12 min | `seg1_module_hierarchy.html` |
| 2 | Parameters & Parameterization | ~15 min | `seg2_parameters_parameterization.html` |
| 3 | Generate Blocks | ~12 min | `seg3_generate_blocks.html` |
| 4 | Design for Reuse | ~6 min | `seg4_design_for_reuse.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/parallel_debounce.v` | Generate-based N-button debouncer |

## Key Concepts
- Hierarchy for complexity management, descriptive naming
- `parameter` (configurable) vs. `localparam` (internal/derived)
- `$clog2()` for automatic width sizing
- `generate for` — hardware replication at elaboration time
- `generate if` — conditional hardware inclusion
- Module reuse checklist: parameterized, tested, documented
