// =============================================================================
// day07_ex02_pattern_detector.v — Sequence Detector FSM (Moore)
// Day 7: Finite State Machines
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Detects the serial bit pattern "101" on i_serial_in.
// When the full pattern is recognized, o_detected pulses high for one state.
// Overlapping detection supported (e.g., 10101 detects twice).
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day07_ex02_pattern_detector.v && vvp sim
// Synth:  yosys -p "read_verilog day07_ex02_pattern_detector.v; synth_ice40 -top pattern_detector"
// =============================================================================

module pattern_detector (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_serial_in,
    output reg  o_detected
);

    // ---- State Encoding ----
    localparam S_IDLE  = 2'd0;   // Waiting for '1'
    localparam S_GOT1  = 2'd1;   // Seen '1'
    localparam S_GOT10 = 2'd2;   // Seen '10'
    localparam S_MATCH = 2'd3;   // Seen '101' — detect!

    reg [1:0] r_state, r_next_state;

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
        r_next_state = r_state;  // default: stay

        case (r_state)
            S_IDLE: begin
                if (i_serial_in)
                    r_next_state = S_GOT1;
            end

            S_GOT1: begin
                if (!i_serial_in)
                    r_next_state = S_GOT10;
                // else stay in S_GOT1 (still seeing 1s)
            end

            S_GOT10: begin
                if (i_serial_in)
                    r_next_state = S_MATCH;  // "101" complete!
                else
                    r_next_state = S_IDLE;   // "100" — restart
            end

            S_MATCH: begin
                // Overlap: after "101", the final '1' could start a new pattern
                if (i_serial_in)
                    r_next_state = S_GOT1;   // overlap: "101" → "1" of next
                else
                    r_next_state = S_GOT10;  // overlap: "101" → "10" of next
            end

            default: r_next_state = S_IDLE;
        endcase
    end

    // ============================================================
    // Block 3 — Output Logic (Moore)
    // ============================================================
    always @(*) begin
        o_detected = 1'b0;   // default

        case (r_state)
            S_MATCH: o_detected = 1'b1;
            default: o_detected = 1'b0;
        endcase
    end

endmodule
