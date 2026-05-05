// =============================================================================
// day13_ex03_traffic_light_sv.sv -- Traffic-Light FSM in SystemVerilog
// Day 13: SystemVerilog for Design -- Segment 4 (enum / struct / package)
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
// Demonstrates the four "named" idioms from segment 4:
//   * typedef enum logic [1:0] { ... } state_t;     <- type-safe FSM states
//   * always_ff for state register, always_comb for next-state + outputs
//   * `state_t` reused as the type of `state` and `next_state`
//   * GTKWave shows the enum names (S_GREEN, S_YELLOW, S_RED) automatically
//     because iverilog records them in the VCD when -g2012 is set.
//
// The companion testbench (tb_traffic_light_sv.sv) drives reset and lets the
// FSM run for several cycles so you can step through the states in the wave
// viewer (segment-4 LIVE DEMO).
// =============================================================================
// Build:  iverilog -g2012 -o sim tb_traffic_light_sv.sv day13_ex03_traffic_light_sv.sv && vvp sim
// Synth:  yosys -p "read_verilog -sv day13_ex03_traffic_light_sv.sv; synth_ice40 -top traffic_light_sv; stat"
// =============================================================================

module traffic_light_sv #(
    parameter int TICKS_PER_PHASE = 10   // override down for fast simulation
)(
    input  logic       i_clk,
    input  logic       i_reset,
    output logic [2:0] o_light          // {red, yellow, green} -- one-hot
);

    // ---- State Type (enum replaces localparam) ----
    typedef enum logic [1:0] {
        S_GREEN  = 2'b00,
        S_YELLOW = 2'b01,
        S_RED    = 2'b10
    } state_t;

    state_t state, next_state;

    // ---- Phase Timer ----
    localparam int CNT_W = (TICKS_PER_PHASE > 1) ? $clog2(TICKS_PER_PHASE) : 1;
    logic [CNT_W-1:0] timer;
    logic             timer_done;
    assign timer_done = (timer == CNT_W'(TICKS_PER_PHASE - 1));

    // ---- Block 1: State Register (always_ff) ----
    always_ff @(posedge i_clk) begin
        if (i_reset) state <= S_GREEN;
        else         state <= next_state;
    end

    // ---- Block 2: Next-State Logic (always_comb prevents latches) ----
    always_comb begin
        next_state = state;          // default: hold
        case (state)
            S_GREEN:  if (timer_done) next_state = S_YELLOW;
            S_YELLOW: if (timer_done) next_state = S_RED;
            S_RED:    if (timer_done) next_state = S_GREEN;
            default:                  next_state = S_GREEN;
        endcase
    end

    // ---- Block 3: Output Logic (always_comb) ----
    always_comb begin
        case (state)
            S_GREEN:  o_light = 3'b001;   // green
            S_YELLOW: o_light = 3'b010;   // yellow
            S_RED:    o_light = 3'b100;   // red
            default:  o_light = 3'b100;   // safe default = red
        endcase
    end

    // ---- Phase Timer ----
    always_ff @(posedge i_clk) begin
        if (i_reset || timer_done) timer <= '0;
        else                       timer <= timer + 1;
    end

endmodule
