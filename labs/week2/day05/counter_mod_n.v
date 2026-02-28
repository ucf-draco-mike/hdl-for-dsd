// Modulo-N counter — counts 0 to N-1, then wraps
module counter_mod_n #(parameter N = 10) (
    input  wire i_clk, i_reset, i_enable,
    output reg  [$clog2(N)-1:0] o_count,
    output wire o_tick
);
    assign o_tick = (o_count == N - 1) && i_enable;

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == N - 1)
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end
endmodule
