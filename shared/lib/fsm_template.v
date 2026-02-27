// =============================================================================
// fsm_template.v — 3-Always-Block FSM Template
// Day 7: Finite State Machines
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// A complete, annotated FSM template. Copy this as a starting point for
// any state machine design.

module fsm_template (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_start,
    input  wire i_done_condition,
    output reg  o_busy,
    output reg  o_complete
);

    // ===== State Encoding =====
    localparam S_IDLE = 2'b00;
    localparam S_RUN  = 2'b01;
    localparam S_DONE = 2'b10;

    reg [1:0] r_state, r_next_state;

    // ===== Block 1: State Register (Sequential) =====
    // This block is always trivial — just a FF with reset.
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_IDLE;
        else
            r_state <= r_next_state;
    end

    // ===== Block 2: Next-State Logic (Combinational) =====
    always @(*) begin
        r_next_state = r_state;  // DEFAULT: stay in current state

        case (r_state)
            S_IDLE: begin
                if (i_start)
                    r_next_state = S_RUN;
            end

            S_RUN: begin
                if (i_done_condition)
                    r_next_state = S_DONE;
            end

            S_DONE: begin
                r_next_state = S_IDLE;  // unconditional return
            end

            default: r_next_state = S_IDLE;  // safety catch
        endcase
    end

    // ===== Block 3: Output Logic (Combinational — Moore) =====
    always @(*) begin
        // Defaults — prevents latches on ALL outputs
        o_busy     = 1'b0;
        o_complete = 1'b0;

        case (r_state)
            S_IDLE: begin
                // all defaults
            end

            S_RUN: begin
                o_busy = 1'b1;
            end

            S_DONE: begin
                o_complete = 1'b1;
            end

            default: begin
                // defaults apply
            end
        endcase
    end

endmodule
