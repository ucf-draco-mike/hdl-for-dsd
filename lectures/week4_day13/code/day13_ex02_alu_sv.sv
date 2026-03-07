// =============================================================================
// day13_ex02_alu_sv.sv — ALU Refactored in SystemVerilog
// Day 13: SystemVerilog for Design
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Demonstrates: logic, always_comb, enum for opcodes.
// Compared to Verilog version: stronger latch checking, typed opcodes.
// =============================================================================
// Build:  iverilog -g2012 -DSIMULATION -o sim day13_ex02_alu_sv.sv && vvp sim
// =============================================================================

module alu_sv #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0]  i_a,
    input  logic [WIDTH-1:0]  i_b,
    input  logic [1:0]        i_op,
    output logic [WIDTH-1:0]  o_result,
    output logic              o_carry,
    output logic              o_zero
);

    // ---- Opcode Enum ----
    typedef enum logic [1:0] {
        OP_ADD = 2'b00,
        OP_SUB = 2'b01,
        OP_AND = 2'b10,
        OP_OR  = 2'b11
    } alu_op_t;

    logic [WIDTH:0] full_result;   // extra bit for carry

    // always_comb: auto-sensitivity, catches latches
    always_comb begin
        full_result = '0;   // default prevents latch

        case (i_op)
            OP_ADD: full_result = {1'b0, i_a} + {1'b0, i_b};
            OP_SUB: full_result = {1'b0, i_a} - {1'b0, i_b};
            OP_AND: full_result = {1'b0, i_a & i_b};
            OP_OR:  full_result = {1'b0, i_a | i_b};
            default: full_result = '0;
        endcase
    end

    assign o_result = full_result[WIDTH-1:0];
    assign o_carry  = full_result[WIDTH];
    assign o_zero   = (o_result == '0);

endmodule

// =============================================================================
// Self-Checking Testbench
// =============================================================================
`ifdef SIMULATION
module tb_alu_sv;

    logic [3:0] a, b;
    logic [1:0] op;
    logic [3:0] result;
    logic       carry, zero;

    alu_sv #(.WIDTH(4)) uut (
        .i_a(a), .i_b(b), .i_op(op),
        .o_result(result), .o_carry(carry), .o_zero(zero)
    );

    int test_count = 0, fail_count = 0;

    task automatic check(
        input logic [3:0] ea, eb,
        input logic [1:0] eop,
        input logic [3:0] exp_res,
        input logic       exp_carry,
        input string      name
    );
    begin
        test_count++;
        a = ea; b = eb; op = eop;
        #1;
        if (result !== exp_res || carry !== exp_carry) begin
            $error("FAIL: %s — got %h c=%b, expected %h c=%b",
                   name, result, carry, exp_res, exp_carry);
            fail_count++;
        end else
            $display("PASS: %s — %h (carry=%b, zero=%b)", name, result, carry, zero);
    end
    endtask

    initial begin
        $display("\n=== ALU (SystemVerilog) Testbench ===\n");

        // ADD tests
        check(4'h3, 4'h5, 2'b00, 4'h8, 1'b0, "ADD 3+5=8");
        check(4'hF, 4'h1, 2'b00, 4'h0, 1'b1, "ADD F+1=0+carry");
        check(4'h0, 4'h0, 2'b00, 4'h0, 1'b0, "ADD 0+0=0 zero");

        // SUB tests
        check(4'h8, 4'h3, 2'b01, 4'h5, 1'b0, "SUB 8-3=5");
        check(4'h0, 4'h1, 2'b01, 4'hF, 1'b1, "SUB 0-1=F+borrow");

        // AND tests
        check(4'hF, 4'hA, 2'b10, 4'hA, 1'b0, "AND F&A=A");
        check(4'h5, 4'hA, 2'b10, 4'h0, 1'b0, "AND 5&A=0 zero");

        // OR tests
        check(4'h5, 4'hA, 2'b11, 4'hF, 1'b0, "OR 5|A=F");
        check(4'h0, 4'h0, 2'b11, 4'h0, 1'b0, "OR 0|0=0 zero");

        $display("\n=== SUMMARY ===");
        $display("Tests: %0d  Passed: %0d  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***\n");
        else                 $display("\n*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
