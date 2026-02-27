# Day 12: Pre-Class Self-Check Quiz
## UART RX, SPI & IP Integration

**Q1:** Why is UART RX harder than TX? What technique solves the bit-alignment problem?

<details><summary>Answer</summary>
TX controls its own timing. RX must find bit boundaries from an incoming signal with no clock reference. **16× oversampling** solves this: sample 16 times per bit period, detect the start bit's falling edge, count half a bit to align to center, then sample each subsequent bit at its center.
</details>

**Q2:** How does start-bit detection work with 16× oversampling?

<details><summary>Answer</summary>
1. Wait for falling edge on synchronized RX. 2. Count 7 oversample ticks (half a bit period) to reach the center. 3. Check RX again — if still low, it's a valid start bit (not noise). 4. Now aligned to bit centers. Count 16 oversamples for each data bit.
</details>

**Q3:** What are the four SPI signals and their directions?

<details><summary>Answer</summary>
- **SCLK** (Master → Slave): Serial clock
- **MOSI** (Master → Slave): Master Out, Slave In (data to slave)
- **MISO** (Slave → Master): Master In, Slave Out (data from slave)
- **CS_N** (Master → Slave): Chip Select, active low
</details>

**Q4:** Name three items on the IP integration checklist.

<details><summary>Answer</summary>
1. Read the documentation — understand the interface contract
2. Write a wrapper module — adapt to your naming/handshake conventions
3. Add synchronizers on external async inputs
4. Write a testbench — verify the IP works as documented
5. Verify resource usage — check it fits on your FPGA
(Any three.)
</details>
