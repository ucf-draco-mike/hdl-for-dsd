// =============================================================================
// day07_ex01_traffic_onehot.v — Traffic-Light FSM, ONE-HOT encoding variant
// Day 7: Finite State Machines (Topic 7.3 State Encoding demo)
// =============================================================================
// Same behavior as day07_ex01_fsm_template.v, but:
//   - State register is N bits wide (one bit per state)
//   - Exactly one bit is high in any legal state
//   - Output decode reduces to a single wire per state (no logic)
//
// Synth comparison (iCE40, 3 states):
//   binary :  2 SB_DFF + ~5 SB_LUT4
//   one-hot:  3 SB_DFF + ~3 SB_LUT4   (cheaper output decode)
// =============================================================================
// Synth:  yosys -p "read_verilog day07_ex01_traffic_onehot.v; \
//                   synth_ice40 -top traffic_light_onehot -nofsm; stat"
// =============================================================================

module traffic_light_onehot #(
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

    // ---- One-Hot State Encoding ----
    localparam [2:0] S_GREEN  = 3'b001;
    localparam [2:0] S_YELLOW = 3'b010;
    localparam [2:0] S_RED    = 3'b100;

    reg [2:0] r_state, r_next_state;

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
    // The one-hot win: outputs are direct bits of r_state, no decoder.
    always @(*) begin
        o_green  = r_state[0];
        o_yellow = r_state[1];
        o_red    = r_state[2];
    end

endmodule
