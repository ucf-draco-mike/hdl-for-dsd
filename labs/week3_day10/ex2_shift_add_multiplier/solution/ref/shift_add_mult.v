// =============================================================================
// shift_add_mult.v — SOLUTION
// Day 10, Exercise 2
// =============================================================================

module shift_add_mult (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_start,
    input  wire [7:0]  i_a,        // multiplicand
    input  wire [7:0]  i_b,        // multiplier
    output reg  [15:0] o_product,
    output reg         o_done,
    output reg         o_busy
);

    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE    = 2'b10;

    reg [1:0]  r_state;
    reg [15:0] r_accumulator;
    reg [15:0] r_mcand;       // 16-bit to hold shifted multiplicand
    reg [7:0]  r_mplier;      // multiplier, shifted right each cycle
    reg [3:0]  r_bit_count;

    // State register
    always @(posedge i_clk) begin
        if (i_rst) begin
            r_state       <= IDLE;
            r_accumulator <= 16'd0;
            r_mcand       <= 16'd0;
            r_mplier      <= 8'd0;
            r_bit_count   <= 4'd0;
            o_product     <= 16'd0;
            o_done        <= 1'b0;
            o_busy        <= 1'b0;
        end else begin
            o_done <= 1'b0;  // default: pulse low

            case (r_state)
                IDLE: begin
                    o_busy <= 1'b0;
                    if (i_start) begin
                        r_accumulator <= 16'd0;
                        r_mcand       <= {8'd0, i_a};  // zero-extend to 16 bits
                        r_mplier      <= i_b;
                        r_bit_count   <= 4'd0;
                        o_busy        <= 1'b1;
                        r_state       <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    // If LSB of multiplier is 1, add multiplicand to accumulator
                    if (r_mplier[0])
                        r_accumulator <= r_accumulator + r_mcand;

                    // Shift: multiplicand left, multiplier right
                    r_mcand  <= r_mcand << 1;
                    r_mplier <= r_mplier >> 1;

                    r_bit_count <= r_bit_count + 1;

                    if (r_bit_count == 4'd7) begin
                        r_state <= DONE;
                    end
                end

                DONE: begin
                    o_product <= r_accumulator;
                    // Account for the last add (if multiplier bit 7 was set)
                    if (r_mplier[0])
                        o_product <= r_accumulator + r_mcand;
                    o_done  <= 1'b1;
                    o_busy  <= 1'b0;
                    r_state <= IDLE;
                end

                default: r_state <= IDLE;
            endcase
        end
    end

endmodule

// ---- For comparison: combinational multiplier ----
module comb_mult (
    input  wire [7:0]  i_a, i_b,
    output wire [15:0] o_product
);
    assign o_product = i_a * i_b;
endmodule
