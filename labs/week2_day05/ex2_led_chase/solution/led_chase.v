// =============================================================================
// led_chase.v — Shift Register LED Chase Pattern (Solution)
// Day 5, Exercise 2
// =============================================================================

module led_chase (
    input  wire i_clk,
    input  wire i_switch1,   // reset
    input  wire i_switch2,   // direction control
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // --- Clock divider for visible speed (~4 Hz) ---
    reg [22:0] r_clk_div;
    wire w_tick = (r_clk_div == 23'd3_124_999);

    always @(posedge i_clk) begin
        if (w_tick)
            r_clk_div <= 0;
        else
            r_clk_div <= r_clk_div + 1;
    end

    // --- Debounce ---
    wire w_reset_clean, w_dir_clean;

    debounce #(.CLKS_TO_STABLE(250_000)) db_reset (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_reset_clean)
    );
    debounce #(.CLKS_TO_STABLE(250_000)) db_dir (
        .i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(w_dir_clean)
    );

    wire w_reset = w_reset_clean;

    // --- Edge detect on direction button ---
    reg r_dir_prev;
    always @(posedge i_clk) r_dir_prev <= w_dir_clean;
    wire w_dir_press = w_dir_clean & ~r_dir_prev;

    // --- Shift register with bounce-back ---
    reg [3:0] r_pattern;
    reg       r_dir;

    always @(posedge i_clk) begin
        if (w_reset) begin
            r_pattern <= 4'b0001;
            r_dir     <= 1'b0;
        end else if (w_tick) begin
            // Direction override from button
            if (w_dir_press)
                r_dir <= ~r_dir;

            if (r_dir == 1'b0) begin
                // Shift left
                if (r_pattern == 4'b1000)
                    r_dir <= 1'b1;
                else
                    r_pattern <= r_pattern << 1;
            end else begin
                // Shift right
                if (r_pattern == 4'b0001)
                    r_dir <= 1'b0;
                else
                    r_pattern <= r_pattern >> 1;
            end
        end
    end

    assign o_led1 = r_pattern[3];
    assign o_led2 = r_pattern[2];
    assign o_led3 = r_pattern[1];
    assign o_led4 = r_pattern[0];

endmodule
