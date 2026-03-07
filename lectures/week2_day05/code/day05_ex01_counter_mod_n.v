// =============================================================================
// day05_ex01_counter_mod_n.v — Parameterized Modulo-N Counter
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Build:  iverilog -o sim day05_ex01_counter_mod_n.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex01_counter_mod_n.v; synth_ice40 -top counter_mod_n"
// =============================================================================

module counter_mod_n #(
    parameter N = 10
)(
    input  wire                     i_clk,
    input  wire                     i_reset,
    input  wire                     i_enable,
    output reg  [$clog2(N)-1:0]     o_count,
    output wire                     o_wrap
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == N - 1)
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end

    assign o_wrap = i_enable && (o_count == N - 1);

endmodule

// =============================================================================
// Quick self-test (simulation only)
// =============================================================================
`ifdef SIMULATION
module tb_counter_mod_n;
    reg clk = 0, reset = 1, enable = 0;
    wire [3:0] count;
    wire       wrap;

    counter_mod_n #(.N(10)) uut (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count), .o_wrap(wrap)
    );

    always #20 clk = ~clk;

    integer fail_count = 0;

    initial begin
        $dumpfile("tb_counter_mod_n.vcd");
        $dumpvars(0, tb_counter_mod_n);

        #100; reset = 0; enable = 1;

        // Let it count through two full cycles (20 clocks for mod-10)
        repeat (20) @(posedge clk);
        #1;
        if (count !== 0) begin
            $display("FAIL: Expected 0 after 20 clocks, got %0d", count);
            fail_count = fail_count + 1;
        end else
            $display("PASS: Counter wrapped correctly after 20 clocks");

        // Check wrap pulse
        repeat (8) @(posedge clk);  // count = 8
        @(posedge clk); #1;        // count = 9
        if (wrap !== 1) begin
            $display("FAIL: wrap should be 1 at count 9");
            fail_count = fail_count + 1;
        end else
            $display("PASS: wrap asserted at count 9");

        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***");
        else $display("\n*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
`endif
