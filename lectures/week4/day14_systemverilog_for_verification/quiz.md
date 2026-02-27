# Day 14: Pre-Class Self-Check Quiz
## SystemVerilog for Verification

**Q1:** What is the difference between an immediate assertion and a concurrent assertion?

<details><summary>Answer</summary>
**Immediate assertions** are checked at a specific point in procedural code (like an `if` check with standardized reporting). **Concurrent assertions** check sequences across multiple clock cycles using properties and implication operators. Immediate = one moment. Concurrent = multi-cycle behavior.
</details>

**Q2:** Write an immediate assertion that checks a counter value never exceeds 99.

<details><summary>Answer</summary>

```systemverilog
always_ff @(posedge clk)
    assert (count < 100)
        else $error("Counter exceeded 99: count = %0d at time %0t",
                    count, $time);
```
</details>

**Q3:** What does `|=>` mean in a concurrent assertion? Write a property that says "if `start` is high, then `busy` must be high on the next cycle."

<details><summary>Answer</summary>
`|=>` is the **non-overlapping implication** operator: "if the left side is true, then one cycle later the right side must be true."

```systemverilog
property p_start_then_busy;
    @(posedge clk) disable iff (reset)
    start |=> busy;
endproperty

assert property (p_start_then_busy)
    else $error("Busy not asserted after start");
```
</details>

**Q4:** What question does functional coverage answer? Name the three key constructs.

<details><summary>Answer</summary>
Functional coverage answers: **"Have we tested enough?"** — measuring what input combinations and conditions were actually exercised during simulation.

Key constructs: **`covergroup`** (defines what to measure), **`coverpoint`** (tracks specific signal values/ranges), and **`cross`** (measures combinations of coverpoints).
</details>
