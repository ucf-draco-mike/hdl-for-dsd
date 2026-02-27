# Day 4: Pre-Class Self-Check Quiz
## Sequential Logic Fundamentals

**Q1:** What's the period of the Go Board's 25 MHz clock? How many cycles for a 1 Hz blink?

<details><summary>Answer</summary>
Period = 1/25,000,000 = 40 ns. For 1 Hz blink (toggle every 0.5s): 25,000,000 / 2 = 12,500,000 cycles per half-period.
</details>

**Q2:** Why does blocking assignment (`=`) break a shift register in a sequential block?

<details><summary>Answer</summary>
With `=`, `b = a; c = b;` — b gets a's value immediately, then c sees b's NEW value (which is already a). Both stages get the same value in one cycle. With `<=`, both right-hand sides are evaluated first with current values, then all updates happen simultaneously.
</details>

**Q3:** Write a D flip-flop with synchronous reset from memory.

<details><summary>Answer</summary>
```verilog
always @(posedge i_clk)
    if (i_reset)
        r_q <= 1'b0;
    else
        r_q <= r_d;
```
</details>

**Q4:** You want an LED to blink at ~2 Hz from a 25 MHz clock. What counter value do you count to?

<details><summary>Answer</summary>
2 Hz = toggle every 0.25s = 6,250,000 clock cycles per half-period. Count to 6,250,000 - 1, then toggle and reset.
</details>
