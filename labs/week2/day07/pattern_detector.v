// Button-press pattern detector FSM
// Detects sequence: SW1, SW2, SW1 -> lights LED
module pattern_detector (
    input  wire i_clk, i_reset,
    input  wire i_btn1, i_btn2,
    output reg  o_detected
);
    localparam S_IDLE = 3'd0,
               S_GOT1 = 3'd1,
               S_GOT2 = 3'd2,
               S_DONE = 3'd3;

    reg [2:0] r_state, r_next;

    // Block 1: State register
    always @(posedge i_clk)
        if (i_reset) r_state <= S_IDLE;
        else         r_state <= r_next;

    // Block 2: Next-state logic
    always @(*) begin
        r_next = r_state;
        case (r_state)
            S_IDLE: if (i_btn1) r_next = S_GOT1;
            S_GOT1: if (i_btn2) r_next = S_GOT2;
                    else if (i_btn1) r_next = S_GOT1;  // stay
                    else r_next = S_IDLE;  // timeout/wrong button
            S_GOT2: if (i_btn1) r_next = S_DONE;
                    else if (i_btn2) r_next = S_GOT2;
                    else r_next = S_IDLE;
            S_DONE: r_next = S_IDLE;  // auto-return
            default: r_next = S_IDLE;
        endcase
    end

    // Block 3: Output logic
    always @(*) begin
        o_detected = (r_state == S_DONE);
    end
endmodule
