# Day 2: Pre-Class Self-Check Quiz
## Combinational Building Blocks

**Q1:** Does `reg` always synthesize to a register?

??? success "Answer"
    No. `reg` in `always @(*)` = combinational logic. `reg` in `always @(posedge clk)` = flip-flop. The keyword only means "can be assigned in a procedural block."

**Q2:** What is `4'hF` in binary? How many bits?

??? success "Answer"
    4-bit binary `1111` (decimal 15). The `4'` specifies 4 bits, `h` means hexadecimal.

**Q3:** What does `assign y = sel ? a : b;` synthesize to?

??? success "Answer"
    A 2-to-1 multiplexer. When `sel=1`, output is `a`. When `sel=0`, output is `b`.

**Q4:** What's the difference between `&` and `&&`?

??? success "Answer"
    `&` is bitwise AND (per-bit, result same width). `&&` is logical AND (1-bit true/false result). `4'b1010 & 4'b0101 = 4'b0000` but `4'b1010 && 4'b0101 = 1'b1`.
