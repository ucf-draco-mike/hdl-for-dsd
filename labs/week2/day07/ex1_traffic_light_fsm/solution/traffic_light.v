// =============================================================================
// traffic_light.v — Timed Traffic Light FSM (Solution)
// Day 7, Exercise 1
// =============================================================================

module traffic_light (
    input  wire       i_clk,
    input  wire       i_reset,
    output reg  [2:0] o_light    // {red, yellow, green}
);

    localparam S_GREEN  = 2'b00;
    localparam S_YELLOW = 2'b01;
    localparam S_RED    = 2'b10;

`ifdef SIMULATION
    localparam GREEN_TIME  = 10;
    localparam YELLOW_TIME = 4;
    localparam RED_TIME    = 8;
`else
    localparam GREEN_TIME  = 25_000_000 * 5;
    localparam YELLOW_TIME = 25_000_000 * 1;
    localparam RED_TIME    = 25_000_000 * 4;
`endif

    localparam MAX_TIME = GREEN_TIME;
    reg [$clog2(MAX_TIME)-1:0] r_timer;

    reg [1:0] r_state, r_next_state;

    // Block 1: State Register
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_GREEN;
        else
            r_state <= r_next_state;
    end

    // Timer
    always @(posedge i_clk) begin
        if (i_reset)
            r_timer <= 0;
        else if (r_state != r_next_state)
            r_timer <= 0;
        else
            r_timer <= r_timer + 1;
    end

    // Block 2: Next-State Logic
    always @(*) begin
        r_next_state = r_state;
        case (r_state)
            S_GREEN:  if (r_timer == GREEN_TIME - 1)  r_next_state = S_YELLOW;
            S_YELLOW: if (r_timer == YELLOW_TIME - 1) r_next_state = S_RED;
            S_RED:    if (r_timer == RED_TIME - 1)    r_next_state = S_GREEN;
            default:  r_next_state = S_GREEN;
        endcase
    end

    // Block 3: Output Logic (Moore)
    always @(*) begin
        o_light = 3'b000;
        case (r_state)
            S_GREEN:  o_light = 3'b001;
            S_YELLOW: o_light = 3'b010;
            S_RED:    o_light = 3'b100;
            default:  o_light = 3'b000;
        endcase
    end

endmodule
