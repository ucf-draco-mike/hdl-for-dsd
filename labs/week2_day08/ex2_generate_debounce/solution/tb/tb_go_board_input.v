// Minimal testbench for go_board_input — uses a small CLK_FREQ override so
// debounce settles in a viewable simulation window.
`timescale 1ns/1ps

module tb_go_board_input;
    localparam N = 4;
    reg          i_clk = 0;
    reg  [N-1:0] i_buttons = 0;
    wire [N-1:0] o_buttons, o_press_edge, o_release_edge;

    always #20 i_clk = ~i_clk;  // 25 MHz

    go_board_input #(
        .N_BUTTONS(N), .CLK_FREQ(25_000), .DEBOUNCE_MS(1)
    ) dut (
        .i_clk(i_clk), .i_buttons(i_buttons),
        .o_buttons(o_buttons),
        .o_press_edge(o_press_edge),
        .o_release_edge(o_release_edge)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_go_board_input);
        #2000 i_buttons = 4'b0001;
        #2000 i_buttons = 4'b0011;
        #2000 i_buttons = 4'b0000;
        #2000;
        $finish;
    end
endmodule
