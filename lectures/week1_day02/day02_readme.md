# Day 2: Combinational Building Blocks

## Pre-Class Videos (~45 minutes total)

| # | Segment | Duration | File | Slides |
|---|---------|----------|------|--------|
| 1 | Data Types and Vectors | ~15 min | `d02_s1_data_types_and_vectors.html` | 7 |
| 2 | Operators | ~12 min | `d02_s2_operators.html` | 7 |
| 3 | Sized Literals & Width Matching | ~8 min | `d02_s3_sized_literals_width_matching.html` | 5 |
| 4 | The 7-Segment Display | ~10 min | `d02_s4_seven_segment_display.html` | 8 |

## Code Examples

| File | Description | Synthesizable? |
|------|-------------|----------------|
| `code/day02_ex01_vector_ops.v` | Bit selection, concatenation, replication, sign extension | Yes |
| `code/day02_ex02_mux_2to1.v` | Parameterized 2-to-1 multiplexer | Yes |
| `code/day02_ex03_hex_to_7seg.v` | Complete hex-to-7-segment decoder (Go Board 7-seg) | Yes |

## Diagrams

| File | Used In | Description |
|------|---------|-------------|
| `diagrams/d02_wire_vs_reg.svg` | Seg 1 | wire vs reg decision flowchart |
| `diagrams/d02_seven_segment.svg` | Seg 4 | 7-segment display with labeled segments (a-g) |

## Pre-Class Quiz

See `day02_quiz.md` — 4 questions. Also embedded as interactive slides at end of Segment 4.

## Naming Convention

| Pattern | Example |
|---------|---------|
| `d##_s#_topic.html` | `d02_s1_data_types_and_vectors.html` |
| `day##_ex##_name.v` | `day02_ex01_vector_ops.v` |
| `d##_name.svg` | `d02_wire_vs_reg.svg` |
| `day##_support.md` | `day02_quiz.md` |

## Directory Structure

```
week1_day02/
├── day02_readme.md
├── day02_quiz.md
├── d02_s1_data_types_and_vectors.html
├── d02_s2_operators.html
├── d02_s3_sized_literals_width_matching.html
├── d02_s4_seven_segment_display.html
├── code/
│   ├── day02_ex01_vector_ops.v
│   ├── day02_ex02_mux_2to1.v
│   └── day02_ex03_hex_to_7seg.v
└── diagrams/
    ├── d02_wire_vs_reg.svg
    └── d02_seven_segment.svg
```
