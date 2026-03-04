module traffic_asserted (
    input  logic       i_clk,
    input  logic       i_reset,
    output logic [2:0] o_light
);
    typedef enum logic [1:0] {
        S_GREEN=2'b00, S_YELLOW=2'b01, S_RED=2'b10
    } state_t;

    state_t state, next_state, prev_state;
    logic [3:0] timer;
    logic timer_done;
    assign timer_done = (timer == 4'd9);

    always_ff @(posedge i_clk) begin
        if (i_reset) begin state <= S_GREEN; prev_state <= S_GREEN; end
        else begin prev_state <= state; state <= next_state; end
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

    // Assertion 1: Legal transitions
    always_ff @(posedge i_clk) begin
        if (!i_reset && state != prev_state) begin
            assert (
                (prev_state == S_GREEN  && state == S_YELLOW) ||
                (prev_state == S_YELLOW && state == S_RED)    ||
                (prev_state == S_RED    && state == S_GREEN)
            ) else $error("Illegal transition: %s -> %s",
                          prev_state.name(), state.name());
        end
    end

    // Assertion 2: One-hot output
    always_comb begin
        assert (o_light == 3'b001 || o_light == 3'b010 || o_light == 3'b100)
            else $error("Output not one-hot: %b", o_light);
    end

    // Assertion 3: Timer range
    always_ff @(posedge i_clk) begin
        assert (timer <= 4'd9)
            else $error("Timer overflow: %0d", timer);
    end
endmodule
