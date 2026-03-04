// uart_tx.v — UART Transmitter (8N1)
// Default: 115200 baud at 25 MHz
module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       i_clk,
    input  wire       i_valid,   // Pulse high for one clock to send
    input  wire [7:0] i_data,    // Byte to transmit
    output reg        o_tx,      // UART TX line
    output wire       o_busy     // High while transmitting
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam S_IDLE  = 2'b00;
    localparam S_START = 2'b01;
    localparam S_DATA  = 2'b10;
    localparam S_STOP  = 2'b11;

    reg [1:0]  r_state = S_IDLE;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_cnt;
    reg [2:0]  r_bit_idx;
    reg [7:0]  r_data;

    assign o_busy = (r_state != S_IDLE);

    always @(posedge i_clk) begin
        case (r_state)
            S_IDLE: begin
                o_tx      <= 1'b1;
                r_clk_cnt <= 0;
                r_bit_idx <= 0;
                if (i_valid) begin
                    r_data  <= i_data;
                    r_state <= S_START;
                end
            end

            S_START: begin
                o_tx <= 1'b0;
                if (r_clk_cnt < CLKS_PER_BIT - 1) begin
                    r_clk_cnt <= r_clk_cnt + 1;
                end else begin
                    r_clk_cnt <= 0;
                    r_state   <= S_DATA;
                end
            end

            S_DATA: begin
                o_tx <= r_data[r_bit_idx];
                if (r_clk_cnt < CLKS_PER_BIT - 1) begin
                    r_clk_cnt <= r_clk_cnt + 1;
                end else begin
                    r_clk_cnt <= 0;
                    if (r_bit_idx < 7) begin
                        r_bit_idx <= r_bit_idx + 1;
                    end else begin
                        r_state <= S_STOP;
                    end
                end
            end

            S_STOP: begin
                o_tx <= 1'b1;
                if (r_clk_cnt < CLKS_PER_BIT - 1) begin
                    r_clk_cnt <= r_clk_cnt + 1;
                end else begin
                    r_state <= S_IDLE;
                end
            end
        endcase
    end
endmodule
