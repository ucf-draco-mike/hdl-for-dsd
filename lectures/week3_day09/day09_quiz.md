# Day 9: Pre-Class Self-Check Quiz
## Memory: RAM, ROM & Block RAM

**Q1:** What is the key difference between async ROM read and sync ROM read? Which infers block RAM?

??? success "Answer"
    Asynchronous read: `assign o_data = r_mem[i_addr];` (combinational, no latency).
    Synchronous read: `always @(posedge i_clk) o_data <= r_mem[i_addr];` (clocked, 1-cycle latency).
    Only **synchronous read** infers block RAM (EBR).

**Q2:** How much block RAM does the iCE40 HX1K have?

??? success "Answer"
    16 Embedded Block RAM (EBR) blocks × 4 Kbit each = **64 Kbit total** (8 KB). Each block configurable as 256×16, 512×8, 1024×4, or 2048×2.

**Q3:** What system task loads a hex file into a memory array? Where does it work?

??? success "Answer"
    `$readmemh("filename.hex", r_mem)` loads hexadecimal data. `$readmemb` loads binary. Both work in **simulation** (Icarus Verilog) and **synthesis** (Yosys uses the data for initialization).

**Q4:** Write the always block for a single-port synchronous RAM with read-before-write behavior.

??? success "Answer"
    ```verilog
    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;
        o_read_data <= r_mem[i_addr]; // reads old value during write
    end
    ```
