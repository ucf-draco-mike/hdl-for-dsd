// top_ram_explorer.v — Hardware RAM explorer on Go Board
// SW1 = write current data, SW2 = increment address
// SW3 = increment data, SW4 = toggle write/read mode
// 7-seg1 = address (lower nibble), 7-seg2 = read data (lower nibble)
// LEDs show upper nibbles or mode
module top_ram_explorer (
    input  wire i_clk,
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_segment2_a, o_segment2_b, o_segment2_c,
    output wire o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);
    wire sw1, sw2, sw3, sw4;
    debounce db1 (.i_clk(i_clk), .i_switch(i_switch1), .o_switch(sw1));
    debounce db2 (.i_clk(i_clk), .i_switch(i_switch2), .o_switch(sw2));
    debounce db3 (.i_clk(i_clk), .i_switch(i_switch3), .o_switch(sw3));
    debounce db4 (.i_clk(i_clk), .i_switch(i_switch4), .o_switch(sw4));

    // Edge detectors
    reg r_sw1_prev, r_sw2_prev, r_sw3_prev;
    always @(posedge i_clk) begin
        r_sw1_prev <= sw1;
        r_sw2_prev <= sw2;
        r_sw3_prev <= sw3;
    end
    wire w_write_pulse = sw1 & ~r_sw1_prev;
    wire w_addr_inc    = sw2 & ~r_sw2_prev;
    wire w_data_inc    = sw3 & ~r_sw3_prev;

    // Address and data registers
    reg [7:0] r_addr = 0;
    reg [7:0] r_wdata = 0;

    always @(posedge i_clk) begin
        if (w_addr_inc) r_addr  <= r_addr + 1;
        if (w_data_inc) r_wdata <= r_wdata + 1;
    end

    // RAM instance
    wire [7:0] w_rdata;
    ram_sp #(.ADDR_WIDTH(8), .DATA_WIDTH(8)) u_ram (
        .i_clk        (i_clk),
        .i_write_en   (w_write_pulse),
        .i_addr       (r_addr),
        .i_write_data (r_wdata),
        .o_read_data  (w_rdata)
    );

    // Display
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_addr[3:0]),  .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(w_rdata[3:0]), .o_seg(w_seg2));

    // LEDs: upper nibbles for context
    assign o_led1 = ~r_addr[4];
    assign o_led2 = ~r_addr[5];
    assign o_led3 = ~r_wdata[4];
    assign o_led4 = ~r_wdata[5];

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
