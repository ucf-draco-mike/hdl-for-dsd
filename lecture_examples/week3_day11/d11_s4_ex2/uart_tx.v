// =============================================================================
// day11_ex01_uart_tx.v — UART Transmitter (8N1, Parameterized)
// Day 11: UART Transmitter
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// FSM + PISO shift register + baud counter.
// Valid/busy handshake. LSB-first. Parameterized for any clock/baud.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day11_ex01_uart_tx.v && vvp sim
// Synth:  yosys -p "read_verilog day11_ex01_uart_tx.v; synth_ice40 -top uart_tx"
// =============================================================================

module uart_tx #(
    `ifdef SIMULATION
    parameter CLK_FREQ  = 1_000,       // tiny for fast sim
    parameter BAUD_RATE = 100
    `else
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
    `endif
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_valid,        // pulse high for 1 cycle with i_data
    input  wire [7:0] i_data,         // byte to transmit
    output reg        o_busy,         // high while transmitting
    output wire       o_tx            // serial output (idle = 1)
);

    // ---- Parameters ----
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CNT_W        = $clog2(CLKS_PER_BIT);

    // ---- State Encoding ----
    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;

    reg [1:0]        r_state, r_next_state;
    reg [CNT_W-1:0]  r_baud_cnt;
    reg [2:0]        r_bit_idx;     // 0..7 for 8 data bits
    reg [9:0]        r_shift;       // {stop, D7..D0, start}

    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);

    // ---- Baud Counter ----
    always @(posedge i_clk) begin
        if (i_reset || r_state == S_IDLE)
            r_baud_cnt <= 0;
        else if (w_baud_tick)
            r_baud_cnt <= 0;
        else
            r_baud_cnt <= r_baud_cnt + 1;
    end

    // ============================================================
    // Block 1 — State Register
    // ============================================================
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_IDLE;
        else
            r_state <= r_next_state;
    end

    // ============================================================
    // Block 2 — Next-State Logic
    // ============================================================
    always @(*) begin
        r_next_state = r_state;

        case (r_state)
            S_IDLE: begin
                if (i_valid)
                    r_next_state = S_START;
            end
            S_START: begin
                if (w_baud_tick)
                    r_next_state = S_DATA;
            end
            S_DATA: begin
                if (w_baud_tick && r_bit_idx == 7)
                    r_next_state = S_STOP;
            end
            S_STOP: begin
                if (w_baud_tick)
                    r_next_state = S_IDLE;
            end
            default: r_next_state = S_IDLE;
        endcase
    end

    // ---- Shift Register & Bit Counter ----
    always @(posedge i_clk) begin
        if (i_reset) begin
            r_shift   <= 10'h3FF;   // all 1s (idle pattern)
            r_bit_idx <= 0;
        end else if (r_state == S_IDLE && i_valid) begin
            // Load frame: {stop=1, data[7:0], start=0}
            r_shift   <= {1'b1, i_data, 1'b0};
            r_bit_idx <= 0;
        end else if (w_baud_tick) begin
            // Shift right: LSB goes out first
            r_shift   <= {1'b1, r_shift[9:1]};
            if (r_state == S_DATA)
                r_bit_idx <= r_bit_idx + 1;
        end
    end

    // ---- Block 3: Output Logic ----
    assign o_tx = (r_state == S_IDLE) ? 1'b1 : r_shift[0];

    always @(*) begin
        o_busy = (r_state != S_IDLE);
    end

endmodule
