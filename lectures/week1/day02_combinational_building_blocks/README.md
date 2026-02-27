# Day 2: Combinational Building Blocks

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Data Types and Vectors | ~15 min | `seg1_data_types_and_vectors.html` |
| 2 | Operators | ~12 min | `seg2_operators.html` |
| 3 | Sized Literals & Width Matching | ~8 min | `seg3_sized_literals_width_matching.html` |
| 4 | The 7-Segment Display | ~10 min | `seg4_seven_segment_display.html` |

## Code Examples

| File | Description |
|------|-------------|
| `code/vector_ops.v` | Bit selection, concatenation, replication, sign extension |
| `code/mux_2to1.v` | Parameterized 2-to-1 multiplexer |
| `code/hex_to_7seg.v` | Complete hex-to-7-segment decoder (active low) |

## Key Concepts

- `wire` vs. `reg` — the most misleading names in Verilog
- Vectors: `[MSB:LSB]`, slicing, concatenation `{}`, replication `{n{val}}`
- Bitwise (`&`) vs. logical (`&&`) operators
- Sized literals: `4'hF`, `8'd255`, `1'b0`
- The conditional operator `? :` as a hardware multiplexer

## Pre-Class Quiz

See `quiz.md` — 4 questions covering all 4 segments.
