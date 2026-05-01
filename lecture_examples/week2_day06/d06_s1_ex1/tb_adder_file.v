// =============================================================================
// tb_adder_file.v -- d06_s4 "1000-Vector Adder Test" Live Demo
// =============================================================================
//   Reads `vectors.hex` (produced by gen_vectors.py) into a 32-bit-wide
//   memory, applies each line's a/b operands to the adder, and asserts
//   the DUT's sum matches the golden value baked into the same line.
//
//   Each `vectors.hex` line is a single 32-bit word:
//     [31:24] = a   [23:16] = b   [15:0] = expected sum
//
//   Run with:
//     iverilog -g2012 -o sim.vvp tb_adder_file.v adder.v
//     vvp sim.vvp
//
//   Final stdout looks like:
//     === 1000 passed, 0 failed ===
// =============================================================================
`timescale 1ns/1ps

module tb_adder_file;
    parameter MAX_VECTORS = 4096;
    parameter VECTOR_FILE = "vectors.hex";

    reg  [31:0] mem [0:MAX_VECTORS-1];

    reg  [7:0] a, b;
    wire [8:0] sum;

    adder #(.WIDTH(8)) dut (.a(a), .b(b), .sum(sum));

    integer i;
    integer count;
    integer passes;
    integer fails;
    reg [15:0] expected;

    initial begin
        $dumpfile("tb_adder_file.vcd");
        $dumpvars(0, tb_adder_file);

        // Seed memory with 'x so we can detect end of file.
        for (i = 0; i < MAX_VECTORS; i = i + 1) mem[i] = 32'hxxxx_xxxx;

        $readmemh(VECTOR_FILE, mem);

        passes = 0;
        fails  = 0;
        count  = 0;

        for (i = 0; i < MAX_VECTORS; i = i + 1) begin
            if (^mem[i] === 1'bx) begin
                // hit the unwritten tail; stop the loop.
                i = MAX_VECTORS;
            end else begin
                a        = mem[i][31:24];
                b        = mem[i][23:16];
                expected = mem[i][15:0];
                #1;
                count = count + 1;
                if (sum === expected[8:0]) begin
                    passes = passes + 1;
                end else begin
                    $display("FAIL [%0d]: %0d + %0d expected=%0d got=%0d",
                             count, a, b, expected, sum);
                    fails = fails + 1;
                end
            end
        end

        if (count == 0)
            $display("ERROR: 0 vectors loaded -- did you run gen_vectors.py?");
        $display("=== %0d passed, %0d failed ===", passes, fails);
        $finish;
    end
endmodule
