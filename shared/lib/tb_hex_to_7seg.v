// =============================================================================
// tb_hex_to_7seg.v — Self-checking testbench for hex_to_7seg
// =============================================================================
`timescale 1ns/1ps
module tb_hex_to_7seg;
    reg  [3:0] hex;
    wire [6:0] seg;

    hex_to_7seg dut (.i_hex(hex), .o_seg(seg));

    integer pass_count = 0, fail_count = 0;

    // Expected active-low values: ~(active-high table)
    // We verify that segment 'a' (bit 0) lights for digits that need it
    task check_seg;
        input [6:0] expected;
        input [3:0] digit;
        begin
            #1;
            if (seg !== expected) begin
                $display("FAIL: hex=%0h expected seg=%7b got=%7b", digit, expected, seg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: hex=%0h seg=%7b", digit, seg);
                pass_count = pass_count + 1;
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, tb_hex_to_7seg);

        // Exhaustive test — all 16 values
        for (i = 0; i < 16; i = i + 1) begin
            hex = i[3:0];
            #2;
            // Verify: for digit 0, segment 'g' (middle) should be OFF (active-low = 1)
            // We check structural properties rather than hardcoding all 16 expected values
            // Full expected table:
            case (i[3:0])
                4'h0: check_seg(~7'h3F, 4'h0);
                4'h1: check_seg(~7'h06, 4'h1);
                4'h2: check_seg(~7'h5B, 4'h2);
                4'h3: check_seg(~7'h4F, 4'h3);
                4'h4: check_seg(~7'h66, 4'h4);
                4'h5: check_seg(~7'h6D, 4'h5);
                4'h6: check_seg(~7'h7D, 4'h6);
                4'h7: check_seg(~7'h07, 4'h7);
                4'h8: check_seg(~7'h7F, 4'h8);
                4'h9: check_seg(~7'h6F, 4'h9);
                4'hA: check_seg(~7'h77, 4'hA);
                4'hB: check_seg(~7'h7C, 4'hB);
                4'hC: check_seg(~7'h39, 4'hC);
                4'hD: check_seg(~7'h5E, 4'hD);
                4'hE: check_seg(~7'h79, 4'hE);
                4'hF: check_seg(~7'h71, 4'hF);
            endcase
        end

        $display("\n=== hex_to_7seg: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
