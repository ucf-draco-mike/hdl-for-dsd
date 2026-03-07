// =============================================================================
// tb_adder.v — Baseline TB for full_adder + ripple_adder_4bit (Day 2, Ex 3)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
`timescale 1ns/1ps

module tb_adder;

    // --- Full Adder (exhaustive: 8 combinations) ---
    reg  fa_a, fa_b, fa_cin;
    wire fa_sum, fa_cout;

    full_adder dut_fa (
        .i_a(fa_a), .i_b(fa_b), .i_cin(fa_cin),
        .o_sum(fa_sum), .o_cout(fa_cout)
    );

    // --- 4-bit Ripple Adder (sampled) ---
    reg  [3:0] ra_a, ra_b;
    reg        ra_cin;
    wire [3:0] ra_sum;
    wire       ra_cout;

    ripple_adder_4bit dut_ra (
        .i_a(ra_a), .i_b(ra_b), .i_cin(ra_cin),
        .o_sum(ra_sum), .o_cout(ra_cout)
    );

    integer pass_count = 0, fail_count = 0;
    integer i;
    reg [1:0] expected_fa;
    reg [4:0] expected_ra;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_adder);

        // --- Full Adder: exhaustive ---
        $display("--- full_adder (exhaustive) ---");
        for (i = 0; i < 8; i = i + 1) begin
            {fa_a, fa_b, fa_cin} = i[2:0];
            #1;
            expected_fa = fa_a + fa_b + fa_cin;
            if ({fa_cout, fa_sum} === expected_fa) begin
                $display("PASS: a=%b b=%b cin=%b -> cout=%b sum=%b",
                         fa_a, fa_b, fa_cin, fa_cout, fa_sum);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: a=%b b=%b cin=%b -> cout=%b sum=%b (expected %b%b)",
                         fa_a, fa_b, fa_cin, fa_cout, fa_sum,
                         expected_fa[1], expected_fa[0]);
                fail_count = fail_count + 1;
            end
        end

        // --- Ripple Adder: sampled test vectors ---
        $display("--- ripple_adder_4bit (sampled) ---");

        // Test 1: 0+0+0
        ra_a=0; ra_b=0; ra_cin=0; #1;
        expected_ra = 0;
        if ({ra_cout,ra_sum}===expected_ra) begin $display("PASS: 0+0+0=%0d",{ra_cout,ra_sum}); pass_count=pass_count+1; end
        else begin $display("FAIL: 0+0+0=%0d expected %0d",{ra_cout,ra_sum},expected_ra); fail_count=fail_count+1; end

        // Test 2: 3+5 = 8
        ra_a=4'd3; ra_b=4'd5; ra_cin=0; #1;
        expected_ra = 8;
        if ({ra_cout,ra_sum}===expected_ra) begin $display("PASS: 3+5=%0d",{ra_cout,ra_sum}); pass_count=pass_count+1; end
        else begin $display("FAIL: 3+5=%0d expected %0d",{ra_cout,ra_sum},expected_ra); fail_count=fail_count+1; end

        // Test 3: 15+1 = 16 (carry out)
        ra_a=4'd15; ra_b=4'd1; ra_cin=0; #1;
        expected_ra = 16;
        if ({ra_cout,ra_sum}===expected_ra) begin $display("PASS: 15+1=%0d (carry)", {ra_cout,ra_sum}); pass_count=pass_count+1; end
        else begin $display("FAIL: 15+1=%0d expected %0d",{ra_cout,ra_sum},expected_ra); fail_count=fail_count+1; end

        // Test 4: 15+15+1 = 31 (max)
        ra_a=4'd15; ra_b=4'd15; ra_cin=1; #1;
        expected_ra = 31;
        if ({ra_cout,ra_sum}===expected_ra) begin $display("PASS: 15+15+1=%0d (max)",{ra_cout,ra_sum}); pass_count=pass_count+1; end
        else begin $display("FAIL: 15+15+1=%0d expected %0d",{ra_cout,ra_sum},expected_ra); fail_count=fail_count+1; end

        // Test 5: 7+8+0 = 15 (no carry)
        ra_a=4'd7; ra_b=4'd8; ra_cin=0; #1;
        expected_ra = 15;
        if ({ra_cout,ra_sum}===expected_ra) begin $display("PASS: 7+8=%0d",{ra_cout,ra_sum}); pass_count=pass_count+1; end
        else begin $display("FAIL: 7+8=%0d expected %0d",{ra_cout,ra_sum},expected_ra); fail_count=fail_count+1; end

        // Test 6: 9+9+1 = 19 (carry)
        ra_a=4'd9; ra_b=4'd9; ra_cin=1; #1;
        expected_ra = 19;
        if ({ra_cout,ra_sum}===expected_ra) begin $display("PASS: 9+9+1=%0d",{ra_cout,ra_sum}); pass_count=pass_count+1; end
        else begin $display("FAIL: 9+9+1=%0d expected %0d",{ra_cout,ra_sum},expected_ra); fail_count=fail_count+1; end

        $display("\n=== tb_adder: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
