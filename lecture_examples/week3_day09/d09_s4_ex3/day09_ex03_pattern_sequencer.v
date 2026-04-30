// =============================================================================
// day09_ex03_pattern_sequencer.v — ROM-Based LED Pattern Player
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Steps through a ROM loaded from a .mem file.
// i_next advances the address. o_pattern drives LEDs / 7-seg.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day09_ex03_pattern_sequencer.v && vvp sim
// Synth:  yosys -p "read_verilog day09_ex03_pattern_sequencer.v; synth_ice40 -top pattern_sequencer"
// =============================================================================

module pattern_sequencer #(
    parameter DEPTH    = 16,
    parameter WIDTH    = 8,
    parameter MEM_FILE = "pattern.mem"
)(
    input  wire             i_clk,
    input  wire             i_reset,
    input  wire             i_next,     // advance one step
    output wire [WIDTH-1:0] o_pattern
);

    reg [WIDTH-1:0] r_mem [0:DEPTH-1];

    initial begin
        $readmemb(MEM_FILE, r_mem);
    end

    reg [$clog2(DEPTH)-1:0] r_addr;

    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (i_next)
            r_addr <= (r_addr == DEPTH - 1) ? 0 : r_addr + 1;
    end

    // Async read is fine for 16 entries (LUT-based)
    assign o_pattern = r_mem[r_addr];

endmodule

// =============================================================================
// Self-Checking Testbench
// =============================================================================
`ifdef SIMULATION
module tb_pattern_sequencer;
    reg        clk = 0, reset = 1, next = 0;
    wire [7:0] pattern;

    pattern_sequencer #(
        .DEPTH(16), .WIDTH(8),
        .MEM_FILE("pattern.mem")
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_next(next), .o_pattern(pattern)
    );

    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    initial begin
        $dumpfile("tb_pattern_seq.vcd");
        $dumpvars(0, tb_pattern_sequencer);
        #100; reset = 0;
        @(posedge clk); #1;

        $display("\n=== Pattern Sequencer Testbench ===\n");

        // Verify first pattern at addr 0 (walking 1)
        test_count = test_count + 1;
        if (pattern !== 8'b00000001) begin
            $display("FAIL: addr 0 expected 00000001, got %b", pattern);
            fail_count = fail_count + 1;
        end else
            $display("PASS: addr 0 = %b", pattern);

        // Step through all 16 patterns
        for (i = 1; i < 16; i = i + 1) begin
            next = 1; @(posedge clk); next = 0; @(posedge clk); #1;
            test_count = test_count + 1;
            $display("  addr %0d = %b", i, pattern);
        end

        // Verify wrap-around
        next = 1; @(posedge clk); next = 0; @(posedge clk); #1;
        test_count = test_count + 1;
        if (pattern !== 8'b00000001) begin
            $display("FAIL: wrap — expected 00000001, got %b", pattern);
            fail_count = fail_count + 1;
        end else
            $display("PASS: Wrapped back to addr 0");

        $display("\n=== SUMMARY: %0d/%0d passed ===",
                 test_count - fail_count, test_count);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
