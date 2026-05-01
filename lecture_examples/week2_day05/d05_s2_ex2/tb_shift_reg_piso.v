// =============================================================================
// tb_shift_reg_piso.v -- extracted from day05_ex02_shift_reg_piso.v
// =============================================================================
`timescale 1ns/1ps

module tb_shift_reg_piso;
    reg        clk = 0, reset = 1, load = 0, shift_en = 0;
    reg  [7:0] parallel_in;
    wire       serial_out;

    shift_reg_piso #(.WIDTH(8)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_load(load), .i_shift_en(shift_en),
        .i_parallel_in(parallel_in),
        .o_serial_out(serial_out)
    );

    always #20 clk = ~clk;

    integer i, fail_count = 0;
    reg [7:0] test_byte;
    reg expected_bit;

    initial begin
        $dumpfile("tb_shift_reg_piso.vcd");
        $dumpvars(0, tb_shift_reg_piso);

        #100; reset = 0;
        test_byte = 8'hA5;  // 10100101 -- good mix of 0s and 1s

        // Load the byte
        @(posedge clk);
        parallel_in = test_byte;
        load = 1;
        @(posedge clk);
        load = 0;
        shift_en = 1;

        // Shift out 8 bits and verify LSB-first
        for (i = 0; i < 8; i = i + 1) begin
            expected_bit = test_byte[i];
            #1;
            if (serial_out !== expected_bit) begin
                $display("FAIL: Bit %0d -- expected %b, got %b", i, expected_bit, serial_out);
                fail_count = fail_count + 1;
            end else
                $display("PASS: Bit %0d = %b", i, serial_out);
            @(posedge clk);
        end

        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***");
        else $display("\n*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
