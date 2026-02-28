// Exercise 3: LED blinker — 25 MHz to ~1 Hz
module led_blinker (
    input  wire i_clk,
    output reg  o_led1
);
    // 25 MHz / 2 = 12,500,000 cycles per toggle for 1 Hz
    localparam COUNT_MAX = 12_500_000 - 1;

    reg [23:0] r_counter;

    always @(posedge i_clk) begin
        if (r_counter == COUNT_MAX) begin
            r_counter <= 24'd0;
            o_led1    <= ~o_led1;
        end else begin
            r_counter <= r_counter + 1;
        end
    end
endmodule
