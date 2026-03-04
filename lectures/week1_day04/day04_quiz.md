# Day 4: Pre-Class Self-Check Quiz
## Sequential Logic Fundamentals

**Q1:** What happens if you use `=` instead of `<=` in `always @(posedge clk)` with two registers?

<details><summary>Answer</summary>
Both registers get the same value in one cycle. With `<=`, both right-hand sides are evaluated first with current values, then all updates happen simultaneously.
</details>

**Q2:** Is a missing `else` in `always @(posedge clk)` a latch?

<details><summary>Answer</summary>
No! Flip-flops inherently hold their value between clock edges. Latch inference only occurs in combinational `always @(*)` blocks.
</details>

**Q3:** Write a D flip-flop with synchronous reset from memory.

<details><summary>Answer</summary>
```verilog
always @(posedge i_clk)
    if (i_reset) r_q <= 1'b0;
    else         r_q <= r_d;
```
</details>

**Q4:** You want an LED to blink at ~2 Hz from a 25 MHz clock. What counter value do you count to?

<details><summary>Answer</summary>
2 Hz = toggle every 0.25s = 6,250,000 clock cycles per half-period. Count to 6,250,000 - 1, then toggle and reset.
</details>
