// signal_spy.v — Route internal signals to LEDs for debug
// Multiplex up to 16 signals onto 4 LEDs using switches to select group
module signal_spy (
    input  wire        i_clk,
    input  wire [1:0]  i_group_sel,  // 2-bit select from switches
    input  wire [15:0] i_signals,    // 16 signals to observe
    output wire [3:0]  o_leds        // 4 LEDs (active-high for Go Board)
);
    reg [3:0] r_selected;

    always @(posedge i_clk) begin
        case (i_group_sel)
            2'b00: r_selected <= i_signals[3:0];
            2'b01: r_selected <= i_signals[7:4];
            2'b10: r_selected <= i_signals[11:8];
            2'b11: r_selected <= i_signals[15:12];
        endcase
    end

    assign o_leds = r_selected;   // active-high for Go Board
endmodule
