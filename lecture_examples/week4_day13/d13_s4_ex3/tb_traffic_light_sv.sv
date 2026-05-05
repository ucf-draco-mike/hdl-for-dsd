// =============================================================================
// tb_traffic_light_sv.sv -- Smoke testbench for traffic_light_sv
// Used by the segment-4 LIVE DEMO ("State Names in GTKWave"). Drives reset,
// runs through several phase transitions, and dumps a VCD that shows the
// `state` signal as the SV enum names (S_GREEN, S_YELLOW, S_RED) rather than
// raw 2'd0/2'd1/2'd2.
// =============================================================================
`timescale 1ns/1ps

module tb_traffic_light_sv;
    // Use the smallest legal phase length so the wave shows several
    // transitions without scrolling.
    localparam int TICKS_PER_PHASE = 4;

    logic       clk = 1'b0;
    logic       reset = 1'b1;
    logic [2:0] light;

    traffic_light_sv #(.TICKS_PER_PHASE(TICKS_PER_PHASE)) uut (
        .i_clk   (clk),
        .i_reset (reset),
        .o_light (light)
    );

    always #5 clk = ~clk;

    int passes = 0;
    int fails  = 0;

    task automatic check(input logic [2:0] exp, input string label);
        if (light !== exp) begin
            $display("FAIL: %s -- got %3b, expected %3b", label, light, exp);
            fails++;
        end else begin
            $display("PASS: %s -- light=%3b", label, light);
            passes++;
        end
    endtask

    initial begin
        $dumpfile("tb_traffic_light_sv.vcd");
        $dumpvars(0, tb_traffic_light_sv);
        $display("=== traffic_light_sv testbench ===");

        // Hold reset for a few cycles, then release
        repeat (3) @(posedge clk);
        reset = 1'b0;
        @(posedge clk);

        // After reset, FSM is in S_GREEN
        check(3'b001, "S_GREEN after reset");

        // Wait a full phase -> should advance to S_YELLOW
        repeat (TICKS_PER_PHASE) @(posedge clk);
        check(3'b010, "S_YELLOW after one phase");

        // Wait another phase -> S_RED
        repeat (TICKS_PER_PHASE) @(posedge clk);
        check(3'b100, "S_RED after two phases");

        // Wait another phase -> back to S_GREEN
        repeat (TICKS_PER_PHASE) @(posedge clk);
        check(3'b001, "S_GREEN after wrap-around");

        // Let it run a bit longer for the wave viewer
        repeat (3 * TICKS_PER_PHASE) @(posedge clk);

        $display("=== %0d passed, %0d failed ===", passes, fails);
        $finish;
    end

    initial begin
        #20_000;
        $display("FAIL: watchdog timeout");
        $finish;
    end
endmodule
