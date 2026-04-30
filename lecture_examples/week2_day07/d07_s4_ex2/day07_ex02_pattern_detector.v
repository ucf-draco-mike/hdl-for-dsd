// =============================================================================
// day07_ex02_pattern_detector.v — Sequence Detector FSM (Moore)
// Day 7: Finite State Machines
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Detects the serial bit pattern "101" on i_serial_in.
// When the full pattern is recognized, o_detected pulses high for one state.
// Overlapping detection supported (e.g., 10101 detects twice).
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day07_ex02_pattern_detector.v && vvp sim
// Synth:  yosys -p "read_verilog day07_ex02_pattern_detector.v; synth_ice40 -top pattern_detector"
// =============================================================================

module pattern_detector (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_serial_in,
    output reg  o_detected
);

    // ---- State Encoding ----
    localparam S_IDLE  = 2'd0;   // Waiting for '1'
    localparam S_GOT1  = 2'd1;   // Seen '1'
    localparam S_GOT10 = 2'd2;   // Seen '10'
    localparam S_MATCH = 2'd3;   // Seen '101' — detect!

    reg [1:0] r_state, r_next_state;

    // ============================================================
    // Block 1 — State Register
    // ============================================================
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_IDLE;
        else
            r_state <= r_next_state;
    end

    // ============================================================
    // Block 2 — Next-State Logic
    // ============================================================
    always @(*) begin
        r_next_state = r_state;  // default: stay

        case (r_state)
            S_IDLE: begin
                if (i_serial_in)
                    r_next_state = S_GOT1;
            end

            S_GOT1: begin
                if (!i_serial_in)
                    r_next_state = S_GOT10;
                // else stay in S_GOT1 (still seeing 1s)
            end

            S_GOT10: begin
                if (i_serial_in)
                    r_next_state = S_MATCH;  // "101" complete!
                else
                    r_next_state = S_IDLE;   // "100" — restart
            end

            S_MATCH: begin
                // Overlap: after "101", the final '1' could start a new pattern
                if (i_serial_in)
                    r_next_state = S_GOT1;   // overlap: "101" → "1" of next
                else
                    r_next_state = S_GOT10;  // overlap: "101" → "10" of next
            end

            default: r_next_state = S_IDLE;
        endcase
    end

    // ============================================================
    // Block 3 — Output Logic (Moore)
    // ============================================================
    always @(*) begin
        o_detected = 1'b0;   // default

        case (r_state)
            S_MATCH: o_detected = 1'b1;
            default: o_detected = 1'b0;
        endcase
    end

endmodule

// =============================================================================
// Self-Checking Testbench
// =============================================================================
`ifdef SIMULATION
module tb_pattern_detector;
    reg  clk = 0, reset = 1, serial_in = 0;
    wire detected;

    pattern_detector uut (
        .i_clk(clk), .i_reset(reset),
        .i_serial_in(serial_in), .o_detected(detected)
    );

    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    task send_bit;
        input bit_val;
    begin
        serial_in = bit_val;
        @(posedge clk); #1;
    end
    endtask

    task check_detect;
        input exp;
        input [8*30-1:0] name;
    begin
        test_count = test_count + 1;
        if (detected !== exp) begin
            $display("FAIL: %0s — detected=%b (expected %b)", name, detected, exp);
            fail_count = fail_count + 1;
        end else
            $display("PASS: %0s — detected=%b", name, detected);
    end
    endtask

    initial begin
        $dumpfile("tb_pattern_detector.vcd");
        $dumpvars(0, tb_pattern_detector);

        $display("\n=== Pattern Detector FSM Testbench ===");
        $display("    Detecting: '101'\n");

        // Reset
        @(posedge clk); @(posedge clk);
        reset = 0;
        @(posedge clk); #1;

        // Test 1: Simple "101" detection
        send_bit(1);
        check_detect(0, "After '1'");
        send_bit(0);
        check_detect(0, "After '10'");
        send_bit(1);
        check_detect(0, "After '101' (detect next cycle)");
        @(posedge clk); #1;
        check_detect(1, "'101' DETECTED");

        // Test 2: "110" — no detection
        reset = 1; @(posedge clk); reset = 0; @(posedge clk); #1;
        send_bit(1); send_bit(1); send_bit(0);
        @(posedge clk); #1;
        check_detect(0, "'110' — no detect");

        // Test 3: Overlapping "10101" — should detect twice
        reset = 1; @(posedge clk); reset = 0; @(posedge clk); #1;
        send_bit(1); send_bit(0); send_bit(1);
        @(posedge clk); #1;
        check_detect(1, "First '101' in '10101'");
        send_bit(0); send_bit(1);
        @(posedge clk); #1;
        check_detect(1, "Second '101' (overlap)");

        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Tests: %0d  Passed: %0d  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
