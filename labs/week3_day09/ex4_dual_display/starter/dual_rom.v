// =============================================================================
// dual_rom.v — Two Independent ROMs with Shared Address Counter (Starter)
// Day 9, Exercise 4 (Stretch)
// =============================================================================
// Demonstrates: multiple ROM instances, shared addressing, speed control
//
// TODO: Implement a module with:
//   - Two ROMs loaded from hex files (display1_patterns.hex, display2_patterns.hex)
//   - A shared address counter that cycles through entries
//   - A speed selector (button press cycles through 1 Hz, 2 Hz, 4 Hz)
//   - Outputs: o_data1[7:0], o_data2[7:0], o_addr[3:0]

module dual_rom #(
    parameter CLK_FREQ  = 25_000_000,
    parameter N_ENTRIES = 16
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_speed_up,
    output wire [7:0] o_data1,
    output wire [7:0] o_data2,
    output wire [3:0] o_addr
);

    // ROM arrays
    reg [7:0] r_rom1 [0:N_ENTRIES-1];
    reg [7:0] r_rom2 [0:N_ENTRIES-1];
    initial $readmemh("display1_patterns.hex", r_rom1);
    initial $readmemh("display2_patterns.hex", r_rom2);

    // TODO: Speed selection — cycle through 3 rates on i_speed_up pulse

    // TODO: Address counter — increment at the selected rate

    // TODO: ROM outputs — registered reads from both ROMs

endmodule
