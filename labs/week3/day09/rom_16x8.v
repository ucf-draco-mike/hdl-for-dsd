// 16x8 ROM using $readmemh
module rom_16x8 (
    input  wire [3:0] i_addr,
    output wire [7:0] o_data
);
    reg [7:0] r_mem [0:15];

    initial $readmemh("rom_data.hex", r_mem);

    assign o_data = r_mem[i_addr];
endmodule
