# Day 3: Pre-Class Self-Check Quiz
## Procedural Combinational Logic

**Q1:** Why must you use `@(*)` instead of a manual sensitivity list for combinational logic?

<details><summary>Answer</summary>
Manual lists risk sim/synth mismatch. If you forget a signal, simulation won't update when it changes, but synthesis will. `@(*)` automatically includes all signals read inside the block.
</details>

**Q2:** What causes an unintentional latch? Give an example.

<details><summary>Answer</summary>
Not assigning a signal in every possible path through an `always @(*)` block. Example: `if (sel) y = a;` with no `else` — when `sel=0`, `y` must hold its value → latch inferred.
</details>

**Q3:** Name three techniques to prevent latch inference.

<details><summary>Answer</summary>
1. Default assignment at the top of the block (`y = 0;` before the `if`)
2. Complete `if/else` chains (always have an `else`)
3. `default` case in `case` statements
</details>

**Q4:** When do you use `=` vs `<=`?

<details><summary>Answer</summary>
`=` (blocking) for combinational `always @(*)`. `<=` (nonblocking) for sequential `always @(posedge clk)`. Never mix them in the same block.
</details>
