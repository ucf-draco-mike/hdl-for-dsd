// =============================================================================
// tb_rom.v — Combined testbench for rom_case and rom_array
// Day 9 · Topic 9.1: ROM in Verilog · Demo example 1
// =============================================================================
// Drives both ROM modules with the same address sequence and verifies they
// produce the same five characters: 'H','E','L','L','O' (then 0/X past idx 4).
// rom_case is combinational; rom_array is synchronous (1-cycle latency).
// VCD: tb_rom.vcd (open in gtkwave to compare).
// =============================================================================

`timescale 1ns/1ps

module tb_rom;
    reg        clk = 0;
    reg  [2:0] addr_case;
    reg  [2:0] addr_array;
    wire [7:0] data_case;
    wire [7:0] data_array;

    rom_case  u_case  (.i_addr(addr_case),  .o_data(data_case));

    // ADDR_W=3 -> 8 entries (2**3 = 8); first 5 hold H,E,L,L,O from hello.hex
    rom_array #(
        .ADDR_W(3), .DATA_W(8), .INIT_FILE("hello.hex")
    ) u_array (
        .i_clk(clk), .i_addr(addr_array), .o_data(data_array)
    );

    always #20 clk = ~clk;   // 25 MHz-ish period for VCD readability

    integer i, test_count = 0, fail_count = 0;
    reg [7:0] expected [0:4];

    initial begin
        expected[0] = 8'h48;  // H
        expected[1] = 8'h45;  // E
        expected[2] = 8'h4C;  // L
        expected[3] = 8'h4C;  // L
        expected[4] = 8'h4F;  // O
    end

    initial begin
        $dumpfile("tb_rom.vcd");
        $dumpvars(0, tb_rom);
        addr_case  = 0;
        addr_array = 0;
        #100;

        $display("\n=== ROM (case vs array) Testbench ===\n");

        // -------- rom_case: combinational, check immediately --------
        $display("--- rom_case (combinational) ---");
        for (i = 0; i < 5; i = i + 1) begin
            addr_case = i[2:0];
            #1;   // settle
            test_count = test_count + 1;
            if (data_case !== expected[i]) begin
                $display("FAIL: rom_case addr=%0d expected=%h got=%h",
                         i, expected[i], data_case);
                fail_count = fail_count + 1;
            end else
                $display("PASS: rom_case addr=%0d = %h ('%s')",
                         i, data_case, data_case);
        end

        // -------- rom_array: synchronous, 1-cycle latency --------
        $display("\n--- rom_array (synchronous, 1-cycle latency) ---");
        @(posedge clk);
        for (i = 0; i < 5; i = i + 1) begin
            addr_array = i[2:0];
            @(posedge clk);     // present address
            #1;                 // data appears after this edge
            test_count = test_count + 1;
            if (data_array !== expected[i]) begin
                $display("FAIL: rom_array addr=%0d expected=%h got=%h",
                         i, expected[i], data_array);
                fail_count = fail_count + 1;
            end else
                $display("PASS: rom_array addr=%0d = %h ('%s')",
                         i, data_array, data_array);
        end

        $display("\n=== SUMMARY: %0d/%0d passed ===",
                 test_count - fail_count, test_count);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else                 $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
