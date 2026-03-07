// =============================================================================
// day05_ex02_shift_reg_piso.v — Parallel-In Serial-Out Shift Register
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// This is the core building block for UART TX (Week 3).
// Load a byte, then shift it out LSB-first one bit per clock.
// =============================================================================
// Build:  iverilog -o sim day05_ex02_shift_reg_piso.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex02_shift_reg_piso.v; synth_ice40 -top shift_reg_piso"
// =============================================================================

module shift_reg_piso #(
    parameter WIDTH = 8
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_load,
    input  wire              i_shift_en,
    input  wire [WIDTH-1:0]  i_parallel_in,
    output wire              o_serial_out
);

    reg [WIDTH-1:0] r_shift;

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= {WIDTH{1'b0}};
        else if (i_load)
            r_shift <= i_parallel_in;       // load wins over shift
        else if (i_shift_en)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};  // shift right, fill MSB with 0
    end

    assign o_serial_out = r_shift[0];       // LSB first (UART convention)

endmodule

// =============================================================================
// Quick self-test
// =============================================================================
`ifdef SIMULATION
module tb_shift_reg_piso;
    reg        clk = 0, reset = 1, load = 0, shift_en = 0;
    reg  [7:0] parallel_in;
    wire       serial_out;

    shift_reg_piso #(.WIDTH(8)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_load(load), .i_shift_en(shift_en),
        .i_parallel_in(parallel_in),
        .o_serial_out(serial_out)
    );

    always #20 clk = ~clk;

    integer i, fail_count = 0;
    reg [7:0] test_byte;
    reg expected_bit;

    initial begin
        $dumpfile("tb_shift_reg_piso.vcd");
        $dumpvars(0, tb_shift_reg_piso);

        #100; reset = 0;
        test_byte = 8'hA5;  // 10100101 — good mix of 0s and 1s

        // Load the byte
        @(posedge clk);
        parallel_in = test_byte;
        load = 1;
        @(posedge clk);
        load = 0;
        shift_en = 1;

        // Shift out 8 bits and verify LSB-first
        for (i = 0; i < 8; i = i + 1) begin
            expected_bit = test_byte[i];
            #1;
            if (serial_out !== expected_bit) begin
                $display("FAIL: Bit %0d — expected %b, got %b", i, expected_bit, serial_out);
                fail_count = fail_count + 1;
            end else
                $display("PASS: Bit %0d = %b", i, serial_out);
            @(posedge clk);
        end

        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***");
        else $display("\n*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
`endif
