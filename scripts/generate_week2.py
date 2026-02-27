#!/usr/bin/env python3
"""
Week 2 Slide Deck Generator
Accelerated HDL for Digital System Design — UCF ECE
Days 5-8: Sequential Building Blocks, Verification, FSMs, Hierarchy
"""
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))
from generate_week1 import (html_template, slide, bridge_slide, end_slide,
                             takeaway_slide, code_slide, write_file)

# =============================================================================
# DAY 5 — Counters, Shift Registers & Debouncing
# =============================================================================

def day05_seg1():
    slides = ""
    slides += slide('''    <h2>Beyond the Free-Running Counter</h2>
    <p style="font-size:0.85em;">Day 4 gave you a simple incrementing counter. Real designs need:</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Modulo-N:</strong> counts 0 to N−1, then wraps (any period)</p>
        <p class="fragment"><strong>Up/Down:</strong> direction-controlled counting</p>
        <p class="fragment"><strong>Loadable:</strong> preset starting value (timers, address generators)</p>
    </div>''',
    notes="Day 4 gave you simple counters. Now we build the variations you'll actually use in real designs: modulo-N, up/down, and loadable counters.")

    slides += slide('''    <h2>Modulo-N Counter</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module counter_mod_n #(
    parameter N = 10
)(
    input  wire                  i_clk,
    input  wire                  i_reset,
    output reg  [$clog2(N)-1:0]  o_count,
    output wire                  o_wrap
);
<span class="fragment">    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (o_count == N - 1)
            o_count <= 0;
        else
            o_count <= o_count + 1;
    end</span>
<span class="fragment">
    assign o_wrap = (o_count == N - 1);</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <code>$clog2(N)</code> returns ceil(log₂(N)) — automatic width sizing. Change N, and the counter width adjusts. No manual math.
    </div>''',
    notes="The modulo-N counter wraps at any value, not just powers of two. The key new feature is dollar-clog2 — automatic width calculation. Change N and the bit width adjusts automatically. The wrap output pulses for one cycle at rollover.")

    slides += slide('''    <h2>Up/Down and Loadable Counters</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// Up/Down counter — direction control
always @(posedge i_clk) begin
    if (i_reset)        o_count <= 0;
    else if (i_enable) begin
        if (i_direction) o_count <= o_count - 1;  // down
        else             o_count <= o_count + 1;  // up
    end
end</code></pre>
    <pre class="synth fragment"><code class="language-verilog" data-noescape>// Loadable counter — preset starting value
always @(posedge i_clk) begin
    if (i_reset)         o_count <= 0;
    else if (i_load)     o_count <= i_data;    // parallel load
    else if (i_enable)   o_count <= o_count + 1;
end</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <strong>Priority matters:</strong> reset > load > enable. The <code>if/else</code> chain defines hardware priority.
    </div>''',
    notes="Up/down adds a direction input. Loadable adds a parallel load — useful for timers and baud rate dividers. Notice the priority: reset beats load, load beats enable. The if/else chain defines this hardware priority.")

    slides += takeaway_slide([
        "Modulo-N: count to N−1, then wrap. <code>$clog2(N)</code> sizes automatically.",
        "Up/Down: direction input selects increment or decrement.",
        "Loadable: parallel load for timer presets and address generators.",
        "Priority is defined by <code>if/else</code> order: reset > load > enable.",
    ])

    slides += bridge_slide("Shift Registers", 2, 12,
        "The building block behind UART and SPI — data moves one bit per clock.")

    return html_template("Day 5.1: Counter Variations", "Counter Variations",
        "Day 5 · Counters, Shift Registers &amp; Debouncing", 1, 10, slides)


def day05_seg2():
    slides = ""
    slides += slide('''    <h2>What Is a Shift Register?</h2>
    <p style="font-size:0.85em;">A chain of flip-flops where each stage passes its value to the next on every clock edge. Data moves <strong>one position per clock cycle</strong>.</p>
    <pre class="synth fragment"><code class="language-verilog">// 8-bit SIPO: Serial In, Parallel Out
reg [7:0] r_shift;

always @(posedge i_clk) begin
    if (i_reset)
        r_shift <= 8'b0;
    else if (i_shift_en)
        r_shift <= {i_serial_in, r_shift[7:1]};
        // New bit at MSB, everything shifts right
end

assign o_parallel_out = r_shift;</code></pre>''',
    notes="A shift register moves data one position per clock. This Serial-In-Parallel-Out version accepts one bit per clock and presents all 8 bits at once. The concatenation operator does the shifting — new bit at MSB, old bits shift right.")

    slides += slide('''    <h2>The Four Configurations</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Type</th><th>Input</th><th>Output</th><th>Use Case</th></tr></thead>
        <tbody>
            <tr class="fragment"><td><strong>SISO</strong></td><td>1 bit/clk</td><td>1 bit/clk</td><td>Delay line, pipeline</td></tr>
            <tr class="fragment"><td><strong>SIPO</strong></td><td>1 bit/clk</td><td>N bits at once</td><td>Serial receiver (<strong>UART RX</strong>)</td></tr>
            <tr class="fragment"><td><strong>PISO</strong></td><td>N bits at once</td><td>1 bit/clk</td><td>Serial transmitter (<strong>UART TX</strong>)</td></tr>
            <tr class="fragment"><td><strong>PIPO</strong></td><td>N bits at once</td><td>N bits at once</td><td>Register with shift</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Week 3 connection:</strong> UART TX is fundamentally a PISO shift register. UART RX is a SIPO. Understanding these now prepares you directly for serial communication.
    </div>''',
    notes="Four configurations. SIPO is the UART receiver. PISO is the UART transmitter. These aren't abstract — they're the exact building blocks you'll use in Week 3.")

    slides += slide('''    <h2>PISO — Parallel In, Serial Out</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module shift_reg_piso #(parameter WIDTH = 8)(
    input  wire              i_clk, i_reset,
    input  wire              i_load, i_shift_en,
    input  wire [WIDTH-1:0]  i_parallel_in,
    output wire              o_serial_out
);
    reg [WIDTH-1:0] r_shift;

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= 0;
<span class="fragment">        else if (i_load)
            r_shift <= i_parallel_in;       // load byte</span>
<span class="fragment">        else if (i_shift_en)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};  // shift right</span>
    end

    assign o_serial_out = r_shift[0];  // LSB out first
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        Load has priority over shift. Load a byte, then clock it out one bit at a time — this is exactly how UART TX works.
    </div>''',
    notes="PISO: load a parallel byte, then shift it out one bit at a time. Load has priority over shift. The LSB comes out first — matching UART convention. This is literally the core of the UART transmitter you'll build in Week 3.")

    slides += takeaway_slide([
        "Shift registers move data one bit per clock via concatenation.",
        "SIPO = serial receiver (UART RX). PISO = serial transmitter (UART TX).",
        "Load has priority over shift — <code>if/else</code> chain enforces this.",
        "These are the exact building blocks for Week 3 serial protocols.",
    ])

    slides += bridge_slide("Metastability &amp; Synchronizers", 3, 12,
        "When the physical world meets your clock — and how to handle it safely.")

    return html_template("Day 5.2: Shift Registers", "Shift Registers",
        "Day 5 · Counters, Shift Registers &amp; Debouncing", 2, 12, slides)


def day05_seg3():
    slides = ""
    slides += slide('''    <h2>The Metastability Problem</h2>
    <p style="font-size:0.8em;">Every flip-flop has <strong>setup time</strong> (data stable <em>before</em> edge) and <strong>hold time</strong> (data stable <em>after</em> edge). Violate either and the output enters a <strong>metastable state</strong> — neither 0 nor 1.</p>
    <pre style="font-family:monospace;font-size:0.6em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
Normal:       ____|‾‾‾‾     Clean transition

Metastable:   ____/‾‾‾‾     Output hovers at ~Vdd/2
                   ↑
             undefined — may resolve to 0 or 1
    </pre>
    <div class="fragment callout-danger" style="font-size:0.75em;">
        Metastability can <strong>propagate through your design</strong>, causing multiple flip-flops to see different values for the same signal. Cascading failures.
    </div>''',
    notes="Setup and hold time violations cause metastability — the output hovers between 0 and 1 for an unpredictable time. This can propagate through your design, causing different flip-flops to see different values. It's a real hardware failure mode.")

    slides += slide('''    <h2>When Does This Happen?</h2>
    <p style="font-size:0.85em;">When an <strong>asynchronous signal</strong> is sampled by a flip-flop. The signal can change at any time, including during the setup/hold window.</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Button inputs:</strong> human presses have no relationship to the 25 MHz clock</p>
        <p class="fragment"><strong>External sensors:</strong> data from another clock domain</p>
        <p class="fragment"><strong>UART RX:</strong> serial data clocked by the remote transmitter</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        Any signal not generated by your clock is potentially asynchronous and needs synchronization.
    </div>''',
    notes="This happens when asynchronous signals — buttons, external data, UART RX — are sampled by your clock. Any signal not generated by your clock needs synchronization.")

    slides += slide('''    <h2>The 2-FF Synchronizer</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module synchronizer (
    input  wire i_clk,
    input  wire i_async_in,
    output wire o_sync_out
);
<span class="fragment">    reg r_meta;   // Stage 1 — may go metastable
    reg r_sync;   // Stage 2 — extremely unlikely to still be metastable</span>

<span class="fragment">    always @(posedge i_clk) begin
        r_meta <= i_async_in;   // capture (might be metastable)
        r_sync <= r_meta;       // gives stage 1 a full cycle to resolve
    end</span>

    assign o_sync_out = r_sync;
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        The second FF almost certainly sees a clean 0 or 1 because the first FF had an entire clock period to resolve. MTBF of 2-FF synchronizer at 25 MHz: <strong>centuries</strong>.
    </div>''',
    notes="The 2-FF synchronizer is the standard fix. The first flip-flop might go metastable, but it has a full clock period to resolve before the second flip-flop samples it. At 25 MHz, the mean time between failure is measured in centuries.")

    slides += takeaway_slide([
        "Metastability = output is neither 0 nor 1 after a timing violation.",
        "Any signal not from your clock domain needs a synchronizer.",
        "2-FF synchronizer: two back-to-back FFs. MTBF: centuries at 25 MHz.",
        "Synchronize first, <strong>then</strong> debounce — order matters.",
    ])

    slides += bridge_slide("Button Debouncing", 4, 11,
        "Buttons bounce for milliseconds. Your clock sees every bounce. Let's fix that.")

    return html_template("Day 5.3: Metastability and Synchronizers",
        "Metastability &amp; Synchronizers",
        "Day 5 · Counters, Shift Registers &amp; Debouncing", 3, 12, slides)


def day05_seg4():
    slides = ""
    slides += slide('''    <h2>The Bounce Problem</h2>
    <pre style="font-family:monospace;font-size:0.55em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
Ideal:    ‾‾‾‾‾‾‾‾‾‾‾|_________________________|‾‾‾‾‾‾‾‾‾‾‾
                     press                    release

Reality:  ‾‾‾‾‾‾‾‾‾‾‾|‾|_|‾|__________________|‾|_|‾‾‾‾‾‾‾‾
                      ↑ ↑ ↑ ↑                  ↑ ↑ ↑
                      bounces (~1-10 ms)       bounces
    </pre>
    <p style="font-size:0.8em;">Mechanical switches bounce for <strong>1–10 ms</strong>. At 25 MHz, that's up to <strong>250,000 clock cycles</strong> of random toggling. Your counter increments on every edge it sees.</p>''',
    notes="Mechanical switches don't transition cleanly. They bounce for 1 to 10 milliseconds. At 25 MHz, that's up to 250,000 cycles of random toggling. Your counter sees every bounce as a separate press.")

    slides += slide('''    <h2>Counter-Based Debounce</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module debounce #(
    parameter CLKS_TO_STABLE = 250_000  // ~10ms at 25MHz
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);
<span class="fragment">    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
    reg r_sync_0, r_sync_1;  // 2-FF synchronizer built in</span>

<span class="fragment">    always @(posedge i_clk) begin
        r_sync_0 <= i_bouncy;      // synchronize
        r_sync_1 <= r_sync_0;</span>

<span class="fragment">        if (r_sync_1 != o_clean) begin
            r_count <= r_count + 1;
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;   // accept new value
                r_count <= 0;
            end
        end else begin
            r_count <= 0;   // input matches output — reset counter
        end</span>
    end
endmodule</code></pre>''',
    notes="The debounce module has a built-in 2-FF synchronizer and a counter. When the synchronized input differs from the clean output, start counting. If it stays different for CLKS_TO_STABLE cycles, accept the new value. If it bounces back, reset the counter.")

    slides += slide('''    <h2>The Complete Input Pipeline</h2>
    <div style="text-align:center;font-size:0.8em;margin-top:1em;">
        <span style="background:#FFEBEE;padding:0.3em 0.6em;border-radius:4px;">Button (async)</span>
        →
        <span style="background:#E3F2FD;padding:0.3em 0.6em;border-radius:4px;">Synchronizer (2-FF)</span>
        →
        <span style="background:#E8F5E9;padding:0.3em 0.6em;border-radius:4px;">Debounce (counter)</span>
        →
        <span style="background:#FFF8E1;padding:0.3em 0.6em;border-radius:4px;">Edge Detect</span>
    </div>
    <pre class="synth fragment" style="margin-top:1em;"><code class="language-verilog">// Edge detector — produces 1-clock pulse on rising edge
reg r_clean_prev;
always @(posedge i_clk) r_clean_prev <= o_clean;
wire w_press = o_clean & ~r_clean_prev;  // rising edge</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Pipeline:</strong> synchronize → debounce → edge detect. This gives you a single clean pulse per button press. Reusable everywhere.
    </div>''',
    notes="The complete input pipeline: synchronize the async signal, debounce it, then edge-detect for a clean single-cycle pulse. This is a reusable pattern for every button input in every design.")

    slides += takeaway_slide([
        "Buttons bounce for 1–10ms = up to 250K cycles at 25 MHz.",
        "Counter-based debounce: require stable input for N cycles before accepting.",
        "Always synchronize <strong>before</strong> debouncing.",
        "Edge detection gives one clean pulse per press. Pipeline: sync → debounce → edge.",
    ])

    slides += end_slide(5)

    return html_template("Day 5.4: Button Debouncing", "Button Debouncing",
        "Day 5 · Counters, Shift Registers &amp; Debouncing", 4, 11, slides)


# =============================================================================
# DAY 6 — Testbenches & Simulation-Driven Development
# =============================================================================

def day06_seg1():
    slides = ""
    slides += slide('''    <h2>Why Testbenches Are Not Optional</h2>
    <p style="font-size:0.85em;">From today forward, this is the workflow:</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p><strong>1.</strong> Write the module (DUT)</p>
        <p><strong>2.</strong> Write the testbench</p>
        <p><strong>3.</strong> Simulate and verify in GTKWave</p>
        <p><strong>4.</strong> Fix bugs found in simulation</p>
        <p><strong>5.</strong> Only then synthesize and program</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        In industry, verification-to-design code ratios are <strong>3:1 to 10:1</strong>. More testbench code than design code. A bug in simulation costs minutes. A bug on hardware costs hours. A bug in an ASIC costs millions.
    </div>''',
    notes="From today forward, every design gets a testbench. This is industry standard. Verification to design ratios are 3 to 1 at minimum. A bug found in simulation costs minutes. On hardware, hours. On an ASIC, millions.")

    slides += slide('''    <h2>Testbench Structure</h2>
    <pre class="sim-only"><code class="language-verilog" data-noescape><span class="fragment">`timescale 1ns / 1ps            // time unit / precision</span>
<span class="fragment">
module tb_my_module;            // NO PORTS — top of simulation</span>
<span class="fragment">
    // 1. Signal declarations (reg for inputs, wire for outputs)
    reg        clk, reset;
    reg  [3:0] a, b;
    wire [3:0] result;</span>
<span class="fragment">
    // 2. DUT instantiation
    alu_4bit uut (.i_a(a), .i_b(b), .o_result(result));</span>
<span class="fragment">
    // 3. Clock generation
    initial clk = 0;
    always #20 clk = ~clk;     // 25 MHz (40ns period)</span>
<span class="fragment">
    // 4. Waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_my_module);
    end</span>
<span class="fragment">
    // 5. Stimulus
    initial begin
        reset = 1; a = 0; b = 0;
        #100; reset = 0;
        // ... test cases ...
        $finish;
    end</span>
endmodule</code></pre>''',
    notes="A testbench has no ports — it's the top of the simulation world. Inputs are reg because you drive them. Outputs are wire because the DUT drives them. Five sections: declarations, DUT instantiation, clock, waveform dump, and stimulus.")

    slides += slide('''    <h2>Key Elements Explained</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Element</th><th>Purpose</th><th>Why</th></tr></thead>
        <tbody>
            <tr><td><code>`timescale 1ns/1ps</code></td><td>Set time units</td><td><code>#10</code> = 10ns; precision to 1ps</td></tr>
            <tr><td><code>reg</code> for inputs</td><td>You drive them</td><td>Assigned in <code>initial</code>/<code>always</code></td></tr>
            <tr><td><code>wire</code> for outputs</td><td>DUT drives them</td><td>You observe, not drive</td></tr>
            <tr><td><code>always #20 clk</code></td><td>25 MHz clock</td><td>40ns period = 20ns half-period</td></tr>
            <tr><td><code>$dumpfile/$dumpvars</code></td><td>VCD for GTKWave</td><td><code>0</code> = all hierarchy levels</td></tr>
            <tr><td><code>$finish</code></td><td>End simulation</td><td>Without it, clock runs forever</td></tr>
        </tbody>
    </table>''',
    notes="Quick reference for the key elements. timescale sets time units. Inputs are reg, outputs are wire. The clock pattern is idiomatic. dumpfile and dumpvars generate the waveform file. $finish stops the simulation.")

    slides += takeaway_slide([
        "Testbench = no-port module. <code>reg</code> for DUT inputs, <code>wire</code> for outputs.",
        "<code>`timescale</code>, clock gen, <code>$dumpfile/$dumpvars</code>, <code>$finish</code> — memorize the template.",
        "Every design gets a testbench from today forward.",
        "Simulate first. Synthesize second. Program last.",
    ])

    slides += bridge_slide("Self-Checking Testbenches", 2, 15,
        "Automated pass/fail — because eyeballing waveforms doesn't scale.")

    return html_template("Day 6.1: Testbench Anatomy", "Testbench Anatomy",
        "Day 6 · Testbenches &amp; Simulation-Driven Development", 1, 12, slides)


def day06_seg2():
    slides = ""
    slides += slide('''    <h2>The Problem With Manual Inspection</h2>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><span style="color:#C62828;">✗</span> You can miss subtle bugs (off-by-one, wrong bit, glitch)</p>
        <p class="fragment"><span style="color:#C62828;">✗</span> Doesn't scale — can't visually verify 1000 test vectors</p>
        <p class="fragment"><span style="color:#C62828;">✗</span> Not repeatable — different people notice different things</p>
        <p class="fragment"><span style="color:#C62828;">✗</span> Not automatable — can't run in CI/CD</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:1em;">
        The testbench must check itself. If it doesn't print PASS or FAIL, you're doing it wrong.
    </div>''',
    notes="Looking at waveforms doesn't scale. You miss subtle bugs, it's not repeatable, and you can't automate it. The testbench must check itself. If it doesn't print PASS or FAIL, you're doing it wrong.")

    slides += slide('''    <h2>Automated Checking Pattern</h2>
    <pre class="sim-only"><code class="language-verilog" data-noescape>initial begin
    // ... setup ...

<span class="fragment">    // Test: ADD 3 + 5 = 8
    a = 4'd3; b = 4'd5; opcode = 2'b00;
    #100;</span>

<span class="fragment">    if (result !== 4'd8)
        $display("FAIL: ADD 3+5: expected 8, got %d", result);
    else
        $display("PASS: ADD 3+5 = %d", result);</span>
end</code></pre>
    <div class="fragment callout-warning" style="font-size:0.75em;">
        <strong><code>!==</code> not <code>!=</code></strong> — case inequality handles <code>x</code> and <code>z</code> correctly.<br>
        <code>x != 0</code> → <code>x</code> (unknown). <code>x !== 0</code> → <code>1</code> (they don't match). Always use <code>===</code>/<code>!==</code> in testbenches.
    </div>''',
    notes="The basic pattern: apply stimulus, wait, check result. Use case inequality — three-equals and bang-double-equals — because they handle x and z values correctly. Regular inequality returns unknown when either side is x.")

    slides += slide('''    <h2>Structured Test Reporting</h2>
    <pre class="sim-only"><code class="language-verilog" data-noescape><span class="fragment">integer test_count = 0;
integer fail_count = 0;</span>

<span class="fragment">task check_result;
    input [3:0] expected;
    input [3:0] actual;
    input [8*20-1:0] test_name;
begin
    test_count = test_count + 1;
    if (actual !== expected) begin
        $display("FAIL [%0d]: %0s — expected %h, got %h",
                 test_count, test_name, expected, actual);
        fail_count = fail_count + 1;
    end else
        $display("PASS [%0d]: %0s", test_count, test_name);
end
endtask</span></code></pre>''',
    notes="The structured pattern: a task that tracks pass/fail counts. Call it after each test. At the end, print a summary. This is the pattern you'll use for every testbench going forward.")

    slides += slide('''    <h2>Final Report Pattern</h2>
    <pre class="sim-only"><code class="language-verilog">initial begin
    // ... tests using check_result(...) ...

    // Final summary
    $display("\\n========================================");
    $display("Tests: %0d  |  Passed: %0d  |  Failed: %0d",
             test_count, test_count - fail_count, fail_count);
    $display("========================================");
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("*** FAILURES DETECTED ***");
    $finish;
end</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        This is your testbench standard from now on. Copy this pattern every time.
    </div>''',
    notes="Always end with a summary. Total tests, passes, failures. ALL TESTS PASSED or FAILURES DETECTED. This is your standard from now on.")

    slides += takeaway_slide([
        "Self-checking testbenches: <code>if (actual !== expected)</code> — automate it.",
        "Use <code>===</code>/<code>!==</code> (case equality) — handles x/z correctly.",
        "Track <code>test_count</code> and <code>fail_count</code>. Print a summary.",
        "This is the pattern for every testbench going forward.",
    ])

    slides += bridge_slide("Tasks for Organization", 3, 10,
        "Reusable testbench procedures — apply stimulus, check results, keep it DRY.")

    return html_template("Day 6.2: Self-Checking Testbenches", "Self-Checking Testbenches",
        "Day 6 · Testbenches &amp; Simulation-Driven Development", 2, 15, slides)


def day06_seg3():
    slides = ""
    slides += slide('''    <h2>The <code>task</code> Construct</h2>
    <p style="font-size:0.85em;">A <code>task</code> is a reusable block of testbench code — like a function but it can include time-consuming operations (<code>#</code> delays, <code>@(posedge clk)</code>).</p>
    <pre class="sim-only fragment"><code class="language-verilog">task apply_and_check;
    input [3:0] in_a, in_b;
    input [2:0] in_op;
    input [3:0] expected;
    input [8*20-1:0] name;
begin
    a = in_a; b = in_b; opcode = in_op;
    @(posedge clk);  // wait one clock
    @(posedge clk);  // let combinational settle
    check_result(expected, result, name);
end
endtask</code></pre>''',
    notes="Tasks are reusable testbench procedures. Unlike functions, they can include delays and clock-edge waits. Combine stimulus application and result checking into one call.")

    slides += slide('''    <h2>Clean Test Cases with Tasks</h2>
    <pre class="sim-only"><code class="language-verilog">initial begin
    // Reset
    reset = 1; #100; reset = 0; #100;

    // Clean, readable test cases
    apply_and_check(4'd3, 4'd5, 3'b000, 4'd8,  "ADD 3+5");
    apply_and_check(4'd7, 4'd3, 3'b001, 4'd4,  "SUB 7-3");
    apply_and_check(4'hA, 4'hC, 3'b010, 4'h8,  "AND A&C");
    apply_and_check(4'hA, 4'hC, 3'b011, 4'hE,  "OR  A|C");
    apply_and_check(4'hF, 4'd0, 3'b101, 4'h0,  "NOT F");

    // Summary report
    // ...
    $finish;
end</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        Each test is one line. Easy to add more. Easy to read. Easy to maintain.
    </div>''',
    notes="With tasks, each test case is a single readable line. Easy to add more, easy to maintain. This is how professional verification engineers write testbenches.")

    slides += takeaway_slide([
        "<code>task</code> can include delays and clock waits — unlike functions.",
        "Combine stimulus + checking in one reusable task.",
        "Result: one-line test cases that are easy to read and extend.",
    ])

    slides += bridge_slide("File-Driven Testing", 4, 13,
        "Load test vectors from a file — separate data from testbench logic.")

    return html_template("Day 6.3: Tasks for Organization", "Tasks for Organization",
        "Day 6 · Testbenches &amp; Simulation-Driven Development", 3, 10, slides)


def day06_seg4():
    slides = ""
    slides += slide('''    <h2>Loading Test Vectors from Files</h2>
    <pre class="sim-only"><code class="language-verilog" data-noescape><span class="fragment">// test_vectors.txt — one vector per line (hex)
// a  b  op  expected
// 3  5  0   8
// 7  3  1   4
// A  C  2   8</span>
<span class="fragment">
reg [3:0] test_mem [0:255];  // storage for vectors
integer i;

initial begin
    $readmemh("test_vectors.txt", test_mem);</span>
<span class="fragment">
    for (i = 0; i < 256; i = i + 1) begin
        // extract fields from packed vector
        a = test_mem[i][15:12];
        b = test_mem[i][11:8];
        opcode = test_mem[i][7:4];
        // ... check against test_mem[i][3:0] ...
    end
end</span></code></pre>''',
    notes="readmemh loads hex values from a text file into a memory array. You can store hundreds of test vectors in a file and loop through them. This separates test data from testbench logic.")

    slides += slide('''    <h2>Sequential Testbench Pattern</h2>
    <pre class="sim-only"><code class="language-verilog" data-noescape>// For sequential DUTs, use clock-edge-based stimulus
task reset_dut;
begin
    i_reset = 1;
    repeat(5) @(posedge clk);  // hold reset for 5 cycles
    i_reset = 0;
    @(posedge clk);
end
endtask
<span class="fragment">
task wait_cycles;
    input integer n;
    integer i;
begin
    for (i = 0; i < n; i = i + 1)
        @(posedge clk);
end
endtask</span>
<span class="fragment">
// Usage:
initial begin
    reset_dut;
    // Apply input, wait for output
    i_data = 8'hA5;
    i_valid = 1;
    @(posedge clk);
    i_valid = 0;
    wait_cycles(10);     // wait for processing
    check_result(expected, o_data, "test 1");
end</span></code></pre>''',
    notes="For sequential designs, use clock-edge-based stimulus. Reset with repeat-posedge. Use wait_cycles for delays. Apply inputs synchronously to clock edges. This is the pattern for all sequential testbenches.")

    slides += takeaway_slide([
        "<code>$readmemh</code>/<code>$readmemb</code> load test vectors from files.",
        "Sequential testbenches: <code>@(posedge clk)</code> and <code>repeat</code> for timing.",
        "Separate test data from testbench logic for maintainability.",
        "From today: <strong>no design without a self-checking testbench.</strong>",
    ])

    slides += end_slide(6)

    return html_template("Day 6.4: File-Driven Testing", "File-Driven &amp; Sequential Testing",
        "Day 6 · Testbenches &amp; Simulation-Driven Development", 4, 13, slides)


# =============================================================================
# DAY 7 — Finite State Machines
# =============================================================================

def day07_seg1():
    slides = ""
    slides += slide('''    <h2>What Is a Finite State Machine?</h2>
    <p style="font-size:0.85em;">An FSM is a sequential circuit defined by:</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment">A finite set of <strong>states</strong> (the machine is always in exactly one)</p>
        <p class="fragment"><strong>Transitions</strong> between states, governed by input conditions</p>
        <p class="fragment"><strong>Outputs</strong> that depend on the current state (and possibly inputs)</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        Every digital controller is fundamentally an FSM: traffic lights, protocol engines, vending machines, CPU control units, elevator controllers, game logic.
    </div>''',
    notes="An FSM has states, transitions, and outputs. Every digital controller is fundamentally an FSM. This is arguably the most important design pattern in digital systems.")

    slides += slide('''    <h2>Moore vs. Mealy</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th></th><th>Moore</th><th>Mealy</th></tr></thead>
        <tbody>
            <tr><td>Outputs depend on</td><td>State only</td><td>State + inputs</td></tr>
            <tr><td>Output changes</td><td>On clock edge (with state)</td><td>Can change mid-state</td></tr>
            <tr><td>Timing</td><td>Clean, stable outputs</td><td>Faster reaction, possible glitches</td></tr>
            <tr><td>States needed</td><td>Typically more</td><td>Typically fewer</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Our default: Moore.</strong> Safer, easier to debug, cleaner timing. Use Mealy only when you need same-cycle reaction.
    </div>''',
    notes="Moore outputs depend only on state — clean and stable. Mealy outputs depend on state and inputs — faster but can glitch. We'll default to Moore. It's safer and easier to debug.")

    slides += slide('''    <h2>FSM Architecture — Three Blocks</h2>
    <pre style="font-family:monospace;font-size:0.5em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
             ┌─────────────────────────────────┐
  inputs ───►│  ┌───────────┐                   │
             │  │ Next-State│  next_state        │
             │  │  Logic    │─────────┐          │
             │  │ (comb.)   │         ▼          │
             │  └───────────┘   ┌──────────┐     │
             │    clk ─────────►│  State   │     │
             │    reset ───────►│ Register │     │
             │                  └────┬─────┘     │
             │                       │ state     │
             │              ┌────────┴────────┐  │
             │              │  Output Logic   │──┼──► outputs
             │              │  (comb.)        │  │
             │              └─────────────────┘  │
             └─────────────────────────────────┘
    </pre>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Block 1:</strong> State Register — sequential (<code>posedge clk</code>)</p>
        <p class="fragment"><strong>Block 2:</strong> Next-State Logic — combinational (<code>@(*)</code>)</p>
        <p class="fragment"><strong>Block 3:</strong> Output Logic — combinational (<code>@(*)</code>)</p>
    </div>''',
    notes="Three distinct blocks that map directly to hardware. State register is the only sequential block — trivially correct. Next-state and output logic are combinational — using all the latch-prevention techniques from Day 3.")

    slides += takeaway_slide([
        "FSM = states + transitions + outputs. Every controller is an FSM.",
        "Moore (default): outputs = f(state). Mealy: outputs = f(state, inputs).",
        "Three-block architecture: state register, next-state logic, output logic.",
        "Each block has one job — easier to reason about, test, and debug.",
    ])

    slides += bridge_slide("The 3-Always-Block Template", 2, 15,
        "The Verilog coding style you'll use for every FSM — with a complete template.")

    return html_template("Day 7.1: FSM Theory and Architecture", "FSM Theory &amp; Architecture",
        "Day 7 · Finite State Machines", 1, 12, slides)


def day07_seg2():
    slides = ""
    slides += slide('''    <h2>The 3-Always-Block Template</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// ===== State Encoding =====
localparam S_IDLE = 2'b00;
localparam S_RUN  = 2'b01;
localparam S_DONE = 2'b10;

reg [1:0] r_state, r_next_state;
<span class="fragment">
// ===== Block 1: State Register (Sequential) =====
always @(posedge i_clk) begin
    if (i_reset) r_state <= S_IDLE;
    else         r_state <= r_next_state;
end</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        Block 1 is always this simple. Just a flip-flop with reset. <strong>Never put logic here.</strong>
    </div>''',
    notes="Block 1 is always trivial — just a flip-flop that loads next_state on each clock edge, with a reset to IDLE. Never put any logic in this block. It's always correct by construction.")

    slides += slide('''    <h2>Block 2: Next-State Logic</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// ===== Block 2: Next-State Logic (Combinational) =====
always @(*) begin
    r_next_state = r_state;  // DEFAULT: stay in current state
<span class="fragment">
    case (r_state)
        S_IDLE: begin
            if (i_start) r_next_state = S_RUN;
        end
        S_RUN: begin
            if (i_done)  r_next_state = S_DONE;
        end
        S_DONE: begin
            r_next_state = S_IDLE;  // unconditional
        end
        default: r_next_state = S_IDLE;
    endcase</span>
end</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <strong>Critical:</strong> <code>r_next_state = r_state;</code> as the first line prevents latches and handles "stay in state" as the default behavior.
    </div>''',
    notes="Block 2 computes the next state. The critical line is the default assignment at the top — r_next_state equals r_state. This prevents latches and means if no transition fires, we stay put. The default case catches illegal states.")

    slides += slide('''    <h2>Block 3: Output Logic (Moore)</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// ===== Block 3: Output Logic (Combinational — Moore) =====
always @(*) begin
    // Defaults — prevents latches on ALL outputs
    o_busy    = 1'b0;
    o_done    = 1'b0;
    o_led     = 1'b0;
<span class="fragment">
    case (r_state)
        S_IDLE: begin
            // all defaults — nothing active
        end
        S_RUN: begin
            o_busy = 1'b1;
            o_led  = 1'b1;
        end
        S_DONE: begin
            o_done = 1'b1;
        end
        default: ; // defaults apply
    endcase</span>
end</code></pre>''',
    notes="Block 3 maps states to outputs. Default all outputs first — prevents latches. Then override in each state. Moore style: outputs depend only on r_state, not on any inputs.")

    slides += takeaway_slide([
        "Block 1: <code>always @(posedge clk)</code> — just a flip-flop. Always trivial.",
        "Block 2: <code>always @(*)</code> — next-state logic. Default: stay in current state.",
        "Block 3: <code>always @(*)</code> — output logic. Default all outputs first.",
        "Template works for any FSM. Memorize it.",
    ])

    slides += bridge_slide("State Encoding", 3, 8,
        "Binary, one-hot, and Gray — how encoding choice affects your hardware.")

    return html_template("Day 7.2: The 3-Always-Block Style", "The 3-Always-Block Style",
        "Day 7 · Finite State Machines", 2, 15, slides)


def day07_seg3():
    slides = ""
    slides += slide('''    <h2>Encoding Options</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// Binary — minimum bits: ceil(log2(N))
localparam S_IDLE = 2'b00;
localparam S_RUN  = 2'b01;
localparam S_DONE = 2'b10;
<span class="fragment">
// One-Hot — one FF per state, one bit high at a time
localparam S_IDLE = 3'b001;
localparam S_RUN  = 3'b010;
localparam S_DONE = 3'b100;</span>
<span class="fragment">
// Gray — adjacent states differ by 1 bit
localparam S_A = 2'b00;
localparam S_B = 2'b01;
localparam S_C = 2'b11;
localparam S_D = 2'b10;</span></code></pre>''',
    notes="Three encoding options. Binary uses minimum flip-flops. One-hot uses one FF per state but simpler next-state logic — often faster on FPGAs. Gray encoding minimizes bit transitions — useful for clock domain crossing.")

    slides += slide('''    <h2>Which Encoding to Use?</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Encoding</th><th>FFs</th><th>Logic Depth</th><th>Best For</th></tr></thead>
        <tbody>
            <tr><td>Binary</td><td>Minimum</td><td>Deeper</td><td>Small FSMs, resource-constrained</td></tr>
            <tr><td>One-Hot</td><td>One per state</td><td>Shallow</td><td>FPGAs (LUT-rich), speed-critical</td></tr>
            <tr><td>Gray</td><td>Minimum</td><td>Moderate</td><td>Clock domain crossing</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Practical advice:</strong> Use binary encoding with <code>localparam</code> (our default). FPGA tools like Yosys can automatically re-encode to one-hot if it's faster. Don't over-optimize encoding manually.
    </div>''',
    notes="Practical advice: use binary with localparam. Yosys can re-encode automatically if one-hot is better for the target. Don't manually optimize encoding unless you have a specific reason.")

    slides += takeaway_slide([
        "Binary: minimum FFs, our default. One-hot: faster on FPGAs.",
        "Gray: adjacent states differ by 1 bit — for clock domain crossing.",
        "Use <code>localparam</code> for state values. Let tools optimize encoding.",
    ])

    slides += bridge_slide("FSM Design Methodology", 4, 15,
        "Step-by-step: state diagram → Verilog → testbench. With a complete example.")

    return html_template("Day 7.3: State Encoding", "State Encoding",
        "Day 7 · Finite State Machines", 3, 8, slides)


def day07_seg4():
    slides = ""
    slides += slide('''    <h2>Step-by-Step FSM Design</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>1. Define states:</strong> What modes does the system have?</p>
        <p class="fragment"><strong>2. Define transitions:</strong> What causes each state change?</p>
        <p class="fragment"><strong>3. Define outputs:</strong> What does each state produce? (Moore)</p>
        <p class="fragment"><strong>4. Draw the state diagram:</strong> Circles + arrows + labels</p>
        <p class="fragment"><strong>5. Code using the 3-block template</strong></p>
        <p class="fragment"><strong>6. Verify:</strong> Self-checking testbench for every transition</p>
    </div>''',
    notes="Six steps. Define states, transitions, and outputs. Draw the state diagram. Code it using the 3-block template. Verify every transition with a testbench. This is the methodology for every FSM.")

    slides += slide('''    <h2>Example: Traffic Light Controller</h2>
    <pre style="font-family:monospace;font-size:0.5em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
         ┌───────────────┐  timer expires
         │               ▼
      ┌──────┐      ┌──────┐
      │GREEN │─────►│YELLOW│
      │ NS   │      │ NS   │
      └──────┘      └──┬───┘
         ▲              │ timer expires
         │              ▼
      ┌──────┐      ┌──────┐
      │YELLOW│◄─────│GREEN │
      │ EW   │      │ EW   │
      └──────┘      └──────┘
         timer expires
    </pre>
    <p style="font-size:0.7em;text-align:center;">Four states, each with a timer. When the timer expires, advance to the next state.</p>''',
    notes="Traffic light: four states cycling with timers. Green NS, Yellow NS, Green EW, Yellow EW. Each has a timer that triggers the transition. This is a classic FSM example that maps perfectly to the 3-block template.")

    slides += slide('''    <h2>Common FSM Mistakes</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#C62828;">✗</span> <strong>No default in next-state logic</strong> → latch on <code>r_next_state</code></p>
        <p class="fragment"><span style="color:#C62828;">✗</span> <strong>Forgetting output defaults</strong> → latches on output signals</p>
        <p class="fragment"><span style="color:#C62828;">✗</span> <strong>Using <code>=</code> in the state register</strong> → should be <code>&lt;=</code></p>
        <p class="fragment"><span style="color:#C62828;">✗</span> <strong>No <code>default</code> case</strong> → stuck in illegal state forever</p>
        <p class="fragment"><span style="color:#C62828;">✗</span> <strong>Putting logic in Block 1</strong> → keep it as a simple flip-flop</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Checklist:</strong> Default assignment in Blocks 2 &amp; 3 ✓ · <code>default</code> case in both ✓ · <code>&lt;=</code> in Block 1 ✓ · <code>=</code> in Blocks 2 &amp; 3 ✓
    </div>''',
    notes="Common mistakes: forgetting defaults causes latches. Using blocking in the state register. No default case leaves you stuck in illegal states. Put logic in Block 1. The checklist at the bottom should be your go-to before submitting any FSM.")

    slides += takeaway_slide([
        "Methodology: states → transitions → outputs → diagram → code → test.",
        "3-block template works for any FSM. Memorize it.",
        "Checklist: defaults in Blocks 2 &amp; 3, <code>default</code> case, correct assignments.",
        "Test every transition — including reset and illegal states.",
    ])

    slides += end_slide(7)

    return html_template("Day 7.4: FSM Design Methodology", "FSM Design Methodology",
        "Day 7 · Finite State Machines", 4, 15, slides)


# =============================================================================
# DAY 8 — Hierarchy, Parameters & Generate
# =============================================================================

def day08_seg1():
    slides = ""
    slides += slide('''    <h2>Hierarchy Manages Complexity</h2>
    <pre style="font-family:monospace;font-size:0.55em;background:none;border:none;box-shadow:none;color:#333;">
    top_button_counter
    ├── debounce (switch 1 — reset)
    ├── debounce (switch 2 — count)
    ├── edge_detector (count press)
    ├── counter_mod_n (4-bit hex counter)
    ├── hex_to_7seg (display decoder)
    └── heartbeat_blinker (LED1)
    </pre>
    <p style="font-size:0.8em;">Already 6+ modules in a simple design. A UART controller will have twice as many.</p>
    <div class="fragment callout" style="font-size:0.75em;">
        Good hierarchy makes each module small enough to <strong>understand, test, and reuse independently</strong>.
    </div>''',
    notes="By Day 8, designs are complex enough that everything in one module is untenable. Good hierarchy makes each piece small enough to understand, test, and reuse on its own.")

    slides += slide('''    <h2>Naming Conventions for Hierarchy</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module top_uart_demo (
    input  wire i_clk, i_switch1,
    output wire o_led1, o_uart_tx
);
<span class="fragment">    // Internal wires — named by source or purpose
    wire w_debounce_clean;
    wire w_edge_press;
    wire [7:0] w_counter_value;</span>
<span class="fragment">
    // Instance names describe their specific role
    debounce #(.CLKS_TO_STABLE(250_000)) debounce_sw1 (
        .i_clk    (i_clk),
        .i_bouncy (i_switch1),
        .o_clean  (w_debounce_clean)
    );</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <strong>Rules:</strong> Descriptive instance names (not <code>u1</code>). Named port connections (never positional). Internal wires describe the signal's purpose.
    </div>''',
    notes="Naming rules: descriptive instance names like debounce_sw1, not u1. Always named port connections — never positional. Internal wires describe what the signal carries.")

    slides += takeaway_slide([
        "Hierarchy = each module is small enough to understand, test, and reuse.",
        "Descriptive instance names: <code>debounce_sw1</code>, not <code>u1</code>.",
        "Always named port connections: <code>.i_clk(i_clk)</code> — never positional.",
        "Design top-down (architecture), implement bottom-up (test small pieces first).",
    ])

    slides += bridge_slide("Parameters &amp; Parameterization", 2, 15,
        "Write once, configure many — the key to reusable modules.")

    return html_template("Day 8.1: Module Hierarchy Deep Dive", "Module Hierarchy",
        "Day 8 · Hierarchy, Parameters &amp; Generate", 1, 12, slides)


def day08_seg2():
    slides = ""
    slides += slide('''    <h2><code>parameter</code> — Configurable at Instantiation</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module counter #(
    parameter WIDTH     = 8,
    parameter MAX_COUNT = 255
)(
    input  wire                 i_clk, i_reset, i_enable,
    output reg  [WIDTH-1:0]     o_count,
    output wire                 o_done
);
    always @(posedge i_clk) begin
        if (i_reset)                    o_count <= 0;
        else if (i_enable) begin
            if (o_count == MAX_COUNT)   o_count <= 0;
            else                        o_count <= o_count + 1;
        end
    end
    assign o_done = (o_count == MAX_COUNT);
endmodule</code></pre>
    <pre class="synth fragment"><code class="language-verilog">// Override parameters at instantiation
counter #(.WIDTH(16), .MAX_COUNT(49_999)) baud_counter (
    .i_clk(i_clk), .i_reset(i_reset), .i_enable(1'b1),
    .o_count(w_baud_count), .o_done(w_baud_tick)
);</code></pre>''',
    notes="Parameters make modules configurable. Define defaults in the module, override at instantiation. One counter module serves as a baud rate timer, a hex counter, or anything else — just change the parameters.")

    slides += slide('''    <h2><code>localparam</code> and <code>$clog2</code></h2>
    <pre class="synth"><code class="language-verilog" data-noescape"><span class="fragment">// localparam — internal, cannot be overridden
localparam MAX_COUNT = (1 << WIDTH) - 1;  // derived from parameter
// WIDTH=8 → MAX_COUNT=255. WIDTH=4 → 15. Always correct!</span>

<span class="fragment">// $clog2 — automatic width calculation
module timer #(parameter TICKS = 1_000_000)(
    input wire i_clk, i_start,
    output reg o_done
);
    localparam CNT_WIDTH = $clog2(TICKS);  // auto-sized
    reg [CNT_WIDTH-1:0] r_count;
    // Change TICKS → width adjusts. No manual math.</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Guideline:</strong> <code>parameter</code> for user-configurable values. <code>localparam</code> for internal/derived constants and state encodings.
    </div>''',
    notes="localparam is for internal constants that shouldn't be overridden — derived values and state encodings. $clog2 automatically sizes counters. Change the parameter, the width adjusts. No manual math, no overflow bugs.")

    slides += takeaway_slide([
        "<code>parameter</code>: configurable at instantiation. <code>localparam</code>: internal only.",
        "<code>$clog2(N)</code>: auto-size counter widths. No manual log calculations.",
        "Parameterize widths, thresholds, timing. Don't over-parameterize.",
        "Derived <code>localparam</code> prevents mismatch bugs (e.g., WIDTH vs MAX_COUNT).",
    ])

    slides += bridge_slide("Generate Blocks", 3, 12,
        "Hardware replication and conditional instantiation — compile-time code generation.")

    return html_template("Day 8.2: Parameters and Parameterization", "Parameters &amp; Parameterization",
        "Day 8 · Hierarchy, Parameters &amp; Generate", 2, 15, slides)


def day08_seg3():
    slides = ""
    slides += slide('''    <h2><code>for</code>-Generate: Hardware Replication</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module parallel_debounce #(
    parameter N_BUTTONS     = 4,
    parameter CLKS_TO_STABLE = 250_000
)(
    input  wire                   i_clk,
    input  wire [N_BUTTONS-1:0]   i_buttons,
    output wire [N_BUTTONS-1:0]   o_clean
);
<span class="fragment">
    genvar g;
    generate
        for (g = 0; g < N_BUTTONS; g = g + 1) begin : gen_debounce
            debounce #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) debounce_inst (
                .i_clk    (i_clk),
                .i_bouncy (i_buttons[g]),
                .o_clean  (o_clean[g])
            );
        end
    endgenerate</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <code>generate for</code> creates N identical instances at <strong>elaboration time</strong> — not a runtime loop. Change <code>N_BUTTONS</code> and the hardware scales automatically.
    </div>''',
    notes="Generate-for creates multiple hardware instances at compile time. This isn't a runtime loop — it's a macro that stamps out N copies of the debounce module. Change the parameter and the hardware scales.")

    slides += slide('''    <h2><code>if</code>-Generate: Conditional Hardware</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module uart_tx #(
    parameter INCLUDE_PARITY = 0
)(
    input wire i_clk, /* ... */
);
<span class="fragment">
    generate
        if (INCLUDE_PARITY) begin : gen_parity
            // Parity logic exists ONLY when parameter is set
            wire w_parity = ^i_data;  // XOR reduction
            // ... include parity bit in frame ...
        end else begin : gen_no_parity
            // No parity — simpler frame
        end
    endgenerate</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <code>if</code>-generate includes or excludes hardware based on parameters. Like <code>#ifdef</code> in C, but for hardware. Zero cost when disabled — the logic doesn't exist.
    </div>''',
    notes="If-generate conditionally includes hardware based on parameters. Like ifdef in C but for hardware. When disabled, the logic simply doesn't exist — zero gates, zero area, zero timing impact.")

    slides += slide('''    <h2>Generate vs. Runtime</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th></th><th>Generate (<code>generate for</code>)</th><th>Runtime (<code>for</code> in <code>always</code>)</th></tr></thead>
        <tbody>
            <tr><td>When</td><td>Elaboration (compile) time</td><td>Simulation / hardware execution</td></tr>
            <tr><td>Loop variable</td><td><code>genvar</code></td><td><code>integer</code></td></tr>
            <tr><td>Creates</td><td>Module instances, wires</td><td>Sequential operations</td></tr>
            <tr><td>Synthesizable?</td><td>Yes (stamps out hardware)</td><td>Only in <code>always</code> blocks</td></tr>
        </tbody>
    </table>
    <div class="fragment callout-warning" style="font-size:0.75em;">
        Don't confuse them. <code>generate for</code> makes <strong>parallel hardware</strong>. A <code>for</code> in <code>always</code> is loop <strong>unrolling</strong> — still synthesizable, but different concept.
    </div>''',
    notes="Critical distinction. Generate-for creates parallel hardware instances — genvar, module instantiation. A for loop inside always is sequential loop unrolling. Both are synthesizable but they're fundamentally different.")

    slides += takeaway_slide([
        "<code>generate for</code>: stamp out N copies of hardware. Uses <code>genvar</code>.",
        "<code>generate if</code>: conditionally include/exclude hardware. Zero cost when off.",
        "Always name generate blocks: <code>begin : gen_name</code>.",
        "Generate ≠ runtime loops. Generate = compile-time hardware replication.",
    ])

    slides += bridge_slide("Design for Reuse", 4, 6,
        "Your module library is growing. Let's make sure it stays clean.")

    return html_template("Day 8.3: Generate Blocks", "Generate Blocks",
        "Day 8 · Hierarchy, Parameters &amp; Generate", 3, 12, slides)


def day08_seg4():
    slides = ""
    slides += slide('''    <h2>Your Growing Module Library</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Module</th><th>Built</th><th>Parameterized?</th><th>Testbench?</th></tr></thead>
        <tbody>
            <tr><td><code>hex_to_7seg</code></td><td>Day 2</td><td>—</td><td>Day 6 ✓</td></tr>
            <tr><td><code>debounce</code></td><td>Day 5</td><td>✓ CLKS_TO_STABLE</td><td>Day 6 ✓</td></tr>
            <tr><td><code>counter_mod_n</code></td><td>Day 5</td><td>✓ N</td><td>Day 6 ✓</td></tr>
            <tr><td><code>edge_detector</code></td><td>Day 5</td><td>—</td><td>Day 6 ✓</td></tr>
            <tr><td><code>synchronizer</code></td><td>Day 5</td><td>—</td><td>✓</td></tr>
            <tr><td><code>shift_reg_piso</code></td><td>Day 5</td><td>✓ WIDTH</td><td>Day 6 ✓</td></tr>
        </tbody>
    </table>
    <p class="fragment" style="font-size:0.8em;margin-top:0.5em;">These modules get reused in Week 3 for UART and SPI. <strong>Building a tested library now pays off later.</strong></p>''',
    notes="Look at what you've built: debounce, counters, shift registers, decoders, edge detectors. All parameterized and tested. These become your building blocks for UART and SPI in Week 3.")

    slides += slide('''    <h2>Reuse Checklist</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Parameterized</strong> widths, thresholds, and timing values</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Self-checking testbench</strong> included</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>ANSI-style ports</strong> with <code>i_/o_/r_/w_</code> naming</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Documented</strong> — header comment with description, ports, parameters</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Active-high internal logic</strong> (handle active-low at boundaries)</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>No hardcoded magic numbers</strong> — use <code>parameter</code>/<code>localparam</code></p>
    </div>''',
    notes="The reuse checklist. Parameterized, tested, documented, clean naming, active-high internally, no magic numbers. Follow this and your modules work in any project.")

    slides += slide('''    <h2>Week 2 Complete — What You Can Build Now</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#FFC904;">★</span> Counter variations (mod-N, up/down, loadable)</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Shift registers (SIPO, PISO — UART building blocks)</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Synchronizers and debouncers for real-world inputs</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Self-checking testbenches with structured reporting</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Finite state machines using the 3-block template</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Parameterized, hierarchical designs with generate blocks</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:0.5em;">
        Week 3: Memory, Timing, and Serial Communication. You'll connect your Go Board to a PC.
    </div>''',
    notes="Week 2 complete. You can now build counter variations, shift registers, synchronizers, debouncers, self-checking testbenches, FSMs, and parameterized hierarchical designs. Next week: memory, timing, and serial communication. You'll talk to a PC.")

    slides += end_slide(8)

    return html_template("Day 8.4: Design for Reuse", "Design for Reuse",
        "Day 8 · Hierarchy, Parameters &amp; Generate", 4, 6, slides)


# =============================================================================
# QUIZ FILES
# =============================================================================

QUIZZES = {
    "day05": """# Day 5: Pre-Class Self-Check Quiz
## Counters, Shift Registers & Debouncing

**Q1:** What does `$clog2(N)` return and why is it useful for counter design?

<details><summary>Answer</summary>
`$clog2(N)` returns ceil(log₂(N)) — the number of bits needed to represent values 0 through N−1. It auto-sizes counter widths so that when you change the parameter N, the bit width adjusts automatically. No manual calculation needed.
</details>

**Q2:** What type of shift register is the core of a UART transmitter? A UART receiver?

<details><summary>Answer</summary>
UART TX: **PISO** (Parallel In, Serial Out) — load a byte, shift it out one bit at a time. UART RX: **SIPO** (Serial In, Parallel Out) — shift bits in one at a time, present the complete byte.
</details>

**Q3:** What causes metastability and what is the standard mitigation?

<details><summary>Answer</summary>
Metastability occurs when an asynchronous signal (not synchronized to the clock) violates setup/hold timing of a flip-flop. The standard mitigation is a **2-FF synchronizer**: two flip-flops in series. The first may go metastable but has a full clock period to resolve before the second samples it.
</details>

**Q4:** Why must you synchronize *before* debouncing, not the other way around?

<details><summary>Answer</summary>
The debounce counter uses flip-flops clocked by your system clock. If the input is asynchronous (not synchronized), those flip-flops can go metastable. Synchronize first to make the signal safe for all downstream clocked logic, then debounce the clean synchronized signal.
</details>
""",

    "day06": """# Day 6: Pre-Class Self-Check Quiz
## Testbenches & Simulation-Driven Development

**Q1:** Why are testbench inputs declared as `reg` and DUT outputs as `wire`?

<details><summary>Answer</summary>
In the testbench, **you** drive the DUT's inputs (assigning them in `initial`/`always` blocks), so they must be `reg`. DUT outputs are driven by the DUT itself (a module output), so they are `wire` — you observe them, you don't drive them.
</details>

**Q2:** Why should you use `!==` instead of `!=` in testbench comparisons?

<details><summary>Answer</summary>
`!==` (case inequality) properly handles `x` and `z` values. `x !== 0` is **true** (they definitely don't match). `x != 0` is **x** (unknown) — which means your if-statement doesn't trigger and the bug goes undetected. Always use `===`/`!==` in testbenches.
</details>

**Q3:** What is the purpose of the `$dumpfile` and `$dumpvars` system tasks?

<details><summary>Answer</summary>
`$dumpfile("name.vcd")` specifies the output waveform file name. `$dumpvars(0, tb_module)` records all signal changes at all hierarchy levels below the specified module. Together they generate the VCD file that GTKWave uses for waveform visualization.
</details>

**Q4:** Write a `task` that applies two 4-bit inputs to signals `a` and `b`, waits one clock cycle, and checks that `result` matches an expected value.

<details><summary>Answer</summary>

```verilog
task apply_and_check;
    input [3:0] in_a, in_b, expected;
    input [8*20-1:0] name;
begin
    a = in_a;
    b = in_b;
    @(posedge clk);
    @(posedge clk);
    if (result !== expected)
        $display("FAIL: %0s — expected %h, got %h", name, expected, result);
    else
        $display("PASS: %0s", name);
end
endtask
```
</details>
""",

    "day07": """# Day 7: Pre-Class Self-Check Quiz
## Finite State Machines

**Q1:** What are the three blocks in the 3-always-block FSM coding style, and what type of logic is each?

<details><summary>Answer</summary>
1. **State Register** — sequential (`always @(posedge clk)`) — just a flip-flop
2. **Next-State Logic** — combinational (`always @(*)`) — computes next state from current state + inputs
3. **Output Logic** — combinational (`always @(*)`) — computes outputs from current state (Moore) or state + inputs (Mealy)
</details>

**Q2:** What is the critical first line in the next-state logic block and why?

<details><summary>Answer</summary>
`r_next_state = r_state;` — This default assignment means "if no transition condition fires, stay in the current state." It prevents latch inference (every path assigns `r_next_state`) and handles the common case of remaining in the current state.
</details>

**Q3:** What is the difference between Moore and Mealy machines? Which do we default to?

<details><summary>Answer</summary>
**Moore**: outputs depend only on state — outputs are stable and change only on clock edges. **Mealy**: outputs depend on state AND current inputs — can react within the same clock cycle but may produce glitches. We default to **Moore** because it's safer and easier to debug.
</details>

**Q4:** Name three common FSM coding mistakes.

<details><summary>Answer</summary>
1. No default assignment in next-state logic → latch on `r_next_state`
2. Forgetting output defaults in Block 3 → latches on outputs
3. No `default` case → FSM gets stuck in illegal state
4. Using blocking `=` in the state register (Block 1) → should be `<=`
5. Putting logic in Block 1 instead of keeping it as a simple flip-flop
(Any three of these.)
</details>
""",

    "day08": """# Day 8: Pre-Class Self-Check Quiz
## Hierarchy, Parameters & Generate

**Q1:** What is the difference between `parameter` and `localparam`?

<details><summary>Answer</summary>
`parameter` can be overridden at module instantiation — used for configurable values like widths, thresholds, and timing. `localparam` cannot be overridden — used for internal/derived constants and state encodings.
</details>

**Q2:** Write the instantiation of a `counter` module with `WIDTH=16` and `MAX_COUNT=49999`.

<details><summary>Answer</summary>

```verilog
counter #(
    .WIDTH(16),
    .MAX_COUNT(49_999)
) my_counter (
    .i_clk    (i_clk),
    .i_reset  (i_reset),
    .i_enable (1'b1),
    .o_count  (w_count),
    .o_done   (w_done)
);
```
</details>

**Q3:** What is the difference between a `generate for` loop and a `for` loop inside an `always` block?

<details><summary>Answer</summary>
`generate for` runs at **elaboration (compile) time** and creates multiple hardware instances (parallel hardware). It uses `genvar` and can instantiate modules. A `for` inside `always` is **loop unrolling** — it describes sequential or combinational operations within a single block. Both are synthesizable but serve different purposes.
</details>

**Q4:** Name at least four things on the "reuse checklist" for a well-designed module.

<details><summary>Answer</summary>
1. Parameterized widths, thresholds, and timing values
2. Self-checking testbench included
3. ANSI-style ports with consistent naming (`i_/o_/r_/w_`)
4. Header comment documentation (description, ports, parameters)
5. Active-high internal logic (handle active-low at boundaries)
6. No hardcoded magic numbers — use `parameter`/`localparam`
(Any four of these.)
</details>
""",
}


# =============================================================================
# MAIN
# =============================================================================

def main():
    base = "/home/claude/hdl-course/lectures/week2"

    print("Generating Week 2 slide decks...\n")

    d5 = f"{base}/day05_counters_shift_registers_debouncing"
    write_file(f"{d5}/seg1_counter_variations.html", day05_seg1())
    write_file(f"{d5}/seg2_shift_registers.html", day05_seg2())
    write_file(f"{d5}/seg3_metastability_synchronizers.html", day05_seg3())
    write_file(f"{d5}/seg4_button_debouncing.html", day05_seg4())
    write_file(f"{d5}/quiz.md", QUIZZES["day05"])

    d6 = f"{base}/day06_testbenches_simulation_driven_development"
    write_file(f"{d6}/seg1_testbench_anatomy.html", day06_seg1())
    write_file(f"{d6}/seg2_self_checking_testbenches.html", day06_seg2())
    write_file(f"{d6}/seg3_tasks_for_organization.html", day06_seg3())
    write_file(f"{d6}/seg4_file_driven_testing.html", day06_seg4())
    write_file(f"{d6}/quiz.md", QUIZZES["day06"])

    d7 = f"{base}/day07_finite_state_machines"
    write_file(f"{d7}/seg1_fsm_theory_architecture.html", day07_seg1())
    write_file(f"{d7}/seg2_three_block_template.html", day07_seg2())
    write_file(f"{d7}/seg3_state_encoding.html", day07_seg3())
    write_file(f"{d7}/seg4_fsm_design_methodology.html", day07_seg4())
    write_file(f"{d7}/quiz.md", QUIZZES["day07"])

    d8 = f"{base}/day08_hierarchy_parameters_generate"
    write_file(f"{d8}/seg1_module_hierarchy.html", day08_seg1())
    write_file(f"{d8}/seg2_parameters_parameterization.html", day08_seg2())
    write_file(f"{d8}/seg3_generate_blocks.html", day08_seg3())
    write_file(f"{d8}/seg4_design_for_reuse.html", day08_seg4())
    write_file(f"{d8}/quiz.md", QUIZZES["day08"])

    print(f"\nDone! Generated 16 slide decks + 4 quizzes.")


if __name__ == "__main__":
    main()
