// =============================================================================
// traffic_light.v — Timed Traffic Light FSM (Starter)
// Day 7, Exercise 1
// =============================================================================

module traffic_light (
    input  wire       i_clk,
    input  wire       i_reset,
    output reg  [2:0] o_light    // {red, yellow, green}
);

    // ========== State Encoding ==========
    localparam S_GREEN  = 2'b00;
    localparam S_YELLOW = 2'b01;
    localparam S_RED    = 2'b10;

    // ========== Timing Parameters ==========
`ifdef SIMULATION
    localparam GREEN_TIME  = 10;
    localparam YELLOW_TIME = 4;
    localparam RED_TIME    = 8;
`else
    localparam GREEN_TIME  = 25_000_000 * 5;  // 5 seconds
    localparam YELLOW_TIME = 25_000_000 * 1;  // 1 second
    localparam RED_TIME    = 25_000_000 * 4;  // 4 seconds
`endif

    localparam MAX_TIME = GREEN_TIME;  // largest timer value
    reg [$clog2(MAX_TIME)-1:0] r_timer;

    reg [1:0] r_state, r_next_state;

    // ===== Block 1: State Register (Sequential) =====
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_GREEN;
        else
            r_state <= r_next_state;
    end

    // ===== Timer: counts up, resets on state transition =====
    always @(posedge i_clk) begin
        if (i_reset)
            r_timer <= 0;
        else if (r_state != r_next_state)
            r_timer <= 0;                // reset on transition
        else
            r_timer <= r_timer + 1;
    end

    // ===== Block 2: Next-State Logic (Combinational) =====
    always @(*) begin
        r_next_state = r_state;  // DEFAULT: stay

        case (r_state)
            S_GREEN: begin
                // ---- TODO: Transition to S_YELLOW when timer reaches GREEN_TIME-1 ----

            end

            S_YELLOW: begin
                // ---- TODO: Transition to S_RED when timer reaches YELLOW_TIME-1 ----

            end

            S_RED: begin
                // ---- TODO: Transition to S_GREEN when timer reaches RED_TIME-1 ----

            end

            default: r_next_state = S_GREEN;
        endcase
    end

    // ===== Block 3: Output Logic (Moore) =====
    always @(*) begin
        o_light = 3'b000;  // default: all off

        case (r_state)
            // ---- TODO: Set o_light = {red, yellow, green} for each state ----
            // S_GREEN:  o_light = 3'b001;
            // S_YELLOW: o_light = 3'b010;
            // S_RED:    o_light = 3'b100;
            default: o_light = 3'b000;
        endcase
    end

endmodule
