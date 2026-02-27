# Day 9: Pre-Class Self-Check Quiz
## Memory: RAM, ROM & Block RAM

**Q1:** What is the key difference between an asynchronous ROM read and a synchronous ROM read? Which one can infer block RAM?

<details><summary>Answer</summary>
Asynchronous read uses `assign o_data = r_mem[i_addr];` (combinational). Synchronous read uses `always @(posedge i_clk) o_data <= r_mem[i_addr];` (clocked). Only **synchronous read** can infer block RAM. The trade-off is one cycle of read latency.
</details>

**Q2:** How much block RAM does the iCE40 HX1K have?

<details><summary>Answer</summary>
16 Embedded Block RAM (EBR) blocks × 4 Kbit each = **64 Kbit total** (8 KB). Each block can be configured as 256×16, 512×8, 1024×4, or 2048×2.
</details>

**Q3:** What system task loads a hex file into a memory array? Where does it work?

<details><summary>Answer</summary>
`$readmemh("filename.hex", r_mem)` loads hexadecimal data. `$readmemb` loads binary data. Both work in **simulation** (Icarus Verilog) and **synthesis** (Yosys uses the data for ROM/RAM initialization).
</details>

**Q4:** Write the always block for a single-port synchronous RAM with read-before-write behavior.

<details><summary>Answer</summary>

```verilog
always @(posedge i_clk) begin
    if (i_write_en)
        r_mem[i_addr] <= i_write_data;
    o_read_data <= r_mem[i_addr];  // reads old value during write
end
```
</details>
