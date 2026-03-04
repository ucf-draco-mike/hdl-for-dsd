// =============================================================================
// tb_pattern_detector.v — Pattern Detector FSM Testbench (Solution)
// Day 7, Exercise 2
// =============================================================================

`timescale 1ns / 1ps
`define SIMULATION

module tb_pattern_detector;

    reg clk, reset;
    reg btn1, btn2, btn3;
    wire detected;
    wire [1:0] progress;

    pattern_detector uut (
        .i_clk(clk), .i_reset(reset),
        .i_btn1(btn1), .i_btn2(btn2), .i_btn3(btn3),
        .o_detected(detected), .o_progress(progress)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    task press_btn;
        input integer which;
    begin
        @(posedge clk);
        case (which)
            1: begin btn1 = 1; @(posedge clk); btn1 = 0; end
            2: begin btn2 = 1; @(posedge clk); btn2 = 0; end
            3: begin btn3 = 1; @(posedge clk); btn3 = 0; end
        endcase
        @(posedge clk);  // let FSM react
    end
    endtask

    task check;
        input [1:0] exp_progress;
        input       exp_detected;
        input [80*8-1:0] label;
    begin
        test_count = test_count + 1;
        #1;
        if (progress !== exp_progress || detected !== exp_detected) begin
            fail_count = fail_count + 1;
            $display("FAIL: %0s — prog=%b det=%b (exp prog=%b det=%b)",
                     label, progress, detected, exp_progress, exp_detected);
        end else begin
            $display("PASS: %0s", label);
        end
    end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pattern_detector);
        btn1 = 0; btn2 = 0; btn3 = 0;
        reset = 1; repeat (3) @(posedge clk); reset = 0;
        @(posedge clk); #1;

        // Test 1: Correct sequence
        press_btn(1); check(2'b01, 1'b0, "After btn1: WAIT_2");
        press_btn(2); check(2'b10, 1'b0, "After btn2: WAIT_3");
        press_btn(3); check(2'b11, 1'b1, "After btn3: DETECTED");
        repeat (25) @(posedge clk);  // wait for timeout
        #1;
        check(2'b00, 1'b0, "After timeout: back to WAIT_1");

        // Test 2: Wrong sequence
        press_btn(2); check(2'b00, 1'b0, "btn2 first: stay WAIT_1");

        // Test 3: Partial then btn1 again
        press_btn(1); press_btn(2);
        check(2'b10, 1'b0, "btn1->btn2: WAIT_3");
        press_btn(1);
        check(2'b01, 1'b0, "btn1 in WAIT_3: restart to WAIT_2");

        // Test 4: Reset mid-sequence
        press_btn(1); press_btn(2);
        reset = 1; repeat (2) @(posedge clk); reset = 0;
        @(posedge clk); #1;
        check(2'b00, 1'b0, "Reset mid-sequence: WAIT_1");

        $display("");
        $display("========================================");
        $display("Pattern Detector: %0d / %0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
