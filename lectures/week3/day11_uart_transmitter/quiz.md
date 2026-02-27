# Day 11: Pre-Class Self-Check Quiz
## UART Transmitter

**Q1:** Draw/describe a UART frame for sending the byte 0x48 ('H') at 115200 baud, 8N1.

<details><summary>Answer</summary>
Idle (high) → Start bit (low, ~8.68µs) → D0=0 → D1=0 → D2=0 → D3=1 → D4=0 → D5=0 → D6=1 → D7=0 → Stop bit (high, ~8.68µs). 0x48 = 0100_1000 binary, sent LSB first = 0,0,0,1,0,0,1,0. Total: 10 bit periods ≈ 86.8µs.
</details>

**Q2:** How many clock cycles per bit at 25 MHz / 115200 baud?

<details><summary>Answer</summary>
25,000,000 / 115,200 = **~217 clock cycles** per bit.
</details>

**Q3:** What three building blocks does the UART TX decompose into?

<details><summary>Answer</summary>
1. **FSM** (control: IDLE → START → DATA → STOP)
2. **PISO shift register** (holds the byte, shifts out LSB first)
3. **Modulo-N counter** (baud rate generator, ticks every 217 cycles)
</details>

**Q4:** What is the valid/busy handshake protocol?

<details><summary>Answer</summary>
Producer asserts `i_valid` for one cycle when it has data and `o_busy` is low. TX latches the data, asserts `o_busy`, and transmits the byte. Producer must wait for `!o_busy` before sending the next byte.
</details>
