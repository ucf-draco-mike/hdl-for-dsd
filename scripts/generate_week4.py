#!/usr/bin/env python3
"""
Week 4 Slide Deck Generator
Accelerated HDL for Digital System Design — UCF ECE
Days 13-16: SystemVerilog for Design, SV for Verification, Project Build, Demos
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from generate_week1 import (html_template, slide, bridge_slide, end_slide,
                             takeaway_slide, write_file)

# =============================================================================
# DAY 13 — SystemVerilog for Design
# =============================================================================

def day13_seg1():
    s = ""
    s += slide('''    <h2>The Evolution</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>Verilog (IEEE 1364):</strong> Standardized 1995, major update 2001. What you've been writing.</p>
        <p class="fragment"><strong>SystemVerilog (IEEE 1800):</strong> Superset of Verilog. First standardized 2005, latest revision 2017.</p>
        <p class="fragment"><strong>Key point:</strong> Every legal Verilog file is legal SystemVerilog. You can mix them freely. Everything you've learned still works.</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:0.5em;">
        SystemVerilog doesn't replace Verilog — it adds safety features that catch bugs the compiler used to silently accept.
    </div>''',
    notes="SystemVerilog is a superset of Verilog. Everything you've written still works. SV adds design features like logic, intent-based always blocks, and enums, plus verification features like assertions and coverage. In industry, SV has largely replaced Verilog for new designs.")

    s += slide('''    <h2>Why Learn It Now?</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>Industry standard:</strong> SystemVerilog has largely replaced Verilog for new designs.</p>
        <p class="fragment"><strong>Safety:</strong> SV catches bugs that Verilog silently accepts — unintentional latches, wrong assignment types, type mismatches.</p>
        <p class="fragment"><strong>Readability:</strong> <code>enum</code> states, <code>logic</code> type, <code>always_ff</code>/<code>always_comb</code> make intent explicit.</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;margin-top:0.5em;">
        <strong>Today:</strong> Design features — making RTL safer and more readable.<br>
        <strong>Tomorrow:</strong> Verification features — making testbenches more powerful.
    </div>''',
    notes="In industry, SystemVerilog is the standard. The design features catch real bugs — especially unintentional latches, which become compile-time errors instead of silent synthesis warnings. Today is design features, tomorrow is verification.")

    s += slide('''    <h2>Toolchain Support</h2>
    <table style="font-size:0.65em;margin-top:0.5em;">
        <thead><tr><th>Tool</th><th>SV Support</th><th>Flag</th></tr></thead>
        <tbody>
            <tr><td>Icarus Verilog</td><td>Partial (<code>logic</code>, <code>always_ff/comb</code>, basic <code>enum</code>)</td><td><code>-g2012</code></td></tr>
            <tr><td>Verilator</td><td>Excellent (synthesis-oriented)</td><td>Default</td></tr>
            <tr><td>Yosys</td><td>Good (many design constructs)</td><td><code>read_verilog -sv</code></td></tr>
            <tr><td>Commercial</td><td>Full (Questa, VCS, Xcelium)</td><td>Default</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        We'll use <code>iverilog -g2012</code> for simulation and <code>yosys read_verilog -sv</code> for synthesis. Some advanced features will be demonstration-only.
    </div>''',
    notes="Icarus supports the core design features with the -g2012 flag. Yosys handles most SV synthesis constructs. For the full verification story tomorrow, we'll note where tool support ends and commercial tools begin.")

    s += takeaway_slide([
        "SystemVerilog is a <strong>superset</strong> of Verilog — all your code still works.",
        "SV catches bugs Verilog silently accepts (latches, wrong assignments).",
        "Industry standard for new designs. Learning it now is career-relevant.",
        "<code>iverilog -g2012</code> and <code>yosys read_verilog -sv</code> for our toolchain.",
    ])
    s += bridge_slide("<code>logic</code> — One Type to Rule Them All", 2, 10, "Replacing the confusing wire/reg distinction.")
    return html_template("Day 13.1: Why SystemVerilog?", "Why SystemVerilog?",
        "Day 13 · SystemVerilog for Design", 1, 8, s)


def day13_seg2():
    s = ""
    s += slide('''    <h2>The Problem With <code>wire</code> and <code>reg</code></h2>
    <pre class="synth"><code class="language-verilog">// Verilog: Must know the assignment context to choose the type
wire [7:0] w_data;      // driven by assign or module output
reg  [7:0] r_result;    // driven inside always block

// But r_result might be combinational (always @(*))
//   or sequential (always @(posedge clk))
// The name 'reg' tells you NOTHING about the hardware</code></pre>
    <div class="fragment callout-danger" style="font-size:0.8em;">
        <code>reg</code> does NOT mean register. It means "assigned in a procedural block." This confuses <em>everyone</em>. SystemVerilog fixes this.
    </div>''',
    notes="In Verilog, you choose wire or reg based on where the signal is assigned, not what hardware it represents. reg does NOT mean register — it means assigned in a procedural block. This confuses everyone, including experienced engineers. SystemVerilog fixes it.")

    s += slide('''    <h2>The <code>logic</code> Type</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// SystemVerilog: one type, any context
logic [7:0] data;       // assign, always_ff, always_comb — all work
logic [7:0] result;     // same type regardless of usage

<span class="fragment">// The HARDWARE is determined by the always block type:
always_ff @(posedge i_clk)  // → register
    result <= data;

always_comb                  // → combinational logic
    result = data + 1;</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>One restriction:</strong> <code>logic</code> can only have <strong>one driver</strong>. For multi-driver buses (rare in FPGA), use <code>wire</code>. For 99% of designs, <code>logic</code> is all you need.
    </div>''',
    notes="logic replaces both wire and reg. It can be driven by assign, always_ff, or always_comb. The hardware is determined by the always block type, not the variable type. One restriction: logic can only have one driver — which is actually a safety feature.")

    s += slide('''    <h2>Port Declarations</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// Verilog — must decide wire vs reg at the port
module my_mod (
    input  wire       i_clk,
    output reg  [7:0] o_result  // reg because assigned in always
);

<span class="fragment">// SystemVerilog — just use logic everywhere
module my_mod (
    input  logic       i_clk,
    output logic [7:0] o_result  // no wire/reg decision needed!
);</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        No more refactoring port types when you change how a signal is driven. <code>logic</code> works for all cases.
    </div>''',
    notes="In Verilog, you must decide wire or reg at the port declaration. Change how a signal is driven and you have to change the port type. With logic, the port type is always the same regardless of how it's assigned inside the module.")

    s += takeaway_slide([
        "<code>logic</code> replaces both <code>wire</code> and <code>reg</code> — use it everywhere.",
        "Hardware is determined by the <code>always</code> block type, not the variable type.",
        "Single-driver restriction is actually a <strong>safety feature</strong>.",
        "Ports: <code>input logic</code>, <code>output logic</code> — no more wire/reg decisions.",
    ])
    s += bridge_slide("Intent-Based Always Blocks", 3, 12, "Telling the compiler what hardware you want — and getting errors when you're wrong.")
    return html_template("Day 13.2: logic — One Type to Rule Them All", "logic Type",
        "Day 13 · SystemVerilog for Design", 2, 10, s)


def day13_seg3():
    s = ""
    s += slide('''    <h2><code>always_ff</code> — Sequential Logic</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>always_ff @(posedge i_clk) begin
    if (i_reset)
        r_count <= '0;          // '0 = all-zeros shorthand
    else
        r_count <= r_count + 1;
end</code></pre>
    <div style="font-size:0.75em;margin-top:0.5em;">
        <p class="fragment"><strong>Compiler enforces:</strong></p>
        <p class="fragment">✓ Must have a clock edge in the sensitivity list</p>
        <p class="fragment">✓ <span style="color:#C62828;">Error</span> if you use blocking assignment (<code>=</code>)</p>
        <p class="fragment">✓ <span style="color:#C62828;">Error</span> if signal is also driven by <code>assign</code> or another <code>always</code></p>
    </div>''',
    notes="always_ff declares intent: I want a flip-flop. The compiler checks: is there a clock edge? Are you using non-blocking assignments? Is this signal driven from only one place? If any check fails, you get a compile error instead of a silent bug.")

    s += slide('''    <h2><code>always_comb</code> — Combinational Logic</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>always_comb begin
    case (i_opcode)
        2'b00:   o_result = i_a + i_b;
        2'b01:   o_result = i_a - i_b;
        2'b10:   o_result = i_a &amp; i_b;
        default: o_result = i_a | i_b;
    endcase
end</code></pre>
    <div style="font-size:0.75em;margin-top:0.5em;">
        <p class="fragment"><strong>Compiler enforces:</strong></p>
        <p class="fragment">✓ No sensitivity list needed (automatic, stronger than <code>@(*)</code>)</p>
        <p class="fragment">✓ Must use blocking assignment (<code>=</code>)</p>
        <p class="fragment">✓ <span style="color:#C62828;">Error if a latch would be inferred</span> (incomplete assignments)</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.85em;">
        This is the biggest win. Unintentional latches become <strong>compile-time errors</strong>.
    </div>''',
    notes="always_comb is the biggest safety win. It tells the compiler: this must be purely combinational. If you forget a default assignment and a latch would be inferred, it's a compile-time error — not a synthesis warning you might miss. The entire category of unintentional latch bugs becomes impossible.")

    s += slide('''    <h2>Side-by-Side Comparison</h2>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:0.5em;">
    <pre class="sim" style="font-size:0.5em;"><code class="language-verilog">// ====== Verilog ======
reg [3:0] r_result;
reg       o_carry;

always @(*) begin
    r_result = 4'b0000;
    o_carry  = 1'b0;
    case (i_opcode)
      2'b00: {o_carry, r_result}
               = i_a + i_b;
      2'b01: {o_carry, r_result}
               = i_a - i_b;
      2'b10: r_result = i_a & i_b;
      2'b11: r_result = i_a | i_b;
    endcase
end
// Forgot defaults? Silent latch.</code></pre>
    <pre class="synth" style="font-size:0.5em;"><code class="language-verilog">// ====== SystemVerilog ======
logic [3:0] result;
logic       carry;

always_comb begin
    result = 4'b0000;
    carry  = 1'b0;
    case (i_opcode)
      2'b00: {carry, result}
               = i_a + i_b;
      2'b01: {carry, result}
               = i_a - i_b;
      2'b10: result = i_a & i_b;
      2'b11: result = i_a | i_b;
    endcase
end
// Forgot defaults? COMPILE ERROR.</code></pre>
    </div>''',
    notes="Side by side, the code looks almost identical. The difference is what happens when you make a mistake. In Verilog, a missing default silently infers a latch. In SystemVerilog with always_comb, it's a compile error. Same code, better safety net.")

    s += takeaway_slide([
        "<code>always_ff</code>: enforces clock edge, non-blocking, single driver.",
        "<code>always_comb</code>: auto-sensitivity, blocking, <strong>errors on latch inference</strong>.",
        "<code>always_latch</code>: documents intentional latches (rare).",
        "Same RTL, stronger compiler checking. Bugs found earlier.",
    ])
    s += bridge_slide("<code>enum</code>, <code>struct</code>, and <code>package</code>", 4, 15, "Type safety for FSMs, grouped signals, and shared definitions.")
    return html_template("Day 13.3: Intent-Based Always Blocks", "Intent-Based Always Blocks",
        "Day 13 · SystemVerilog for Design", 3, 12, s)


def day13_seg4():
    s = ""
    s += slide('''    <h2><code>enum</code> — Named States</h2>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:0.5em;">
    <pre class="sim" style="font-size:0.5em;"><code class="language-verilog">// Verilog FSM states
localparam S_IDLE  = 2'b00;
localparam S_START = 2'b01;
localparam S_DATA  = 2'b10;
localparam S_STOP  = 2'b11;
reg [1:0] r_state;</code></pre>
    <pre class="synth" style="font-size:0.5em;"><code class="language-verilog">// SystemVerilog FSM states
typedef enum logic [1:0] {
    S_IDLE  = 2'b00,
    S_START = 2'b01,
    S_DATA  = 2'b10,
    S_STOP  = 2'b11
} uart_state_t;
uart_state_t state;</code></pre>
    </div>
    <div style="font-size:0.75em;margin-top:0.5em;">
        <p class="fragment"><strong>Type safety:</strong> <code>state = 3;</code> → compile warning (3 isn't a <code>uart_state_t</code>)</p>
        <p class="fragment"><strong>Debug:</strong> <code>$display("State: %s", state.name());</code> prints <code>"State: S_IDLE"</code></p>
        <p class="fragment"><strong>Synthesis:</strong> Identical to <code>localparam</code> — zero hardware cost</p>
    </div>''',
    notes="enum gives you named, type-safe states. The compiler warns if you assign an invalid value. In simulation, state.name() prints the state name instead of a number. Zero hardware cost — synthesizes identically to localparam.")

    s += slide('''    <h2><code>struct</code> — Grouped Signals</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// Instead of many separate signals:
logic [7:0] tx_data;
logic       tx_valid, tx_busy, tx_done;

<span class="fragment">// Group them into a struct:
typedef struct packed {
    logic [7:0] data;
    logic       valid;
    logic       busy;
    logic       done;
} uart_tx_ctrl_t;

uart_tx_ctrl_t tx_ctrl;

// Access with dot notation:
tx_ctrl.data  = 8'h41;
tx_ctrl.valid = 1'b1;
if (tx_ctrl.busy) ...</span></code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <code>packed</code> = contiguous bit vector. <code>uart_tx_ctrl_t</code> is 11 bits wide (8+1+1+1). Fully synthesizable.
    </div>''',
    notes="Structs group related signals with named fields. The packed keyword makes it a contiguous bit vector — fully synthesizable. Use dot notation to access fields. Great for bus interfaces, configuration registers, and internal datapaths.")

    s += slide('''    <h2><code>package</code> — Shared Definitions</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// File: uart_pkg.sv
package uart_pkg;
    typedef enum logic [2:0] {
        S_IDLE, S_START, S_DATA, S_PARITY, S_STOP
    } uart_state_t;

    typedef struct packed {
        logic [7:0] data;
        logic       parity_error;
        logic       frame_error;
    } uart_rx_result_t;
endpackage

<span class="fragment">// File: uart_tx.sv
module uart_tx
    import uart_pkg::*;   // import all types
(
    input  logic i_clk, ...
);
    uart_state_t state;   // type from package
endmodule</span></code></pre>
    <div class="fragment callout-warning" style="font-size:0.7em;">
        <strong>Toolchain caveat:</strong> <code>package</code> requires full SV support. Icarus Verilog does NOT support it. Verilator and Yosys do. For this course, demonstrated but optional.
    </div>''',
    notes="Packages provide a single source of truth for shared types and constants. Change a state encoding in one place and all modules update. Clean alternative to include files. Icarus doesn't support packages, but Verilator and most commercial tools do.")

    s += takeaway_slide([
        "<code>enum</code>: type-safe FSM states. Zero hardware cost. <code>.name()</code> for debug.",
        "<code>struct packed</code>: grouped signals with dot notation. Fully synthesizable.",
        "<code>package</code>: shared types/constants across modules. Single source of truth.",
        "All three improve readability and catch bugs — no hardware overhead.",
    ])
    s += end_slide(13)
    return html_template("Day 13.4: enum, struct, and package", "enum, struct, package",
        "Day 13 · SystemVerilog for Design", 4, 15, s)


# =============================================================================
# DAY 14 — SystemVerilog for Verification
# =============================================================================

def day14_seg1():
    s = ""
    s += slide('''    <h2>What Are Assertions?</h2>
    <p style="font-size:0.85em;">An assertion is a statement that must <strong>always</strong> be true. If it's ever false during simulation, the simulator reports an error.</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Executable documentation:</strong> Design rules the simulator checks automatically</p>
        <p class="fragment"><strong>Always-on monitors:</strong> Unlike directed tests, assertions run continuously</p>
        <p class="fragment"><strong>Bug locators:</strong> Fire at the exact signal and time of the violation</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:0.5em;">
        Directed tests check specific moments. Assertions check <em>every</em> moment.
    </div>''',
    notes="Assertions are executable specifications. They describe rules that must always be true and the simulator checks them automatically, continuously, on every cycle. When a rule is violated, the assertion fires with the exact signal and time. Much more powerful than directed test checks.")

    s += slide('''    <h2>Immediate Assertions</h2>
    <pre class="sim"><code class="language-verilog" data-noescape>always_ff @(posedge i_clk) begin
    state <= next_state;

<span class="fragment">    // Assert: state should never be undefined
    assert (state !== 'x)
        else $error("State is undefined at time %0t", $time);</span>

<span class="fragment">    // Assert: don't accept data while busy
    assert (!(o_busy && i_valid))
        else $warning("Valid asserted while busy");</span>
end</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <strong>Severity levels:</strong> <code>$info</code> (note), <code>$warning</code> (potential issue), <code>$error</code> (definite bug), <code>$fatal</code> (stop simulation).
    </div>''',
    notes="Immediate assertions check a condition at a specific point in procedural code. If the condition is false, the else clause fires with the specified severity. Use $error for definite bugs, $warning for potential issues, $fatal to stop simulation immediately.")

    s += slide('''    <h2>Assertions in Design Modules</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module counter_mod_n #(parameter int N = 16) (
    input  logic                 i_clk, i_reset, i_enable,
    output logic [$clog2(N)-1:0] o_count
);
    always_ff @(posedge i_clk) begin
        if (i_reset) o_count <= '0;
        else if (i_enable)
            o_count <= (o_count == N-1) ? '0 : o_count + 1;
    end

<span class="fragment">    // Design assertion — runs every cycle, ignored by synthesis
    always_ff @(posedge i_clk)
        assert (o_count < N)
            else $fatal(1, "Counter exceeded max: %0d >= %0d",
                        o_count, N);</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        Assertions in RTL are ignored by synthesis but active during <em>every</em> simulation. Always-on bug detection.
    </div>''',
    notes="You can embed assertions directly in design RTL. Synthesis ignores them, but they're active during every simulation. This assertion fires immediately if a bug ever causes the counter to exceed its maximum. Compare that to manually inspecting waveforms.")

    s += takeaway_slide([
        "Assertions = executable specifications. Always on, every cycle.",
        "Immediate assertions: checked at a specific point in procedural code.",
        "Embed in RTL: ignored by synthesis, active in simulation.",
        "Severity: <code>$info</code> → <code>$warning</code> → <code>$error</code> → <code>$fatal</code>.",
    ])
    s += bridge_slide("Concurrent Assertions", 2, 12, "Checking multi-cycle protocol behavior — sequences and properties.")
    return html_template("Day 14.1: Assertions — Executable Specs", "Assertions",
        "Day 14 · SystemVerilog for Verification", 1, 15, s)


def day14_seg2():
    s = ""
    s += slide('''    <h2>Multi-Cycle Protocol Checks</h2>
    <p style="font-size:0.85em;">Immediate assertions check one moment. <strong>Concurrent assertions</strong> check sequences across multiple clock cycles — perfect for protocol verification.</p>
    <pre class="sim"><code class="language-verilog" data-noescape><span class="fragment">// After valid is asserted, busy must go high next cycle
property p_valid_then_busy;
    @(posedge i_clk) disable iff (i_reset)
    i_valid |=> o_busy;      // |=> = non-overlapping implication
endproperty

assert property (p_valid_then_busy)
    else $error("Busy not asserted after valid");</span></code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <code>|=></code> means "if the left side is true, then one cycle later the right side must be true." The assertion checks this on <em>every</em> clock edge.
    </div>''',
    notes="Concurrent assertions check sequences across clock cycles. The implication operator says: if the left side is true, then the right side must follow. This checks every clock edge, continuously, for the entire simulation.")

    s += slide('''    <h2>Common Sequence Operators</h2>
    <table style="font-size:0.65em;margin-top:0.5em;">
        <thead><tr><th>Operator</th><th>Meaning</th><th>Example</th></tr></thead>
        <tbody>
            <tr><td><code>##1</code></td><td>One cycle delay</td><td><code>a ##1 b</code> — a, then b next cycle</td></tr>
            <tr><td><code>##[1:3]</code></td><td>1-to-3 cycle delay</td><td><code>a ##[1:3] b</code> — b within 1-3 cycles</td></tr>
            <tr><td><code>|‑></code></td><td>Overlapping implication</td><td>if a, then b <em>same cycle</em></td></tr>
            <tr><td><code>|=></code></td><td>Non-overlapping</td><td>if a, then b <em>next cycle</em></td></tr>
            <tr><td><code>[*N]</code></td><td>Repetition</td><td><code>a[*3]</code> — a for 3 consecutive cycles</td></tr>
        </tbody>
    </table>''',
    notes="Key operators: hash-hash for cycle delays, implication arrows for if-then relationships, and repetition for consecutive cycles. These compose into powerful protocol checks.")

    s += slide('''    <h2>UART Protocol Assertions</h2>
    <pre class="sim"><code class="language-verilog" data-noescape>// TX line high when idle
property p_idle_high;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_IDLE) |-> (o_tx == 1'b1);
endproperty
<span class="fragment">
// Start bit is low
property p_start_low;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_START) |-> (o_tx == 1'b0);
endproperty</span>
<span class="fragment">
// After stop, return to idle
property p_stop_then_idle;
    @(posedge i_clk) disable iff (i_reset)
    (state == S_STOP && w_baud_tick) |=> (state == S_IDLE);
endproperty</span></code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        These assertions monitor protocol compliance on <strong>every clock cycle</strong> of <strong>every simulation</strong>. No waveform inspection needed.
    </div>''',
    notes="Four assertions that completely describe UART TX protocol compliance. Idle must be high, start must be low, stop must be high, and the FSM must return to idle after stop. These run continuously — any violation is caught instantly.")

    s += takeaway_slide([
        "Concurrent assertions check multi-cycle sequences — perfect for protocols.",
        "<code>|=></code> (non-overlapping): if A, then B next cycle.",
        "<code>disable iff (reset)</code>: don't check during reset.",
        "Write once, check every cycle of every simulation — always-on monitors.",
    ])
    s += bridge_slide("Functional Coverage", 3, 12, "Answering the question: have we tested enough?")
    return html_template("Day 14.2: Concurrent Assertions", "Concurrent Assertions",
        "Day 14 · SystemVerilog for Verification", 2, 12, s)


def day14_seg3():
    s = ""
    s += slide('''    <h2>The Question Coverage Answers</h2>
    <p style="font-size:0.85em;">Your testbench passes all its tests. But <strong>how do you know you've tested enough?</strong></p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment">Directed tests exercise <em>known</em> scenarios.</p>
        <p class="fragment">What about the scenarios you <em>forgot</em> to test?</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:0.5em;">
        Functional coverage measures what your testbench <em>actually exercised</em> — with data, not intuition.
    </div>''',
    notes="Your tests pass. Great. But how do you know you've tested enough? Directed tests check what you thought of. Coverage measures what was actually exercised — what input combinations, state transitions, and conditions were observed. It answers 'are we done testing?' with data.")

    s += slide('''    <h2><code>covergroup</code> and <code>coverpoint</code></h2>
    <pre class="sim"><code class="language-verilog" data-noescape>covergroup alu_coverage @(posedge clk);
<span class="fragment">    // Cover all opcodes
    cp_opcode: coverpoint i_opcode {
        bins add = {2'b00};  bins sub = {2'b01};
        bins and_op = {2'b10};  bins or_op = {2'b11};
    }</span>
<span class="fragment">
    // Cover interesting input ranges
    cp_a_value: coverpoint i_a {
        bins zero = {4'h0};   bins low  = {[4'h1:4'h7]};
        bins high = {[4'h8:4'hE]};  bins max  = {4'hF};
    }</span>
<span class="fragment">
    // Cross coverage: opcode × a_range × b_range
    cx_op_a_b: cross cp_opcode, cp_a_value, cp_b_value;
    // 4 × 4 × 4 = 64 bins</span>
endgroup</code></pre>''',
    notes="A covergroup defines what to measure. Coverpoints define the value categories. Bins group values into meaningful ranges. Cross coverage measures combinations. After simulation, the report shows which bins were hit and which were missed.")

    s += slide('''    <h2>Coverage-Driven Workflow</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>1. Define goals:</strong> What combinations matter?</p>
        <p class="fragment"><strong>2. Write initial tests:</strong> Directed tests for known scenarios</p>
        <p class="fragment"><strong>3. Run and check coverage:</strong> What's missing?</p>
        <p class="fragment"><strong>4. Add tests for gaps:</strong> Fill uncovered bins</p>
        <p class="fragment"><strong>5. Repeat until goal met</strong></p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        This is the <strong>industry-standard verification workflow</strong>. It answers "are we done?" with data, not guesswork.
    </div>
    <div class="fragment callout-warning" style="font-size:0.7em;">
        <strong>Toolchain note:</strong> <code>covergroup</code> requires commercial tools (Questa, VCS). For this course, we understand the concept and write the code — even if we can't run it in Icarus.
    </div>''',
    notes="The coverage-driven workflow: define goals, write tests, check coverage, fill gaps, repeat. This is how industry verification works. Icarus doesn't support covergroups, but understanding the concept is essential for anyone going into chip design or verification.")

    s += takeaway_slide([
        "Coverage answers: <em>have we tested enough?</em> — with data.",
        "<code>coverpoint</code>: which values were observed. <code>cross</code>: which combinations.",
        "Coverage-driven: define → test → measure → fill gaps → repeat.",
        "Industry-standard workflow. Concept transfers even without full tool support.",
    ])
    s += bridge_slide("Interfaces &amp; the Road to UVM", 4, 11, "Bundled connections, classes, and where verification goes next.")
    return html_template("Day 14.3: Functional Coverage", "Functional Coverage",
        "Day 14 · SystemVerilog for Verification", 3, 12, s)


def day14_seg4():
    s = ""
    s += slide('''    <h2><code>interface</code> — Bundled Connections</h2>
    <pre class="sim"><code class="language-verilog" data-noescape>interface uart_if (input logic clk);
    logic       tx, rx;
    logic [7:0] data;
    logic       valid, busy;

<span class="fragment">    modport tx_port (
        input  clk, data, valid,
        output tx, busy
    );
    modport tb (
        input  clk, tx, busy, data, valid,
        output rx
    );</span>
endinterface</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        One <code>interface</code> definition, multiple <code>modport</code> views. The module sees only its port direction. The testbench sees everything. No more 20-signal port lists.
    </div>''',
    notes="An interface bundles related signals and provides different views via modport. The TX module sees its ports, the testbench sees everything. One definition replaces long port lists and ensures consistency between modules.")

    s += slide('''    <h2>The Road to UVM</h2>
    <div style="font-size:0.75em;">
        <p class="fragment"><strong>Where you are:</strong> Directed testbenches, self-checking, tasks for organization.</p>
        <p class="fragment"><strong>Next level:</strong> SystemVerilog classes, object-oriented testbenches, randomization.</p>
        <p class="fragment"><strong>Industry standard:</strong> <strong>UVM</strong> (Universal Verification Methodology) — a class library + methodology for building reusable, scalable verification environments.</p>
    </div>
    <pre style="font-family:monospace;font-size:0.45em;text-align:center;background:none;border:none;box-shadow:none;color:#333;" class="fragment">
    ┌─────────────────────────────────────────────┐
    │              UVM Environment                 │
    │  ┌─────────┐  ┌──────────┐  ┌───────────┐  │
    │  │ Driver  │  │ Monitor  │  │Scoreboard │  │
    │  │(stimulus)│  │(observe) │  │ (check)   │  │
    │  └────┬────┘  └────┬─────┘  └─────┬─────┘  │
    │       ▼            ▼               ▲        │
    │  ┌──────────────────────────────────┘        │
    │  │     Interface (signal bundle)   │        │
    │  └──────────────────────────────────┘        │
    │       ▼            ▼                         │
    │  ┌─────────────────────────────┐             │
    │  │        DUT (your design)    │             │
    │  └─────────────────────────────┘             │
    └─────────────────────────────────────────────┘
    </pre>''',
    notes="UVM is the industry-standard verification methodology. Driver generates stimulus, monitor observes outputs, scoreboard checks correctness. All connected through interfaces. You don't need UVM for this course, but understanding where it fits is important for career planning.")

    s += slide('''    <h2>The Verification Maturity Scale</h2>
    <table style="font-size:0.65em;margin-top:0.3em;">
        <thead><tr><th>Level</th><th>Technique</th><th>Where You Are</th></tr></thead>
        <tbody>
            <tr><td>1</td><td>Visual waveform inspection</td><td>Week 1</td></tr>
            <tr><td>2</td><td>Self-checking testbenches</td><td>Week 2 ✓</td></tr>
            <tr><td>3</td><td>Assertions (immediate)</td><td>Today ✓</td></tr>
            <tr><td>4</td><td>Concurrent assertions + coverage</td><td>Today (conceptual)</td></tr>
            <tr><td>5</td><td>Constrained random + coverage-driven</td><td>Next course</td></tr>
            <tr><td>6</td><td>UVM environments</td><td>Industry / grad school</td></tr>
            <tr><td>7</td><td>Formal verification</td><td>Advanced / research</td></tr>
        </tbody>
    </table>
    <div class="fragment golden-rule" style="font-size:0.85em;margin-top:0.5em;">
        You're at Level 3 with awareness of Level 4. That's a strong foundation.
    </div>''',
    notes="The verification maturity scale puts your skills in context. You've gone from visual waveform inspection to self-checking testbenches to assertions in four weeks. You have awareness of coverage and UVM. That's a strong foundation for whatever comes next.")

    s += takeaway_slide([
        "<code>interface</code>: bundled signals with <code>modport</code> views. Eliminates long port lists.",
        "UVM: driver + monitor + scoreboard. Industry-standard methodology.",
        "You're at verification Level 3 with Level 4 awareness — strong foundation.",
        "Tomorrow: put it all together in your final project.",
    ])
    s += end_slide(14)
    return html_template("Day 14.4: Interfaces & the Road to UVM", "Interfaces &amp; Road to UVM",
        "Day 14 · SystemVerilog for Verification", 4, 11, s)


# =============================================================================
# QUIZZES
# =============================================================================

QUIZZES = {
    "day13": """# Day 13: Pre-Class Self-Check Quiz
## SystemVerilog for Design

**Q1:** What does the `logic` type replace? What is its one restriction?

<details><summary>Answer</summary>
`logic` replaces both `wire` and `reg`. It can be driven by `assign`, `always_ff`, or `always_comb`. Its one restriction: it can only have **one driver**. For multi-driver buses (rare in FPGA), use `wire`.
</details>

**Q2:** What happens if you accidentally create an incomplete `case` statement (missing a default) inside `always_comb`? How is this different from Verilog's `always @(*)`?

<details><summary>Answer</summary>
In `always_comb`, the compiler **errors** because a latch would be inferred — `always_comb` requires purely combinational logic. In Verilog's `always @(*)`, a latch is silently inferred with at most a synthesis warning that you might miss. This is the biggest safety win of SystemVerilog.
</details>

**Q3:** Rewrite this Verilog FSM state declaration using SystemVerilog `enum`:
```verilog
localparam S_IDLE = 2'b00, S_RUN = 2'b01, S_DONE = 2'b10;
reg [1:0] state;
```

<details><summary>Answer</summary>

```systemverilog
typedef enum logic [1:0] {
    S_IDLE = 2'b00,
    S_RUN  = 2'b01,
    S_DONE = 2'b10
} my_state_t;

my_state_t state;
```
Bonus: `$display("State: %s", state.name());` prints the state name.
</details>

**Q4:** What is a `packed struct` and why is it synthesizable?

<details><summary>Answer</summary>
A `packed struct` stores its fields as a contiguous bit vector. For example, a struct with an 8-bit data field, a valid bit, and a busy bit is 10 bits wide. Because it's a flat bit vector, synthesis tools can map it directly to wires and registers — no different from a `logic [9:0]` bus, but with named fields for readability.
</details>
""",

    "day14": """# Day 14: Pre-Class Self-Check Quiz
## SystemVerilog for Verification

**Q1:** What is the difference between an immediate assertion and a concurrent assertion?

<details><summary>Answer</summary>
**Immediate assertions** are checked at a specific point in procedural code (like an `if` check with standardized reporting). **Concurrent assertions** check sequences across multiple clock cycles using properties and implication operators. Immediate = one moment. Concurrent = multi-cycle behavior.
</details>

**Q2:** Write an immediate assertion that checks a counter value never exceeds 99.

<details><summary>Answer</summary>

```systemverilog
always_ff @(posedge clk)
    assert (count < 100)
        else $error("Counter exceeded 99: count = %0d at time %0t",
                    count, $time);
```
</details>

**Q3:** What does `|=>` mean in a concurrent assertion? Write a property that says "if `start` is high, then `busy` must be high on the next cycle."

<details><summary>Answer</summary>
`|=>` is the **non-overlapping implication** operator: "if the left side is true, then one cycle later the right side must be true."

```systemverilog
property p_start_then_busy;
    @(posedge clk) disable iff (reset)
    start |=> busy;
endproperty

assert property (p_start_then_busy)
    else $error("Busy not asserted after start");
```
</details>

**Q4:** What question does functional coverage answer? Name the three key constructs.

<details><summary>Answer</summary>
Functional coverage answers: **"Have we tested enough?"** — measuring what input combinations and conditions were actually exercised during simulation.

Key constructs: **`covergroup`** (defines what to measure), **`coverpoint`** (tracks specific signal values/ranges), and **`cross`** (measures combinations of coverpoints).
</details>
""",
}

# =============================================================================
# MAIN
# =============================================================================

def main():
    base = "/home/claude/hdl-course/lectures/week4"
    print("Generating Week 4 slide decks...\n")

    d = f"{base}/day13_systemverilog_for_design"
    write_file(f"{d}/seg1_why_systemverilog.html", day13_seg1())
    write_file(f"{d}/seg2_logic_type.html", day13_seg2())
    write_file(f"{d}/seg3_intent_based_always.html", day13_seg3())
    write_file(f"{d}/seg4_enum_struct_package.html", day13_seg4())
    write_file(f"{d}/quiz.md", QUIZZES["day13"])

    d = f"{base}/day14_systemverilog_for_verification"
    write_file(f"{d}/seg1_assertions.html", day14_seg1())
    write_file(f"{d}/seg2_concurrent_assertions.html", day14_seg2())
    write_file(f"{d}/seg3_functional_coverage.html", day14_seg3())
    write_file(f"{d}/seg4_interfaces_road_to_uvm.html", day14_seg4())
    write_file(f"{d}/quiz.md", QUIZZES["day14"])

    print(f"\nDone! Generated 8 slide decks + 2 quizzes.")

if __name__ == "__main__":
    main()
