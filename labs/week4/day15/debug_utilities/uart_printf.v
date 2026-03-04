// uart_printf.v — UART debug message sender
// Sends a fixed-length hex dump of up to 4 bytes over UART
// Format: "DBG: XX XX XX XX\r\n"
// Trigger with a pulse on i_trigger
module uart_printf #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115200,
    parameter NUM_BYTES = 4          // 1–4 bytes to display
)(
    input  wire                   i_clk,
    input  wire                   i_trigger,   // Pulse to send message
    input  wire [NUM_BYTES*8-1:0] i_data,      // Data bytes to print
    output wire                   o_tx,        // UART TX line
    output wire                   o_busy       // High while sending
);
    // Message: "DBG: " + hex bytes + "\r\n"
    // Each byte = 3 chars ("XX "), total message ≤ 5 + 3*4 + 2 = 19 chars
    localparam MSG_LEN = 5 + 3 * NUM_BYTES + 2;

    reg [7:0] r_msg [0:MSG_LEN-1];
    reg [$clog2(MSG_LEN+1)-1:0] r_idx;
    reg r_sending;
    reg r_tx_valid;
    reg [7:0] r_tx_data;
    wire w_tx_busy;

    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_tx (
        .i_clk   (i_clk),
        .i_valid (r_tx_valid),
        .i_data  (r_tx_data),
        .o_tx    (o_tx),
        .o_busy  (w_tx_busy)
    );

    assign o_busy = r_sending;

    // Hex nibble to ASCII
    function [7:0] hex_char;
        input [3:0] nibble;
        hex_char = (nibble < 10) ? (8'h30 + nibble) : (8'h41 + nibble - 10);
    endfunction

    integer k;
    always @(posedge i_clk) begin
        r_tx_valid <= 1'b0;

        if (i_trigger && !r_sending) begin
            // Build message in buffer
            r_msg[0] <= "D";
            r_msg[1] <= "B";
            r_msg[2] <= "G";
            r_msg[3] <= ":";
            r_msg[4] <= " ";
            for (k = 0; k < NUM_BYTES; k = k + 1) begin
                r_msg[5 + k*3]     <= hex_char(i_data[(NUM_BYTES-1-k)*8 +: 4]);
                r_msg[5 + k*3 + 1] <= hex_char(i_data[(NUM_BYTES-1-k)*8+4 +: 4]);
                r_msg[5 + k*3 + 2] <= " ";
            end
            r_msg[5 + NUM_BYTES*3]     <= 8'h0D;  // \r
            r_msg[5 + NUM_BYTES*3 + 1] <= 8'h0A;  // \n
            r_idx     <= 0;
            r_sending <= 1'b1;
        end
        else if (r_sending && !w_tx_busy && !r_tx_valid) begin
            if (r_idx < MSG_LEN) begin
                r_tx_data  <= r_msg[r_idx];
                r_tx_valid <= 1'b1;
                r_idx      <= r_idx + 1;
            end else begin
                r_sending <= 1'b0;
            end
        end
    end
endmodule
