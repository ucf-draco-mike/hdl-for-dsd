# Day 5: Pre-Class Self-Check Quiz
## Counters, Shift Registers & Debouncing

**Q1:** What does `$clog2(N)` return and why is it useful for counter design?

??? success "Answer"
    `$clog2(N)` returns ceil(log₂(N)) — the number of bits needed to represent values 0 through N−1. It auto-sizes counter widths so that when you change the parameter N, the bit width adjusts automatically. No manual calculation needed.

**Q2:** What type of shift register is the core of a UART transmitter? A UART receiver?

??? success "Answer"
    UART TX: **PISO** (Parallel In, Serial Out) — load a byte, shift it out one bit at a time.
    UART RX: **SIPO** (Serial In, Parallel Out) — shift bits in one at a time, present the complete byte.

**Q3:** What causes metastability and what is the standard mitigation?

??? success "Answer"
    Metastability occurs when an asynchronous signal (not synchronized to the clock) violates setup/hold timing of a flip-flop. The standard mitigation is a **2-FF synchronizer**: two flip-flops in series. The first may go metastable but has a full clock period to resolve before the second samples it.

**Q4:** Why must you synchronize *before* debouncing, not the other way around?

??? success "Answer"
    The debounce counter uses flip-flops clocked by your system clock. If the input is asynchronous (not synchronized), those flip-flops can go metastable. Synchronize first to make the signal safe for all downstream clocked logic, then debounce the clean synchronized signal.
