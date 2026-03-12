# Day 12: Pre-Class Self-Check Quiz
## UART RX, SPI & IP Integration

**Q1:** Why does the UART RX use 16× oversampling instead of 1× sampling?

??? success "Answer"
    Without a shared clock, the RX doesn't know exactly when each bit starts. 16× oversampling provides 16 sample points per bit, allowing center-of-bit sampling (tick 7-8) for maximum noise immunity and baud rate mismatch tolerance.

**Q2:** What is the loopback test and why is it the gold standard?

??? success "Answer"
    RX → TX echo: type characters on PC terminal, see them echoed back. If the echo works, both TX and RX are verified correct with a single test. It validates the complete communication path end-to-end.

**Q3:** How many wires does SPI use? What advantage does it have over UART?

??? success "Answer"
    4 wires: SCLK, MOSI, MISO, CS_N. The master provides the clock, so there's no baud rate negotiation and no oversampling needed. SPI is synchronous and can run at much higher speeds (10+ Mbps vs. ~1 Mbps for UART).

**Q4:** What's the first step on the IP integration checklist?

??? success "Answer"
    **Read the interface specification.** Understand the ports, protocols, timing requirements, and configuration options before writing any wrapper or testbench code.
