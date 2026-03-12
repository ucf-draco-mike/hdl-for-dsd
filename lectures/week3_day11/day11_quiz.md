# Day 11: Pre-Class Self-Check Quiz
## UART Transmitter

**Q1:** Draw/describe a UART frame for byte 0x48 ('H') at 115200 baud, 8N1. What's the bit order on the wire?

??? success "Answer"
    Idle(1) → Start(0) → D0=0 → D1=0 → D2=0 → D3=1 → D4=0 → D5=0 → D6=1 → D7=0 → Stop(1).
    0x48 = 01001000 binary, sent **LSB first** = 0,0,0,1,0,0,1,0 on the wire.
    Total: 10 bit periods ≈ 86.8 µs.

**Q2:** How many clock cycles per bit at 25 MHz / 115200 baud?

??? success "Answer"
    25,000,000 / 115,200 = **~217 clock cycles** per bit. Actual baud rate = 25M/217 ≈ 115,207 (0.006% error, well within tolerance).

**Q3:** What three building blocks does the UART TX decompose into?

??? success "Answer"
    1. **FSM** (control: IDLE → START → DATA → STOP)
    2. **PISO shift register** (holds the byte, shifts out LSB first)
    3. **Modulo-N counter** (baud rate generator, ticks every 217 cycles)

**Q4:** What is the valid/busy handshake protocol?

??? success "Answer"
    Producer asserts `i_valid` for one cycle when `o_busy` is low. TX latches the data, asserts `o_busy`, and transmits. Producer must wait for `!o_busy` before sending the next byte.
