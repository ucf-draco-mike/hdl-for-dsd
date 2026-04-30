// =============================================================================
// tb_pattern_detector.v — Smoke testbench for pattern_detector ('101' Moore)
// =============================================================================
`timescale 1ns/1ps

module tb_pattern_detector;
    reg  clk = 1'b0, reset = 1'b1, serial_in = 1'b0;
    wire detected;

    pattern_detector uut (
        .i_clk(clk), .i_reset(reset),
        .i_serial_in(serial_in), .o_detected(detected)
    );

    always #5 clk = ~clk;

    integer fails = 0;

    task send(input bit_val);
        begin
            serial_in = bit_val;
            @(posedge clk);
        end
    endtask

    task check_after_settle(input exp, input [255:0] name);
        begin
            #1;
            if (detected !== exp) begin
                $display("FAIL: %0s — got %b, expected %b", name, detected, exp);
                fails = fails + 1;
            end else
                $display("PASS: %0s — detected=%b", name, detected);
        end
    endtask

    initial begin
        $dumpfile("tb_pattern_detector.vcd");
        $dumpvars(0, tb_pattern_detector);

        // Hold reset through two posedges so state register lands in S_IDLE
        @(posedge clk); @(posedge clk);
        reset = 1'b0;

        // Send "101" — detected should be high in cycle following the final '1'
        send(1'b1);  check_after_settle(1'b0, "after '1'");
        send(1'b0);  check_after_settle(1'b0, "after '10'");
        send(1'b1);  check_after_settle(1'b1, "after '101'  -> detected");

        // Continue with '0' — Moore output drops back
        send(1'b0);  check_after_settle(1'b0, "after '1010'");

        // Overlap test: send another '1' immediately after '0'
        send(1'b1);  check_after_settle(1'b1, "overlap '10101' second match");

        // Negative case: '110' should NOT detect
        send(1'b1);  check_after_settle(1'b0, "after extra '1' (no match)");
        send(1'b0);  check_after_settle(1'b0, "after '0' (no match)");

        if (fails == 0) $display("=== 7 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
