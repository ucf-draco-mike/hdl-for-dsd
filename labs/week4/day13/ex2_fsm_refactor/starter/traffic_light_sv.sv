// =============================================================================
// traffic_light_sv.sv — Traffic Light FSM Refactored
// Day 13, Exercise 2
// =============================================================================
// Refactor the Day 7 traffic light using: logic, always_ff,
// always_comb, typedef enum

module traffic_light_sv (
    input  logic       i_clk,
    input  logic       i_reset,
    output logic [2:0] o_light   // {red, yellow, green}
);

    // TODO: Replace localparam states with typedef enum
    // typedef enum logic [1:0] {
    //     S_GREEN  = 2'b00,
    //     S_YELLOW = 2'b01,
    //     S_RED    = 2'b10
    // } state_t;
    //
    // state_t state, next_state;

    // ---- YOUR CODE HERE ----

    // Timer (simplified for testing)
    logic [3:0] timer;
    logic       timer_done;
    assign timer_done = (timer == 4'd9);

    // TODO: Block 1 — State register with always_ff
    // ---- YOUR CODE HERE ----

    // TODO: Block 2 — Next-state logic with always_comb
    // ---- YOUR CODE HERE ----

    // TODO: Block 3 — Output logic with always_comb
    // ---- YOUR CODE HERE ----

    // Timer counter
    always_ff @(posedge i_clk) begin
        if (i_reset || timer_done)
            timer <= '0;
        else
            timer <= timer + 1;
    end

endmodule
