// =============================================================================
// tb_top_with_three_counters.v — self-checking testbench
// Day 8: Hierarchy, Parameters & Generate
// =============================================================================
// Verifies that each of the three parameterized counter instances rolls
// over at the correct width-dependent value (2^WIDTH - 1). The same RTL
// (counter.v) produces three different hardware sizes; each is checked
// independently.
// =============================================================================
`timescale 1ns/1ps

module tb_top_with_three_counters;

    reg         clk    = 1'b0;
    reg         reset  = 1'b1;
    reg         enable = 1'b0;
    wire [3:0]  cnt_4;
    wire [7:0]  cnt_8;
    wire [15:0] cnt_16;
    wire        ro_4, ro_8, ro_16;

    top dut (
        .i_clk         (clk),
        .i_reset       (reset),
        .i_enable      (enable),
        .o_cnt_4bit    (cnt_4),
        .o_cnt_8bit    (cnt_8),
        .o_cnt_16bit   (cnt_16),
        .o_rollover_4  (ro_4),
        .o_rollover_8  (ro_8),
        .o_rollover_16 (ro_16)
    );

    always #5 clk = ~clk;       // 100 MHz

    integer pass = 0;
    integer fail = 0;

    task check;
        input        cond;
        input [511:0] msg;
    begin
        if (cond) begin
            $display("PASS: %0s", msg);
            pass = pass + 1;
        end else begin
            $display("FAIL: %0s", msg);
            fail = fail + 1;
        end
    end
    endtask

    integer ro4_pulses  = 0;
    integer ro8_pulses  = 0;
    integer ro16_pulses = 0;

    always @(posedge clk) begin
        if (ro_4)  ro4_pulses  <= ro4_pulses  + 1;
        if (ro_8)  ro8_pulses  <= ro8_pulses  + 1;
        if (ro_16) ro16_pulses <= ro16_pulses + 1;
    end

    initial begin
        $dumpfile("tb_top_with_three_counters.vcd");
        $dumpvars(0, tb_top_with_three_counters);
        $display("\n=== top_with_three_counters testbench ===\n");

        // Hold reset and verify all three counters read zero.
        reset  = 1'b1;
        enable = 1'b0;
        repeat (4) @(posedge clk);
        #1;
        check(cnt_4  === 4'd0,  "4-bit reset");
        check(cnt_8  === 8'd0,  "8-bit reset");
        check(cnt_16 === 16'd0, "16-bit reset");

        // Deassert reset and start counting. The next posedge takes count
        // from 0 to 1 in every instance.
        ro4_pulses = 0; ro8_pulses = 0; ro16_pulses = 0;
        reset  = 1'b0;
        enable = 1'b1;

        // 16 enabled cycles: 4-bit wraps once, 8-bit/16-bit do not.
        repeat (16) @(posedge clk);
        #1;
        check(ro4_pulses == 1,  "4-bit rolls over at 2^4");
        check(ro8_pulses == 0,  "8-bit has not rolled over yet");
        check(cnt_4 === 4'd0,   "4-bit wraps to 0 after 16 cycles");

        // Continue to 256 enabled cycles total. 4-bit has rolled over 16x,
        // 8-bit rolls over for the first time, 16-bit reads 256.
        repeat (256 - 16) @(posedge clk);
        #1;
        check(ro4_pulses  == 16, "4-bit rolled over 16 times in 256 cycles");
        check(ro8_pulses  == 1,  "8-bit rolls over at 2^8");
        check(ro16_pulses == 0,  "16-bit has not rolled over yet");
        check(cnt_4  === 4'd0,    "4-bit wraps to 0 after 256 cycles");
        check(cnt_8  === 8'd0,    "8-bit wraps to 0 after 256 cycles");
        check(cnt_16 === 16'd256, "16-bit reads 256 after 256 cycles");

        // Enable-low must freeze every counter.
        enable = 1'b0;
        repeat (32) @(posedge clk);
        #1;
        check(cnt_4  === 4'd0,    "4-bit frozen with enable low");
        check(cnt_8  === 8'd0,    "8-bit frozen with enable low");
        check(cnt_16 === 16'd256, "16-bit frozen with enable low");

        $display("\n=== %0d passed, %0d failed ===\n", pass, fail);
        if (fail == 0) $display("*** ALL TESTS PASSED ***\n");
        $finish;
    end

    initial begin
        #200_000;
        $display("FAIL: simulation timed out");
        $finish;
    end

endmodule
