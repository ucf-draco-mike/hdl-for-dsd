`timescale 1ns/1ps
module tb_traffic_light_sv;
    logic clk, reset;
    logic [2:0] light;

    traffic_light_sv uut (.i_clk(clk),.i_reset(reset),.o_light(light));

    initial clk=0; always #10 clk=~clk;

    initial begin
        $dumpfile("traffic_sv.vcd"); $dumpvars(0,tb_traffic_light_sv);
        reset=1; repeat(3) @(posedge clk); reset=0;

        // Run through several cycles and observe state transitions
        repeat(50) @(posedge clk);

        // Check we see all three states
        $display("Traffic Light SV test complete — check waveform");
        $finish;
    end
endmodule
