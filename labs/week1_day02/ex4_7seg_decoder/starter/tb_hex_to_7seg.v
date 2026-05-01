// =============================================================================
// tb_hex_to_7seg.v -- Baseline TB for hex_to_7seg (Day 2, Ex 4)
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
`timescale 1ns/1ps

module tb_hex_to_7seg;
    reg  [3:0] hex;
    wire [6:0] seg;

    hex_to_7seg dut (.i_hex(hex), .o_seg(seg));

    integer pass_count = 0, fail_count = 0;

    // Expected values: {a,b,c,d,e,f,g} active-low
    task check_seg;
        input [6:0] expected;
        input [3:0] digit;
        begin
            #1;
            if (seg === expected) begin
                $display("PASS: hex=%0h seg=%7b", digit, seg);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: hex=%0h expected=%7b got=%7b", digit, expected, seg);
                fail_count = fail_count + 1;
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_hex_to_7seg);

        for (i = 0; i < 16; i = i + 1) begin
            hex = i[3:0];
            case (i[3:0])
                4'h0: check_seg(7'b0000001, 4'h0);
                4'h1: check_seg(7'b1001111, 4'h1);
                4'h2: check_seg(7'b0010010, 4'h2);
                4'h3: check_seg(7'b0000110, 4'h3);
                4'h4: check_seg(7'b1001100, 4'h4);
                4'h5: check_seg(7'b0100100, 4'h5);
                4'h6: check_seg(7'b0100000, 4'h6);
                4'h7: check_seg(7'b0001111, 4'h7);
                4'h8: check_seg(7'b0000000, 4'h8);
                4'h9: check_seg(7'b0000100, 4'h9);
                4'hA: check_seg(7'b0001000, 4'hA);
                4'hB: check_seg(7'b1100000, 4'hB);
                4'hC: check_seg(7'b0110001, 4'hC);
                4'hD: check_seg(7'b1000010, 4'hD);
                4'hE: check_seg(7'b0110000, 4'hE);
                4'hF: check_seg(7'b0111000, 4'hF);
            endcase
        end

        $display("\n=== tb_hex_to_7seg: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
