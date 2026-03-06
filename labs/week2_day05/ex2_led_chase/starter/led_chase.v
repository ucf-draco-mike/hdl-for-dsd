// =============================================================================
// led_chase.v — Shift Register LED Chase Pattern (Starter)
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

    // --- Debounce the reset and direction switches ---
    wire w_reset_clean, w_dir_clean;

    debounce #(.CLKS_TO_STABLE(250_000)) db_reset (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_reset_clean)
    );
    debounce #(.CLKS_TO_STABLE(250_000)) db_dir (
        .i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(w_dir_clean)
    );

    wire w_reset = ~w_reset_clean;  // active-high button -> active-high reset

    // --- Shift register with bounce-back ---
    reg [3:0] r_pattern;
    reg       r_dir;  // 0 = shift left, 1 = shift right

    always @(posedge i_clk) begin
        if (w_reset) begin
            r_pattern <= 4'b0001;
            r_dir     <= 1'b0;
        end else if (w_tick) begin
            // ---- TODO: Implement bounce-back chase logic ----
            // Override direction from debounced switch if pressed:
            //   if (!w_dir_clean) r_dir <= ~r_dir;  (toggle on press)
            //
            // Check wall collisions and shift:
            //   If shifting left (r_dir == 0):
            //     If at left wall (r_pattern == 4'b1000), reverse direction
            //     Else shift left: r_pattern <= r_pattern << 1
            //   If shifting right (r_dir == 1):
            //     If at right wall (r_pattern == 4'b0001), reverse direction
            //     Else shift right: r_pattern <= r_pattern >> 1

        end
    end

    // active-high LED outputs
    assign o_led1 = r_pattern[3];
    assign o_led2 = r_pattern[2];
    assign o_led3 = r_pattern[1];
    assign o_led4 = r_pattern[0];

endmodule
