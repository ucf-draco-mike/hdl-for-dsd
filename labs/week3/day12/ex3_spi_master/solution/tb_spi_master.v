`timescale 1ns/1ps
module tb_spi_master;
    reg clk, reset, start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire done, busy, sclk, mosi, cs_n;
    reg miso;

    localparam CLK_FREQ=1000, SPI_FREQ=100;

    spi_master #(.CLK_FREQ(CLK_FREQ),.SPI_FREQ(SPI_FREQ)) uut (
        .i_clk(clk),.i_reset(reset),.i_start(start),
        .i_tx_data(tx_data),.o_rx_data(rx_data),.o_done(done),
        .o_busy(busy),.o_sclk(sclk),.o_mosi(mosi),.i_miso(miso),.o_cs_n(cs_n));

    initial clk=0; always #500 clk=~clk;

    // Simple SPI slave model
    reg [7:0] slave_shift;
    always @(negedge cs_n) slave_shift <= 8'hA5;
    assign miso_wire = slave_shift[7];
    always @(negedge sclk) if (!cs_n) slave_shift <= {slave_shift[6:0], mosi};
    always @(*) miso = slave_shift[7];

    initial begin
        $dumpfile("spi.vcd"); $dumpvars(0,tb_spi_master);
        reset=1; start=0; tx_data=0;
        repeat(5) @(posedge clk); reset=0;
        repeat(5) @(posedge clk);

        tx_data=8'h42; start=1; @(posedge clk); start=0;
        @(posedge done);
        if (rx_data==8'hA5) $display("PASS: SPI RX=A5");
        else $display("FAIL: SPI RX=%h expected A5",rx_data);
        repeat(10) @(posedge clk);
        $finish;
    end
endmodule
