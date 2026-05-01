// =============================================================================
// day11_ex02_hello_emitter.v — "HELLO" UART TX demo
// Day 11: Connecting to a PC
// Slide:   d11_s4 "Your Go Board Says HELLO" Live Demo
// =============================================================================
// Walks through the 5 ASCII characters of "HELLO" plus CR+LF, feeding each
// byte into a `uart_tx` instance one at a time. After the line completes,
// it waits for a roughly 200 ms gap and starts over — so the PC terminal
// streams "HELLO\r\n" forever as long as the board is plugged in.
//
// Build/program (Go Board, 25 MHz, 115200 baud):
//   yosys -p "read_verilog day11_ex02_hello_emitter.v uart_tx.v; \
//             synth_ice40 -top hello_emitter -json hello.json"
//   nextpnr-ice40 --hx1k --package vq100 --pcf ../go_board.pcf \
//                 --json hello.json --asc hello.asc
//   icepack hello.asc hello.bin && iceprog hello.bin
//
// Open a serial terminal at 115200 8N1, no flow control:
//   screen /dev/ttyUSB0 115200       (Linux/macOS)
//   python3 rx_display.py            (any platform with pyserial)
// =============================================================================

module hello_emitter #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200,
    // ~200 ms gap between bursts. Override in sim to keep runs fast.
    parameter GAP_CYCLES = 32'd5_000_000
)(
    input  wire i_clk,
    output wire o_uart_tx,
    output wire o_led1                // toggles each time a HELLO completes
);

    // ---- Message ROM: H, E, L, L, O, '\r', '\n' --------------------------
    localparam MSG_LEN = 7;

    function [7:0] msg_byte (input [2:0] idx);
        case (idx)
            3'd0: msg_byte = "H";
            3'd1: msg_byte = "E";
            3'd2: msg_byte = "L";
            3'd3: msg_byte = "L";
            3'd4: msg_byte = "O";
            3'd5: msg_byte = 8'h0D;   // CR
            default: msg_byte = 8'h0A; // LF
        endcase
    endfunction

    // ---- UART TX instance ------------------------------------------------
    reg  [7:0] r_data;
    reg        r_valid;
    wire       w_busy;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx (
        .i_clk   (i_clk),
        .i_reset (1'b0),
        .i_valid (r_valid),
        .i_data  (r_data),
        .o_busy  (w_busy),
        .o_tx    (o_uart_tx)
    );

    // ---- Driver FSM -----------------------------------------------------
    localparam S_LOAD = 2'd0;
    localparam S_WAIT = 2'd1;
    localparam S_GAP  = 2'd2;

    reg [1:0]  r_state;
    reg [2:0]  r_idx;
    reg [31:0] r_gap_cnt;
    reg        r_blink;

    initial begin
        r_state   = S_LOAD;
        r_idx     = 3'd0;
        r_gap_cnt = 32'd0;
        r_data    = 8'd0;
        r_valid   = 1'b0;
        r_blink   = 1'b0;
    end

    always @(posedge i_clk) begin
        r_valid <= 1'b0;     // default: only pulse high for one cycle.

        case (r_state)
            S_LOAD: begin
                if (!w_busy) begin
                    r_data  <= msg_byte(r_idx);
                    r_valid <= 1'b1;
                    r_state <= S_WAIT;
                end
            end

            S_WAIT: begin
                if (!w_busy) begin
                    if (r_idx == MSG_LEN - 1) begin
                        r_idx     <= 3'd0;
                        r_blink   <= ~r_blink;
                        r_gap_cnt <= GAP_CYCLES;
                        r_state   <= S_GAP;
                    end else begin
                        r_idx   <= r_idx + 1'b1;
                        r_state <= S_LOAD;
                    end
                end
            end

            S_GAP: begin
                if (r_gap_cnt == 32'd0)
                    r_state <= S_LOAD;
                else
                    r_gap_cnt <= r_gap_cnt - 1'b1;
            end

            default: r_state <= S_LOAD;
        endcase
    end

    assign o_led1 = r_blink;

endmodule
