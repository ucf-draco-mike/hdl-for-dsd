# Day 8: Pre-Class Self-Check Quiz
## Hierarchy, Parameters & Generate

**Q1:** What is the difference between `parameter` and `localparam`?

<details><summary>Answer</summary>

`parameter` can be overridden at instantiation time using the `#(.PARAM(value))` syntax — use for configurable values like widths, thresholds, and counts.
`localparam` is internal to the module and **cannot** be overridden — use for derived constants (e.g., `localparam MAX = (1 << WIDTH) - 1`).

</details>

**Q2:** Is `generate for` a runtime loop? Explain what it actually does.

<details><summary>Answer</summary>

No! `generate for` runs at **elaboration time** (compile time). It physically creates N independent copies of the hardware. Each iteration produces a separate instance with its own flip-flops and logic. It is NOT a sequential loop — it is hardware replication.

</details>

**Q3:** What does `$clog2(1000)` return and why is it useful?

<details><summary>Answer</summary>

It returns **10** — because ceil(log₂(1000)) = 10. You need 10 bits to represent values 0 through 999. It's useful because it automatically derives the correct bit width from a parameter, eliminating manual calculation and the bugs that come with it. When the parameter changes, the width adjusts automatically.

</details>

**Q4:** Why should you name generate blocks (e.g., `begin : gen_debounce`)?

<details><summary>Answer</summary>

Named generate blocks create hierarchical paths visible in simulation waveforms and synthesis reports. Debugging `gen_debounce[2].db.r_count` is much easier than navigating anonymous generated instances. It also makes `$display` and `$dumpvars` output meaningful.

</details>
