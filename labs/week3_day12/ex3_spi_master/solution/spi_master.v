module spi_master #(
    parameter CLK_FREQ  = 25_000_000,
    parameter SPI_FREQ  = 1_000_000,
    parameter DATA_BITS = 8
)(
    input  wire                  i_clk, i_reset, i_start,
    input  wire [DATA_BITS-1:0]  i_tx_data,
    output reg  [DATA_BITS-1:0]  o_rx_data,
    output reg                   o_done,
    output wire                  o_busy,
    output reg                   o_sclk, o_mosi,
    input  wire                  i_miso,
    output reg                   o_cs_n
);
    localparam CLKS_PER_HALF_SCLK = CLK_FREQ / (SPI_FREQ * 2);
    localparam S_IDLE=2'b00, S_RUNNING=2'b01, S_DONE=2'b10;

    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_HALF_SCLK)-1:0] r_sclk_cnt;
    reg [$clog2(DATA_BITS):0] r_bit_cnt;
    reg [DATA_BITS-1:0] r_tx_shift, r_rx_shift;
    reg r_sclk_phase; // 0 = about to go high, 1 = about to go low

    assign o_busy = (r_state != S_IDLE);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state <= S_IDLE; o_cs_n <= 1'b1; o_sclk <= 1'b0;
            o_mosi <= 1'b0; o_done <= 1'b0;
        end else begin
            o_done <= 1'b0;
            case (r_state)
                S_IDLE: begin
                    o_cs_n <= 1'b1; o_sclk <= 1'b0;
                    if (i_start) begin
                        r_tx_shift <= i_tx_data;
                        r_rx_shift <= 0;
                        r_bit_cnt  <= 0;
                        r_sclk_cnt <= 0;
                        r_sclk_phase <= 0;
                        o_cs_n <= 1'b0;
                        o_mosi <= i_tx_data[DATA_BITS-1]; // MSB first
                        r_state <= S_RUNNING;
                    end
                end
                S_RUNNING: begin
                    if (r_sclk_cnt == CLKS_PER_HALF_SCLK-1) begin
                        r_sclk_cnt <= 0;
                        if (!r_sclk_phase) begin
                            o_sclk <= 1'b1; // rising edge: sample MISO
                            r_rx_shift <= {r_rx_shift[DATA_BITS-2:0], i_miso};
                            r_sclk_phase <= 1;
                        end else begin
                            o_sclk <= 1'b0; // falling edge: shift MOSI
                            r_bit_cnt <= r_bit_cnt + 1;
                            if (r_bit_cnt == DATA_BITS-1)
                                r_state <= S_DONE;
                            else begin
                                r_tx_shift <= {r_tx_shift[DATA_BITS-2:0], 1'b0};
                                o_mosi <= r_tx_shift[DATA_BITS-2];
                            end
                            r_sclk_phase <= 0;
                        end
                    end else
                        r_sclk_cnt <= r_sclk_cnt + 1;
                end
                S_DONE: begin
                    o_cs_n <= 1'b1; o_sclk <= 1'b0;
                    o_rx_data <= r_rx_shift;
                    o_done <= 1'b1;
                    r_state <= S_IDLE;
                end
            endcase
        end
    end
endmodule
