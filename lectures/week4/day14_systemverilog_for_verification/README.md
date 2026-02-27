# Day 14: SystemVerilog for Verification

## Pre-Class Videos (~50 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Assertions — Executable Specifications | ~15 min | `seg1_assertions.html` |
| 2 | Concurrent Assertions | ~12 min | `seg2_concurrent_assertions.html` |
| 3 | Functional Coverage | ~12 min | `seg3_functional_coverage.html` |
| 4 | Interfaces & the Road to UVM | ~11 min | `seg4_interfaces_road_to_uvm.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/uart_tx_assertions.sv` | UART TX with immediate + concurrent assertions |

## Key Concepts
- Immediate assertions: checked at a point in procedural code
- Concurrent assertions: check multi-cycle sequences (property/assert)
- Implication operators: `|->` (overlapping), `|=>` (non-overlapping)
- `disable iff (reset)` to skip checks during reset
- Functional coverage: covergroup, coverpoint, cross, bins
- Coverage-driven workflow: define → test → measure → fill gaps
- `interface` with `modport`: bundled connections, different views
- UVM roadmap: driver → monitor → scoreboard → DUT
- Verification maturity: waveforms → self-checking → assertions → coverage → UVM → formal
- Toolchain notes: immediate assertions in iverilog; concurrent/coverage need commercial tools
