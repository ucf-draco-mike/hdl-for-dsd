# Day 14: Pre-Class Self-Check Quiz
## SystemVerilog for Verification

**Q1:** What's the difference between `assert (condition) else $error(...)` and `if (!condition) $display("Error...")`?

<details><summary>Answer</summary>
Assertions are: (1) standardized — tools can count, filter, and report uniformly, (2) have severity levels (`$info`, `$warning`, `$error`, `$fatal`), (3) can be globally enabled/disabled without code changes, (4) are recognized by formal verification tools. `if`-statements provide none of these benefits.
</details>

**Q2:** Write a concurrent assertion: after reset falls, TX must be high within 2 cycles.

<details><summary>Answer</summary>

```systemverilog
property p_post_reset_idle;
    @(posedge i_clk)
    $fell(i_reset) |=> ##[0:1] (o_tx == 1'b1);
endproperty

assert property (p_post_reset_idle)
    else $error("TX not idle after reset");
```

`|=>` is non-overlapping implication. `##[0:1]` means within 0 to 1 cycles after the trigger.
</details>

**Q3:** Your coverage report shows 85%. Should you ship?

<details><summary>Answer</summary>
It depends on **what's missing**. If the uncovered 15% are unreachable states or don't-care conditions, 85% may be acceptable. If they include critical edge cases (overflow, underflow, error conditions), you need more tests. Goals vary: 95%+ for safety-critical, 80-90% for general designs. The key is understanding *what* is uncovered.
</details>

**Q4:** A module has 12 ports. You add a 13th. How many files change with Verilog vs. SV interface?

<details><summary>Answer</summary>
**Verilog:** Every file that instantiates the module needs its port map updated — potentially many files. **SV interface:** Modify the interface definition (one file) and the module internals. Instantiation sites that connect via the interface automatically get the new signal.
</details>
