# Day 6: Pre-Class Self-Check Quiz
## Testbenches & Simulation-Driven Development

**Q1:** Why are DUT inputs declared as `reg` in the testbench, but outputs as `wire`?

??? success "Answer"
    In the testbench, **you** drive the DUT's inputs (assigning them in `initial`/`always` blocks), so they must be `reg`. DUT outputs are driven by the DUT itself (a module output), so they are `wire` — you observe them, you don't drive them.

**Q2:** Why should you use `!==` instead of `!=` in testbench comparisons?

??? success "Answer"
    `!==` (case inequality) properly handles `x` and `z` values. `x !== 0` is **true** (they definitely don't match). `x != 0` is **x** (unknown) — which means your if-statement doesn't trigger and the bug goes undetected. Always use `===`/`!==` in testbenches.

**Q3:** What is the purpose of the `$dumpfile` and `$dumpvars` system tasks?

??? success "Answer"
    `$dumpfile("name.vcd")` specifies the output waveform file name. `$dumpvars(0, tb_module)` records all signal changes at all hierarchy levels below the specified module. Together they generate the VCD file that GTKWave uses for waveform visualization.

**Q4:** Write a `task` that applies two 4-bit inputs to signals `a` and `b`, waits one clock cycle, and checks that `result` matches an expected value.

??? success "Answer"
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
