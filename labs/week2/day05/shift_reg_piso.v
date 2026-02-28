// Parallel-In Serial-Out shift register
module shift_reg_piso #(parameter WIDTH = 8) (
    input  wire             i_clk, i_reset,
    input  wire             i_load, i_shift,
    input  wire [WIDTH-1:0] i_data,
    output wire             o_serial
);
    reg [WIDTH-1:0] r_shift;

    assign o_serial = r_shift[0];

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= {WIDTH{1'b0}};
        else if (i_load)
            r_shift <= i_data;
        else if (i_shift)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};
    end
endmodule
