# Day 6: Pre-Class Self-Check Quiz
## Testbenches & Simulation-Driven Development

**Q1:** Why are testbench inputs declared as `reg` and DUT outputs as `wire`?

<details><summary>Answer</summary>
In the testbench, **you** drive the DUT's inputs (assigning them in `initial`/`always` blocks), so they must be `reg`. DUT outputs are driven by the DUT itself (a module output), so they are `wire` — you observe them, you don't drive them.
</details>

**Q2:** Why should you use `!==` instead of `!=` in testbench comparisons?

<details><summary>Answer</summary>
`!==` (case inequality) properly handles `x` and `z` values. `x !== 0` is **true** (they definitely don't match). `x != 0` is **x** (unknown) — which means your if-statement doesn't trigger and the bug goes undetected. Always use `===`/`!==` in testbenches.
</details>

**Q3:** What is the purpose of the `$dumpfile` and `$dumpvars` system tasks?

<details><summary>Answer</summary>
`$dumpfile("name.vcd")` specifies the output waveform file name. `$dumpvars(0, tb_module)` records all signal changes at all hierarchy levels below the specified module. Together they generate the VCD file that GTKWave uses for waveform visualization.
</details>

**Q4:** Write a `task` that applies two 4-bit inputs to signals `a` and `b`, waits one clock cycle, and checks that `result` matches an expected value.

<details><summary>Answer</summary>

```verilog
task apply_and_check;
    input [3:0] in_a, in_b, expected;
    input [8*20-1:0] name;
begin
    a = in_a;
    b = in_b;
    @(posedge clk);
    @(posedge clk);
    if (result !== expected)
        $display("FAIL: %0s — expected %h, got %h", name, expected, result);
    else
        $display("PASS: %0s", name);
end
endtask
```
</details>
