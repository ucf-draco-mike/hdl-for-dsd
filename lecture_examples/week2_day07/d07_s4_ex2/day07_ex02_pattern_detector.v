// =============================================================================
// day07_ex02_pattern_detector.v — Sequence Detector FSM (Moore, "1011")
// Day 7: Finite State Machines
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Detects the serial bit pattern "1011" on i_bit.
// When the full pattern is recognized, o_detected pulses high for one cycle.
// Overlapping detection supported (e.g., "10110111" detects twice).
// =============================================================================
// State encoding follows the slide-4 walk-through:
//   S0    : haven't matched anything (or last bit broke the prefix)
//   S1    : last bit was '1'
//   S10   : last two bits were "10"
//   S101  : last three bits were "101"  -- one '1' away from a match
//   SMATCH: just consumed the final '1' of "1011"  -> o_detected = 1
//
// Why a 5th state for Moore?  In Moore the output is f(state) only, so we need
// a dedicated "we just matched" state to pulse o_detected for exactly one cycle.
//
// Overlap rules (from the diagram):
//   SMATCH -> '1' : the trailing '1' is the start of a new pattern  -> S1
//   SMATCH -> '0' : the trailing "10" is the prefix of a new match -> S10
//   S101   -> '0' : the trailing "10" is a fresh prefix            -> S10
//   S10    -> '0' : two consecutive zeros, throw away              -> S0
//   S1     -> '1' : another '1', stay armed                        -> S1
// =============================================================================
// Build:  iverilog -g2012 -o sim tb_pattern_detector.v day07_ex02_pattern_detector.v && vvp sim
// Synth:  yosys -p "read_verilog day07_ex02_pattern_detector.v; synth_ice40 -top pattern_detector; stat"
// =============================================================================

module pattern_detector (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_bit,
    output reg  o_detected
);

    // ---- State Encoding (binary, 3 bits for 5 states) ----
    localparam [2:0] S0     = 3'd0;   // nothing useful matched
    localparam [2:0] S1     = 3'd1;   // last bit was '1'
    localparam [2:0] S10    = 3'd2;   // last two bits were "10"
    localparam [2:0] S101   = 3'd3;   // last three bits were "101"
    localparam [2:0] SMATCH = 3'd4;   // just matched "1011" -> pulse output

    reg [2:0] r_state, r_next_state;

    // ============================================================
    // Block 1 — State Register (sequential, nonblocking)
    // ============================================================
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S0;
        else
            r_state <= r_next_state;
    end

    // ============================================================
    // Block 2 — Next-State Logic (combinational, blocking)
    // Default-first prevents latch inference.
    // ============================================================
    always @(*) begin
        r_next_state = r_state;     // DEFAULT: stay in current state

        case (r_state)
            S0: begin
                if (i_bit) r_next_state = S1;
                else       r_next_state = S0;
            end

            S1: begin
                if (i_bit) r_next_state = S1;    // saw "11" — still armed
                else       r_next_state = S10;   // saw "10"
            end

            S10: begin
                if (i_bit) r_next_state = S101;  // saw "101"
                else       r_next_state = S0;    // saw "100" — restart
            end

            S101: begin
                if (i_bit) r_next_state = SMATCH; // saw "1011" — match!
                else       r_next_state = S10;    // saw "1010" — keep "10" prefix
            end

            SMATCH: begin
                // Overlap: the trailing '1' from "1011" can seed a new match.
                if (i_bit) r_next_state = S1;     // "...1011" + 1  -> "...1"
                else       r_next_state = S10;    // "...1011" + 0  -> "...10"
            end

            default: r_next_state = S0;           // illegal-state recovery
        endcase
    end

    // ============================================================
    // Block 3 — Output Logic (combinational, Moore)
    // o_detected pulses high only in SMATCH.
    // ============================================================
    always @(*) begin
        o_detected = 1'b0;          // DEFAULT for every output

        case (r_state)
            SMATCH:  o_detected = 1'b1;
            default: o_detected = 1'b0;
        endcase
    end

endmodule
