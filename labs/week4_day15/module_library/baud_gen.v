// baud_gen.v — Baud rate tick generator
// Produces a single-cycle pulse at the baud rate
module baud_gen #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire i_clk,
    input  wire i_rst,
    output reg  o_tick
);
    localparam COUNT_MAX = CLK_FREQ / BAUD_RATE - 1;
    reg [$clog2(COUNT_MAX+1)-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_rst) begin
            r_count <= 0;
            o_tick  <= 1'b0;
        end else if (r_count == COUNT_MAX) begin
            r_count <= 0;
            o_tick  <= 1'b1;
        end else begin
            r_count <= r_count + 1;
            o_tick  <= 1'b0;
        end
    end
endmodule
