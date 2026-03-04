// =============================================================================
// traffic_asserted.sv — FSM with Transition Assertions
// Day 14, Exercise 2
// =============================================================================
// Add assertions that verify:
//   1. Only legal state transitions occur
//   2. Output matches state
//   3. Timer stays in range

module traffic_asserted (
    input  logic       i_clk,
    input  logic       i_reset,
    output logic [2:0] o_light
);
    typedef enum logic [1:0] {
        S_GREEN=2'b00, S_YELLOW=2'b01, S_RED=2'b10
    } state_t;

    state_t state, next_state;
    logic [3:0] timer;
    logic timer_done;
    assign timer_done = (timer == 4'd9);

    always_ff @(posedge i_clk) begin
        if (i_reset) state <= S_GREEN;
        else         state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            S_GREEN:  if (timer_done) next_state = S_YELLOW;
            S_YELLOW: if (timer_done) next_state = S_RED;
            S_RED:    if (timer_done) next_state = S_GREEN;
            default:  next_state = S_GREEN;
        endcase
    end

    always_comb begin
        case (state)
            S_GREEN:  o_light = 3'b001;
            S_YELLOW: o_light = 3'b010;
            S_RED:    o_light = 3'b100;
            default:  o_light = 3'b100;
        endcase
    end

    always_ff @(posedge i_clk) begin
        if (i_reset || timer_done) timer <= '0;
        else timer <= timer + 1;
    end

    // TODO: Add assertions
    // 1. Legal transitions only (GREEN→YELLOW, YELLOW→RED, RED→GREEN, or hold)
    // 2. Exactly one bit in o_light is high (one-hot output)
    // 3. Timer never exceeds 9

    // ---- YOUR ASSERTIONS HERE ----

endmodule
