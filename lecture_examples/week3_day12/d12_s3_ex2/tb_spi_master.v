// =============================================================================
// tb_spi_master.v — Self-checking testbench for spi_master (Mode 0).
//
// Drives the master with a known TX byte and models an AD7476-style ADC slave
// that:
//   * latches an 8-bit response on falling CS,
//   * shifts out MSB-first on each rising SCK,
//   * sinks MOSI into a shadow shift register so we can echo what the master
//     sent (round-trip check).
//
// Checks:
//   * CS_N falls before SCK toggles, rises after the 8th SCK pulse
//   * 8 SCK pulses per transaction
//   * MISO comes back as the slave's pre-loaded byte (0xA5)
//   * Slave's shadow register matches the master's TX byte (MSB-first MOSI)
// =============================================================================
`timescale 1ns/1ps

module tb_spi_master;
    localparam CLK_FREQ = 1_000;
    localparam SPI_FREQ = 100;          // 5 clocks per half-period

    reg          clk = 0;
    reg          reset = 1;
    reg          start = 0;
    reg  [7:0]   tx_data = 0;
    wire [7:0]   rx_data;
    wire         done, busy, sclk, mosi, cs_n;
    reg          miso;

    spi_master #(.CLK_FREQ(CLK_FREQ), .SPI_FREQ(SPI_FREQ)) uut (
        .i_clk(clk), .i_reset(reset), .i_start(start),
        .i_tx_data(tx_data), .o_rx_data(rx_data),
        .o_done(done), .o_busy(busy),
        .o_sclk(sclk), .o_mosi(mosi), .i_miso(miso), .o_cs_n(cs_n)
    );

    always #5 clk = ~clk;

    // ---- ADC-style slave model: returns 0xA5, captures MOSI ----
    reg [7:0] slave_tx;          // bits we feed back on MISO
    reg [7:0] slave_rx;          // bits captured from MOSI
    integer   sclk_pulses;

    always @(negedge cs_n) begin
        slave_tx    <= 8'hA5;
        slave_rx    <= 8'h00;
        sclk_pulses  = 0;
    end

    // Master samples MISO on rising SCK (CPHA=0). Present new MISO on falling
    // SCK so it's stable by the next rising edge. While CS_N is high, idle.
    always @(negedge sclk) begin
        if (!cs_n) begin
            slave_tx <= {slave_tx[6:0], 1'b0};
        end
    end

    // Combinational MISO drive: MSB of slave_tx
    always @(*) miso = cs_n ? 1'b0 : slave_tx[7];

    // Slave latches MOSI on rising SCK (the same edge the master drives MISO
    // sampling on). For Mode 0 a real slave samples on the leading edge.
    always @(posedge sclk) begin
        if (!cs_n) begin
            slave_rx    <= {slave_rx[6:0], mosi};
            sclk_pulses  = sclk_pulses + 1;
        end
    end

    // ---- Bus-level scoreboard ----
    integer fails = 0, passes = 0;

    task check;
        input        cond;
        input [255:0] name;
    begin
        if (cond) begin
            $display("PASS: %0s", name);
            passes = passes + 1;
        end else begin
            $display("FAIL: %0s", name);
            fails = fails + 1;
        end
    end
    endtask

    // ---- Watch CS / SCK ordering ----
    reg cs_fell_before_sclk;
    initial cs_fell_before_sclk = 1'b0;
    always @(negedge cs_n) begin
        // sclk should still be low at this moment (Mode 0)
        cs_fell_before_sclk = (sclk == 1'b0);
    end

    initial begin
        $dumpfile("tb_spi_master.vcd");
        $dumpvars(0, tb_spi_master);

        $display("\n=== SPI Master Mode-0 Testbench ===\n");

        // Reset
        repeat (5) @(posedge clk);
        @(negedge clk); reset = 0;
        repeat (5) @(posedge clk);

        // Transaction: send 0x42, expect to receive 0xA5 from the slave.
        // Drive control signals on the falling edge so the next rising edge
        // sees the updated values without a race.
        @(negedge clk);
        tx_data = 8'h42;
        start   = 1;
        @(negedge clk);
        start   = 0;

        // Wait for completion
        @(posedge done);
        @(posedge clk);

        check(cs_fell_before_sclk,         "CS_N asserted before SCK toggled");
        check(sclk_pulses == 8,            "8 SCK pulses per byte");
        check(rx_data == 8'hA5,            "MISO returned 0xA5 (ADC result)");
        check(slave_rx == 8'h42,           "MOSI delivered 0x42 MSB-first");
        check(cs_n == 1'b1,                "CS_N de-asserted after transfer");

        repeat (10) @(posedge clk);

        $display("\n=== %0d passed, %0d failed ===\n", passes, fails);
        if (fails == 0)
            $display("*** ALL TESTS PASSED ***\n");
        else
            $display("*** %0d FAILURES ***\n", fails);

        $finish;
    end

    // safety net
    initial begin
        #200_000;
        $display("FAIL: simulation timeout");
        $finish;
    end
endmodule
