# Day 10: Pre-Class Self-Check Quiz
## Timing, Clocking & Constraints

**Q1:** Your critical path is 35 ns. You're running at 25 MHz (40 ns period). What's the slack? Is timing met? What's the Fmax?

<details><summary>Answer</summary>
Slack = 40 ns − 35 ns = **5 ns** (positive → timing met). Fmax ≈ 1/35 ns ≈ **28.6 MHz**. You have some margin, but not a lot.
</details>

**Q2:** What `nextpnr` flag enables timing analysis? What happens without it?

<details><summary>Answer</summary>
`--freq 25` (target clock in MHz). Without it, nextpnr performs no timing analysis and cannot warn about violations. Always include it.
</details>

**Q3:** What tool calculates iCE40 PLL parameters? What signal must you wait for?

<details><summary>Answer</summary>
`icepll -i 25 -o 50` calculates DIVR, DIVF, DIVQ, FILTER_RANGE. Wait for the **LOCK** signal to go high before using the PLL output clock. The PLL needs time to stabilize after power-up.
</details>

**Q4:** How do you safely pass a multi-bit counter value across clock domains?

<details><summary>Answer</summary>
Convert to **Gray code** (only 1 bit changes per increment), pass through a 2-FF synchronizer in the destination domain, then convert back to binary. This prevents the receiver from seeing corrupted intermediate values.
</details>
