// =============================================================================
// pattern_detector.v — Button Sequence Detector FSM (Starter)
// Day 7, Exercise 2
// =============================================================================
// Detect: btn1 -> btn2 -> btn3 (in order)
// Wrong button resets. LED lights for ~1 second on detection.

module pattern_detector (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_btn1,    // debounced, active-high press edges
    input  wire       i_btn2,
    input  wire       i_btn3,
    output reg        o_detected,
    output reg  [1:0] o_progress  // 00=waiting, 01=got 1, 10=got 1+2, 11=done
);

    // ---- TODO: State encoding ----
    localparam S_WAIT_1   = 2'b00;
    localparam S_WAIT_2   = 2'b01;
    localparam S_WAIT_3   = 2'b10;
    localparam S_DETECTED = 2'b11;

    reg [1:0] r_state, r_next_state;

    // Timer for DETECTED state (~1 second display)
`ifdef SIMULATION
    localparam DETECT_TIME = 20;
`else
    localparam DETECT_TIME = 25_000_000;
`endif
    reg [$clog2(DETECT_TIME)-1:0] r_detect_timer;

    // ===== Block 1: State Register =====
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_WAIT_1;
        else
            r_state <= r_next_state;
    end

    // Timer for detected state
    always @(posedge i_clk) begin
        if (i_reset || r_state != S_DETECTED)
            r_detect_timer <= 0;
        else
            r_detect_timer <= r_detect_timer + 1;
    end

    // ===== Block 2: Next-State Logic =====
    always @(*) begin
        r_next_state = r_state;

        case (r_state)
            S_WAIT_1: begin
                // ---- TODO ----
                // btn1 pressed -> S_WAIT_2
                // any other button -> stay (S_WAIT_1)
            end

            S_WAIT_2: begin
                // ---- TODO ----
                // btn2 pressed -> S_WAIT_3
                // btn1 pressed -> S_WAIT_2 (restart valid first press)
                // btn3 pressed -> S_WAIT_1 (wrong sequence)
            end

            S_WAIT_3: begin
                // ---- TODO ----
                // btn3 pressed -> S_DETECTED
                // btn1 pressed -> S_WAIT_2
                // btn2 pressed -> S_WAIT_1 (wrong)
            end

            S_DETECTED: begin
                // ---- TODO ----
                // After DETECT_TIME -> S_WAIT_1
            end

            default: r_next_state = S_WAIT_1;
        endcase
    end

    // ===== Block 3: Output Logic (Moore) =====
    always @(*) begin
        o_detected  = 1'b0;
        o_progress  = 2'b00;

        case (r_state)
            // ---- TODO: Set outputs for each state ----
            // S_WAIT_1:   o_progress = 2'b00;
            // S_WAIT_2:   o_progress = 2'b01;
            // S_WAIT_3:   o_progress = 2'b10;
            // S_DETECTED: o_progress = 2'b11; o_detected = 1'b1;
            default: ;
        endcase
    end

endmodule
