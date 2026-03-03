# Day 1: Pre-Class Self-Check Quiz
## Welcome to Hardware Thinking

**Q1:** Name three fundamental differences between writing software (C/Python) and writing Verilog.

<details><summary>Answer</summary>

1. **Execution model:** Software executes sequentially (line by line). Verilog describes hardware that operates in parallel (all at once).
2. **Resource mapping:** More software = more time. More Verilog = more physical hardware (gates, wires, area).
3. **No dynamic allocation:** Hardware is fixed at synthesis time. No malloc, no recursion, no variable-length anything.
</details>

**Q2:** What happens to `#10` (a delay statement) during synthesis? During simulation?

<details><summary>Answer</summary>

- **Simulation:** The simulator waits 10 time units before continuing.
- **Synthesis:** Completely ignored. The synthesizer cannot create physical delays from `#` statements. This is why you should never use `#delay` in synthesizable design code — it causes a simulation/synthesis mismatch.
</details>

**Q3:** Write a complete Verilog module (from `module` to `endmodule`) that connects an input `i_switch` to an output `o_led`.

<details><summary>Answer</summary>

```verilog
module led_driver (
    input  wire i_switch,
    output wire o_led
);
    assign o_led = i_switch;
endmodule
```
</details>

**Q4:** What does `assign` mean in Verilog — is it a one-time computation or something else?

<details><summary>Answer</summary>

`assign` creates a **permanent physical wire connection**. It is NOT a one-time computation. The output continuously reflects the input — whenever the right-hand side changes, the left-hand side updates instantly. It exists for the entire lifetime of the hardware.
</details>

**Q5:** In the module below, does the order of the two `assign` statements matter? Why or why not?

```verilog
module example (input wire a, b, output wire y1, y2);
    assign y2 = a | b;
    assign y1 = a & b;
endmodule
```

<details><summary>Answer</summary>

**No, the order does not matter.** Both `assign` statements create hardware that exists simultaneously. The AND gate and OR gate operate in parallel. Swapping the lines produces identical hardware. This is fundamentally different from software, where line order determines execution order.
</details>
