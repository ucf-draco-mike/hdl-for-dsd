#!/usr/bin/env python3
"""
Week 1 Slide Deck Generator
Accelerated HDL for Digital System Design — UCF ECE

Generates reveal.js HTML slide decks for all Week 1 video segments.
Each day has 4 segments; each segment produces one self-contained HTML file.
"""

import os
import textwrap

# =============================================================================
# HTML TEMPLATE
# =============================================================================

def html_template(title, subtitle, day_label, video_num, duration, slides_html):
    """Wrap slide content in a complete reveal.js HTML document."""
    return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} — Accelerated HDL for Digital System Design</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/reveal.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/theme/white.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/vs2015.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../../theme/ucf-hdl.css">
    <style>
        .two-col {{ display: flex; gap: 2em; }}
        .two-col .col {{ flex: 1; }}
        .panel {{ padding: 1em; border-radius: 8px; }}
        .panel-sw {{ background: #F3E5F5; border: 2px solid #9C27B0; }}
        .panel-hw {{ background: #E3F2FD; border: 2px solid #1565C0; }}
        .panel-good {{ background: #E8F5E9; border: 2px solid #2E7D32; }}
        .panel-bad {{ background: #FFEBEE; border: 2px solid #C62828; }}
        .panel-neutral {{ background: #FFF8E1; border: 2px solid #F9A825; }}
        .check {{ color: #2E7D32; font-weight: 700; }}
        .cross {{ color: #C62828; font-weight: 700; }}
    </style>
</head>
<body>
<div class="reveal">
<div class="slides">

<!-- TITLE SLIDE -->
<section class="title-slide" data-background-color="#000000">
    <div style="margin-bottom:1em;">
        <span style="color:#FFC904;font-weight:700;font-size:0.6em;letter-spacing:0.15em;text-transform:uppercase;">
            {day_label}
        </span>
    </div>
    <h1 style="color:#FFC904;border-bottom:none;font-size:2.2em;">{subtitle}</h1>
    <p class="subtitle" style="color:#E8E8E4;">Video {video_num} of 4 · ~{duration} minutes</p>
    <p class="course-info" style="color:#888;">UCF · Department of ECE</p>
</section>

{slides_html}

</div></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/reveal.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/plugin/highlight/highlight.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/4.6.1/plugin/notes/notes.min.js"></script>
<script>
Reveal.initialize({{
    hash: true, slideNumber: 'c/t', showSlideNumber: 'all',
    width: 1280, height: 720, margin: 0.04,
    transition: 'slide', transitionSpeed: 'default', backgroundTransition: 'fade',
    plugins: [ RevealHighlight, RevealNotes ],
}});
</script>
</body>
</html>'''


def slide(content, notes="", bg="", extra_class=""):
    """Generate a single slide section."""
    bg_attr = f' data-background-color="{bg}"' if bg else ''
    cls = f' class="{extra_class}"' if extra_class else ''
    notes_html = f'\n    <aside class="notes">{notes}</aside>' if notes else ''
    return f'<section{bg_attr}{cls}>\n{content}{notes_html}\n</section>\n'


def bridge_slide(next_title, next_video_num, next_duration, teaser):
    """Generate a 'Up Next' transition slide."""
    return slide(f'''    <div style="text-align:center;">
        <p style="color:#FFC904;font-size:0.7em;font-weight:600;letter-spacing:0.1em;text-transform:uppercase;">Up Next</p>
        <h2 style="color:#FFFFFF;font-size:1.8em;">{next_title}</h2>
        <p style="color:#E8E8E4;font-size:0.8em;margin-top:0.5em;">Video {next_video_num} of 4 · ~{next_duration} minutes</p>
        <p style="color:#888;font-size:0.6em;margin-top:2em;">{teaser}</p>
    </div>''', bg="#000000")


def end_slide(day_num):
    """Generate the final 'prepare for class' slide."""
    return slide(f'''    <div style="text-align:center;">
        <p style="color:#FFC904;font-size:0.7em;font-weight:600;letter-spacing:0.1em;text-transform:uppercase;">Pre-Class Videos Complete</p>
        <h2 style="color:#FFFFFF;font-size:1.6em;">See You in Class!</h2>
        <p style="color:#E8E8E4;font-size:0.8em;margin-top:0.5em;">Day {day_num} · Hands-On Lab</p>
        <p style="color:#888;font-size:0.6em;margin-top:2em;">Make sure your toolchain is working and your Go Board is connected.</p>
    </div>''', bg="#000000")


def takeaway_slide(points):
    """Generate a numbered takeaway slide."""
    items = ""
    for i, pt in enumerate(points, 1):
        items += f'''        <p class="fragment" style="font-size:0.85em;">
            <span style="color:#FFC904;font-size:1.3em;font-weight:700;">{"①②③④⑤⑥"[i-1]}</span>&ensp;{pt}
        </p>\n'''
    return slide(f'    <h2>Key Takeaways</h2>\n    <div style="margin-top:0.5em;">\n{items}    </div>')


def code_slide(title, code, lang="verilog", notes="", code_class="synth", fragments=False):
    """Generate a slide with a code block."""
    if fragments:
        # Wrap each line in a fragment span
        lines = code.strip().split('\n')
        frag_code = '\n'.join(
            f'<span class="fragment">{line}</span>' for line in lines
        )
        code_block = f'<pre class="{code_class}"><code class="language-{lang}" data-noescape>{frag_code}</code></pre>'
    else:
        code_block = f'<pre class="{code_class}"><code class="language-{lang}">{code}</code></pre>'
    return slide(f'    <h2>{title}</h2>\n    {code_block}', notes=notes)


# =============================================================================
# DAY 1 — Segments 2, 3, 4 (Segment 1 already built manually)
# =============================================================================

def day01_seg2():
    """Synthesis vs. Simulation — already built in prototype, recreate here."""
    slides = ""

    slides += slide('''    <h2>One Source File, Two Consumers</h2>
    <div style="text-align:center;margin-top:1em;">
        <div style="display:inline-block;padding:0.5em 0.8em;border-radius:6px;font-weight:600;background:#FFF8E1;border:2px solid #F9A825;color:#E65100;">
            Your Verilog Source (<code>.v</code>)
        </div>
    </div>
    <div class="two-col" style="margin-top:1em;">
        <div class="panel panel-good fragment">
            <h3 style="color:#2E7D32;margin-top:0;">🔨 Synthesis (Yosys)</h3>
            <p style="font-size:0.7em;">Converts Verilog → netlist of FPGA primitives<br>(LUTs, flip-flops, I/O buffers, block RAM)</p>
            <p style="font-size:0.65em;color:#555;">Produces <strong>real, physical circuitry</strong></p>
        </div>
        <div class="panel" style="background:#E3F2FD;border:2px solid #1565C0;" >
            <h3 style="color:#1565C0;margin-top:0;" class="fragment">🔬 Simulation (Icarus Verilog)</h3>
            <p style="font-size:0.7em;" class="fragment">Models behavior computationally<br>Respects delays, display statements, testbenches</p>
            <p style="font-size:0.65em;color:#555;" class="fragment">Produces a <strong>prediction</strong> of hardware behavior</p>
        </div>
    </div>''',
    notes="The same Verilog source file gets consumed by two very different tools. Synthesis, Yosys in our case, converts it to real hardware primitives. Simulation, Icarus Verilog, models behavior computationally and produces waveforms.")

    slides += slide('''    <h2>What Synthesis Ignores</h2>
    <p style="font-size:0.8em;">These constructs are <strong>simulation-only</strong>:</p>
    <pre class="sim-only"><code class="language-verilog" data-noescape><span class="fragment">initial begin              // ← Can't "start up" hardware</span>
<span class="fragment">    #10;                   // ← Can't tell gates to "wait"</span>
<span class="fragment">    $display("x = %b", x); // ← No printf in silicon</span>
<span class="fragment">    $dumpfile("dump.vcd");  // ← Waveform dump is a sim concept</span>
<span class="fragment">    $finish;               // ← Hardware doesn't "finish"</span>
<span class="fragment">end</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Key insight:</strong> Testbenches are simulation artifacts. Design modules must avoid these constructs.
    </div>''',
    notes="This is critical. initial blocks, delay values, display statements, dumpfile, finish — all simulation-only. Synthesis ignores them completely. Your testbenches are full of these. Your synthesizable design must avoid them.")

    slides += slide('''    <h2>The Hidden Danger: Sim/Synth Mismatch</h2>
    <pre class="mistake"><code class="language-verilog">// In a DESIGN module (not testbench) — DON'T DO THIS
always @(a or b) begin
    y = a & b;
    #10;           // Synthesis IGNORES this
    z = a | b;
end</code></pre>
    <div class="two-col fragment" style="margin-top:0.5em;">
        <div class="panel" style="background:#E3F2FD;border-left:4px solid #1565C0;font-size:0.7em;">
            <strong>Simulation:</strong> y updates, waits 10 units, then z updates.
        </div>
        <div class="panel panel-good" style="font-size:0.7em;">
            <strong>Synthesis:</strong> #10 ignored. Both update simultaneously.
        </div>
    </div>
    <div class="fragment callout-danger" style="font-size:0.8em;">
        <strong>The simulation lies to you.</strong> It shows sequential behavior that won't exist in hardware.
    </div>''',
    notes="Here's the real danger. If you put a delay in a design module, simulation models the delay. But synthesis ignores it. Your simulation says one thing, your hardware does another. This is a simulation-synthesis mismatch.")

    slides += slide('''    <h2>The Workflow Golden Rule</h2>
    <div class="golden-rule" style="margin-top:1em;font-size:1.3em;padding:1.2em;">
        Simulate first. Synthesize second. Program last.
    </div>
    <div style="margin-top:1.5em;">
        <p class="fragment" style="font-size:0.8em;"><span class="cross">✗</span> You <strong>cannot</strong> set breakpoints on an FPGA.</p>
        <p class="fragment" style="font-size:0.8em;"><span class="cross">✗</span> You <strong>cannot</strong> print from inside the chip <span style="color:#888;">(until Week 3 — UART)</span></p>
        <p class="fragment" style="font-size:0.8em;"><span class="check">✓</span> Waveform simulation is your <strong>primary debugging tool</strong>.</p>
    </div>''',
    notes="This is the golden rule of this course. Simulate first, synthesize second, program last. You cannot set breakpoints on an FPGA. You cannot print from inside the chip until we build UART in Week 3. Waveform simulation is your primary debugging tool.")

    slides += slide('''    <h2>Our Complete Toolchain</h2>
    <div style="text-align:center;margin-top:0.5em;font-size:0.7em;">
        <p style="color:#2E7D32;font-weight:600;">Synthesis Path → Real Hardware</p>
        <p>Verilog <code>.v</code> → <strong>Yosys</strong> (synthesis) → <strong>nextpnr</strong> (place &amp; route) → <strong>icepack</strong> (bitstream) → <strong>iceprog</strong> (program)</p>
    </div>
    <div style="text-align:center;margin-top:1em;font-size:0.7em;">
        <p style="color:#1565C0;font-weight:600;">Simulation Path → Behavioral Prediction</p>
        <p>Verilog <code>.v</code> + <code>tb.v</code> → <strong>iverilog</strong> (compile) → <strong>vvp</strong> (simulate) → <strong>GTKWave</strong> (waveforms)</p>
    </div>
    <div class="fragment callout" style="font-size:0.7em;margin-top:0.8em;">
        <strong>All free, open-source tools.</strong> No expensive licenses. Everything runs on Linux, macOS, and Windows.
    </div>''',
    notes="Here's the complete toolchain. Synthesis path: Yosys, nextpnr, icepack, iceprog. Simulation path: iverilog, vvp, GTKWave. All free and open-source.")

    slides += takeaway_slide([
        "Synthesis → real hardware. Simulation → behavioral prediction.",
        "<code>initial</code>, <code>#delay</code>, <code>$display</code> are <strong>simulation-only</strong>.",
        "Sim/synth mismatches are real and dangerous.",
        "<strong>Simulate first. Synthesize second. Program last.</strong>",
    ])

    slides += bridge_slide("Anatomy of a Verilog Module", 3, 12,
        "Your first Verilog code — ports, assign, and naming conventions.")

    return html_template("Day 1.2: Synthesis vs. Simulation", "Synthesis vs. Simulation",
        "Day 1 · Welcome to Hardware Thinking", 2, 10, slides)


def day01_seg3():
    """Anatomy of a Verilog Module"""
    slides = ""

    slides += slide('''    <h2>The Module: Verilog's Building Block</h2>
    <p style="margin-top:0.5em;">Every Verilog design is composed of <strong>modules</strong>.</p>
    <div class="callout" style="margin-top:1em;font-size:0.85em;">
        Think of a module as a <strong>chip on a circuit board</strong> with labeled pins.
        You define what goes in, what comes out, and what happens inside.
    </div>''',
    notes="Every Verilog design is composed of modules. A module is a self-contained hardware block with defined inputs and outputs. Think of it as a chip on a circuit board with labeled pins.")

    slides += slide('''    <h2>Building a Module Step by Step</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment highlight-current-blue" data-fragment-index="1">module led_driver (</span>
<span class="fragment highlight-current-blue" data-fragment-index="2">    input  wire i_switch,</span>
<span class="fragment highlight-current-blue" data-fragment-index="3">    output wire o_led</span>
<span class="fragment highlight-current-blue" data-fragment-index="4">);</span>
<span class="fragment highlight-current-blue" data-fragment-index="5">
    assign o_led = i_switch;</span>
<span class="fragment highlight-current-blue" data-fragment-index="6">
endmodule</span></code></pre>
    <div style="font-size:0.7em;margin-top:0.5em;">
        <p class="fragment" data-fragment-index="1"><code>module led_driver</code> — keyword + name (<code>snake_case</code>)</p>
        <p class="fragment" data-fragment-index="2"><code>input wire i_switch</code> — input port with <code>i_</code> prefix</p>
        <p class="fragment" data-fragment-index="4"><code>);</code> — port list ends with <strong>semicolon</strong> (most common typo!)</p>
        <p class="fragment" data-fragment-index="5"><code>assign</code> — permanent wire, always active</p>
        <p class="fragment" data-fragment-index="6"><code>endmodule</code> — no semicolon after this</p>
    </div>''',
    notes="Let's build a module line by line. module keyword, then the name. Input port with wire type and i_ prefix. Output port with o_ prefix. Don't forget the semicolon after the closing parenthesis. assign creates a permanent connection. endmodule closes the definition, no semicolon.")

    slides += slide('''    <h2>What <code>assign</code> Really Means</h2>
    <pre class="synth"><code class="language-verilog">assign o_led = i_switch;</code></pre>
    <div class="two-col" style="margin-top:1em;">
        <div class="col fragment">
            <h3 style="color:#C62828;">NOT: one-time computation</h3>
            <p style="font-size:0.75em;">"Compute i_switch and store in o_led"</p>
        </div>
        <div class="col fragment">
            <h3 style="color:#2E7D32;">YES: permanent wire</h3>
            <p style="font-size:0.75em;">"Create a physical connection. When input changes, output changes instantly."</p>
        </div>
    </div>''',
    notes="assign does NOT mean compute and store. It means create a permanent physical wire. When the input changes, the output changes. The wire exists for the entire lifetime of the hardware.")

    slides += slide('''    <h2>Multiple Assigns = Parallel Hardware</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module button_logic (
    input  wire i_switch1, i_switch2,
    output wire o_led1, o_led2, o_led3
);
<span class="fragment">    assign o_led1 = i_switch1 & i_switch2;  // AND gate</span>
<span class="fragment">    assign o_led2 = i_switch1 | i_switch2;  // OR gate</span>
<span class="fragment">    assign o_led3 = i_switch1 ^ i_switch2;  // XOR gate</span>
endmodule</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        All three gates exist <strong>simultaneously</strong>. The order of these lines doesn't matter.
    </div>''',
    notes="Each assign creates a physical gate. Three gates exist simultaneously. The order you write these lines is irrelevant — the hardware is identical regardless.")

    slides += slide('''    <h2>Naming Conventions</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th>Prefix</th><th>Meaning</th><th>Examples</th></tr></thead>
        <tbody>
            <tr class="fragment"><td><code>i_</code></td><td>Input port</td><td><code>i_clk</code>, <code>i_reset</code>, <code>i_data</code></td></tr>
            <tr class="fragment"><td><code>o_</code></td><td>Output port</td><td><code>o_led</code>, <code>o_tx</code>, <code>o_valid</code></td></tr>
            <tr class="fragment"><td><code>r_</code></td><td>Register (sequential)</td><td><code>r_count</code>, <code>r_state</code></td></tr>
            <tr class="fragment"><td><code>w_</code></td><td>Wire (combinational)</td><td><code>w_sum</code>, <code>w_carry</code></td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        Not required by the language, but eliminates an entire class of bugs.
    </div>''',
    notes="We use consistent naming prefixes throughout this course. i_ for inputs, o_ for outputs, r_ for registers, w_ for wires. This tells you at a glance what every signal is.")

    slides += slide('''    <h2>The #1 Syntax Error</h2>
    <pre class="mistake"><code class="language-verilog" data-noescape>module my_module (
    input  wire a,
    output wire y
)                         // ← MISSING SEMICOLON!
    assign y = a;
endmodule</code></pre>
    <div class="fragment">
    <pre class="synth"><code class="language-verilog" data-noescape>module my_module (
    input  wire a,
    output wire y
);                        // ← CORRECT
    assign y = a;
endmodule</code></pre>
    </div>
    <p class="fragment" style="font-size:0.75em;color:#888;">You <em>will</em> make this mistake. Now you know what to look for.</p>''',
    notes="The number one syntax error: forgetting the semicolon after the closing parenthesis of the port list. The error message won't always point to the right line. You will make this mistake. Now you know what to look for.")

    slides += takeaway_slide([
        "Modules are the fundamental building block — inputs, outputs, behavior.",
        "<code>assign</code> = permanent wire, not a one-time computation.",
        "Use ANSI-style ports and consistent naming (<code>i_</code>, <code>o_</code>, <code>r_</code>, <code>w_</code>).",
        "Don't forget the semicolon after <code>);</code> in the port list.",
    ])

    slides += bridge_slide("Digital Logic Refresher", 4, 8,
        "Gates → Verilog. The concepts you already know, in a new language.")

    return html_template("Day 1.3: Anatomy of a Verilog Module", "Anatomy of a Verilog Module",
        "Day 1 · Welcome to Hardware Thinking", 3, 12, slides)


def day01_seg4():
    """Digital Logic Refresher"""
    slides = ""

    slides += slide('''    <h2>What You Must Have Cold</h2>
    <div style="font-size:0.85em;margin-top:0.5em;">
        <p class="fragment"><strong>Logic gates:</strong> AND, OR, NOT, NAND, NOR, XOR, XNOR</p>
        <p class="fragment"><strong>Boolean algebra:</strong> DeMorgan's, distribution, complement</p>
        <p class="fragment"><strong>Combinational vs. sequential:</strong><br>
            <span style="margin-left:1.5em;">Combinational = f(current inputs)</span><br>
            <span style="margin-left:1.5em;">Sequential = f(inputs, stored state)</span></p>
        <p class="fragment"><strong>Truth tables ↔ Boolean expressions:</strong> both directions</p>
        <p class="fragment"><strong>The D flip-flop:</strong> captures D on clock edge</p>
    </div>''',
    notes="Checklist of prerequisites. Logic gates and truth tables. Boolean algebra. Combinational vs sequential. Truth tables to expressions and back. And the D flip-flop.")

    slides += slide('''    <h2>Gates → Verilog: The Translation Table</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th>Digital Logic</th><th>Verilog</th></tr></thead>
        <tbody>
            <tr class="fragment"><td>Wire</td><td><code>assign y = a;</code></td></tr>
            <tr class="fragment"><td>AND gate</td><td><code>assign y = a & b;</code></td></tr>
            <tr class="fragment"><td>OR gate</td><td><code>assign y = a | b;</code></td></tr>
            <tr class="fragment"><td>NOT (inverter)</td><td><code>assign y = ~a;</code></td></tr>
            <tr class="fragment"><td>XOR gate</td><td><code>assign y = a ^ b;</code></td></tr>
            <tr class="fragment"><td>2:1 Multiplexer</td><td><code>assign y = sel ? a : b;</code></td></tr>
            <tr class="fragment"><td>D flip-flop</td><td><code>always @(posedge clk) q <= d;</code></td></tr>
        </tbody>
    </table>''',
    notes="The Rosetta Stone between digital logic and Verilog. Wire is assign. AND is ampersand. OR is pipe. NOT is tilde. XOR is caret. The mux uses the conditional operator. And the D flip-flop uses always at posedge with the nonblocking assignment.")

    slides += slide('''    <h2>Compound Expressions</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">// NAND: ~(a & b)    NOR: ~(a | b)</span>
<span class="fragment">
// Sum-of-products: y = AB + CD
assign y = (a & b) | (c & d);</span>
<span class="fragment">
// DeMorgan's: these produce IDENTICAL hardware
assign y1 = ~(a & b);
assign y2 = ~a | ~b;     // same gate!</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>The synthesizer optimizes.</strong> Write for readability — the tool reduces to minimum hardware.
    </div>''',
    notes="Compound expressions work like Boolean algebra. NAND, NOR, sum of products. DeMorgan's produces identical hardware. The synthesizer optimizes — write for readability.")

    slides += slide('''    <h2>Combinational vs. Sequential in Verilog</h2>
    <div class="two-col" style="margin-top:1em;">
        <div class="col">
            <h3 style="color:#1565C0;">Combinational</h3>
            <pre class="synth"><code class="language-verilog">// Output changes whenever
// inputs change
assign y = a & b;</code></pre>
            <p style="font-size:0.65em;">No clock. No memory. <strong>Weeks 1–2 focus.</strong></p>
        </div>
        <div class="col">
            <h3 style="color:#E65100;">Sequential</h3>
            <pre class="synth"><code class="language-verilog">// Output changes only on
// the clock edge
always @(posedge clk)
    q <= d;</code></pre>
            <p style="font-size:0.65em;">Clock-driven. Has memory. <strong>Introduced Day 4.</strong></p>
        </div>
    </div>''',
    notes="Preview of combinational versus sequential. Combinational: assign, no clock, no memory. That's our focus for the first few days. Sequential: always at posedge clk, clock-driven, has memory. Introduced on Day 4.")

    slides += slide('''    <h2>You Already Know the Hardware</h2>
    <p style="font-size:1.1em;text-align:center;margin-top:0.5em;">
        Gates ✓ &ensp; Boolean algebra ✓ &ensp; Truth tables ✓ &ensp; Flip-flops ✓
    </p>
    <div class="golden-rule" style="margin-top:1.5em;font-size:1.1em;">
        This course teaches you the <em>language</em> to describe it.
    </div>''',
    notes="You already know the hardware from your digital logic courses. This course teaches you the language to describe it in Verilog.")

    slides += slide('''    <h2>Pre-Class Self-Check</h2>
    <p style="font-size:0.75em;color:#888;">Before class, make sure you can answer:</p>
    <div style="font-size:0.8em;margin-top:0.5em;">
        <p class="fragment"><strong>Q1:</strong> Name three differences between software and Verilog.</p>
        <p class="fragment"><strong>Q2:</strong> What happens to <code>#10</code> during synthesis? During simulation?</p>
        <p class="fragment"><strong>Q3:</strong> Write a 2-input AND module from memory.</p>
    </div>
    <div class="fragment callout" style="font-size:0.7em;margin-top:1em;">
        If Q3 feels hard, re-watch Video 3. Getting the module template into muscle memory saves you time in lab.
    </div>''',
    notes="Self-check before class. Can you name three differences? What happens to hash-10 in synthesis? Can you write a module from memory? If not, re-watch the relevant video. See you in class!", bg="#FAFAFA")

    return html_template("Day 1.4: Digital Logic Refresher", "Digital Logic Refresher You Need",
        "Day 1 · Welcome to Hardware Thinking", 4, 8, slides)


# =============================================================================
# DAY 2 — Combinational Building Blocks
# =============================================================================

def day02_seg1():
    slides = ""
    slides += slide('''    <h2><code>wire</code> vs. <code>reg</code> — Misleading Names</h2>
    <div class="two-col" style="margin-top:0.5em;">
        <div class="col">
            <h3><code>wire</code></h3>
            <p style="font-size:0.75em;">Combinational connection. Must be <strong>continuously driven</strong> by <code>assign</code> or module output. Cannot hold a value.</p>
        </div>
        <div class="col">
            <h3><code>reg</code></h3>
            <p style="font-size:0.75em;">Can be assigned inside <code>always</code> blocks. <strong>Does NOT always mean register!</strong> Becomes a FF only with <code>posedge clk</code>.</p>
        </div>
    </div>
    <pre class="synth fragment"><code class="language-verilog">// This reg → flip-flop (clock edge)
reg [7:0] r_counter;
always @(posedge clk) r_counter <= r_counter + 1;

// This reg → combinational logic (no clock!)
reg [3:0] r_mux_out;
always @(*) r_mux_out = sel ? a : b;</code></pre>
    <div class="fragment callout" style="font-size:0.7em;">SystemVerilog fixes this confusion with <code>logic</code> — Week 4.</div>''',
    notes="Wire vs reg is the most confusing naming in Verilog. Wire is a combinational connection driven by assign. Reg can be assigned in always blocks, but does NOT always become a register. It becomes a flip-flop only with a clock edge. SystemVerilog fixes this with the logic type.")

    slides += slide('''    <h2>Vectors (Buses)</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">wire [7:0] w_data;     // 8-bit bus: bit 7 (MSB) to bit 0 (LSB)</span>
<span class="fragment">
w_data[7]              // single bit — the MSB
w_data[3:0]            // lower nibble — bits 3 down to 0
w_data[7:4]            // upper nibble</span></code></pre>
    <div class="fragment" style="margin-top:1em;">
        <h3>Concatenation &amp; Replication</h3>
        <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">wire [7:0] w_byte = {w_hi_nibble, w_lo_nibble};  // join: 4+4=8 bits</span>
<span class="fragment">wire [7:0] w_zeros = {8{1'b0}};                   // replicate: 8 copies of 0</span>
<span class="fragment">wire [7:0] w_sign_ext = {{4{w_data[3]}}, w_data[3:0]}; // sign extend 4→8</span></code></pre>
    </div>''',
    notes="Vectors are multi-bit signals. MSB on the left, LSB on the right. You can slice and index individual bits. Concatenation with curly braces joins signals together. Replication repeats a pattern. Sign extension uses nested replication.")

    slides += slide('''    <h2>The Rule: Always Use <code>[MSB:LSB]</code></h2>
    <pre class="synth"><code class="language-verilog">wire [7:0] w_data;    // ✓ MSB > LSB, LSB = 0</code></pre>
    <pre class="mistake"><code class="language-verilog">wire [0:7] w_data;    // ✗ Ascending — causes confusion</code></pre>
    <div class="callout" style="font-size:0.8em;margin-top:1em;">
        <strong>Convention:</strong> Always <code>[MSB:LSB]</code> with MSB > LSB and LSB = 0. You <em>can</em> use ascending, but don't.
    </div>''',
    notes="Convention: always use descending bit order, MSB colon LSB, with LSB equal to zero. You can use ascending order, but it causes confusion and we won't use it.")

    slides += takeaway_slide([
        "<code>wire</code> = driven by <code>assign</code>. <code>reg</code> = assigned in <code>always</code>.",
        "<code>reg</code> does NOT always mean register — it depends on context.",
        "Vectors: <code>[7:0]</code> is 8 bits. Slice with <code>[3:0]</code>. Join with <code>{a, b}</code>.",
        "Always use <code>[MSB:LSB]</code> with LSB = 0.",
    ])

    slides += bridge_slide("Operators", 2, 12,
        "Bitwise, arithmetic, relational, conditional — and their hardware cost.")

    return html_template("Day 2.1: Data Types and Vectors", "Data Types and Vectors",
        "Day 2 · Combinational Building Blocks", 1, 15, slides)


def day02_seg2():
    slides = ""
    slides += slide('''    <h2>Operator Reference</h2>
    <table style="font-size:0.65em;">
        <thead><tr><th>Category</th><th>Operators</th><th>Hardware Cost</th></tr></thead>
        <tbody>
            <tr class="fragment"><td>Bitwise</td><td><code>&amp;</code> <code>|</code> <code>^</code> <code>~</code> <code>~^</code></td><td>1 LUT per bit</td></tr>
            <tr class="fragment"><td>Logical</td><td><code>&amp;&amp;</code> <code>||</code> <code>!</code></td><td>Reduction + 1 LUT</td></tr>
            <tr class="fragment"><td>Arithmetic</td><td><code>+</code> <code>-</code> <code>*</code></td><td>Adder/multiplier chains</td></tr>
            <tr class="fragment"><td>Relational</td><td><code>==</code> <code>!=</code> <code>&lt;</code> <code>&gt;</code> <code>&lt;=</code> <code>&gt;=</code></td><td>Comparator logic</td></tr>
            <tr class="fragment"><td>Shift</td><td><code>&lt;&lt;</code> <code>&gt;&gt;</code></td><td>Free (just rewiring) if constant</td></tr>
            <tr class="fragment"><td>Conditional</td><td><code>? :</code></td><td>Multiplexer</td></tr>
            <tr class="fragment"><td>Reduction</td><td><code>&amp;</code> <code>|</code> <code>^</code> (unary)</td><td>Tree of gates</td></tr>
        </tbody>
    </table>''',
    notes="Here's the complete operator table with hardware cost. Bitwise operators: one LUT per bit. Arithmetic: adder and multiplier chains. Shifts by a constant are free — just rewiring. The conditional operator builds a mux.")

    slides += slide('''    <h2>Bitwise vs. Logical — Critical Difference</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">wire [3:0] a = 4'b1010;
wire [3:0] b = 4'b0101;</span>

<span class="fragment">wire [3:0] w_bitwise = a & b;   // → 4'b0000 (per-bit AND)</span>
<span class="fragment">wire       w_logical = a && b;  // → 1'b1   (both nonzero → true)</span></code></pre>
    <div class="fragment callout-warning" style="font-size:0.8em;">
        <code>&amp;</code> operates on each bit. <code>&amp;&amp;</code> treats the entire value as true/false.<br>
        Using the wrong one is a common source of subtle bugs.
    </div>''',
    notes="Critical distinction. Ampersand is bitwise AND — operates on each bit independently. Double ampersand is logical AND — treats the entire value as true or false. Using the wrong one is a common and subtle bug.")

    slides += slide('''    <h2>The Conditional Operator: Your Multiplexer</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">// 2:1 mux
assign y = sel ? a : b;</span>

<span class="fragment">// 4:1 mux via nesting
assign y = sel[1] ? (sel[0] ? d : c)
                  : (sel[0] ? b : a);</span></code></pre>
    <div class="fragment callout" style="font-size:0.8em;">
        The conditional operator <code>? :</code> is the most important combinational construct after <code>assign</code>. It builds <strong>hardware multiplexers</strong>.
    </div>''',
    notes="The conditional operator, question-mark colon, builds multiplexers. 2-to-1 mux is straightforward. You can nest them for 4-to-1. This is one of the most important combinational constructs you'll use.")

    slides += takeaway_slide([
        "Bitwise <code>&amp;</code> ≠ logical <code>&amp;&amp;</code>. Know the difference.",
        "Conditional <code>? :</code> = hardware multiplexer.",
        "Shifts by constants are free (rewiring). Multiplies are expensive.",
        "Every operator implies hardware. More operators = more gates.",
    ])

    slides += bridge_slide("Sized Literals &amp; Width Matching", 3, 8,
        "Why <code>1'b0</code> matters and how width mismatches cause bugs.")

    return html_template("Day 2.2: Operators", "Operators",
        "Day 2 · Combinational Building Blocks", 2, 12, slides)


def day02_seg3():
    slides = ""
    slides += slide('''    <h2>Literal Syntax</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment">1'b0          // 1-bit binary zero</span>
<span class="fragment">1'b1          // 1-bit binary one</span>
<span class="fragment">4'hF          // 4-bit hex: 1111</span>
<span class="fragment">8'd255        // 8-bit decimal: 11111111</span>
<span class="fragment">8'b1010_0011  // 8-bit binary with underscore separator (readability)</span>
<span class="fragment">16'hDEAD      // 16-bit hex</span></code></pre>
    <div class="fragment" style="margin-top:0.5em;font-size:0.75em;">
        <strong>Format:</strong> <code>&lt;width&gt;'&lt;base&gt;&lt;value&gt;</code> where base is <code>b</code> (binary), <code>h</code> (hex), <code>d</code> (decimal), <code>o</code> (octal).
    </div>''',
    notes="Sized literals have three parts: width, base, and value. 1'b0 is a 1-bit zero. 4'hF is a 4-bit hex F. Underscores are allowed for readability. Always specify the size.")

    slides += slide('''    <h2>Why Unsized Literals Are Dangerous</h2>
    <pre class="mistake"><code class="language-verilog">wire [3:0] a = 1;       // What width is 1? (32-bit default!)
wire [7:0] b = a + 1;   // Width mismatch — truncation?</code></pre>
    <pre class="synth fragment"><code class="language-verilog">wire [3:0] a = 4'd1;    // Explicit: 4-bit
wire [7:0] b = {4'b0, a} + 8'd1;  // Widths match</code></pre>
    <div class="fragment callout-danger" style="font-size:0.8em;">
        Unsized literals default to <strong>32 bits</strong>. This causes silent width mismatches, unexpected truncation, and synthesis warnings you'll learn to ignore (don't).
    </div>''',
    notes="Unsized literals default to 32 bits! This causes silent width mismatches and truncation. Always use sized literals. Never write just 1 or 0 — write 1'b1 or 1'b0.")

    slides += slide('''    <h2>Width Matching Rules</h2>
    <div style="font-size:0.8em;">
        <p class="fragment"><span class="check">✓</span> <code>wire [3:0] y = a & b;</code> — both 4-bit → result 4-bit</p>
        <p class="fragment"><span class="cross">✗</span> <code>wire [3:0] y = a[7:0] & b[3:0];</code> — 8-bit & 4-bit → <strong>b gets zero-extended!</strong></p>
        <p class="fragment"><span class="check">✓</span> <code>wire [7:0] sum = a + b;</code> — 8-bit result, but <strong>carry is lost</strong> unless you account for it</p>
    </div>
    <div class="fragment golden-rule" style="font-size:0.9em;margin-top:1em;">
        Rule: match widths explicitly. Let the code say what you mean.
    </div>''',
    notes="Width matching is a source of bugs. Mismatched widths get zero-extended silently. Carry bits get lost. Always match widths explicitly.")

    slides += takeaway_slide([
        "Always use sized literals: <code>4'hF</code> not <code>15</code>.",
        "Unsized literals default to 32 bits — silent mismatch source.",
        "Match widths explicitly in all expressions.",
    ])

    slides += bridge_slide("The 7-Segment Display", 4, 10,
        "Your first real building block — mapping hex digits to display segments.")

    return html_template("Day 2.3: Sized Literals and Width Matching", "Sized Literals &amp; Width Matching",
        "Day 2 · Combinational Building Blocks", 3, 8, slides)


def day02_seg4():
    slides = ""
    slides += slide('''    <h2>How a 7-Segment Display Works</h2>
    <pre style="font-family:monospace;font-size:0.7em;text-align:center;background:none;border:none;box-shadow:none;">
     aaaa
    f    b
    f    b
     gggg
    e    c
    e    c
     dddd
    </pre>
    <p style="font-size:0.8em;text-align:center;">7 segments labeled <code>a</code> through <code>g</code>. Turn segments on/off to display digits.</p>
    <div class="fragment callout-warning" style="font-size:0.75em;">
        <strong>Go Board:</strong> segments are <strong>active low</strong>. <code>0</code> = segment ON, <code>1</code> = segment OFF.
    </div>''',
    notes="A 7-segment display has segments labeled a through g. You turn combinations on and off to form digits. On the Go Board, they're active low — 0 means the segment is on.")

    slides += slide('''    <h2>Hex-to-7-Segment Mapping</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg    // {a,b,c,d,e,f,g}
);
always @(*) begin
    case (i_hex)         //     abcdefg
        4'h0: o_seg = 7'b0000001;  // 0
        4'h1: o_seg = 7'b1001111;  // 1
        4'h2: o_seg = 7'b0010010;  // 2
        4'h3: o_seg = 7'b0000110;  // 3
<span class="fragment">        4'h4: o_seg = 7'b1001100;  // 4
        4'h5: o_seg = 7'b0100100;  // 5
        4'h6: o_seg = 7'b0100000;  // 6
        4'h7: o_seg = 7'b0001111;  // 7</span>
<span class="fragment">        4'h8: o_seg = 7'b0000000;  // 8
        4'h9: o_seg = 7'b0000100;  // 9
        4'hA: o_seg = 7'b0001000;  // A
        4'hB: o_seg = 7'b1100000;  // b</span>
<span class="fragment">        4'hC: o_seg = 7'b0110001;  // C
        4'hD: o_seg = 7'b1000010;  // d
        4'hE: o_seg = 7'b0110000;  // E
        4'hF: o_seg = 7'b0111000;  // F</span>
    endcase
end
endmodule</code></pre>''',
    notes="Here's the complete hex to 7-segment decoder. 4-bit input, 7-bit output, one segment per bit. This uses a case statement inside an always-star block — we'll cover that syntax in detail tomorrow. For now, just see the pattern: each hex value maps to a specific segment pattern.")

    slides += slide('''    <h2>Sneak Preview: Hierarchy</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// In your top module, you INSTANTIATE the decoder:
hex_to_7seg display1 (
    .i_hex  (w_some_value),     // connect input
    .o_seg  (w_segments)        // connect output
);</code></pre>
    <div class="callout" style="font-size:0.8em;margin-top:1em;">
        Modules instantiate other modules — like placing chips on a circuit board.
        Always use <strong>named port connections</strong> (<code>.port_name(signal)</code>).
    </div>''',
    notes="Quick preview of hierarchy. In your top module, you instantiate the decoder by name. Named port connections — dot port name, then the signal you're connecting to. Always use named connections, never positional. We'll cover this more on Day 8.")

    slides += takeaway_slide([
        "7-segment displays map 4-bit hex to 7 segment enables.",
        "Go Board segments are <strong>active low</strong> (0 = ON).",
        "The <code>case</code> statement (tomorrow) is the natural way to express this.",
        "Modules instantiate other modules — hierarchy is key.",
    ])

    slides += end_slide(2)

    return html_template("Day 2.4: The 7-Segment Display", "The 7-Segment Display",
        "Day 2 · Combinational Building Blocks", 4, 10, slides)


# =============================================================================
# DAY 3 — Procedural Combinational Logic
# =============================================================================

def day03_seg1():
    slides = ""
    slides += slide('''    <h2>Why Procedural Blocks?</h2>
    <p style="font-size:0.85em;"><code>assign</code> works for simple expressions, but as logic gets complex — multi-way decisions, large lookup tables — it becomes unwieldy.</p>
    <p class="fragment" style="font-size:0.85em;">The <code>always</code> block gives us <code>if/else</code>, <code>case</code>, and other procedural constructs.</p>''',
    notes="We need procedural blocks because assign gets unwieldy for complex logic. The always block gives us if/else and case statements.")

    slides += slide('''    <h2>Sensitivity Lists</h2>
    <pre class="mistake"><code class="language-verilog">// Manual list — DON'T do this
always @(a or b or sel)
    if (sel) y = a; else y = b;</code></pre>
    <pre class="synth fragment"><code class="language-verilog">// Wildcard — ALWAYS do this for combinational
always @(*)
    if (sel) y = a; else y = b;</code></pre>
    <div class="fragment callout-danger" style="font-size:0.75em;">
        <strong>If you forget a signal in a manual list:</strong> simulation won't update when that signal changes, but synthesis WILL. Your simulation lies to you. Use <code>@(*)</code> — no exceptions.
    </div>''',
    notes="Sensitivity lists control when an always block re-evaluates. Manual lists are error-prone — forget one signal and you get a sim-synth mismatch. Always use the wildcard @star for combinational logic. No exceptions.")

    slides += slide('''    <h2><code>reg</code> Inside <code>always</code> — Again, Not a Register</h2>
    <pre class="synth"><code class="language-verilog">reg [3:0] r_result;  // declared as reg...
always @(*)          // ...but combinational (no clock)!
    r_result = a + b;  // → synthesizes to an ADDER, not a register</code></pre>
    <div class="callout" style="font-size:0.8em;">
        <strong>Rule:</strong> <code>wire</code> with <code>assign</code>. <code>reg</code> inside <code>always</code>.<br>
        Whether it's a register depends on the sensitivity list, not the keyword.
    </div>''',
    notes="Signals assigned inside an always block must be declared as reg. But reg does not mean register when used with always-star. It synthesizes to combinational logic. The keyword is misleading — it just means 'can be assigned procedurally.'")

    slides += takeaway_slide([
        "Use <code>always @(*)</code> for all combinational procedural blocks.",
        "<strong>Never</strong> use manual sensitivity lists — sim/synth mismatch risk.",
        "<code>reg</code> inside <code>always @(*)</code> = combinational, not a register.",
        "Use <code>begin/end</code> for multi-statement blocks.",
    ])

    slides += bridge_slide("if/else and case", 2, 15,
        "Priority logic, parallel selection, and the hardware they imply.")

    return html_template("Day 3.1: The always @(*) Block", "The <code>always @(*)</code> Block",
        "Day 3 · Procedural Combinational Logic", 1, 12, slides)


def day03_seg2():
    slides = ""
    slides += slide('''    <h2><code>if/else</code> — Priority Logic</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>always @(*) begin
<span class="fragment">    if (condition1)
        y = value1;</span>
<span class="fragment">    else if (condition2)
        y = value2;</span>
<span class="fragment">    else
        y = default_value;</span>
end</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <code>if/else</code> implies <strong>priority</strong>: condition1 is checked first. This synthesizes to a <strong>priority chain</strong> of muxes. First match wins.
    </div>''',
    notes="if/else implies priority. Condition 1 is checked first. If it's true, we're done. Otherwise check condition 2. This synthesizes to a priority chain of multiplexers.")

    slides += slide('''    <h2><code>case</code> — Parallel Selection</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>always @(*) begin
    case (sel)
<span class="fragment">        2'b00: y = a;</span>
<span class="fragment">        2'b01: y = b;</span>
<span class="fragment">        2'b10: y = c;</span>
<span class="fragment">        2'b11: y = d;</span>
<span class="fragment">        default: y = 4'b0;  // always include default!</span>
    endcase
end</code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        <code>case</code> implies <strong>parallel selection</strong> — all conditions checked simultaneously. Synthesizes to a <strong>multiplexer</strong>. No priority chain.
    </div>''',
    notes="The case statement is parallel selection — all conditions checked simultaneously. This synthesizes to a clean multiplexer, not a priority chain. Always include a default case.")

    slides += slide('''    <h2><code>if/else</code> vs. <code>case</code>: When to Use Which</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th>Use</th><th>When</th><th>Hardware</th></tr></thead>
        <tbody>
            <tr class="fragment"><td><code>if/else</code></td><td>Conditions have natural priority</td><td>Priority mux chain</td></tr>
            <tr class="fragment"><td><code>case</code></td><td>Selecting among equal alternatives</td><td>Parallel mux</td></tr>
            <tr class="fragment"><td><code>casez</code></td><td>Don't-care bits in selection</td><td>Priority + partial decode</td></tr>
        </tbody>
    </table>
    <pre class="synth fragment"><code class="language-verilog">// casez example: priority encoder
always @(*) begin
    casez (request)
        4'b1???: grant = 2'd3;   // highest priority
        4'b01??: grant = 2'd2;
        4'b001?: grant = 2'd1;
        4'b0001: grant = 2'd0;
        default: grant = 2'd0;
    endcase
end</code></pre>''',
    notes="Use if/else when conditions have natural priority. Use case for equal-weight selection. casez lets you use don't-care bits with question marks — useful for priority encoders.")

    slides += takeaway_slide([
        "<code>if/else</code> = priority chain. <code>case</code> = parallel mux.",
        "Use <code>case</code> when alternatives are equal; <code>if/else</code> when priority matters.",
        "<code>casez</code> allows don't-care matching with <code>?</code>.",
        "<strong>Always include <code>default</code></strong> in <code>case</code> statements.",
    ])

    slides += bridge_slide("The Latch Problem", 3, 12,
        "The most dangerous bug in combinational Verilog — and three ways to prevent it.")

    return html_template("Day 3.2: if/else and case", "if/else and case",
        "Day 3 · Procedural Combinational Logic", 2, 15, slides)


def day03_seg3():
    slides = ""
    slides += slide('''    <h2>What Is an Unintentional Latch?</h2>
    <p style="font-size:0.85em;">If a signal assigned in an <code>always @(*)</code> block is <strong>not assigned in every possible path</strong>, the synthesizer must preserve its old value.</p>
    <p class="fragment" style="font-size:0.85em;">The only hardware that "remembers" a value without a clock is a <strong>latch</strong>.</p>
    <div class="fragment callout-danger" style="font-size:0.8em;">
        Latches are almost never what you want. They are timing-hazard-prone, hard to test, and most FPGA tools handle them poorly.
    </div>''',
    notes="If a signal isn't assigned in every path through an always-star block, the synthesizer infers a latch to hold the old value. Latches are almost never what you want — they cause timing hazards and are hard to test.")

    slides += slide('''    <h2>How Latches Are Inferred</h2>
    <pre class="mistake"><code class="language-verilog" data-noescape>always @(*) begin
    if (sel)
        y = a;
    // NO else! What happens when sel=0?
    // y must keep its old value → LATCH inferred
end</code></pre>
    <pre class="mistake fragment"><code class="language-verilog" data-noescape>always @(*) begin
    case (opcode)
        2'b00: result = a + b;
        2'b01: result = a - b;
        // 2'b10 and 2'b11 not specified → LATCH
    endcase
end</code></pre>''',
    notes="Two classic latch inference patterns. First: if without else. When sel is 0, y must keep its old value, so a latch is inferred. Second: incomplete case — missing entries mean the output holds its value.")

    slides += slide('''    <h2>Three Techniques to Prevent Latches</h2>
    <div style="font-size:0.8em;">
    <div class="fragment">
        <h3 style="color:#2E7D32;">① Default assignment at the top</h3>
        <pre class="synth"><code class="language-verilog">always @(*) begin
    y = 4'b0;          // default — covers ALL paths
    if (sel) y = a;    // override only when needed
end</code></pre>
    </div>
    <div class="fragment">
        <h3 style="color:#2E7D32;">② Complete if/else chains</h3>
        <pre class="synth"><code class="language-verilog">always @(*) begin
    if (sel) y = a;
    else     y = b;    // every path assigns y
end</code></pre>
    </div>
    <div class="fragment">
        <h3 style="color:#2E7D32;">③ Default in case statements</h3>
        <pre class="synth"><code class="language-verilog">always @(*) begin
    case (opcode)
        2'b00: result = a + b;
        2'b01: result = a - b;
        default: result = 4'b0; // catches everything else
    endcase
end</code></pre>
    </div></div>''',
    notes="Three techniques. One: default assignment at the top of the block — this is my preferred approach. Two: complete if/else chains, always have an else. Three: default case in case statements. Technique 1 is the safest because it works globally.")

    slides += slide('''    <h2>How to Detect Latches</h2>
    <pre class="synth"><code class="language-bash"># Yosys will TELL you if it infers a latch:
yosys -p "synth_ice40 -top my_module" my_module.v

# Look for this in the output:
# Warning: Latch inferred for signal `\y'</code></pre>
    <div class="callout" style="font-size:0.8em;margin-top:1em;">
        <strong>In lab today:</strong> you'll intentionally create a latch, see Yosys warn about it, then fix it. Never ignore latch warnings.
    </div>''',
    notes="Yosys tells you when it infers a latch. Look for the warning in the synthesis output. In lab today you'll intentionally create one, see the warning, and fix it. Never ignore latch warnings.")

    slides += takeaway_slide([
        "Incomplete assignments in <code>always @(*)</code> → <strong>latch</strong>.",
        "Latches are almost never intentional. Treat latch warnings as errors.",
        "Prevention: default assignment at the top, complete else chains, default case.",
        "Yosys will warn you — <strong>never ignore latch warnings</strong>.",
    ])

    slides += bridge_slide("Blocking vs. Nonblocking", 4, 6,
        "The simple rule that will save you from one of Verilog's biggest pitfalls.")

    return html_template("Day 3.3: The Latch Problem", "The Latch Problem",
        "Day 3 · Procedural Combinational Logic", 3, 12, slides)


def day03_seg4():
    slides = ""
    slides += slide('''    <h2>The Rule (For Now)</h2>
    <div class="golden-rule" style="font-size:1.1em;margin-top:1em;">
        Combinational → <code>=</code> (blocking)<br>
        Sequential → <code>&lt;=</code> (nonblocking)
    </div>
    <pre class="synth fragment" style="margin-top:1em;"><code class="language-verilog">// Combinational: use =
always @(*) begin
    y = a & b;       // blocking — evaluates immediately
end

// Sequential: use <=  (Day 4)
always @(posedge clk) begin
    q <= d;          // nonblocking — all update "at once"
end</code></pre>''',
    notes="Here's the simple rule. For combinational always-star blocks, use blocking assignment, equals sign. For sequential always-posedge blocks, use nonblocking, less-than-equals. We'll explain WHY on Day 4. For now, memorize this rule.")

    slides += slide('''    <h2>Why This Matters (Preview)</h2>
    <p style="font-size:0.85em;">Mixing them up causes simulation/synthesis mismatches:</p>
    <div class="two-col" style="margin-top:0.5em;">
        <div class="panel panel-good" style="font-size:0.7em;">
            <strong>Correct:</strong> <code>=</code> in <code>@(*)</code><br>
            Immediate evaluation, like wires.
        </div>
        <div class="panel panel-bad" style="font-size:0.7em;">
            <strong>Dangerous:</strong> <code>=</code> in <code>@(posedge clk)</code><br>
            Creates race conditions between registers.
        </div>
    </div>
    <div class="fragment callout" style="font-size:0.8em;margin-top:1em;">
        Day 4 will show you the exact failure mode with a timing diagram. For now: <strong>memorize the rule</strong>.
    </div>''',
    notes="Mixing them up causes real problems. We'll see the exact failure mode on Day 4 with timing diagrams. For now, just memorize: equals in always-star, less-than-equals in always-posedge.")

    slides += takeaway_slide([
        "<code>=</code> (blocking) for combinational <code>always @(*)</code>.",
        "<code>&lt;=</code> (nonblocking) for sequential <code>always @(posedge clk)</code>.",
        "Mixing them causes race conditions — Day 4 will prove it.",
    ])

    slides += end_slide(3)

    return html_template("Day 3.4: Blocking vs. Nonblocking", "Blocking vs. Nonblocking",
        "Day 3 · Procedural Combinational Logic", 4, 6, slides)


# =============================================================================
# DAY 4 — Sequential Logic Fundamentals
# =============================================================================

def day04_seg1():
    slides = ""
    slides += slide('''    <h2>The Clock: Heartbeat of Sequential Logic</h2>
    <pre style="font-family:monospace;font-size:0.6em;text-align:center;background:none;border:none;box-shadow:none;color:#333;">
         ┌───┐   ┌───┐   ┌───┐   ┌───┐
clk  ────┘   └───┘   └───┘   └───┘   └───
         ↑       ↑       ↑       ↑
     posedge  posedge  posedge  posedge
    </pre>
    <p style="font-size:0.8em;">On each <strong>positive edge</strong>, every flip-flop captures its input. Between edges, combinational logic computes the next values.</p>
    <p class="fragment" style="font-size:0.8em;">This is <strong>Register Transfer Level (RTL)</strong> design — the fundamental abstraction of synchronous digital design.</p>''',
    notes="In sequential logic, the clock is everything. On each positive edge, every flip-flop captures its input. Between edges, combinational logic computes next values. This is Register Transfer Level design — the fundamental abstraction.")

    slides += slide('''    <h2>The Go Board's Clock</h2>
    <div style="font-size:0.85em;">
        <p class="fragment"><strong>Frequency:</strong> 25 MHz crystal oscillator (pin 15)</p>
        <p class="fragment"><strong>Period:</strong> 1 / 25,000,000 = <strong>40 ns</strong></p>
        <p class="fragment"><strong>Problem:</strong> 25 MHz is far too fast for human eyes</p>
        <p class="fragment"><strong>Solution:</strong> Clock divider — our first sequential design!</p>
    </div>
    <div class="fragment callout" style="font-size:0.8em;">
        To blink an LED at 1 Hz, we need to count <strong>25,000,000</strong> clock cycles. That requires a counter — which requires a flip-flop — which requires <code>always @(posedge clk)</code>.
    </div>''',
    notes="The Go Board has a 25 MHz clock. That's a 40 nanosecond period — way too fast to see. To blink an LED at 1 Hz, we need to count 25 million clock cycles. That's our first sequential design.")

    slides += slide('''    <h2>The Fundamental Sequential Pattern</h2>
    <pre class="synth"><code class="language-verilog">always @(posedge i_clk) begin
    r_q <= r_d;
end</code></pre>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th></th><th>Combinational</th><th>Sequential</th></tr></thead>
        <tbody>
            <tr><td>Sensitivity</td><td><code>always @(*)</code></td><td><code>always @(posedge clk)</code></td></tr>
            <tr><td>Assignment</td><td>Blocking <code>=</code></td><td>Nonblocking <code>&lt;=</code></td></tr>
            <tr><td>Output</td><td>Changes with inputs</td><td>Changes on clock edge only</td></tr>
            <tr><td>Synthesizes to</td><td>Gates, muxes</td><td>Flip-flops, registers</td></tr>
            <tr><td>Has memory?</td><td>No</td><td><strong>Yes</strong></td></tr>
        </tbody>
    </table>''',
    notes="Here's the fundamental pattern. always at posedge clk with nonblocking assignment. Compare with combinational: different sensitivity, different assignment, different hardware.")

    slides += takeaway_slide([
        "Clock edges define when state changes — everything else is combinational.",
        "<code>always @(posedge clk)</code> + <code>&lt;=</code> = flip-flop / register.",
        "The Go Board's 25 MHz clock needs dividers for human-visible rates.",
        "RTL = registers + combinational logic + clock.",
    ])

    slides += bridge_slide("Nonblocking Assignment — Why It Matters", 2, 15,
        "The most important 'why' in Verilog — with a timing diagram proof.")

    return html_template("Day 4.1: Clocks and Edge-Triggered Behavior", "Clocks &amp; Edge-Triggered Behavior",
        "Day 4 · Sequential Logic Fundamentals", 1, 12, slides)


def day04_seg2():
    slides = ""
    slides += slide('''    <h2>The Problem: Blocking in Sequential Blocks</h2>
    <pre class="mistake"><code class="language-verilog" data-noescape>// WRONG — blocking assignment in sequential block
always @(posedge clk) begin
    b = a;     // b gets a's value immediately
    c = b;     // c gets b's NEW value (= a) — NOT the old b!
end</code></pre>
    <div class="fragment callout-danger" style="font-size:0.8em;">
        <strong>Intended:</strong> a 2-stage shift register (a → b → c on successive clock edges).<br>
        <strong>Got:</strong> a and c are copies of the same value. The pipeline stage is destroyed.
    </div>''',
    notes="Here's the problem. With blocking assignment in a sequential block, b gets a's value immediately, then c gets b's NEW value — which is already a. Both stages see the same value on the same clock edge. The pipeline is destroyed.")

    slides += slide('''    <h2>The Fix: Nonblocking Assignment</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// CORRECT — nonblocking assignment
always @(posedge clk) begin
    b <= a;    // scheduled: b will get a's CURRENT value
    c <= b;    // scheduled: c will get b's CURRENT (old) value
end</code></pre>
    <div class="fragment callout" style="font-size:0.8em;">
        With <code>&lt;=</code>, all right-hand sides are evaluated <strong>first</strong>, then all left-hand sides are updated <strong>simultaneously</strong>. Order within the block doesn't matter.
    </div>''',
    notes="With nonblocking assignment, all right-hand sides are evaluated first with current values, then all left-hand sides update simultaneously at the clock edge. c gets the OLD value of b. The pipeline works correctly.")

    slides += slide('''    <h2>Timing Diagram Proof</h2>
    <pre style="font-family:monospace;font-size:0.5em;background:none;border:none;box-shadow:none;color:#333;">
         ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
clk  ────┘  └──┘  └──┘  └──┘  └──┘  └──
         ↑     ↑     ↑     ↑     ↑

a:   ─[X]─────────────────────────────
        X

          Blocking (=)        Nonblocking (<=)
b:   ────[X]──────────    ────[·]─[X]────────
          X  (same clk)        ·   X  (1 clk delay)

c:   ────[X]──────────    ────[·]─[·]─[X]────
          X  (same clk!)       ·   ·   X  (2 clk delay) ✓
    </pre>
    <div class="fragment golden-rule" style="font-size:0.9em;">
        Blocking: a, b, c all update in the <strong>same</strong> cycle. Pipeline destroyed.<br>
        Nonblocking: each stage delays by one cycle. <strong>Correct shift register.</strong>
    </div>''',
    notes="The timing diagram makes it clear. With blocking, everything updates in the same cycle — pipeline destroyed. With nonblocking, each stage delays by one clock cycle — correct shift register behavior.")

    slides += slide('''    <h2>The Complete Rule</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th>Context</th><th>Assignment</th><th>Reason</th></tr></thead>
        <tbody>
            <tr><td><code>always @(*)</code></td><td><code>=</code> blocking</td><td>Evaluate immediately, like combinational wires</td></tr>
            <tr><td><code>always @(posedge clk)</code></td><td><code>&lt;=</code> nonblocking</td><td>All registers update simultaneously at edge</td></tr>
            <tr><td><code>assign</code></td><td><code>=</code> (only option)</td><td>Continuous drive</td></tr>
        </tbody>
    </table>
    <div class="callout-danger" style="font-size:0.8em;margin-top:1em;">
        <strong>Never mix</strong> <code>=</code> and <code>&lt;=</code> in the same <code>always</code> block.
    </div>''',
    notes="The complete rule. Blocking in combinational, nonblocking in sequential, and never mix them in the same block.")

    slides += takeaway_slide([
        "Blocking <code>=</code> evaluates immediately — destroys pipelines in sequential blocks.",
        "Nonblocking <code>&lt;=</code> schedules updates — all registers update at once.",
        "<strong>Never mix <code>=</code> and <code>&lt;=</code> in the same block.</strong>",
        "This is not just style — it's correctness.",
    ])

    slides += bridge_slide("Flip-Flops With Reset and Enable", 3, 10,
        "The D-FF variations you'll use in every sequential design.")

    return html_template("Day 4.2: Nonblocking Assignment — Why It Matters",
        "Nonblocking Assignment",
        "Day 4 · Sequential Logic Fundamentals", 2, 15, slides)


def day04_seg3():
    slides = ""
    slides += slide('''    <h2>D Flip-Flop Variants</h2>
    <pre class="synth"><code class="language-verilog" data-noescape><span class="fragment" data-fragment-index="1">// Basic D flip-flop
always @(posedge i_clk)
    r_q <= r_d;</span>

<span class="fragment" data-fragment-index="2">// With synchronous reset
always @(posedge i_clk)
    if (i_reset) r_q <= 1'b0;
    else         r_q <= r_d;</span>

<span class="fragment" data-fragment-index="3">// With asynchronous reset
always @(posedge i_clk or posedge i_reset)
    if (i_reset) r_q <= 1'b0;
    else         r_q <= r_d;</span>

<span class="fragment" data-fragment-index="4">// With enable
always @(posedge i_clk)
    if (i_reset)    r_q <= 1'b0;
    else if (i_en)  r_q <= r_d;</span></code></pre>''',
    notes="Four D flip-flop variants you'll use constantly. Basic — just captures on edge. Synchronous reset — resets on the clock edge. Asynchronous reset — resets immediately, note the sensitivity list includes reset. With enable — only captures when enable is high.")

    slides += slide('''    <h2>Synchronous vs. Asynchronous Reset</h2>
    <table style="margin-top:0.5em;">
        <thead><tr><th></th><th>Synchronous</th><th>Asynchronous</th></tr></thead>
        <tbody>
            <tr><td>When it resets</td><td>On clock edge only</td><td>Immediately</td></tr>
            <tr><td>Sensitivity</td><td><code>@(posedge clk)</code></td><td><code>@(posedge clk or posedge rst)</code></td></tr>
            <tr><td>FPGA preference</td><td>Often preferred (iCE40)</td><td>Some FPGAs have dedicated async</td></tr>
            <tr><td>Timing</td><td>Clean, predictable</td><td>Can cause timing issues</td></tr>
        </tbody>
    </table>
    <div class="fragment callout" style="font-size:0.75em;">
        <strong>Our convention:</strong> synchronous, active-high reset unless there's a specific reason otherwise.
    </div>''',
    notes="Synchronous reset is cleaner and we'll prefer it for this course. It resets on the clock edge, keeps timing predictable, and works well with the iCE40.")

    slides += takeaway_slide([
        "Basic D-FF: <code>always @(posedge clk) r_q &lt;= r_d;</code>",
        "Sync reset: <code>if (reset) r_q &lt;= 0; else r_q &lt;= r_d;</code>",
        "Enable: adds another condition — <code>else if (en)</code>",
        "Prefer synchronous, active-high reset on iCE40.",
    ])

    slides += bridge_slide("Counters and Clock Division", 4, 13,
        "From 25 MHz to a visible blink — your first real sequential design.")

    return html_template("Day 4.3: Flip-Flops With Reset and Enable", "Flip-Flop Variants",
        "Day 4 · Sequential Logic Fundamentals", 3, 10, slides)


def day04_seg4():
    slides = ""
    slides += slide('''    <h2>The Free-Running Counter</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>reg [7:0] r_count;

always @(posedge i_clk)
    r_count <= r_count + 1;
<span class="fragment">
// What happens?
// Cycle 0: r_count = 8'h00
// Cycle 1: r_count = 8'h01
// ...
// Cycle 255: r_count = 8'hFF
// Cycle 256: r_count = 8'h00  ← rollover!</span></code></pre>
    <div class="fragment callout" style="font-size:0.75em;">
        An 8-bit counter rolls over every 256 cycles. An N-bit counter rolls over every 2<sup>N</sup> cycles.
    </div>''',
    notes="A free-running counter increments every clock cycle and rolls over when it reaches its maximum. 8-bit counter rolls over every 256 cycles. N-bit counter every 2-to-the-N cycles.")

    slides += slide('''    <h2>Clock Division: 25 MHz → 1 Hz</h2>
    <pre class="synth"><code class="language-verilog" data-noescape>// 25 MHz clock → 1 Hz blink
// Need to count 25,000,000 cycles per half-period
// log2(25000000) ≈ 25 bits
<span class="fragment">
reg [24:0] r_counter;
reg        r_led;

always @(posedge i_clk) begin
    if (r_counter == 25_000_000 - 1) begin
        r_counter <= 0;
        r_led     <= ~r_led;    // toggle
    end else begin
        r_counter <= r_counter + 1;
    end
end</span>

<span class="fragment">assign o_led1 = r_led;</span></code></pre>''',
    notes="To get 1 Hz from 25 MHz, count to 25 million per half-period. That needs a 25-bit counter. When it hits the target, reset and toggle the LED output. This is your first real sequential design — you'll build it in lab today.")

    slides += slide('''    <h2>Choosing Divider Rates</h2>
    <table style="margin-top:0.5em;font-size:0.7em;">
        <thead><tr><th>Target Frequency</th><th>Count Target</th><th>Counter Bits</th></tr></thead>
        <tbody>
            <tr><td>~1 Hz (visible blink)</td><td>12,500,000</td><td>24</td></tr>
            <tr><td>~2 Hz (fast blink)</td><td>6,250,000</td><td>23</td></tr>
            <tr><td>~1 kHz (audio range)</td><td>12,500</td><td>14</td></tr>
            <tr><td>~100 Hz (display refresh)</td><td>125,000</td><td>17</td></tr>
        </tbody>
    </table>
    <div class="callout" style="font-size:0.75em;margin-top:0.5em;">
        <strong>Quick trick:</strong> Use the MSB of a free-running counter as a divided clock.<br>
        Bit 23 of a 25 MHz counter toggles at ~1.5 Hz. Bit 24 at ~0.75 Hz. Close enough for LEDs!
    </div>''',
    notes="Quick reference for common divider rates. And here's a trick: just use the MSB of a free-running counter as your divided output. Bit 23 gives you about 1.5 Hz. Not exact, but great for LED blinking.")

    slides += takeaway_slide([
        "Counters are the fundamental sequential building block.",
        "N-bit counter rolls over every 2<sup>N</sup> cycles.",
        "Clock divider: count to a target, then toggle or reset.",
        "Quick trick: use counter MSBs for approximate clock division.",
    ])

    slides += end_slide(4)

    return html_template("Day 4.4: Counters and Clock Division", "Counters &amp; Clock Division",
        "Day 4 · Sequential Logic Fundamentals", 4, 13, slides)


# =============================================================================
# QUIZ FILES
# =============================================================================

QUIZZES = {
    "day02": """# Day 2: Pre-Class Self-Check Quiz
## Combinational Building Blocks

**Q1:** What's the difference between `wire` and `reg`? Does `reg` always synthesize to a register?

<details><summary>Answer</summary>
`wire` must be driven by `assign` or module output. `reg` can be assigned inside `always` blocks. `reg` does NOT always become a register — it depends on whether there's a clock edge in the sensitivity list. `reg` in `always @(*)` = combinational.
</details>

**Q2:** What is `4'hF` in binary? How many bits?

<details><summary>Answer</summary>
4-bit binary `1111` (decimal 15). The `4'` specifies 4 bits, `h` means hexadecimal.
</details>

**Q3:** What does `assign y = sel ? a : b;` synthesize to?

<details><summary>Answer</summary>
A 2-to-1 multiplexer. When `sel=1`, output is `a`. When `sel=0`, output is `b`.
</details>

**Q4:** What's the difference between `&` and `&&`?

<details><summary>Answer</summary>
`&` is bitwise AND (operates on each bit). `&&` is logical AND (treats entire value as true/false). `4'b1010 & 4'b0101 = 4'b0000`. `4'b1010 && 4'b0101 = 1'b1` (both nonzero).
</details>
""",

    "day03": """# Day 3: Pre-Class Self-Check Quiz
## Procedural Combinational Logic

**Q1:** Why must you use `@(*)` instead of a manual sensitivity list for combinational logic?

<details><summary>Answer</summary>
Manual lists risk sim/synth mismatch. If you forget a signal, simulation won't update when it changes, but synthesis will. `@(*)` automatically includes all signals read inside the block.
</details>

**Q2:** What causes an unintentional latch? Give an example.

<details><summary>Answer</summary>
Not assigning a signal in every possible path through an `always @(*)` block. Example: `if (sel) y = a;` with no `else` — when `sel=0`, `y` must hold its value → latch inferred.
</details>

**Q3:** Name three techniques to prevent latch inference.

<details><summary>Answer</summary>
1. Default assignment at the top of the block (`y = 0;` before the `if`)
2. Complete `if/else` chains (always have an `else`)
3. `default` case in `case` statements
</details>

**Q4:** When do you use `=` vs `<=`?

<details><summary>Answer</summary>
`=` (blocking) for combinational `always @(*)`. `<=` (nonblocking) for sequential `always @(posedge clk)`. Never mix them in the same block.
</details>
""",

    "day04": """# Day 4: Pre-Class Self-Check Quiz
## Sequential Logic Fundamentals

**Q1:** What's the period of the Go Board's 25 MHz clock? How many cycles for a 1 Hz blink?

<details><summary>Answer</summary>
Period = 1/25,000,000 = 40 ns. For 1 Hz blink (toggle every 0.5s): 25,000,000 / 2 = 12,500,000 cycles per half-period.
</details>

**Q2:** Why does blocking assignment (`=`) break a shift register in a sequential block?

<details><summary>Answer</summary>
With `=`, `b = a; c = b;` — b gets a's value immediately, then c sees b's NEW value (which is already a). Both stages get the same value in one cycle. With `<=`, both right-hand sides are evaluated first with current values, then all updates happen simultaneously.
</details>

**Q3:** Write a D flip-flop with synchronous reset from memory.

<details><summary>Answer</summary>
```verilog
always @(posedge i_clk)
    if (i_reset)
        r_q <= 1'b0;
    else
        r_q <= r_d;
```
</details>

**Q4:** You want an LED to blink at ~2 Hz from a 25 MHz clock. What counter value do you count to?

<details><summary>Answer</summary>
2 Hz = toggle every 0.25s = 6,250,000 clock cycles per half-period. Count to 6,250,000 - 1, then toggle and reset.
</details>
""",
}


# =============================================================================
# GENERATE ALL FILES
# =============================================================================

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"  ✓ {path}")


def main():
    base = "/home/claude/hdl-course/lectures/week1"

    print("Generating Week 1 slide decks...\n")

    # Day 1 (seg1 already exists)
    d1 = f"{base}/day01_welcome_to_hardware_thinking"
    write_file(f"{d1}/seg2_synthesis_vs_simulation.html", day01_seg2())
    write_file(f"{d1}/seg3_anatomy_of_a_module.html", day01_seg3())
    write_file(f"{d1}/seg4_digital_logic_refresher.html", day01_seg4())

    # Day 2
    d2 = f"{base}/day02_combinational_building_blocks"
    write_file(f"{d2}/seg1_data_types_and_vectors.html", day02_seg1())
    write_file(f"{d2}/seg2_operators.html", day02_seg2())
    write_file(f"{d2}/seg3_sized_literals_width_matching.html", day02_seg3())
    write_file(f"{d2}/seg4_seven_segment_display.html", day02_seg4())
    write_file(f"{d2}/quiz.md", QUIZZES["day02"])

    # Day 3
    d3 = f"{base}/day03_procedural_combinational_logic"
    write_file(f"{d3}/seg1_always_star_block.html", day03_seg1())
    write_file(f"{d3}/seg2_if_else_and_case.html", day03_seg2())
    write_file(f"{d3}/seg3_the_latch_problem.html", day03_seg3())
    write_file(f"{d3}/seg4_blocking_vs_nonblocking.html", day03_seg4())
    write_file(f"{d3}/quiz.md", QUIZZES["day03"])

    # Day 4
    d4 = f"{base}/day04_sequential_logic_fundamentals"
    write_file(f"{d4}/seg1_clocks_and_edges.html", day04_seg1())
    write_file(f"{d4}/seg2_nonblocking_assignment.html", day04_seg2())
    write_file(f"{d4}/seg3_flip_flop_variants.html", day04_seg3())
    write_file(f"{d4}/seg4_counters_and_clock_division.html", day04_seg4())
    write_file(f"{d4}/quiz.md", QUIZZES["day04"])

    print(f"\nDone! Generated {15} slide decks + {3} quizzes.")


if __name__ == "__main__":
    main()
