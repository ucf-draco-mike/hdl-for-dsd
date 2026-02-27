# Day 13: Pre-Class Self-Check Quiz
## SystemVerilog for Design

**Q1:** What does the `logic` type replace? What is its one restriction?

<details><summary>Answer</summary>
`logic` replaces both `wire` and `reg`. It can be driven by `assign`, `always_ff`, or `always_comb`. Its one restriction: it can only have **one driver**. For multi-driver buses (rare in FPGA), use `wire`.
</details>

**Q2:** What happens if you accidentally create an incomplete `case` statement (missing a default) inside `always_comb`? How is this different from Verilog's `always @(*)`?

<details><summary>Answer</summary>
In `always_comb`, the compiler **errors** because a latch would be inferred — `always_comb` requires purely combinational logic. In Verilog's `always @(*)`, a latch is silently inferred with at most a synthesis warning that you might miss. This is the biggest safety win of SystemVerilog.
</details>

**Q3:** Rewrite this Verilog FSM state declaration using SystemVerilog `enum`:
```verilog
localparam S_IDLE = 2'b00, S_RUN = 2'b01, S_DONE = 2'b10;
reg [1:0] state;
```

<details><summary>Answer</summary>

```systemverilog
typedef enum logic [1:0] {
    S_IDLE = 2'b00,
    S_RUN  = 2'b01,
    S_DONE = 2'b10
} my_state_t;

my_state_t state;
```
Bonus: `$display("State: %s", state.name());` prints the state name.
</details>

**Q4:** What is a `packed struct` and why is it synthesizable?

<details><summary>Answer</summary>
A `packed struct` stores its fields as a contiguous bit vector. For example, a struct with an 8-bit data field, a valid bit, and a busy bit is 10 bits wide. Because it's a flat bit vector, synthesis tools can map it directly to wires and registers — no different from a `logic [9:0]` bus, but with named fields for readability.
</details>
