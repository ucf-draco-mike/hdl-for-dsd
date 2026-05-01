// =============================================================================
// tb_before.v -- d06_s3 demo, "BEFORE" snapshot
// =============================================================================
//   Monolithic testbench, no tasks. 12 cases inlined, each with its own
//   stimulus block + check. Long, repetitive, hard to extend -- exactly the
//   pain point Mike refactors away in tb_after.v during d06_s3.
// =============================================================================
`timescale 1ns/1ps

module tb_before;
    reg  [7:0] a, b;
    wire [8:0] sum;
    integer passes = 0;
    integer fails  = 0;

    adder #(.WIDTH(8)) dut (.a(a), .b(b), .sum(sum));

    initial begin
        $dumpfile("tb_before.vcd");
        $dumpvars(0, tb_before);

        // Case 1
        a = 8'd0; b = 8'd0; #5;
        if (sum === 9'd0)   begin $display("PASS: 0+0");        passes=passes+1; end
        else                begin $display("FAIL: 0+0 -> %0d", sum); fails=fails+1; end

        // Case 2
        a = 8'd1; b = 8'd2; #5;
        if (sum === 9'd3)   begin $display("PASS: 1+2");        passes=passes+1; end
        else                begin $display("FAIL: 1+2 -> %0d", sum); fails=fails+1; end

        // Case 3
        a = 8'd5; b = 8'd7; #5;
        if (sum === 9'd12)  begin $display("PASS: 5+7");        passes=passes+1; end
        else                begin $display("FAIL: 5+7 -> %0d", sum); fails=fails+1; end

        // Case 4
        a = 8'd10; b = 8'd20; #5;
        if (sum === 9'd30)  begin $display("PASS: 10+20");      passes=passes+1; end
        else                begin $display("FAIL: 10+20 -> %0d", sum); fails=fails+1; end

        // Case 5
        a = 8'd100; b = 8'd50; #5;
        if (sum === 9'd150) begin $display("PASS: 100+50");     passes=passes+1; end
        else                begin $display("FAIL: 100+50 -> %0d", sum); fails=fails+1; end

        // Case 6
        a = 8'd200; b = 8'd100; #5;
        if (sum === 9'd300) begin $display("PASS: 200+100");    passes=passes+1; end
        else                begin $display("FAIL: 200+100 -> %0d", sum); fails=fails+1; end

        // Case 7
        a = 8'hFF; b = 8'd0; #5;
        if (sum === 9'd255) begin $display("PASS: FF+0");       passes=passes+1; end
        else                begin $display("FAIL: FF+0 -> %0d", sum); fails=fails+1; end

        // Case 8
        a = 8'hFF; b = 8'd1; #5;
        if (sum === 9'd256) begin $display("PASS: FF+1");       passes=passes+1; end
        else                begin $display("FAIL: FF+1 -> %0d", sum); fails=fails+1; end

        // Case 9
        a = 8'hFF; b = 8'hFF; #5;
        if (sum === 9'd510) begin $display("PASS: FF+FF");      passes=passes+1; end
        else                begin $display("FAIL: FF+FF -> %0d", sum); fails=fails+1; end

        // Case 10
        a = 8'd128; b = 8'd128; #5;
        if (sum === 9'd256) begin $display("PASS: 128+128");    passes=passes+1; end
        else                begin $display("FAIL: 128+128 -> %0d", sum); fails=fails+1; end

        // Case 11
        a = 8'h0F; b = 8'h0F; #5;
        if (sum === 9'd30)  begin $display("PASS: 0F+0F");      passes=passes+1; end
        else                begin $display("FAIL: 0F+0F -> %0d", sum); fails=fails+1; end

        // Case 12
        a = 8'h55; b = 8'hAA; #5;
        if (sum === 9'd255) begin $display("PASS: 55+AA");      passes=passes+1; end
        else                begin $display("FAIL: 55+AA -> %0d", sum); fails=fails+1; end

        $display("=== %0d passed, %0d failed ===", passes, fails);
        $finish;
    end
endmodule
