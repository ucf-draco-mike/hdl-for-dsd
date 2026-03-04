// dual_rom.v — Two independent ROMs with shared address counter
// Demonstrates: multiple ROM instances, shared addressing, speed control
module dual_rom #(
    parameter CLK_FREQ = 25_000_000,
    parameter N_ENTRIES = 16
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_speed_up,    // Cycle through speeds (pulse)
    output wire [7:0] o_data1,       // ROM 1 output
    output wire [7:0] o_data2,       // ROM 2 output
    output wire [3:0] o_addr         // Current shared address
);
    // Two ROMs
    reg [7:0] r_rom1 [0:N_ENTRIES-1];
    reg [7:0] r_rom2 [0:N_ENTRIES-1];
    initial $readmemh("display1_patterns.hex", r_rom1);
    initial $readmemh("display2_patterns.hex", r_rom2);

    // Speed selection: 1 Hz, 2 Hz, 4 Hz
    reg [1:0] r_speed_sel;
    always @(posedge i_clk) begin
        if (i_reset)
            r_speed_sel <= 0;
        else if (i_speed_up)
            r_speed_sel <= (r_speed_sel == 2'd2) ? 2'd0 : r_speed_sel + 1;
    end

    // Prescaler (divide by speed)
    reg [24:0] r_prescaler;
    wire [24:0] w_limit = (r_speed_sel == 2'd0) ? (CLK_FREQ - 1) :
                          (r_speed_sel == 2'd1) ? (CLK_FREQ/2 - 1) :
                                                  (CLK_FREQ/4 - 1);
    wire w_tick = (r_prescaler == w_limit);

    always @(posedge i_clk) begin
        if (i_reset || w_tick)
            r_prescaler <= 0;
        else
            r_prescaler <= r_prescaler + 1;
    end

    // Shared address counter
    reg [3:0] r_addr;
    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (w_tick)
            r_addr <= (r_addr == N_ENTRIES - 1) ? 4'd0 : r_addr + 1;
    end

    // Async ROM reads
    assign o_data1 = r_rom1[r_addr];
    assign o_data2 = r_rom2[r_addr];
    assign o_addr  = r_addr;
endmodule
