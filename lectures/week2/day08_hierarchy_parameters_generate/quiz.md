# Day 8: Pre-Class Self-Check Quiz
## Hierarchy, Parameters & Generate

**Q1:** What is the difference between `parameter` and `localparam`?

<details><summary>Answer</summary>
`parameter` can be overridden at module instantiation — used for configurable values like widths, thresholds, and timing. `localparam` cannot be overridden — used for internal/derived constants and state encodings.
</details>

**Q2:** Write the instantiation of a `counter` module with `WIDTH=16` and `MAX_COUNT=49999`.

<details><summary>Answer</summary>

```verilog
counter #(
    .WIDTH(16),
    .MAX_COUNT(49_999)
) my_counter (
    .i_clk    (i_clk),
    .i_reset  (i_reset),
    .i_enable (1'b1),
    .o_count  (w_count),
    .o_done   (w_done)
);
```
</details>

**Q3:** What is the difference between a `generate for` loop and a `for` loop inside an `always` block?

<details><summary>Answer</summary>
`generate for` runs at **elaboration (compile) time** and creates multiple hardware instances (parallel hardware). It uses `genvar` and can instantiate modules. A `for` inside `always` is **loop unrolling** — it describes sequential or combinational operations within a single block. Both are synthesizable but serve different purposes.
</details>

**Q4:** Name at least four things on the "reuse checklist" for a well-designed module.

<details><summary>Answer</summary>
1. Parameterized widths, thresholds, and timing values
2. Self-checking testbench included
3. ANSI-style ports with consistent naming (`i_/o_/r_/w_`)
4. Header comment documentation (description, ports, parameters)
5. Active-high internal logic (handle active-low at boundaries)
6. No hardcoded magic numbers — use `parameter`/`localparam`
(Any four of these.)
</details>
