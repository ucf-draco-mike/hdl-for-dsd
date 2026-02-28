// Parameterized LED blinker — generate N instances at different rates
module blink_n #(
    parameter NUM_LEDS = 4,
    parameter CLK_FREQ = 25_000_000
)(
    input  wire              i_clk,
    output wire [NUM_LEDS-1:0] o_leds
);
    genvar g;
    generate
        for (g = 0; g < NUM_LEDS; g = g + 1) begin : gen_blink
            reg [$clog2(CLK_FREQ)-1:0] r_cnt;
            reg r_led;

            localparam HALF_PERIOD = CLK_FREQ / (2 * (g + 1));

            always @(posedge i_clk) begin
                if (r_cnt >= HALF_PERIOD - 1) begin
                    r_cnt <= 0;
                    r_led <= ~r_led;
                end else
                    r_cnt <= r_cnt + 1;
            end

            assign o_leds[g] = r_led;
        end
    endgenerate
endmodule
