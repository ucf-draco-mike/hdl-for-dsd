module debounce #(parameter DEBOUNCE_LIMIT = 250000)(
    input  wire i_clk, input wire i_switch, output reg o_switch);
    reg r_sync_0, r_sync_1;
    always @(posedge i_clk) begin r_sync_0 <= i_switch; r_sync_1 <= r_sync_0; end
    reg [$clog2(DEBOUNCE_LIMIT)-1:0] r_count; reg r_state;
    always @(posedge i_clk) begin
        if (r_sync_1 != r_state && r_count < DEBOUNCE_LIMIT-1) r_count <= r_count+1;
        else if (r_count == DEBOUNCE_LIMIT-1) begin r_state <= r_sync_1; r_count <= 0; end
        else r_count <= 0;
        o_switch <= r_state;
    end
endmodule
