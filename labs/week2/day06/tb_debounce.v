// Debounce module testbench template
`timescale 1ns / 1ps

module tb_debounce;
    reg  r_clk = 0;
    reg  r_bouncy;
    wire w_clean;

    // Use small threshold for simulation speed
    debounce #(.CLKS_TO_STABLE(10)) uut (
        .i_clk(r_clk), .i_bouncy(r_bouncy), .o_clean(w_clean)
    );

    always #20 r_clk = ~r_clk;  // 25 MHz

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce);
        r_bouncy = 1; // unpressed

        // TODO: Test clean press, bounce rejection, glitch rejection
        #1000;

        $display("Debounce testbench complete — inspect waveforms");
        $finish;
    end
endmodule
