// =============================================================================
// counter_mod_n.v — Parameterized Modulo-N Counter
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Description:
//   Counts from 0 to (MAX-1), then wraps back to 0.
//   Provides a one-cycle-wide tick output when the counter wraps.
//   Supports synchronous reset and clock enable.
//
// Parameters:
//   N    Bit width of the counter (default 8)
//   MAX  Modulo value — counts 0..MAX-1 (default 100)
//
// Ports:
//   i_clk     Clock
//   i_reset   Synchronous reset (active high, returns to 0)
//   i_enable  Count enable (count only when high)
//   o_count   Current count value [N-1:0]
//   o_tick    High for one cycle when counter wraps (0→MAX-1→0)
//
// Introduced: Day 5
// =============================================================================
module counter_mod_n #(
    parameter N   = 8,
    parameter MAX = 100
) (
    input  wire           i_clk,
    input  wire           i_reset,
    input  wire           i_enable,
    output reg  [N-1:0]   o_count,
    output wire           o_tick
);
    always @(posedge i_clk) begin
        if (i_reset) begin
            o_count <= {N{1'b0}};
        end else if (i_enable) begin
            if (o_count == MAX - 1)
                o_count <= {N{1'b0}};
            else
                o_count <= o_count + 1'b1;
        end
    end

    assign o_tick = i_enable && (o_count == MAX - 1);

endmodule
