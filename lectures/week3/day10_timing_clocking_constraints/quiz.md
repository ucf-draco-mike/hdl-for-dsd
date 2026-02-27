# Day 10: Pre-Class Self-Check Quiz
## Timing, Clocking & Constraints

**Q1:** What is "slack" in timing analysis? What does negative slack mean?

<details><summary>Answer</summary>
Slack = clock_period − (propagation_delay + setup_time). **Positive slack** means the signal arrives with time to spare — timing is met. **Negative slack** means the signal arrives too late — timing violation. The design may work intermittently or fail unpredictably.
</details>

**Q2:** How do you enable timing analysis in nextpnr? What happens without it?

<details><summary>Answer</summary>
Add `--freq 25` (or your target MHz) to the nextpnr command. Without it, nextpnr doesn't know your target frequency and cannot warn about timing violations.
</details>

**Q3:** What tool calculates PLL divider values for the iCE40? What primitive do you instantiate?

<details><summary>Answer</summary>
`icepll -i 25 -o <target_freq>` calculates DIVR, DIVF, DIVQ, and FILTER_RANGE values. Instantiate the `SB_PLL40_CORE` primitive with those values.
</details>

**Q4:** What is the safest strategy for handling clock domain crossing?

<details><summary>Answer</summary>
**Avoid multiple clock domains whenever possible.** One clock = zero CDC problems. When crossing is unavoidable: single-bit signals use a 2-FF synchronizer; multi-bit values use Gray code encoding (for counters) or an asynchronous FIFO.
</details>
