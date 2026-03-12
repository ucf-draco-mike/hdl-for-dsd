# Day 14: Pre-Class Self-Check Quiz
## Verification Techniques, AI-Driven Testing & PPA Analysis

**Q1:** What does `assert (o_tx == 1'b1) else $error("TX not idle");` do that `if (!o_tx) $display("Error")` doesn't?

??? success "Answer"
    Assertions are: (1) standardized — tools can count, filter, and report uniformly, (2) have severity levels ($info, $warning, $error, $fatal), (3) can be globally enabled/disabled without code changes, (4) are recognized by formal verification tools. `if`-statements provide none of these benefits.

**Q2:** Write a 3-line constraint spec for testing an ALU with AI. What should you specify?

??? success "Answer"
    "Test all opcodes (ADD, SUB, AND, OR, XOR) with random operands from $urandom_range(0, 2^WIDTH-1). For ADD/SUB, ensure at least 10 overflow and 10 zero-result cases. Self-checking: compute expected = a OP b in the testbench, compare to DUT output."

    A good spec specifies: module interface, legal input ranges, corner cases with quantities, and self-checking method.

**Q3:** Your PPA table shows adding parity to UART TX costs 6 LUTs. Write one sentence explaining whether this is "expensive."

??? success "Answer"
    6 LUTs = 0.5% of the iCE40 HX1K (1,280 total), which is negligible for most designs; however, the cost should be evaluated relative to total design utilization — if you're already at 90%, every LUT matters, and the `generate if` allows compiling it out at zero cost. The key is stating both absolute and relative cost.

**Q4:** Name the 5 levels of the verification maturity scale covered in this course. Which level are you at now?

??? success "Answer"
    (1) Manual directed tests (Day 4), (2) Self-checking testbenches (Day 6), (3) AI-scaffolded testbenches (Days 6/8/12), (4) Assertion-enhanced (Day 14 Seg 1), (5) Constrained random + coverage analysis (Day 14 lab). Students are at Level 5 by end of today. Levels 6 (UVM) and 7 (formal) are covered in the department's V&V course.
