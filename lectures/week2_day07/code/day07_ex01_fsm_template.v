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

// =============================================================================
// Self-Checking Testbench
// =============================================================================
`ifdef SIMULATION
module tb_traffic_light;
    reg  clk = 0, reset = 1;
    wire red, yellow, green;

    traffic_light uut (
        .i_clk(clk), .i_reset(reset),
        .o_red(red), .o_yellow(yellow), .o_green(green)
    );

    always #20 clk = ~clk;  // 25 MHz

    integer test_count = 0, fail_count = 0;

    task check_state;
        input exp_r, exp_y, exp_g;
        input [8*20-1:0] name;
    begin
        test_count = test_count + 1;
        if (red !== exp_r || yellow !== exp_y || green !== exp_g) begin
            $display("FAIL: %0s — R=%b Y=%b G=%b (expected R=%b Y=%b G=%b)",
                     name, red, yellow, green, exp_r, exp_y, exp_g);
            fail_count = fail_count + 1;
        end else
            $display("PASS: %0s — R=%b Y=%b G=%b", name, red, yellow, green);
    end
    endtask

    task wait_cycles;
        input integer n;
        integer i;
        for (i = 0; i < n; i = i + 1) @(posedge clk);
    endtask

    initial begin
        $dumpfile("tb_traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        $display("\n=== Traffic Light FSM Testbench ===\n");

        // Reset
        wait_cycles(3);
        reset = 0;
        @(posedge clk); #1;
        check_state(0, 0, 1, "After reset: GREEN");

        // Wait for GREEN → YELLOW transition (GREEN_TIME = 10 cycles)
        wait_cycles(10);
        @(posedge clk); #1;
        check_state(0, 1, 0, "GREEN→YELLOW");

        // Wait for YELLOW → RED transition (YELLOW_TIME = 4 cycles)
        wait_cycles(4);
        @(posedge clk); #1;
        check_state(1, 0, 0, "YELLOW→RED");

        // Wait for RED → GREEN transition (RED_TIME = 10 cycles)
        wait_cycles(10);
        @(posedge clk); #1;
        check_state(0, 0, 1, "RED→GREEN (cycle 2)");

        // Test mid-cycle reset
        wait_cycles(5);
        reset = 1;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;
        check_state(0, 0, 1, "Mid-cycle reset → GREEN");

        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Tests run:    %0d", test_count);
        $display("Tests passed: %0d", test_count - fail_count);
        $display("Tests failed: %0d", fail_count);
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
