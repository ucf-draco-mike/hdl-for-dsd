// =============================================================================
// tb_hex_to_7seg.v -- Sweep-all-16 testbench for hex_to_7seg
// =============================================================================
`timescale 1ns/1ps

module tb_hex_to_7seg;
    reg  [3:0] hex;
    wire [6:0] seg;

    hex_to_7seg dut (.i_hex(hex), .o_seg(seg));

    // Expected segment pattern (active-low) for each hex digit
    reg [6:0] expected [0:15];
    integer i, fails;

    initial begin
        $dumpfile("tb_hex_to_7seg.vcd");
        $dumpvars(0, tb_hex_to_7seg);

        expected[0]  = 7'b0000001;
        expected[1]  = 7'b1001111;
        expected[2]  = 7'b0010010;
        expected[3]  = 7'b0000110;
        expected[4]  = 7'b1001100;
        expected[5]  = 7'b0100100;
        expected[6]  = 7'b0100000;
        expected[7]  = 7'b0001111;
        expected[8]  = 7'b0000000;
        expected[9]  = 7'b0000100;
        expected[10] = 7'b0001000;
        expected[11] = 7'b1100000;
        expected[12] = 7'b0110001;
        expected[13] = 7'b1000010;
        expected[14] = 7'b0110000;
        expected[15] = 7'b0111000;

        fails = 0;
        for (i = 0; i < 16; i = i + 1) begin
            hex = i[3:0];
            #5;
            if (seg !== expected[i]) begin
                $display("FAIL: hex=%h expected=%b got=%b", i[3:0], expected[i], seg);
                fails = fails + 1;
            end else
                $display("PASS: hex=%h seg=%b", i[3:0], seg);
        end

        if (fails == 0) $display("=== 16 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
