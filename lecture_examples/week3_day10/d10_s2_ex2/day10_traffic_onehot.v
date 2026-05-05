// =============================================================================
// day10_traffic_onehot.v — Traffic-light FSM, ONE-HOT encoding
// Day 10: Numerical Architectures & Design Trade-offs (PPA demo)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
//   Encoding: 3-bit one-hot (001,010,100) — fastest next-state logic, more FFs.
// =============================================================================

module traffic_onehot (
    input  wire i_clk,
    input  wire i_reset,
    output reg  o_red,
    output reg  o_yellow,
    output reg  o_green
);

    // ---- Encoding ----
    localparam [2:0] S_GREEN  = 3'b001;
    localparam [2:0] S_YELLOW = 3'b010;
    localparam [2:0] S_RED    = 3'b100;

    reg [2:0] state, next_state;

    localparam GREEN_TIME  = 8'd200;
    localparam YELLOW_TIME = 8'd60;
    localparam RED_TIME    = 8'd200;
    reg [7:0] tick;
    wire timer_done = (state == S_GREEN  && tick == GREEN_TIME  - 1) ||
                      (state == S_YELLOW && tick == YELLOW_TIME - 1) ||
                      (state == S_RED    && tick == RED_TIME    - 1);

    always @(posedge i_clk) begin
        if (i_reset) begin
            state <= S_GREEN;
            tick  <= 8'd0;
        end else begin
            state <= next_state;
            tick  <= timer_done ? 8'd0 : tick + 1'b1;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            S_GREEN:  if (timer_done) next_state = S_YELLOW;
            S_YELLOW: if (timer_done) next_state = S_RED;
            S_RED:    if (timer_done) next_state = S_GREEN;
            default:                  next_state = S_GREEN;
        endcase
    end

    always @(*) begin
        o_green  = state[0];
        o_yellow = state[1];
        o_red    = state[2];
    end

endmodule
