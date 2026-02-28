// UART Receiver — 8N1 with oversampling
// Built: Day 12 | Tested: Day 12
module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk, i_reset, i_rx,
    output reg  [7:0] o_data,
    output reg        o_valid
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT     = CLKS_PER_BIT / 2;
    localparam S_IDLE=0, S_START=1, S_DATA=2, S_STOP=3;
    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_cnt;
    reg [7:0] r_shift;
    reg [2:0] r_bit_idx;
    reg r_rx0, r_rx1;
    always @(posedge i_clk) begin r_rx0<=i_rx; r_rx1<=r_rx0; end
    always @(posedge i_clk) begin
        if (i_reset) begin r_state<=S_IDLE; o_valid<=0; end
        else begin
            o_valid <= 0;
            case (r_state)
                S_IDLE:  begin r_clk_cnt<=0; r_bit_idx<=0;
                         if (!r_rx1) r_state<=S_START; end
                S_START: if (r_clk_cnt==HALF_BIT-1) begin
                             if (!r_rx1) begin r_clk_cnt<=0; r_state<=S_DATA; end
                             else r_state<=S_IDLE;
                         end else r_clk_cnt<=r_clk_cnt+1;
                S_DATA:  if (r_clk_cnt==CLKS_PER_BIT-1) begin
                             r_clk_cnt<=0; r_shift<={r_rx1,r_shift[7:1]};
                             if (r_bit_idx==7) r_state<=S_STOP;
                             else r_bit_idx<=r_bit_idx+1;
                         end else r_clk_cnt<=r_clk_cnt+1;
                S_STOP:  if (r_clk_cnt==CLKS_PER_BIT-1) begin
                             o_data<=r_shift; o_valid<=1; r_state<=S_IDLE;
                         end else r_clk_cnt<=r_clk_cnt+1;
            endcase
        end
    end
endmodule
