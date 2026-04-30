// =============================================================================
// day07_ex01_fsm_template.v — 3-Always-Block FSM Template (Traffic Light)
// Day 7: Finite State Machines
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// The canonical FSM coding style:
//   Block 1 (seq):  State register — just a flip-flop
//   Block 2 (comb): Next-state logic — case statement with default
//   Block 3 (comb): Output logic — Moore: outputs depend only on state
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day07_ex01_fsm_template.v && vvp sim
// View:   gtkwave tb_traffic_light.vcd
// Synth:  yosys -p "read_verilog day07_ex01_fsm_template.v; synth_ice40 -top traffic_light"
// =============================================================================

module traffic_light #(
    `ifdef SIMULATION
    parameter GREEN_TIME  = 10,    // Short for simulation
    parameter YELLOW_TIME = 4,
    parameter RED_TIME    = 10
    `else
    parameter GREEN_TIME  = 125_000_000,  // 5 sec at 25 MHz
    parameter YELLOW_TIME =  25_000_000,  // 1 sec
    parameter RED_TIME    = 125_000_000   // 5 sec
    `endif
)(
    input  wire i_clk,
    input  wire i_reset,
    output reg  o_red,
    output reg  o_yellow,
    output reg  o_green
);

    // ---- State Encoding ----
    localparam S_GREEN  = 2'd0;
    localparam S_YELLOW = 2'd1;
    localparam S_RED    = 2'd2;

    reg [1:0] r_state, r_next_state;

    // ---- Timer ----
    localparam MAX_TIME = (GREEN_TIME > RED_TIME) ? GREEN_TIME : RED_TIME;
    reg [$clog2(MAX_TIME)-1:0] r_timer;
    wire w_timer_done;

    // Timer target depends on current state
    reg [$clog2(MAX_TIME)-1:0] r_timer_target;

    always @(*) begin
        case (r_state)
            S_GREEN:  r_timer_target = GREEN_TIME - 1;
            S_YELLOW: r_timer_target = YELLOW_TIME - 1;
            S_RED:    r_timer_target = RED_TIME - 1;
            default:  r_timer_target = GREEN_TIME - 1;
        endcase
    end

    assign w_timer_done = (r_timer == r_timer_target);

    // Timer: reset on state change, else increment
    always @(posedge i_clk) begin
        if (i_reset || (r_state != r_next_state))
            r_timer <= 0;
        else if (!w_timer_done)
            r_timer <= r_timer + 1;
    end

    // ============================================================
    // Block 1 — State Register (Sequential)
    // Always this simple. No logic here.
    // ============================================================
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_GREEN;
        else
            r_state <= r_next_state;
    end

    // ============================================================
    // Block 2 — Next-State Logic (Combinational)
    // Critical: default assignment prevents latches.
    // ============================================================
    always @(*) begin
        r_next_state = r_state;  // DEFAULT: stay in current state

        case (r_state)
            S_GREEN: begin
                if (w_timer_done)
                    r_next_state = S_YELLOW;
            end

            S_YELLOW: begin
                if (w_timer_done)
                    r_next_state = S_RED;
            end

            S_RED: begin
                if (w_timer_done)
                    r_next_state = S_GREEN;
            end

            default: r_next_state = S_GREEN;  // illegal state recovery
        endcase
    end

    // ============================================================
    // Block 3 — Output Logic (Combinational — Moore)
    // Outputs depend ONLY on r_state.
    // ============================================================
    always @(*) begin
        // Defaults: all off
        o_red    = 1'b0;
        o_yellow = 1'b0;
        o_green  = 1'b0;

        case (r_state)
            S_GREEN:  o_green  = 1'b1;
            S_YELLOW: o_yellow = 1'b1;
            S_RED:    o_red    = 1'b1;
            default:  o_red    = 1'b1;  // safe default
        endcase
    end

endmodule
