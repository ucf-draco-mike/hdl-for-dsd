# Day 10: Pre-Class Self-Check Quiz
## Numerical Architectures & Design Trade-offs

**Q1:** What does positive slack mean? What about negative slack? What happens in hardware with negative slack?

<details><summary>Answer</summary>
Positive slack = timing met (data arrives before the setup time deadline). Negative slack = timing violation — the design may work intermittently, capturing wrong values on some clock cycles. This causes the worst kind of bugs: random, non-reproducible failures.
</details>

**Q2:** Why does `assign product = a * b;` use so many LUTs on the iCE40? Would it be different on a larger FPGA?

<details><summary>Answer</summary>
The iCE40 has **no DSP blocks**. Multiplication is implemented entirely in LUT logic, with O(N²) gate count growth. On larger FPGAs (Xilinx, Intel, larger Lattice), the `*` operator maps to dedicated DSP slices — nearly free in LUTs.
</details>

**Q3:** When would you choose a sequential (shift-and-add) multiplier over a combinational one? Explain using PPA.

<details><summary>Answer</summary>
When **area** is constrained and **latency** is acceptable. The sequential version uses O(N) LUTs but takes N clock cycles. The combinational version uses O(N²) LUTs but completes in 1 cycle. Additionally, the sequential version has a shorter critical path, so it can run at a higher Fmax. Trade-off: area + Fmax vs. latency.
</details>

**Q4:** What are the three FPGA PPA proxies, and which tools measure them?

<details><summary>Answer</summary>
**Performance** → Fmax from `nextpnr` timing report (`--freq` flag). **Area** → LUT count, FF count, EBR count from `yosys stat`. **Power** → estimated from toggle rate × capacitance (limited on iCE40, mostly conceptual). The iCE40 HX1K has 1,280 LUTs, 1,280 FFs, 16 EBR blocks, and 1 PLL.
</details>

**Q5:** In Q4.4 fixed-point format, what is the product of 2.5 × 3.0? How many bits is the full product, and which bits do you extract for a Q4.4 result?

<details><summary>Answer</summary>
2.5 × 3.0 = **7.5**. The full product of two Q4.4 numbers is Q8.8 (16 bits). To extract Q4.4, take bits [11:4] — the 4 lower integer bits and 4 upper fractional bits. The integer part (7) is in bits [11:8], and 0.5 is in bits [7:4] = 4'b1000.
</details>
