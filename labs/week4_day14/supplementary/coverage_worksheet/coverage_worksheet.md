# Coverage Analysis Worksheet — Day 14, Exercise 3

## ALU Coverage Model

```systemverilog
covergroup alu_coverage @(posedge clk);
    cp_op: coverpoint i_opcode {
        bins add    = {2'b00};
        bins sub    = {2'b01};
        bins bw_and = {2'b10};
        bins bw_or  = {2'b11};
    }
    cp_a: coverpoint i_a {
        bins zero     = {4'h0};
        bins mid_low  = {[4'h1:4'h7]};
        bins mid_high = {[4'h8:4'hE]};
        bins max      = {4'hF};
    }
    cp_b: coverpoint i_b {
        bins zero     = {4'h0};
        bins mid_low  = {[4'h1:4'h7]};
        bins mid_high = {[4'h8:4'hE]};
        bins max      = {4'hF};
    }
    cp_zero:  coverpoint zero_flag  { bins yes={1'b1}; bins no={1'b0}; }
    cp_carry: coverpoint carry_flag { bins yes={1'b1}; bins no={1'b0}; }
    cx_full:     cross cp_op, cp_a, cp_b;     // 4×4×4 = 64 bins
    cx_op_zero:  cross cp_op, cp_zero;          // 4×2 = 8 bins
    cx_op_carry: cross cp_op, cp_carry;         // 4×2 = 8 bins
endgroup
```

## Manual Analysis

Review your Day 6 ALU testbench. For each cross-coverage bin,
determine if your tests cover it.

### Cross: opcode × a_range × b_range (64 bins)

| Opcode | A Range | B Range | Covered? | Test that covers it |
|:------:|:-------:|:-------:|:--------:|:--------------------|
| ADD | zero | zero | ? | |
| ADD | zero | mid_low | ? | |
| ADD | zero | mid_high | ? | |
| ADD | zero | max | ? | |
| ADD | mid_low | zero | ? | |
| ... | ... | ... | | |
| ADD | max | max | ? | |
| SUB | zero | zero | ? | |
| SUB | zero | max | ? | |
| ... | ... | ... | | |

(Fill in at least 16 representative bins)

### Key Questions
1. What percentage of the 64 cx_full bins does your test cover?
2. Which bins are most likely to reveal bugs?
3. Add 3-5 tests to cover the most important gaps.
