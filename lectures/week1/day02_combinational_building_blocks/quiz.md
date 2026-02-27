# Day 2: Pre-Class Self-Check Quiz
## Combinational Building Blocks

**Q1:** What's the difference between `wire` and `reg`? Does `reg` always synthesize to a register?

<details><summary>Answer</summary>
`wire` must be driven by `assign` or module output. `reg` can be assigned inside `always` blocks. `reg` does NOT always become a register — it depends on whether there's a clock edge in the sensitivity list. `reg` in `always @(*)` = combinational.
</details>

**Q2:** What is `4'hF` in binary? How many bits?

<details><summary>Answer</summary>
4-bit binary `1111` (decimal 15). The `4'` specifies 4 bits, `h` means hexadecimal.
</details>

**Q3:** What does `assign y = sel ? a : b;` synthesize to?

<details><summary>Answer</summary>
A 2-to-1 multiplexer. When `sel=1`, output is `a`. When `sel=0`, output is `b`.
</details>

**Q4:** What's the difference between `&` and `&&`?

<details><summary>Answer</summary>
`&` is bitwise AND (operates on each bit). `&&` is logical AND (treats entire value as true/false). `4'b1010 & 4'b0101 = 4'b0000`. `4'b1010 && 4'b0101 = 1'b1` (both nonzero).
</details>
