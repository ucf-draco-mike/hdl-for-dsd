// =============================================================================
// day07_ex01_traffic_gray.v — Traffic-Light FSM, GRAY-code encoding variant
// Day 7: Finite State Machines (Topic 7.3 State Encoding demo)
// =============================================================================
// Same behavior as day07_ex01_fsm_template.v, but state values change by
// exactly one bit per transition (Gray code).  Useful for clock-domain
// crossings — multi-bit transitions can sample as illegal intermediate
// codes; Gray prevents that.
//
// 3-state Gray sequence: 00 -> 01 -> 11 -> 00 ...
//   S_GREEN  = 2'b00
//   S_YELLOW = 2'b01
//   S_RED    = 2'b11
//   (2'b10 is unused; default-case routes any glitch back to S_GREEN.)
// =============================================================================
// Synth:  yosys -p "read_verilog day07_ex01_traffic_gray.v; \
//                   synth_ice40 -top traffic_light_gray -nofsm; stat"
// =============================================================================

module traffic_light_gray #(
    `ifdef SIMULATION
    parameter GREEN_TIME  = 10,
    parameter YELLOW_TIME = 4,
    parameter RED_TIME    = 10
    `else
    parameter GREEN_TIME  = 125_000_000,
    parameter YELLOW_TIME =  25_000_000,
    parameter RED_TIME    = 125_000_000
    `endif
)(
    input  wire i_clk,
    input  wire i_reset,
    output reg  o_red,
    output reg  o_yellow,
    output reg  o_green
);

    // ---- Gray-Code State Encoding (single-bit transitions) ----
    localparam [1:0] S_GREEN  = 2'b00;
    localparam [1:0] S_YELLOW = 2'b01;
    localparam [1:0] S_RED    = 2'b11;
    // 2'b10 is the unused legal codeword — covered by default.

    reg [1:0] r_state, r_next_state;

    // ---- Timer ----
    localparam MAX_TIME = (GREEN_TIME > RED_TIME) ? GREEN_TIME : RED_TIME;
    reg [$clog2(MAX_TIME)-1:0] r_timer;
    reg [$clog2(MAX_TIME)-1:0] r_timer_target;
    wire w_timer_done = (r_timer == r_timer_target);

    always @(*) begin
        case (r_state)
            S_GREEN:  r_timer_target = GREEN_TIME  - 1;
            S_YELLOW: r_timer_target = YELLOW_TIME - 1;
            S_RED:    r_timer_target = RED_TIME    - 1;
            default:  r_timer_target = GREEN_TIME  - 1;
        endcase
    end

    always @(posedge i_clk) begin
        if (i_reset || (r_state != r_next_state))
            r_timer <= 0;
        else if (!w_timer_done)
            r_timer <= r_timer + 1;
    end

    // Block 1 — State Register
    always @(posedge i_clk) begin
        if (i_reset) r_state <= S_GREEN;
        else         r_state <= r_next_state;
    end

    // Block 2 — Next-State Logic
    always @(*) begin
        r_next_state = r_state;
        case (r_state)
            S_GREEN:  if (w_timer_done) r_next_state = S_YELLOW;
            S_YELLOW: if (w_timer_done) r_next_state = S_RED;
            S_RED:    if (w_timer_done) r_next_state = S_GREEN;
            default:                    r_next_state = S_GREEN;
        endcase
    end

    // Block 3 — Output Logic (Moore)
    always @(*) begin
        o_red    = 1'b0;
        o_yellow = 1'b0;
        o_green  = 1'b0;
        case (r_state)
            S_GREEN:  o_green  = 1'b1;
            S_YELLOW: o_yellow = 1'b1;
            S_RED:    o_red    = 1'b1;
            default:  o_green  = 1'b1;  // safe default
        endcase
    end

endmodule
