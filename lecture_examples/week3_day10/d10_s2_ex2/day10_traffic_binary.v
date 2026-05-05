// =============================================================================
// day10_traffic_binary.v — Traffic-light FSM, BINARY encoding
// Day 10: Numerical Architectures & Design Trade-offs (PPA demo)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Same FSM as d07_s2_ex1. Three encoding variants live side-by-side here so
// `make ppa_report` can synthesize all three and emit a comparable CSV row.
//
//   Encoding: 2-bit binary  (00,01,10) — minimum FF count.
// =============================================================================

module traffic_binary (
    input  wire i_clk,
    input  wire i_reset,
    output reg  o_red,
    output reg  o_yellow,
    output reg  o_green
);

    // ---- Encoding ----
    localparam [1:0] S_GREEN  = 2'd0;
    localparam [1:0] S_YELLOW = 2'd1;
    localparam [1:0] S_RED    = 2'd2;

    reg [1:0] state, next_state;

    // Tick counter — short cycles for synth-only PPA reporting.
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
        o_red    = 1'b0;
        o_yellow = 1'b0;
        o_green  = 1'b0;
        case (state)
            S_GREEN:  o_green  = 1'b1;
            S_YELLOW: o_yellow = 1'b1;
            S_RED:    o_red    = 1'b1;
        endcase
    end

endmodule
