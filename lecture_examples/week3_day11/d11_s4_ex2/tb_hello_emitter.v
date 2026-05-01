// =============================================================================
// tb_hello_emitter.v -- sanity testbench for the d11_s4 HELLO demo
// =============================================================================
//   Drives `hello_emitter` long enough to capture the first complete
//   "HELLO\r\n" frame on `o_uart_tx`. A bit-banged decoder watches the line,
//   reconstructs each byte, and prints it; the testbench then asserts the
//   first 7 bytes match the expected ASCII sequence.
// =============================================================================
`timescale 1ns/1ps

module tb_hello_emitter;
    reg  clk = 1'b0;
    wire tx;
    wire led1;

    // 2 ns clock period -> 500 MHz "sim" clock. Combined with CLK_FREQ=1_000
    // and BAUD_RATE=100 inside the DUT (10 clock cycles per bit), each UART
    // bit lasts 10 * 2 = 20 sim time units.
    always #1 clk = ~clk;

    hello_emitter #(
        .CLK_FREQ  (1_000),
        .BAUD_RATE (100),
        .GAP_CYCLES(32'd200)
    ) dut (
        .i_clk     (clk),
        .o_uart_tx (tx),
        .o_led1    (led1)
    );

    // ---- Bit-banged UART RX (8N1, LSB-first) ---------------------------
    //   1 UART bit = CLKS_PER_BIT clock cycles = (CLKS_PER_BIT * 2) sim
    //   time units. Sample at the centre of each bit.
    localparam integer BIT_NS      = 20;
    localparam integer HALF_BIT_NS = BIT_NS / 2;
    localparam EXPECTED = "HELLO";

    reg [7:0] received [0:6];
    integer   rx_idx = 0;
    reg [7:0] rx_byte;
    integer   bit_i;

    initial begin : capture
        $dumpfile("tb_hello_emitter.vcd");
        $dumpvars(0, tb_hello_emitter);

        // Skip the initial high (idle) -- wait for the first start bit.
        forever begin
            @(negedge tx);
            // Move to centre of start bit, then advance to centre of bit 0.
            #(HALF_BIT_NS);
            #(BIT_NS);
            for (bit_i = 0; bit_i < 8; bit_i = bit_i + 1) begin
                rx_byte[bit_i] = tx;
                #(BIT_NS);
            end
            // We're now at the centre of the stop bit; let it idle out.
            if (rx_idx < 7) begin
                received[rx_idx] = rx_byte;
                $display("RX[%0d] = 0x%02h  '%s'",
                         rx_idx,
                         rx_byte,
                         (rx_byte >= 8'h20 && rx_byte <= 8'h7E)
                            ? rx_byte : 8'h2E);
                rx_idx = rx_idx + 1;
            end
        end
    end

    // ---- Watchdog: assert the first 7 bytes match HELLO\r\n ------------
    integer fails = 0;
    integer i;
    initial begin : watchdog
        // 7 bytes x (1 start + 8 data + 1 stop) bits x BIT_NS, plus slack.
        #(7 * 10 * BIT_NS + 4 * BIT_NS);

        if (rx_idx < 7) begin
            $display("FAIL: only captured %0d bytes (expected 7).", rx_idx);
            fails = fails + 1;
        end else begin
            for (i = 0; i < 5; i = i + 1) begin
                if (received[i] !== EXPECTED[(4-i)*8 +: 8]) begin
                    $display("FAIL byte %0d: got 0x%02h expected 0x%02h",
                             i, received[i], EXPECTED[(4-i)*8 +: 8]);
                    fails = fails + 1;
                end
            end
            if (received[5] !== 8'h0D) begin
                $display("FAIL byte 5: got 0x%02h expected CR (0x0D)",
                         received[5]);
                fails = fails + 1;
            end
            if (received[6] !== 8'h0A) begin
                $display("FAIL byte 6: got 0x%02h expected LF (0x0A)",
                         received[6]);
                fails = fails + 1;
            end
        end

        if (fails == 0) $display("=== HELLO frame OK ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
