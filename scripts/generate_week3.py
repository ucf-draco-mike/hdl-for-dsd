#!/usr/bin/env python3
"""
Week 3 Slide Deck Generator
Accelerated HDL for Digital System Design — UCF ECE
Days 9-12: Memory, Timing, UART TX, UART RX/SPI/IP Integration
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from generate_week1 import (html_template, slide, bridge_slide, end_slide,
                             takeaway_slide, write_file)

# =============================================================================
# DAY 9 — Memory: RAM, ROM, Block RAM
# =============================================================================

def day09_seg1():
    s = ""
    s += slide('''    <h2>What Is ROM in an FPGA?</h2>
    <p style="font-size:0.85em;">ROM = Read-Only Memory. Data is fixed at synthesis/programming time.</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Use cases:</strong> lookup tables, character maps, sine tables, instruction memory, configuration data</p>
        <p class="fragment"><strong>FPGA reality:</strong> No true ROM hardware. ROM is implemented as either LUTs (small) or initialized block RAM (large).</p>
    </div>''',
    notes="ROM in an FPGA isn't a separate chip — it's either LUT logic or initialized block RAM. Use it for lookup tables, character maps, instruction memory, and fixed data patterns.")

    s += slide('''    <h2>Approach 1: <code>case</code>-Based ROM</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module rom_case (
    input  wire [3:0] i_addr,
    output reg  [7:0] o_data
);
    always @(*) begin
        case (i_addr)
<span class="fragment">            4'h0: o_data = 8'h3E;
            4'h1: o_data = 8'h41;
            4'h2: o_data = 8'h49;
            // ... up to 15 entries
            default: o_data = 8'h00;</span>
        endcase
    end
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <strong>Pros:</strong> Readable, easy to edit. <strong>Cons:</strong> Doesn't scale — 256 entries = 256 case items.
    </div>''',
    notes="A case-based ROM is just a case statement. Works great for small lookup tables — the 7-segment decoder from Day 2 was exactly this pattern. But it doesn't scale beyond a few dozen entries.")

    s += slide('''    <h2>Approach 2: Array + <code>$readmemh</code></h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module rom_array #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "rom_data.hex"
)(
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output wire [DATA_WIDTH-1:0] o_data
);
<span class="fragment">    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemh(MEM_FILE, r_mem);  // load from hex file
    end</span>
<span class="fragment">
    assign o_data = r_mem[i_addr];  // asynchronous read</span>
endmodule</code></pre>
    <div class="fragment callout-warning" style="font-size:0.7em;">
        <strong>Async read → LUT-based.</strong> For block RAM inference, you need a synchronous (clocked) read. Next slide.
    </div>''',
    notes="The standard approach for larger ROMs: declare a memory array, initialize it from a hex file with readmemh. This asynchronous version maps to LUTs. For block RAM inference, you need a synchronous read.")

    s += slide('''    <h2>Synchronous ROM → Block RAM Inference</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module rom_sync #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "rom_data.hex"
)(
    input  wire                  i_clk,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output reg  [DATA_WIDTH-1:0] o_data
);
    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    initial $readmemh(MEM_FILE, r_mem);

<span class="fragment">    // Synchronous read — this is the key for block RAM inference
    always @(posedge i_clk)
        o_data <= r_mem[i_addr];</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        The <strong>one-cycle read latency</strong> is the price of block RAM. Apply address on cycle N, data available on cycle N+1.
    </div>''',
    notes="Add a clock to the read and the synthesizer can infer block RAM. The trade-off: one cycle of latency. Apply the address, and the data appears on the next clock edge. This is how all FPGA block RAM works.")

    s += takeaway_slide([
        "<code>case</code>-ROM for small tables. Array + <code>$readmemh</code> for larger ones.",
        "Async read → LUT-based. Sync read → <strong>block RAM inference</strong>.",
        "Block RAM has one-cycle read latency — address on cycle N, data on N+1.",
        "Parameterize width, depth, and data file for reuse.",
    ])
    s += bridge_slide("RAM in Verilog", 2, 12, "Writeable memory — single-port and dual-port patterns.")
    return html_template("Day 9.1: ROM in Verilog", "ROM in Verilog",
        "Day 9 · Memory: RAM, ROM &amp; Block RAM", 1, 12, s)


def day09_seg2():
    s = ""
    s += slide('''    <h2>Single-Port Synchronous RAM</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module ram_sp #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                  i_clk,
    input  wire                  i_write_en,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    input  wire [DATA_WIDTH-1:0] i_write_data,
    output reg  [DATA_WIDTH-1:0] o_read_data
);
    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

<span class="fragment">    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;
        o_read_data <= r_mem[i_addr];  // read-before-write
    end</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        One address port shared for reads and writes. <code>i_write_en</code> controls whether we write on this cycle. Read always happens (synchronous).
    </div>''',
    notes="Single-port RAM: one address shared for reads and writes. Write-enable controls writing. Read is always synchronous. This read-before-write style reads the old value during a write — maps cleanly to iCE40 block RAM.")

    s += slide('''    <h2>Read-After-Write Variations</h2>
    <pre class="synth"><code class="language-verilog">// Style A: Read-before-write (old data during write)
always @(posedge i_clk) begin
    if (i_write_en) r_mem[i_addr] <= i_write_data;
    o_read_data <= r_mem[i_addr];       // reads OLD value
end

// Style B: Write-first (new data during write)
always @(posedge i_clk) begin
    if (i_write_en) r_mem[i_addr] <= i_write_data;
    o_read_data <= (i_write_en) ? i_write_data : r_mem[i_addr];
end</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        For iCE40 EBR, read-before-write maps most naturally. Don't overthink this — just be aware it exists.
    </div>''',
    notes="Two read-after-write styles. Read-before-write returns the old value during a simultaneous write — maps cleanly to iCE40 block RAM. Write-first returns the new data using a bypass mux.")

    s += slide('''    <h2>Dual-Port RAM (Brief Introduction)</h2>
    <p style="font-size:0.8em;">Two independent ports — can read and write simultaneously at different addresses:</p>
    <pre class="synth"><code class="language-verilog">// Port A: write
always @(posedge i_clk)
    if (i_write_en_a)
        r_mem[i_addr_a] <= i_data_a;

// Port B: read (different address)
always @(posedge i_clk)
    o_data_b <= r_mem[i_addr_b];</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        iCE40 EBR natively supports true dual-port. Useful for FIFOs, video frame buffers, and CPU register files.
    </div>''',
    notes="Dual-port RAM has two independent ports — one for write, one for read, operating simultaneously at different addresses. iCE40 block RAM natively supports this. Essential for FIFOs and frame buffers.")

    s += takeaway_slide([
        "Single-port RAM: one address, <code>i_write_en</code> controls writes.",
        "Synchronous read + write → block RAM inference.",
        "Read-before-write maps cleanly to iCE40 EBR.",
        "Dual-port: two addresses, simultaneous read/write — FIFO building block.",
    ])
    s += bridge_slide("iCE40 Memory Resources", 3, 10, "What the HX1K gives you — and when Yosys uses it.")
    return html_template("Day 9.2: RAM in Verilog", "RAM in Verilog",
        "Day 9 · Memory: RAM, ROM &amp; Block RAM", 2, 12, s)


def day09_seg3():
    s = ""
    s += slide('''    <h2>What the iCE40 HX1K Gives You</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th>Resource</th><th>Quantity</th><th>Notes</th></tr></thead>
        <tbody>
            <tr><td>Logic Cells (LUTs)</td><td>1,280</td><td>4-input LUTs + flip-flops</td></tr>
            <tr><td>Embedded Block RAM (EBR)</td><td>16 blocks</td><td>4 Kbit each = <strong>64 Kbit total</strong></td></tr>
            <tr><td>EBR configs</td><td colspan="2">256×16, 512×8, 1024×4, 2048×2</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        64 Kbit = 8 KB total. Sounds small, but it's enough for: 8K bytes of instruction ROM, dual UART FIFOs, a small frame buffer, or a character ROM + video buffer.
    </div>''',
    notes="The HX1K has 16 blocks of 4 Kbit each — 64 Kbit or 8 KB total. Each block can be configured as 256 by 16, 512 by 8, 1024 by 4, or 2048 by 2. Enough for useful ROMs, FIFOs, and buffers.")

    s += slide('''    <h2>When Does Yosys Use EBR vs. LUTs?</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#2E7D32;">✓ EBR:</span> Synchronous read AND write, size ≥ ~64 bits, standard patterns</p>
        <p class="fragment"><span style="color:#E65100;">✗ LUTs:</span> Asynchronous read, very small memories, unusual access patterns</p>
    </div>
    <pre class="synth fragment"><code class="language-bash"># Check in Yosys synthesis output:
# "Mapping to bram type $__ICE40_RAM4K"  → EBR used ✓
# No bram mapping message               → LUT-based ✗</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Rule of thumb:</strong> If you want block RAM, use synchronous read. Check the Yosys output to confirm inference.
    </div>''',
    notes="Yosys uses EBR when it sees synchronous read and write patterns and the memory is large enough to be worth it. Check the synthesis output for the mapping message. If you don't see it, your memory is in LUTs.")

    s += takeaway_slide([
        "iCE40 HX1K: 16 EBR blocks × 4 Kbit = 64 Kbit (8 KB) total.",
        "Synchronous read → EBR. Asynchronous read → LUTs.",
        "Check Yosys output: look for <code>$__ICE40_RAM4K</code> mapping.",
        "8 KB is enough for instruction ROMs, FIFOs, character tables.",
    ])
    s += bridge_slide("Practical Memory Applications", 4, 11, "Pattern sequencers, sine tables, and character ROMs.")
    return html_template("Day 9.3: iCE40 Memory Resources", "iCE40 Memory Resources",
        "Day 9 · Memory: RAM, ROM &amp; Block RAM", 3, 10, s)


def day09_seg4():
    s = ""
    s += slide('''    <h2>Pattern Sequencer</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// LED pattern player — reads patterns from ROM
module pattern_sequencer #(
    parameter PATTERN_LEN = 16
)(
    input  wire       i_clk, i_reset,
    input  wire       i_tick,    // advance rate (from clock divider)
    output wire [3:0] o_leds
);
<span class="fragment">    reg [$clog2(PATTERN_LEN)-1:0] r_addr;
    reg [3:0] r_pattern [0:PATTERN_LEN-1];

    initial $readmemb("pattern.mem", r_pattern);</span>
<span class="fragment">
    always @(posedge i_clk) begin
        if (i_reset) r_addr <= 0;
        else if (i_tick)
            r_addr <= (r_addr == PATTERN_LEN-1) ? 0 : r_addr + 1;
    end

    assign o_leds = r_pattern[r_addr];</span>
endmodule</code></pre>''',
    notes="A pattern sequencer reads LED patterns from a ROM at a programmable rate. The ROM is loaded from a file. A counter steps through addresses on each tick. Simple but powerful — change the file to change the animation.")

    s += slide('''    <h2>More Applications</h2>
    <div style="font-size:0.8em;">
        <div class="fragment">
            <h3>Sine Wave Lookup Table</h3>
            <p>256-entry ROM with one quarter of a sine wave. Use address manipulation for all four quadrants. Feed to a DAC or PWM for audio.</p>
        </div>
        <div class="fragment">
            <h3>Character ROM</h3>
            <p>Store font bitmaps (e.g., 8×8 pixels per character). Address = {char_code, row}. Data = 8-bit pixel pattern. Essential for VGA text display.</p>
        </div>
        <div class="fragment">
            <h3>Instruction Memory</h3>
            <p>ROM holding a program for a simple processor. Address = program counter. Data = instruction word. (Final project option!)</p>
        </div>
    </div>''',
    notes="Beyond LED patterns: sine tables for audio, character ROMs for VGA text, instruction memory for simple processors. All use the same ROM pattern — just different data files and addressing.")

    s += takeaway_slide([
        "ROMs are lookup tables — change the data file, change the behavior.",
        "Counter + ROM = sequencer. Classic pattern for animations, waveforms.",
        "Character ROM: address = {char, row}, data = pixel pattern.",
        "<code>$readmemh</code>/<code>$readmemb</code> works in both simulation and synthesis.",
    ])
    s += end_slide(9)
    return html_template("Day 9.4: Practical Memory Applications", "Memory Applications",
        "Day 9 · Memory: RAM, ROM &amp; Block RAM", 4, 11, s)


# =============================================================================
# DAY 10 — Timing, Clocking & Constraints
# =============================================================================

def day10_seg1():
    s = ""
    s += slide('''    <h2>Why Timing Matters</h2>
    <p style="font-size:0.85em;">Every gate and wire has a <strong>propagation delay</strong>. Signals take time to travel through combinational logic between flip-flops.</p>
    <p class="fragment" style="font-size:0.85em;">If the signal arrives <strong>too late</strong>, the receiving flip-flop captures garbage.</p>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:1em;">
        Timing determines the maximum clock frequency of your design.
    </div>''',
    notes="Every gate and wire has propagation delay. If signals arrive at a flip-flop too late — after the setup time — the flip-flop captures garbage. Timing determines your maximum clock frequency.")

    s += slide('''    <h2>Setup and Hold Time</h2>
    <pre style="font-family:monospace;font-size:0.5em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
         ┌───┐       ┌───┐
clk  ────┘   └───────┘   └────
             ↑
         ←t_su→←t_h→
     data must  data must
     be stable  stay stable
     BEFORE     AFTER
    </pre>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Setup time (t_su):</strong> Data must be stable <em>before</em> the clock edge</p>
        <p class="fragment"><strong>Hold time (t_h):</strong> Data must stay stable <em>after</em> the clock edge</p>
        <p class="fragment"><strong>Violation:</strong> Metastability or incorrect capture. Design fails.</p>
    </div>''',
    notes="Setup time: data must be stable before the clock edge. Hold time: data must remain stable after. Violate either one and you get metastability or incorrect capture. This is why timing analysis exists.")

    s += slide('''    <h2>Critical Path and Slack</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>Critical path:</strong> The longest combinational delay between any two flip-flops. This limits your maximum clock frequency.</p>
        <p class="fragment"><strong>Slack:</strong> How much time margin you have.<br>
            <code>slack = clock_period − (propagation_delay + setup_time)</code></p>
        <p class="fragment"><span style="color:#2E7D32;">Positive slack ✓</span> = timing is met. Design works at this frequency.</p>
        <p class="fragment"><span style="color:#C62828;">Negative slack ✗</span> = timing violated. Design may fail unpredictably.</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>At 25 MHz:</strong> clock period = 40 ns. Plenty of room for simple iCE40 designs. Timing becomes critical at higher frequencies or with deep logic chains.
    </div>''',
    notes="Critical path is the longest delay between flip-flops. Slack is your timing margin. Positive slack means the design meets timing. Negative means it may fail. At 25 MHz with a 40 ns period, most simple designs have plenty of margin.")

    s += takeaway_slide([
        "Every gate/wire has delay. Signals must arrive before setup time.",
        "Critical path = longest delay = limits max frequency.",
        "Slack = clock_period − (delay + setup). Positive = good. Negative = broken.",
        "25 MHz (40 ns) gives plenty of margin for simple iCE40 designs.",
    ])
    s += bridge_slide("Timing Constraints &amp; Reports", 2, 12, "Telling the tools what clock you have — and reading the results.")
    return html_template("Day 10.1: The Physics of Timing", "The Physics of Timing",
        "Day 10 · Timing, Clocking &amp; Constraints", 1, 15, s)


def day10_seg2():
    s = ""
    s += slide('''    <h2>Adding Timing Constraints</h2>
    <pre class="synth"><code class="language-bash"># Tell nextpnr about your clock
nextpnr-ice40 --hx1k --package vq100 \\
    --pcf go_board.pcf \\
    --json top.json --asc top.asc \\
    --freq 25</code></pre>
    <div class="fragment" style="font-size:0.8em;">
        <p><code>--freq 25</code> tells nextpnr: "My clock is 25 MHz. Make sure all paths meet timing at this frequency."</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        Without <code>--freq</code>, nextpnr doesn't know your target frequency and cannot warn about timing violations.
    </div>''',
    notes="The --freq flag tells nextpnr your target clock frequency. Without it, the tool can't check timing. Always specify it. For the Go Board, --freq 25 for the 25 MHz crystal.")

    s += slide('''    <h2>Reading the Timing Report</h2>
    <pre class="synth"><code class="language-bash" data-noescape><span class="fragment">Info: Max frequency for clock 'i_clk': 48.23 MHz
#  ↑ Your design can run at up to 48 MHz
#    You asked for 25 MHz → PASS (plenty of margin)</span>

<span class="fragment">Info: Max frequency for clock 'i_clk': 22.10 MHz
#  ↑ Your design only supports 22 MHz
#    You asked for 25 MHz → FAIL! Timing violated.</span></code></pre>
    <div class="fragment callout-danger" style="font-size:0.75em;">
        <strong>If max frequency &lt; target frequency:</strong> Your design has a timing violation. It may work sometimes and fail randomly — the worst kind of bug.
    </div>''',
    notes="nextpnr reports the maximum frequency your design can achieve. If it's above your target, you're good. If it's below, you have a timing violation. These bugs are intermittent — the worst kind.")

    s += slide('''    <h2>What If Timing Fails?</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>1. Pipeline:</strong> Break long combinational chains into stages with registers between them. Adds latency, improves throughput.</p>
        <p class="fragment"><strong>2. Simplify logic:</strong> Reduce the depth of cascaded muxes, fewer levels of if/else.</p>
        <p class="fragment"><strong>3. Lower the clock:</strong> Sometimes the simplest fix. Use PLL to generate a slower clock.</p>
        <p class="fragment"><strong>4. Restructure:</strong> Move complex computation to a multi-cycle FSM instead of one giant combinational block.</p>
    </div>''',
    notes="Four fixes for timing failures: pipeline the logic, simplify the combinational depth, lower the clock frequency, or restructure into a multi-cycle FSM. Pipelining is the most common professional approach.")

    s += takeaway_slide([
        "<code>--freq 25</code> on nextpnr enables timing analysis.",
        "Max frequency > target → pass. Less than target → timing violation.",
        "Timing violations cause intermittent failures — the worst bug.",
        "Fix: pipeline, simplify, lower clock, or multi-cycle FSM.",
    ])
    s += bridge_slide("The iCE40 PLL", 3, 12, "Generating custom clock frequencies from the 25 MHz crystal.")
    return html_template("Day 10.2: Timing Constraints and Reports", "Timing Constraints &amp; Reports",
        "Day 10 · Timing, Clocking &amp; Constraints", 2, 12, s)


def day10_seg3():
    s = ""
    s += slide('''    <h2>What Is a PLL?</h2>
    <p style="font-size:0.85em;">A <strong>Phase-Locked Loop</strong> generates a new clock frequency from a reference clock. The iCE40 has a built-in PLL primitive.</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Input:</strong> 25 MHz crystal oscillator</p>
        <p class="fragment"><strong>Output:</strong> Nearly any frequency from ~16 MHz to ~275 MHz</p>
        <p class="fragment"><strong>Lock signal:</strong> Goes high when the PLL output is stable</p>
    </div>
    <pre class="synth fragment"><code class="language-bash"># Use icepll to calculate divider values
$ icepll -i 25 -o 50
# F_PLLIN: 25.000 MHz  F_PLLOUT: 50.000 MHz
# DIVR: 0  DIVF: 31  DIVQ: 4  FILTER_RANGE: 2</code></pre>''',
    notes="The PLL generates custom frequencies from the 25 MHz crystal. The icepll command-line tool calculates the divider values you need. Feed it input and output frequencies, and it gives you the parameters.")

    s += slide('''    <h2>PLL Instantiation</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>wire w_pll_clk, w_pll_locked;

SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
<span class="fragment">    .DIVR(4'b0000),         // from icepll
    .DIVF(7'b0011111),      // from icepll
    .DIVQ(3'b100),          // from icepll
    .FILTER_RANGE(3'b010)   // from icepll</span>
) pll_inst (
<span class="fragment">    .REFERENCECLK(i_clk),   // 25 MHz input
    .PLLOUTCORE(w_pll_clk), // generated clock
    .LOCK(w_pll_locked),    // stable indicator
    .RESETB(1'b1),          // active-low reset
    .BYPASS(1'b0)</span>
);</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        <strong>Always wait for <code>LOCK</code></strong> before using the PLL clock. Use <code>!w_pll_locked</code> as your reset condition.
    </div>''',
    notes="Instantiate the SB_PLL40_CORE primitive with the divider values from icepll. Always wait for the LOCK signal before using the PLL clock. Use not-locked as your reset.")

    s += takeaway_slide([
        "PLL generates custom frequencies from 25 MHz reference.",
        "Use <code>icepll -i 25 -o &lt;target&gt;</code> to get divider values.",
        "Instantiate <code>SB_PLL40_CORE</code> with those values.",
        "Always wait for <code>LOCK</code> — use <code>!locked</code> as reset.",
    ])
    s += bridge_slide("Clock Domain Crossing", 4, 11, "When signals move between different clocks — and how to handle it safely.")
    return html_template("Day 10.3: The iCE40 PLL", "The iCE40 PLL",
        "Day 10 · Timing, Clocking &amp; Constraints", 3, 12, s)


def day10_seg4():
    s = ""
    s += slide('''    <h2>The Clock Domain Crossing Problem</h2>
    <p style="font-size:0.85em;">Signals generated in one clock domain can violate setup/hold when sampled in another. This is <strong>exactly the metastability problem from Day 5</strong> — but between two clocks instead of async input vs. clock.</p>
    <div class="fragment callout-danger" style="font-size:0.8em;">
        <strong>Single-bit crossing:</strong> Use the 2-FF synchronizer — same as Day 5.<br>
        <strong>Multi-bit crossing:</strong> Much harder. Different bits can arrive at different times → corrupted values.
    </div>''',
    notes="Clock domain crossing is the metastability problem between two clocks. Single-bit: use a 2-FF synchronizer. Multi-bit is harder because different bits can arrive at different times, causing corrupted intermediate values.")

    s += slide('''    <h2>Multi-Bit CDC: Gray Code</h2>
    <pre class="synth"><code class="language-verilog">// Binary to Gray: only one bit changes per increment
assign gray = binary ^ (binary >> 1);

// Gray to Binary: reconstruct from MSB down
assign binary[N-1] = gray[N-1];
generate
    for (g = N-2; g >= 0; g = g - 1) begin : g2b
        assign binary[g] = binary[g+1] ^ gray[g];
    end
endgenerate</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Safe for counters/pointers:</strong> Gray code guarantees only one bit changes per increment, so the receiver sees either the old or new value — never a corrupted mix.
    </div>''',
    notes="Gray code guarantees only one bit changes per increment. Synchronize the Gray-coded value across clock domains, then convert back to binary. The receiver sees either the old value or the new value, never a corrupt mix. This is the foundation of dual-clock FIFOs.")

    s += slide('''    <h2>When To Worry About CDC</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#C62828;">✗</span> PLL clock domain ↔ raw 25 MHz domain</p>
        <p class="fragment"><span style="color:#C62828;">✗</span> Data from another chip with a different clock</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> External async inputs (already handled with synchronizers)</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> Single-clock designs have <strong>zero</strong> CDC problems</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:0.5em;">
        Rule: avoid unnecessary clock domains. One clock = zero CDC problems.
    </div>''',
    notes="The best CDC strategy is avoidance. One clock means zero CDC problems. Every additional clock multiplies verification complexity. Only add clock domains when you truly need different frequencies.")

    s += takeaway_slide([
        "CDC = metastability between two clock domains.",
        "Single-bit: 2-FF synchronizer. Multi-bit: Gray code.",
        "One clock = zero CDC problems. Avoid unnecessary domains.",
        "If you must cross: Gray-coded counters or async FIFOs.",
    ])
    s += end_slide(10)
    return html_template("Day 10.4: Clock Domain Crossing", "Clock Domain Crossing",
        "Day 10 · Timing, Clocking &amp; Constraints", 4, 11, s)


# =============================================================================
# DAY 11 — UART Transmitter
# =============================================================================

def day11_seg1():
    s = ""
    s += slide('''    <h2>What Is UART?</h2>
    <p style="font-size:0.85em;"><strong>Universal Asynchronous Receiver/Transmitter</strong> — the simplest serial protocol. Two wires: TX (transmit) and RX (receive). No shared clock.</p>
    <div class="fragment callout" style="font-size:0.8em;">
        UART is how your Go Board will talk to your PC. One wire out (TX), one wire in (RX). Both sides agree on the bit rate (baud rate) in advance.
    </div>''',
    notes="UART is the simplest serial protocol. Two wires, no shared clock. Both sides agree on the baud rate in advance. This is how your Go Board talks to your PC through the USB-to-serial chip.")

    s += slide('''    <h2>UART Frame Format</h2>
    <pre style="font-family:monospace;font-size:0.5em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
Idle ‾‾‾‾‾┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐‾‾‾‾
          └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   └───┘   │
          START  D0    D1    D2    D3    D4    D5    D6    D7    STOP
          (low)  (LSB)                                    (MSB)  (high)
    </pre>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Idle:</strong> Line held high</p>
        <p class="fragment"><strong>Start bit:</strong> Pull low for one bit period — signals start of frame</p>
        <p class="fragment"><strong>Data bits:</strong> 8 bits, LSB first</p>
        <p class="fragment"><strong>Stop bit:</strong> Return high for one bit period — signals end of frame</p>
    </div>''',
    notes="UART frame: idle is high, start bit pulls low, then 8 data bits LSB first, then stop bit goes high. Ten total bit periods for one byte. No parity in our configuration — 8N1.")

    s += slide('''    <h2>Baud Rate</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>Baud rate:</strong> bits per second. Standard rates: 9600, 115200, 230400, ...</p>
        <p class="fragment"><strong>We'll use 115200 baud.</strong> Each bit lasts 1/115200 ≈ 8.68 µs.</p>
        <p class="fragment"><strong>Clocks per bit:</strong> 25,000,000 / 115,200 = <strong>217 clock cycles</strong></p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        The UART TX module counts 217 clock cycles per bit. That's the baud rate generator — a counter you already know how to build.
    </div>''',
    notes="At 115200 baud, each bit lasts about 8.68 microseconds. With a 25 MHz clock, that's 217 clock cycles per bit. The baud rate generator is just a counter that ticks every 217 cycles. You already know how to build this.")

    s += takeaway_slide([
        "UART: 2 wires, no shared clock. Both sides agree on baud rate.",
        "Frame: idle (high) → start (low) → 8 data bits (LSB first) → stop (high).",
        "115200 baud: 217 clock cycles per bit at 25 MHz.",
        "The baud rate generator is just a modulo-N counter.",
    ])
    s += bridge_slide("UART TX Architecture", 2, 15, "Decomposing the transmitter into FSM + datapath.")
    return html_template("Day 11.1: The UART Protocol", "The UART Protocol",
        "Day 11 · UART Transmitter", 1, 15, s)


def day11_seg2():
    s = ""
    s += slide('''    <h2>Decomposition: FSM + Datapath</h2>
    <pre style="font-family:monospace;font-size:0.5em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
  ┌─────────────────────────────────────────────┐
  │            UART TX Module                    │
  │                                              │
  │  i_valid ──►┌──────────┐                     │
  │  i_data ───►│   FSM    │──► baud_en          │
  │             │ (control)│──► shift_en          │
  │             │          │──► load_en           │
  │  o_busy ◄──│          │                     │
  │             └──────────┘                     │
  │                  │                           │
  │                  ▼                           │
  │             ┌──────────┐                     │
  │             │ Shift Reg│──► o_tx             │
  │             │ (PISO)   │                     │
  │             └──────────┘                     │
  │             ┌──────────┐                     │
  │             │Baud Cntr │──► baud_tick        │
  │             └──────────┘                     │
  └─────────────────────────────────────────────┘
    </pre>
    <p class="fragment" style="font-size:0.75em;text-align:center;">Three parts you already know: FSM (Day 7) + PISO shift register (Day 5) + modulo-N counter (Day 5).</p>''',
    notes="The UART TX decomposes into three parts you already know how to build. An FSM for control, a PISO shift register for the data, and a modulo-N counter for the baud rate. This is where everything comes together.")

    s += slide('''    <h2>FSM States</h2>
    <pre style="font-family:monospace;font-size:0.55em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
    ┌──────┐  i_valid   ┌───────┐  baud_tick   ┌──────┐
    │ IDLE │───────────►│ START │──────────────►│ DATA │
    │      │            │       │               │      │
    └──────┘            └───────┘               └──┬───┘
       ▲                                           │
       │              ┌──────┐   baud_tick         │ 8 bits sent
       └──────────────│ STOP │◄────────────────────┘
                      │      │
                      └──────┘
    </pre>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>IDLE:</strong> TX line high. Wait for <code>i_valid</code>.</p>
        <p class="fragment"><strong>START:</strong> TX line low for one bit period.</p>
        <p class="fragment"><strong>DATA:</strong> Shift out 8 bits, one per baud tick.</p>
        <p class="fragment"><strong>STOP:</strong> TX line high for one bit period. Return to IDLE.</p>
    </div>''',
    notes="Four states. IDLE waits for valid data. START drives the line low for one bit period. DATA shifts out 8 bits. STOP drives the line high. Then back to IDLE, ready for the next byte.")

    s += slide('''    <h2>Handshake Protocol</h2>
    <pre class="synth"><code class="language-verilog">// Producer side (top module):
if (!o_busy) begin
    i_valid <= 1'b1;   // assert valid when ready
    i_data  <= 8'h48;  // 'H'
end

// Inside UART TX:
// When i_valid seen in IDLE → latch data, go to START
// o_busy high during START/DATA/STOP</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Valid/busy handshake:</strong> Producer asserts <code>i_valid</code> for one cycle. TX latches data and asserts <code>o_busy</code> until the byte is fully sent. Producer must wait for <code>!o_busy</code> before sending next byte.
    </div>''',
    notes="The handshake: the producer asserts i_valid when it has data and the TX isn't busy. The TX latches the data, asserts busy, and sends the byte. The producer waits for not-busy before the next byte.")

    s += takeaway_slide([
        "UART TX = FSM + PISO shift register + baud counter.",
        "Four states: IDLE → START → DATA (×8) → STOP → IDLE.",
        "Valid/busy handshake between producer and TX module.",
        "Everything is a module you've already built. This is integration.",
    ])
    s += bridge_slide("Implementation Walk-Through", 3, 12, "The complete UART TX module — line by line.")
    return html_template("Day 11.2: UART TX Architecture", "UART TX Architecture",
        "Day 11 · UART Transmitter", 2, 15, s)


def day11_seg3():
    s = ""
    s += slide('''    <h2>UART TX — Complete Module (Part 1)</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk, i_reset,
    input  wire       i_valid,
    input  wire [7:0] i_data,
    output reg        o_tx,
    output wire       o_busy
);
<span class="fragment">    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 217
    localparam S_IDLE=2'd0, S_START=2'd1, S_DATA=2'd2, S_STOP=2'd3;

    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_baud_cnt;
    reg [7:0] r_shift;
    reg [2:0] r_bit_idx;</span></code></pre>''',
    notes="Module header with parameterized clock frequency and baud rate. localparam derives clocks-per-bit automatically. Four states, a baud counter, a shift register, and a bit index.")

    s += slide('''    <h2>UART TX — Complete Module (Part 2)</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state <= S_IDLE; o_tx <= 1'b1; // idle = high
        end else begin
            case (r_state)
<span class="fragment">                S_IDLE: begin
                    o_tx <= 1'b1;
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    if (i_valid) begin
                        r_shift <= i_data;   // latch data
                        r_state <= S_START;
                    end
                end</span>
<span class="fragment">                S_START: begin
                    o_tx <= 1'b0;            // start bit = low
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state <= S_DATA;
                    end
                end</span></code></pre>''',
    notes="IDLE: line high, wait for valid, latch data. START: drive line low for one full bit period. When the baud counter ticks, move to DATA state.")

    s += slide('''    <h2>UART TX — Complete Module (Part 3)</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">                S_DATA: begin
                    o_tx <= r_shift[0];      // LSB first
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_shift <= {1'b0, r_shift[7:1]};  // shift right
                        r_bit_idx <= r_bit_idx + 1;
                        if (r_bit_idx == 3'd7)
                            r_state <= S_STOP;
                    end
                end</span>
<span class="fragment">                S_STOP: begin
                    o_tx <= 1'b1;            // stop bit = high
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state <= S_IDLE;
                    end
                end</span>
            endcase
        end
    end
    assign o_busy = (r_state != S_IDLE);
endmodule</code></pre>''',
    notes="DATA: output the LSB of the shift register, shift right on each baud tick, count 8 bits. STOP: drive line high for one bit period, then return to IDLE. o_busy is high whenever we're not idle.")

    s += takeaway_slide([
        "Complete UART TX: ~50 lines of Verilog. FSM + shift register + counter.",
        "IDLE → latch data. START → line low. DATA → shift 8 bits. STOP → line high.",
        "<code>o_busy</code> protects against sending while transmitting.",
        "Parameterized: change CLK_FREQ or BAUD_RATE and it recalculates.",
    ])
    s += bridge_slide("Connecting to a PC", 4, 8, "Hardware setup, terminal emulators, and your first 'Hello World' moment.")
    return html_template("Day 11.3: Implementation Walk-Through", "UART TX Implementation",
        "Day 11 · UART Transmitter", 3, 12, s)


def day11_seg4():
    s = ""
    s += slide('''    <h2>Hardware Connection</h2>
    <div style="font-size:0.8em;">
        <p class="fragment">The Go Board has an <strong>FTDI USB-to-serial chip</strong> built in.</p>
        <p class="fragment">UART TX (pin 74) connects through FTDI to your PC's USB port.</p>
        <p class="fragment">Your PC sees it as a <strong>virtual serial port</strong> (COM port / /dev/ttyUSB0).</p>
    </div>
    <div class="fragment callout" style="font-size:0.8em;">
        No extra wires needed. Just the USB cable you're already using for programming.
    </div>''',
    notes="The Go Board has a built-in USB-to-serial chip. Pin 74 is UART TX. When you send data out that pin, it goes through FTDI to your PC as a virtual serial port. No extra hardware needed.")

    s += slide('''    <h2>Terminal Emulator Setup</h2>
    <table style="margin-top:0.5em;font-size:0.75em;">
        <thead><tr><th>Platform</th><th>Tool</th><th>Command / Setup</th></tr></thead>
        <tbody>
            <tr><td>Linux</td><td><code>screen</code></td><td><code>screen /dev/ttyUSB0 115200</code></td></tr>
            <tr><td>macOS</td><td><code>screen</code></td><td><code>screen /dev/cu.usbserial-* 115200</code></td></tr>
            <tr><td>Windows</td><td>PuTTY</td><td>COMx, 115200, 8N1</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;margin-top:0.5em;">
        <strong>Settings:</strong> 115200 baud, 8 data bits, No parity, 1 stop bit (<strong>8N1</strong>).<br>
        When your FPGA sends <code>8'h48</code>, the terminal shows <strong>H</strong>.
    </div>''',
    notes="Open a serial terminal at 115200 baud, 8N1. When your FPGA sends hex 48, the terminal shows capital H. This is the milestone — your hardware talks to your PC.")

    s += slide('''    <h2>The Milestone</h2>
    <div class="golden-rule" style="font-size:1.1em;margin-top:1em;">
        Your FPGA is talking to your computer.<br>
        You built the hardware. From gates.
    </div>
    <p class="fragment" style="font-size:0.8em;text-align:center;margin-top:1em;">
        This is what makes hardware design different from software.<br>
        You didn't call <code>printf</code>. You built the serial port.
    </p>''',
    notes="This is the milestone of the course. Your FPGA talks to your computer. You didn't call printf — you built the serial port from flip-flops and gates. This is what makes hardware design special.")

    s += takeaway_slide([
        "Go Board's FTDI chip provides USB-serial — no extra hardware.",
        "Terminal at 115200/8N1. Send <code>8'h48</code>, see <strong>H</strong>.",
        "You built the serial port from gates. That's hardware engineering.",
    ])
    s += end_slide(11)
    return html_template("Day 11.4: Connecting to a PC", "Connecting to a PC",
        "Day 11 · UART Transmitter", 4, 8, s)


# =============================================================================
# DAY 12 — UART RX, SPI & IP Integration
# =============================================================================

def day12_seg1():
    s = ""
    s += slide('''    <h2>Why RX Is Harder Than TX</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>TX:</strong> You control the clock. You decide when each bit starts.</p>
        <p class="fragment"><strong>RX:</strong> The <em>remote</em> transmitter controls timing. You must <strong>find</strong> where each bit is and <strong>sample at the center</strong>.</p>
    </div>
    <div class="fragment callout-warning" style="font-size:0.8em;margin-top:0.5em;">
        The RX signal is <strong>asynchronous</strong> — it needs a synchronizer (Day 5). Then we need to detect the start bit, align to bit boundaries, and sample each bit at its center.
    </div>''',
    notes="RX is harder because you don't control the timing. The remote transmitter decides when bits start. You must detect the start bit, find the center of each bit, and sample there. Plus the signal is asynchronous — needs a synchronizer.")

    s += slide('''    <h2>The Oversampling Solution</h2>
    <p style="font-size:0.85em;">Sample the RX line at <strong>16× the baud rate</strong>. This gives you 16 samples per bit period, letting you find the center accurately.</p>
    <pre style="font-family:monospace;font-size:0.5em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
  ←─── one bit period ───→
  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓        16 oversamples
  0 1 2 3 4 5 6 7 8 ...15
              ↑
          sample here (count 7-8)
          = center of bit
    </pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Oversampling rate:</strong> 16× is standard. At 115200 baud: oversample clock = 115200 × 16 = 1,843,200 Hz. Clocks per oversample = 25M / 1.8M ≈ <strong>13-14 cycles</strong>.
    </div>''',
    notes="16x oversampling is the standard approach. You get 16 samples per bit period. Sample at count 7 or 8 to hit the center. At 115200 baud, each oversample tick is about 13-14 clock cycles.")

    s += slide('''    <h2>Start-Bit Detection</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><strong>1.</strong> In IDLE, watch for a falling edge on the (synchronized) RX line.</p>
        <p class="fragment"><strong>2.</strong> Start the oversample counter. Count to 7 (half a bit).</p>
        <p class="fragment"><strong>3.</strong> Check RX again. If still low → valid start bit. If high → noise, abort.</p>
        <p class="fragment"><strong>4.</strong> Now you're aligned to the center. Count 16 oversamples per bit.</p>
        <p class="fragment"><strong>5.</strong> At each bit center, shift the RX value into the SIPO register.</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        The half-bit offset at the start is what aligns all subsequent samples to bit centers.
    </div>''',
    notes="Start-bit detection: wait for a falling edge, count half a bit period to reach the center, verify it's still low. Now you're aligned. Count 16 oversamples for each subsequent bit and sample at the center.")

    s += takeaway_slide([
        "RX is harder: you must find bit boundaries from the incoming signal.",
        "16× oversampling: 16 samples per bit, sample at the center.",
        "Start-bit detection: falling edge → half-bit delay → verify → aligned.",
        "After alignment, count 16 per bit. SIPO shift register collects data.",
    ])
    s += bridge_slide("UART RX Implementation", 2, 15, "The complete receiver module with oversampling FSM.")
    return html_template("Day 12.1: UART RX — Oversampling", "UART RX — Oversampling",
        "Day 12 · UART RX, SPI &amp; IP Integration", 1, 15, s)


def day12_seg2():
    s = ""
    s += slide('''    <h2>UART RX Module Structure</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk, i_reset,
    input  wire       i_rx,          // serial input (async!)
    output reg  [7:0] o_data,        // received byte
    output reg        o_valid        // one-cycle pulse when ready
);
<span class="fragment">    localparam CLKS_PER_OS = CLK_FREQ / (BAUD_RATE * 16);  // ~13

    // Synchronizer (RX is async!)
    reg r_rx_sync_0, r_rx_sync;
    always @(posedge i_clk) begin
        r_rx_sync_0 <= i_rx;
        r_rx_sync   <= r_rx_sync_0;
    end</span></code></pre>
    <div class="fragment callout" style="font-size:0.7em;">
        Built-in 2-FF synchronizer — the RX pin is asynchronous to our clock. Everything downstream uses <code>r_rx_sync</code>.
    </div>''',
    notes="The RX module starts with a built-in 2-FF synchronizer because the RX pin is asynchronous. The oversample counter ticks at 16 times the baud rate. Everything downstream uses the synchronized signal.")

    s += slide('''    <h2>RX FSM States</h2>
    <pre style="font-family:monospace;font-size:0.55em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
    ┌──────┐ falling   ┌───────┐ mid-bit    ┌──────┐
    │ IDLE │──────────►│ START │───────────►│ DATA │
    │      │  edge     │verify │  confirmed │ ×8   │
    └──────┘           └───┬───┘            └──┬───┘
       ▲                   │ noise              │ 8 bits done
       │                   │ (abort)            ▼
       │                   ▼               ┌──────┐
       │              ┌──────┐             │ STOP │
       └──────────────│ back │◄────────────│verify│
                      │to idle│            └──────┘
    </pre>
    <div style="font-size:0.75em;margin-top:0.5em;">
        <p class="fragment"><strong>IDLE:</strong> Wait for falling edge (start bit)</p>
        <p class="fragment"><strong>START:</strong> Count to mid-bit (7 oversamples). Verify still low.</p>
        <p class="fragment"><strong>DATA:</strong> Count 16 oversamples per bit. Sample at center. 8 bits.</p>
        <p class="fragment"><strong>STOP:</strong> Verify stop bit is high. Assert <code>o_valid</code>.</p>
    </div>''',
    notes="Four states. IDLE waits for a falling edge. START counts to mid-bit and verifies it's a real start bit. DATA collects 8 bits at the center of each bit period. STOP verifies the stop bit and pulses o_valid.")

    s += slide('''    <h2>The Loopback Test</h2>
    <pre class="synth"><code class="language-verilog">// Loopback: RX → TX (echo everything back)
uart_rx #(.CLK_FREQ(25_000_000)) rx_inst (
    .i_clk(i_clk), .i_reset(i_reset),
    .i_rx(i_uart_rx),
    .o_data(w_rx_data), .o_valid(w_rx_valid)
);

uart_tx #(.CLK_FREQ(25_000_000)) tx_inst (
    .i_clk(i_clk), .i_reset(i_reset),
    .i_valid(w_rx_valid), .i_data(w_rx_data),
    .o_tx(o_uart_tx), .o_busy()
);</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Loopback:</strong> Type in the terminal → RX receives → TX echoes back → you see what you typed. If it works, both RX and TX are correct.
    </div>''',
    notes="The loopback test: connect RX output to TX input. Type a character in the terminal, the FPGA receives it and echoes it back. If you see what you typed, both modules work correctly. This is your hardware verification.")

    s += takeaway_slide([
        "RX FSM: IDLE → START (verify) → DATA (8 bits) → STOP (valid pulse).",
        "Built-in synchronizer — RX is always asynchronous.",
        "Loopback test: RX → TX echo. Type and see your character returned.",
        "If loopback works, both RX and TX are verified on real hardware.",
    ])
    s += bridge_slide("SPI Protocol", 3, 12, "The other serial protocol — with a shared clock and chip select.")
    return html_template("Day 12.2: UART RX Implementation", "UART RX Implementation",
        "Day 12 · UART RX, SPI &amp; IP Integration", 2, 15, s)


def day12_seg3():
    s = ""
    s += slide('''    <h2>What Is SPI?</h2>
    <p style="font-size:0.85em;"><strong>Serial Peripheral Interface</strong> — synchronous serial protocol with a shared clock. Faster and simpler than UART for chip-to-chip communication.</p>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Signal</th><th>Direction</th><th>Purpose</th></tr></thead>
        <tbody>
            <tr><td><code>SCLK</code></td><td>Master → Slave</td><td>Serial clock</td></tr>
            <tr><td><code>MOSI</code></td><td>Master → Slave</td><td>Master Out, Slave In (data)</td></tr>
            <tr><td><code>MISO</code></td><td>Slave → Master</td><td>Master In, Slave Out (data)</td></tr>
            <tr><td><code>CS_N</code></td><td>Master → Slave</td><td>Chip Select (active low)</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        SPI is <strong>synchronous</strong> — the master provides the clock. No baud rate negotiation, no oversampling, no start/stop bits. Simpler protocol, faster data rates.
    </div>''',
    notes="SPI has four signals: clock, data out, data in, and chip select. The master provides the clock — so there's no baud rate problem, no oversampling, no start/stop bits. Simpler and faster than UART.")

    s += slide('''    <h2>CPOL/CPHA and SPI Transaction</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Mode</th><th>CPOL</th><th>CPHA</th><th>Idle Clock</th><th>Sample Edge</th></tr></thead>
        <tbody>
            <tr><td>0</td><td>0</td><td>0</td><td>Low</td><td>Rising</td></tr>
            <tr><td>1</td><td>0</td><td>1</td><td>Low</td><td>Falling</td></tr>
            <tr><td>2</td><td>1</td><td>0</td><td>High</td><td>Falling</td></tr>
            <tr><td>3</td><td>1</td><td>1</td><td>High</td><td>Rising</td></tr>
        </tbody>
    </table>
    <div class="fragment" style="font-size:0.8em;margin-top:0.5em;">
        <p><strong>SPI transaction:</strong> Assert CS_N low → clock out/in data → deassert CS_N.</p>
        <p>Data is shifted on one edge, sampled on the other — just like PISO/SIPO shift registers.</p>
    </div>
    <div class="fragment callout" style="font-size:0.75em;">
        SPI = two shift registers (master PISO + slave SIPO) connected by a clock. Everything you built in Week 2.
    </div>''',
    notes="Four SPI modes based on clock polarity and phase. A transaction is: assert chip select, clock data out and in simultaneously, deassert chip select. It's really just two shift registers connected by a clock — exactly what you built in Week 2.")

    s += takeaway_slide([
        "SPI: 4 wires (SCLK, MOSI, MISO, CS_N). Master provides clock.",
        "Synchronous = no baud rate negotiation. Simpler than UART.",
        "Four modes (CPOL/CPHA) — check your device's datasheet.",
        "SPI = connected shift registers. Same building blocks as UART.",
    ])
    s += bridge_slide("IP Integration Philosophy", 4, 8, "Working with third-party modules — wrapping, adapting, trusting.")
    return html_template("Day 12.3: SPI Protocol", "SPI Protocol",
        "Day 12 · UART RX, SPI &amp; IP Integration", 3, 12, s)


def day12_seg4():
    s = ""
    s += slide('''    <h2>Working With Third-Party IP</h2>
    <p style="font-size:0.85em;">Not every module needs to be written from scratch. The skill is knowing when to <strong>build</strong> vs. when to <strong>integrate</strong>.</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Build yourself:</strong> When learning (this course!), when requirements are custom, when the module is small enough.</p>
        <p class="fragment"><strong>Integrate IP:</strong> Complex protocols (USB, Ethernet, PCIe), vendor primitives (PLL, SERDES), battle-tested open-source libraries.</p>
    </div>''',
    notes="Not everything needs to be built from scratch. Build when learning, when requirements are custom, or when it's small. Integrate when the protocol is complex or when battle-tested IP exists.")

    s += slide('''    <h2>Integration Checklist</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Read the documentation</strong> — understand the interface contract</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Write a wrapper</strong> — adapt their interface to your naming/handshake conventions</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Add synchronizers</strong> — on any external async inputs</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Write a testbench</strong> — verify the IP works as documented</p>
        <p class="fragment"><span style="color:#2E7D32;">✓</span> <strong>Verify resource usage</strong> — check it fits on your FPGA</p>
    </div>''',
    notes="Integration checklist: read the docs, write a wrapper module to adapt the interface, add synchronizers for async signals, write a testbench to verify behavior, and check that it fits in your resource budget.")

    s += slide('''    <h2>Week 3 Complete — What You Can Build Now</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span style="color:#FFC904;">★</span> ROM and RAM with block RAM inference</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Timing analysis, PLL clock generation, CDC</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Complete UART TX — send data to a PC</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> Complete UART RX — receive data from a PC</p>
        <p class="fragment"><span style="color:#FFC904;">★</span> SPI protocol understanding and IP integration</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:0.5em;">
        Week 4: SystemVerilog primer + final project. You're ready.
    </div>''',
    notes="Week 3 complete. You can build memory systems, manage timing, use PLLs, and communicate with a PC over UART. You understand SPI and IP integration. Next week: SystemVerilog and your final project.")

    s += end_slide(12)
    return html_template("Day 12.4: IP Integration Philosophy", "IP Integration Philosophy",
        "Day 12 · UART RX, SPI &amp; IP Integration", 4, 8, s)


# =============================================================================
# QUIZZES
# =============================================================================

QUIZZES = {
    "day09": """# Day 9: Pre-Class Self-Check Quiz
## Memory: RAM, ROM & Block RAM

**Q1:** What is the key difference between an asynchronous ROM read and a synchronous ROM read? Which one can infer block RAM?

<details><summary>Answer</summary>
Asynchronous read uses `assign o_data = r_mem[i_addr];` (combinational). Synchronous read uses `always @(posedge i_clk) o_data <= r_mem[i_addr];` (clocked). Only **synchronous read** can infer block RAM. The trade-off is one cycle of read latency.
</details>

**Q2:** How much block RAM does the iCE40 HX1K have?

<details><summary>Answer</summary>
16 Embedded Block RAM (EBR) blocks × 4 Kbit each = **64 Kbit total** (8 KB). Each block can be configured as 256×16, 512×8, 1024×4, or 2048×2.
</details>

**Q3:** What system task loads a hex file into a memory array? Where does it work?

<details><summary>Answer</summary>
`$readmemh("filename.hex", r_mem)` loads hexadecimal data. `$readmemb` loads binary data. Both work in **simulation** (Icarus Verilog) and **synthesis** (Yosys uses the data for ROM/RAM initialization).
</details>

**Q4:** Write the always block for a single-port synchronous RAM with read-before-write behavior.

<details><summary>Answer</summary>

```verilog
always @(posedge i_clk) begin
    if (i_write_en)
        r_mem[i_addr] <= i_write_data;
    o_read_data <= r_mem[i_addr];  // reads old value during write
end
```
</details>
""",

    "day10": """# Day 10: Pre-Class Self-Check Quiz
## Timing, Clocking & Constraints

**Q1:** What is "slack" in timing analysis? What does negative slack mean?

<details><summary>Answer</summary>
Slack = clock_period − (propagation_delay + setup_time). **Positive slack** means the signal arrives with time to spare — timing is met. **Negative slack** means the signal arrives too late — timing violation. The design may work intermittently or fail unpredictably.
</details>

**Q2:** How do you enable timing analysis in nextpnr? What happens without it?

<details><summary>Answer</summary>
Add `--freq 25` (or your target MHz) to the nextpnr command. Without it, nextpnr doesn't know your target frequency and cannot warn about timing violations.
</details>

**Q3:** What tool calculates PLL divider values for the iCE40? What primitive do you instantiate?

<details><summary>Answer</summary>
`icepll -i 25 -o <target_freq>` calculates DIVR, DIVF, DIVQ, and FILTER_RANGE values. Instantiate the `SB_PLL40_CORE` primitive with those values.
</details>

**Q4:** What is the safest strategy for handling clock domain crossing?

<details><summary>Answer</summary>
**Avoid multiple clock domains whenever possible.** One clock = zero CDC problems. When crossing is unavoidable: single-bit signals use a 2-FF synchronizer; multi-bit values use Gray code encoding (for counters) or an asynchronous FIFO.
</details>
""",

    "day11": """# Day 11: Pre-Class Self-Check Quiz
## UART Transmitter

**Q1:** Draw/describe a UART frame for sending the byte 0x48 ('H') at 115200 baud, 8N1.

<details><summary>Answer</summary>
Idle (high) → Start bit (low, ~8.68µs) → D0=0 → D1=0 → D2=0 → D3=1 → D4=0 → D5=0 → D6=1 → D7=0 → Stop bit (high, ~8.68µs). 0x48 = 0100_1000 binary, sent LSB first = 0,0,0,1,0,0,1,0. Total: 10 bit periods ≈ 86.8µs.
</details>

**Q2:** How many clock cycles per bit at 25 MHz / 115200 baud?

<details><summary>Answer</summary>
25,000,000 / 115,200 = **~217 clock cycles** per bit.
</details>

**Q3:** What three building blocks does the UART TX decompose into?

<details><summary>Answer</summary>
1. **FSM** (control: IDLE → START → DATA → STOP)
2. **PISO shift register** (holds the byte, shifts out LSB first)
3. **Modulo-N counter** (baud rate generator, ticks every 217 cycles)
</details>

**Q4:** What is the valid/busy handshake protocol?

<details><summary>Answer</summary>
Producer asserts `i_valid` for one cycle when it has data and `o_busy` is low. TX latches the data, asserts `o_busy`, and transmits the byte. Producer must wait for `!o_busy` before sending the next byte.
</details>
""",

    "day12": """# Day 12: Pre-Class Self-Check Quiz
## UART RX, SPI & IP Integration

**Q1:** Why is UART RX harder than TX? What technique solves the bit-alignment problem?

<details><summary>Answer</summary>
TX controls its own timing. RX must find bit boundaries from an incoming signal with no clock reference. **16× oversampling** solves this: sample 16 times per bit period, detect the start bit's falling edge, count half a bit to align to center, then sample each subsequent bit at its center.
</details>

**Q2:** How does start-bit detection work with 16× oversampling?

<details><summary>Answer</summary>
1. Wait for falling edge on synchronized RX. 2. Count 7 oversample ticks (half a bit period) to reach the center. 3. Check RX again — if still low, it's a valid start bit (not noise). 4. Now aligned to bit centers. Count 16 oversamples for each data bit.
</details>

**Q3:** What are the four SPI signals and their directions?

<details><summary>Answer</summary>
- **SCLK** (Master → Slave): Serial clock
- **MOSI** (Master → Slave): Master Out, Slave In (data to slave)
- **MISO** (Slave → Master): Master In, Slave Out (data from slave)
- **CS_N** (Master → Slave): Chip Select, active low
</details>

**Q4:** Name three items on the IP integration checklist.

<details><summary>Answer</summary>
1. Read the documentation — understand the interface contract
2. Write a wrapper module — adapt to your naming/handshake conventions
3. Add synchronizers on external async inputs
4. Write a testbench — verify the IP works as documented
5. Verify resource usage — check it fits on your FPGA
(Any three.)
</details>
""",
}

# =============================================================================
# MAIN
# =============================================================================

def main():
    base = "/home/claude/hdl-course/lectures/week3"
    print("Generating Week 3 slide decks...\n")

    d = f"{base}/day09_memory_ram_rom_block_ram"
    write_file(f"{d}/seg1_rom_in_verilog.html", day09_seg1())
    write_file(f"{d}/seg2_ram_in_verilog.html", day09_seg2())
    write_file(f"{d}/seg3_ice40_memory_resources.html", day09_seg3())
    write_file(f"{d}/seg4_memory_applications.html", day09_seg4())
    write_file(f"{d}/quiz.md", QUIZZES["day09"])

    d = f"{base}/day10_timing_clocking_constraints"
    write_file(f"{d}/seg1_physics_of_timing.html", day10_seg1())
    write_file(f"{d}/seg2_timing_constraints_reports.html", day10_seg2())
    write_file(f"{d}/seg3_ice40_pll.html", day10_seg3())
    write_file(f"{d}/seg4_clock_domain_crossing.html", day10_seg4())
    write_file(f"{d}/quiz.md", QUIZZES["day10"])

    d = f"{base}/day11_uart_transmitter"
    write_file(f"{d}/seg1_uart_protocol.html", day11_seg1())
    write_file(f"{d}/seg2_uart_tx_architecture.html", day11_seg2())
    write_file(f"{d}/seg3_uart_tx_implementation.html", day11_seg3())
    write_file(f"{d}/seg4_connecting_to_pc.html", day11_seg4())
    write_file(f"{d}/quiz.md", QUIZZES["day11"])

    d = f"{base}/day12_uart_rx_spi_ip_integration"
    write_file(f"{d}/seg1_uart_rx_oversampling.html", day12_seg1())
    write_file(f"{d}/seg2_uart_rx_implementation.html", day12_seg2())
    write_file(f"{d}/seg3_spi_protocol.html", day12_seg3())
    write_file(f"{d}/seg4_ip_integration.html", day12_seg4())
    write_file(f"{d}/quiz.md", QUIZZES["day12"])

    print(f"\nDone! Generated 16 slide decks + 4 quizzes.")

if __name__ == "__main__":
    main()
