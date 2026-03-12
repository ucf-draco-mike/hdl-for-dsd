# Day 3: Pre-Class Self-Check Quiz
## Procedural Combinational Logic

**Q1:** Why must you use `@(*)` instead of a manual sensitivity list?

??? success "Answer"
    Manual lists risk sim/synth mismatch. If you forget a signal, simulation won't update when it changes, but synthesis will. `@(*)` automatically includes all signals read inside the block.

**Q2:** What causes an unintentional latch? Give an example.

??? success "Answer"
    Not assigning a signal in every possible path through `always @(*)`. Example: `if (sel) y = a;` with no `else` — when `sel=0`, `y` must hold its value → latch inferred.

**Q3:** Name three techniques to prevent latch inference.

??? success "Answer"
    1. Default assignment at the top of the block
    2. Complete `if/else` chains (always have an `else`)
    3. `default` case in `case` statements

**Q4:** When do you use `=` vs `<=`?

??? success "Answer"
    `=` (blocking) for combinational `always @(*)`. `<=` (nonblocking) for sequential `always @(posedge clk)`. Never mix them in the same block.
