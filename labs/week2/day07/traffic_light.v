// Traffic light controller FSM — 3-always-block style
module traffic_light (
    input  wire       i_clk, i_reset,
    output reg  [2:0] o_light  // {RED, YELLOW, GREEN}
);
    // State encoding
    localparam S_GREEN  = 2'd0,
               S_YELLOW = 2'd1,
               S_RED    = 2'd2;

    // Timing (use small values for sim; parameterize for board)
    localparam GREEN_TIME  = 5_000_000;  // ~200ms at 25MHz
    localparam YELLOW_TIME = 1_250_000;  // ~50ms
    localparam RED_TIME    = 5_000_000;   // ~200ms

    reg [1:0] r_state, r_next_state;
    reg [22:0] r_timer;

    // Block 1: State register
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_RED;
        else
            r_state <= r_next_state;
    end

    // Block 2: Next-state logic
    always @(*) begin
        r_next_state = r_state;  // default: stay
        case (r_state)
            S_GREEN:  if (r_timer == 0) r_next_state = S_YELLOW;
            S_YELLOW: if (r_timer == 0) r_next_state = S_RED;
            S_RED:    if (r_timer == 0) r_next_state = S_GREEN;
            default:  r_next_state = S_RED;
        endcase
    end

    // Block 3: Output logic
    always @(*) begin
        case (r_state)
            S_GREEN:  o_light = 3'b001;
            S_YELLOW: o_light = 3'b010;
            S_RED:    o_light = 3'b100;
            default:  o_light = 3'b100;
        endcase
    end

    // Timer (counts down to 0)
    always @(posedge i_clk) begin
        if (i_reset)
            r_timer <= RED_TIME - 1;
        else if (r_state != r_next_state) begin
            case (r_next_state)
                S_GREEN:  r_timer <= GREEN_TIME - 1;
                S_YELLOW: r_timer <= YELLOW_TIME - 1;
                S_RED:    r_timer <= RED_TIME - 1;
                default:  r_timer <= RED_TIME - 1;
            endcase
        end else if (r_timer != 0)
            r_timer <= r_timer - 1;
    end
endmodule
