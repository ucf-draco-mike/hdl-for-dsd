// =============================================================================
// tb_shift_reg_sipo.v -- Smoke testbench for shift_reg_sipo
// Mirrors the slide demo: stream the bit pattern 1, 0, 1, 1, 0, 0, 1, 0
// (MSB-first when read out of the parallel register) and confirm the
// assembled byte is 0xB2.
// =============================================================================
`timescale 1ns/1ps

module tb_shift_reg_sipo;
    reg        clk = 1'b0, reset = 1'b1, shift_en = 1'b0, serial_in = 1'b0;
    wire [7:0] parallel_out;

    shift_reg_sipo #(.WIDTH(8)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_shift_en(shift_en), .i_serial_in(serial_in),
        .o_parallel_out(parallel_out)
    );

    always #20 clk = ~clk;

    // Bit stream the slide traces: first bit becomes MSB.
    // 1, 0, 1, 1, 0, 0, 1, 0  ->  10110010 = 0xB2
    reg [7:0] stream  = 8'b10110010;
    // Per-cycle expected snapshots after each shift (LSB-first build-up).
    reg [7:0] expect [0:7];
    initial begin
        expect[0] = 8'b00000001;
        expect[1] = 8'b00000010;
        expect[2] = 8'b00000101;
        expect[3] = 8'b00001011;
        expect[4] = 8'b00010110;
        expect[5] = 8'b00101100;
        expect[6] = 8'b01011001;
        expect[7] = 8'b10110010;
    end

    integer i, fail_count = 0;

    initial begin
        $dumpfile("tb_shift_reg_sipo.vcd");
        $dumpvars(0, tb_shift_reg_sipo);

        // Hold reset, then release.
        repeat (3) @(posedge clk);
        @(posedge clk); reset = 1'b0; shift_en = 1'b1;

        // Stream the 8 bits, MSB-first: stream[7], stream[6], ..., stream[0].
        for (i = 0; i < 8; i = i + 1) begin
            serial_in = stream[7-i];
            @(posedge clk); #1;
            $display("Cycle %0d: in=%b, par=%08b", i+1, stream[7-i], parallel_out);
            if (parallel_out !== expect[i]) begin
                $display("FAIL: expected par=%08b, got par=%08b", expect[i], parallel_out);
                fail_count = fail_count + 1;
            end
        end

        if (parallel_out === 8'hB2) begin
            $display("PASS: assembled 0x%02h", parallel_out);
        end else begin
            $display("FAIL: expected 0xB2, got 0x%02h", parallel_out);
            fail_count = fail_count + 1;
        end

        if (fail_count == 0) $display("\n=== all checks passed ===");
        else                 $display("\n*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
