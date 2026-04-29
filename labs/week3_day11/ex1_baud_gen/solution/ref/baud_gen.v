module baud_gen #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_enable,
    output wire o_tick
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CNT_WIDTH    = $clog2(CLKS_PER_BIT);

    reg [CNT_WIDTH-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_reset || !i_enable)
            r_count <= 0;
        else if (r_count == CLKS_PER_BIT - 1)
            r_count <= 0;
        else
            r_count <= r_count + 1;
    end

    assign o_tick = (r_count == CLKS_PER_BIT - 1) && i_enable;
endmodule
