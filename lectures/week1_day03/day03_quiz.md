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

**Q4:** You add a variable-shift op (`a << n`) to a 4-bit ALU. The LUT count jumps but the SB_CARRY count stays the same. Why?

??? success "Answer"
    Variable shift synthesizes to a **barrel shifter** — a stack of 2:1 muxes that only consume LUTs (no inter-bit carry propagation). The dedicated SB_CARRY chain is only used by carry-propagating operators like `+`, `-`, `<`, `>`. So adding a shifter grows LUTs without touching the carry budget.
