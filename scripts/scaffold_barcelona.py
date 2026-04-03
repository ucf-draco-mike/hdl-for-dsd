#!/usr/bin/env python3
"""
scaffold_barcelona.py — Creates the Barcelona abroad overlay in the hdl-for-dsd repo.

Usage:
    python3 scripts/scaffold_barcelona.py              # dry run
    python3 scripts/scaffold_barcelona.py --apply      # create files

This does NOT modify any baseline course content. It creates:
  barcelona/                    — overlay root (new)
  docs/barcelona_schedule.md    — persistent source for MkDocs (new)
  docs/barcelona_project.md    — rescoped project spec (new)

And patches:
  scripts/prep_mkdocs.py       — adds Barcelona symlinks + nav section
  mkdocs.yml                   — adds Barcelona nav tab
"""

import os
import sys
from pathlib import Path
from textwrap import dedent

REPO = Path(__file__).resolve().parent.parent
DRY_RUN = "--apply" not in sys.argv

# ── Day mapping: Barcelona calendar → baseline days ──────────────────────────
BARCELONA_DAYS = [
    # (date, cal_label, baseline_day(s), session_title, week_num)
    ("Mon 5/25", "CLASS",     "D1",     "Welcome to Hardware Thinking",               1),
    ("Tue 5/26", "CLASS",     "D2",     "Data Types, Vectors & Operators",            1),
    ("Wed 5/27", "CLASS",     "D3",     "Combinational Logic & always@(*)",           1),
    ("Thu 5/28", "EXCURSION", None,     "Montserrat Day Trip",                        1),
    ("Fri 5/29", "CLASS",     "D4",     "Clocked Logic & RTL Thinking",               1),
    ("Mon 6/1",  "CLASS",     "D5+D6",  "Counters, Testbenches & AI Verification",    2),
    ("Tue 6/2",  "CLASS",     "D7",     "Finite State Machines",                      2),
    ("Wed 6/3",  "CLASS",     "D8",     "Hierarchy, Parameters & Generate",           2),
    ("Thu 6/4",  "CLASS",     "D9",     "Memory: RAM, ROM & Block RAM",               2),
    ("Fri 6/5",  "FREE",      None,     "Independent study / explore Barcelona",      2),
    ("Mon 6/8",  "CLASS",     "D10",    "Timing, Numerical Architectures & PPA",      3),
    ("Tue 6/9",  "CLASS",     "D11",    "UART: Protocol Design & Implementation",     3),
    ("Wed 6/10", "CLASS",     "D12",    "SystemVerilog for Design",                   3),
    ("Thu 6/11", "CLASS",     "D13",    "SystemVerilog for Verification",             3),
    ("Fri 6/12", "FREE",      None,     "Independent project work",                   3),
    ("Mon 6/15", "VISIT",     None,     "Barcelona Metro Control Room",               4),
    ("Tue 6/16", "CLASS",     "D14",    "Project Build Day",                          4),
    ("Wed 6/17", "GUEST",     None,     "RISC-V Lecture — David Castells Rufas",      4),
    ("Thu 6/18", "CLASS",     "D15",    "Project Demos & Course Wrap",                4),
    ("Fri 6/19", "FREE",      None,     "Departure / free day",                       4),
]

# ── CRAFT phase template (shared across all session plans) ───────────────────
CRAFT_SESSION_TEMPLATE = dedent("""\
    ## CRAFT Session Structure

    Every 2.5-hour teaching session follows the CRAFT cycle:

    | Phase | Time | Element | Description |
    |-------|------|---------|-------------|
    | 🌍 **Contextualize** | 10 min | "Where This Lives" | Real-world framing; connect to academic visits |
    | ⚠️ **Reframe** | 15 min | "If You're Thinking Like a..." | Surface misconception → install correct model |
    | 👁️🤝🧪 **Assemble** | 80–90 min | I Do → We Do → You Do | Scaffolded practice with named patterns |
    | 🔧🤖 **Fortify** | 20 min | Tool + AI verification | "What Did the Tool Build?" + "Check the Machine" |
    | 🔗 **Transfer** | 10 min | "What's Next" | Bridge to next session + homework |

    ### Standing Elements (every session)

    - 🔑 **Key Insight** — captured on board/slide during Reframe or Assemble
    - ❓ **No Dumb Questions** — 3-min pause after Reframe
    - 💡 **Pattern** — named when introduced (e.g., "3-block FSM")
    - 🧠 **How You Learn** — metacognitive moment before Fortify
    - 🤖 **Check the Machine** — AI exercise from D4 onward
    - 📊 **Industry Alignment** — professional connection during Contextualize
    """)

# ── Merged session: D5+D6 ───────────────────────────────────────────────────
D5_D6_MERGED_PLAN = dedent("""\
    # Day 5+6 (Merged): Counters, Testbenches & AI Verification

    **Date:** Monday, June 1, 2026 · 10:00–12:30
    **Baseline days:** D5 (Counters, Shift Registers & Debounce) + D6 (Testbenches & AI-Assisted Verification)
    **Pre-class videos:** V5 (Counters/Debounce, 45 min) + V6 (Testbench Anatomy, 55 min) — assigned over weekend
    **Afternoon:** Academic visit to Semidynamics (RISC-V processor design), 4:00–5:30 PM

    ---

    ## 🌍 Contextualize (10 min)

    **"Where This Lives":** "Every digital system counts, shifts, and debounces.
    The processor pipelines at Semidynamics — the company you'll visit this
    afternoon — are built from the same counters and shift registers you're about
    to design. And the testbenches you'll write today? That's how they know their
    silicon actually works before they tape out."

    **📊 Industry Alignment:** Verification consumes 60–70% of chip development effort.
    The AI-assisted approach we introduce today is how the industry is evolving.

    ---

    ## ⚠️ Reframe (15 min)

    **"If You're Thinking Like a Programmer..."**

    1. "Buttons just work → Mechanical contacts bounce for milliseconds.
       You need a saturating counter, not a `delay()` call."
    2. "If it simulates, it works → Simulation proves correctness for tested
       cases only. It cannot prove the absence of bugs."

    **🔑 Key Insight:** "A testbench is not optional — it's how you know your
    design works. Writing it *after* the design is common; writing it *before*
    is better."

    **❓ No Dumb Questions** (3 min): "What's the dumbest question about
    counters or testing you're afraid to ask?"

    ---

    ## 👁️🤝🧪 Assemble — Part 1: Sequential Building Blocks (50 min)

    ### 👁️ I Do (15 min)
    Live-code a modular counter (`counter_mod_n`) and debounce circuit.
    Show synthesis output — point out flip-flops in the schematic.

    **💡 Pattern:** "Parameterized counter" — `parameter MOD = 10` makes this
    reusable at any modulus.

    ### 🤝 We Do (15 min)
    Together: add LFSR (linear feedback shift register), wire debounced
    buttons to control the counter. Deploy to Go Board — verify count on
    7-segment display.

    ### 🧪 You Do (20 min)
    - **Exercise 1:** Design a mod-N counter with configurable modulus.
      Simulate with provided testbench, then deploy to Go Board.
    - **Exercise 2:** Build a configurable shift register (serial-in,
      parallel-out). Simulate.
    - **Stretch:** LFSR-based pseudo-random number generator on LEDs.

    ---

    ## 👁️🤝🧪 Assemble — Part 2: Testbenches & AI Verification (45 min)

    ### 👁️ I Do (10 min)
    Write a self-checking testbench for the mod-N counter:
    - `$dumpvars` setup, clock generation
    - Expected-vs-actual comparison with pass/fail counters
    - Summary message: "X/Y tests passed"

    **💡 Pattern:** "Self-checking testbench" — the testbench tells you
    pass/fail without you reading waveforms.

    ### 🤝 We Do (15 min)
    Together: prompt an AI to generate a testbench for the debounce module.
    - Structured prompt: module interface, expected behavior, edge cases
    - Evaluate the AI output: Does it handle bounce timing? Reset?
    - Annotate corrections directly in the generated code

    **🔑 Key Insight:** "The AI doesn't know your design intent. Your prompt
    must specify what 'correct' means."

    ### 🧪 You Do (20 min)
    - **Exercise 3:** Write a manual self-checking TB for your mod-N counter.
    - **Exercise 4:** Prompt AI to generate a second TB for the same module.
      Compare: which found more issues? What did each miss? Annotate.
    - **Stretch:** AI-generate a TB for the LFSR. Does it check the
      polynomial correctly?

    ---

    ## 🔧🤖 Fortify (15 min)

    **🔧 What Did the Tool Build?**
    Open both TBs in GTKWave side by side. Compare coverage — which
    exercised more input combinations?

    **🤖 Check the Machine:** "Which TB caught more bugs — yours or the AI's?
    Why? What did each miss?" Brief written reflection (3 sentences).

    **🧠 How You Learn:** "You wrote the TB *after* building the module.
    What would change if you wrote it *before*? That's called test-driven
    development — and it works in hardware too."

    ---

    ## 🔗 Transfer (10 min)

    "You can now build sequential circuits AND verify them — both manually
    and with AI assistance. Tomorrow: Finite State Machines — the design
    pattern that ties everything together."

    **📊 Industry Alignment:** "This afternoon at Semidynamics, ask them:
    how much of their RISC-V development time is verification?"

    **Homework:** Watch D7 pre-class video (FSM theory, Moore/Mealy, 3-block
    pattern, ~50 min).

    ---

    ## Lab Exercises Summary

    | # | Exercise | Source | Type | Time |
    |---|----------|--------|------|------|
    | 1 | Mod-N counter | D5 Ex 1 | 🧪 You Do | 10 min |
    | 2 | Shift register | D5 Ex 2 | 🧪 You Do | 10 min |
    | 3 | Manual TB for counter | D6 Ex 1 | 🧪 You Do | 10 min |
    | 4 | AI TB + comparison | D6 Ex 2 | 🧪 You Do | 10 min |
    | S1 | LFSR on LEDs | D5 stretch | Stretch | — |
    | S2 | AI TB for LFSR | D6 stretch | Stretch | — |

    **Starter code:** Use baseline D5 + D6 lab packages. No new starter code needed.
    **Deliverable:** Mod-N counter + manual TB + AI-generated TB with annotations.
    """)

# ── Condensed UART session ──────────────────────────────────────────────────
D11_CONDENSED_PLAN = dedent("""\
    # Day 11 (Condensed): UART — Protocol Design & Implementation

    **Date:** Tuesday, June 9, 2026 · 10:00–12:30
    **Baseline days:** D11 (UART TX) + D12 (UART RX — conceptual only)
    **Pre-class videos:** V11 (UART TX, 50 min) + V12 (UART RX conceptual, 40 min)
    **Evening:** Flamenco show at Los Tarantos, 7:10 PM

    ---

    ## 🌍 Contextualize (10 min)

    **"Where This Lives":** "Serial communication is everywhere — your Go Board's
    USB-to-UART bridge, the debug ports on the RISC-V chips at Semidynamics,
    the telemetry links in the Metro control room you'll visit next week."

    ---

    ## ⚠️ Reframe (15 min)

    **"If You're Thinking Like a Programmer..."**
    "You send a string with `print()`. Reframe: you're building a state machine
    that shifts out one bit at a time at a precise baud rate. There's no `print`
    — there's a shift register, a baud counter, and an FSM."

    UART protocol walkthrough: start bit, 8 data bits, optional parity, stop bit.
    Baud rate = bit period. 115200 baud → ~8.68 µs per bit.

    **🔑 Key Insight:** "UART TX is an FSM that shifts bits out at a fixed rate.
    That's it. The protocol complexity is in the *timing*, not the logic."

    ---

    ## 👁️🤝🧪 Assemble (80 min)

    ### 👁️ I Do (20 min)
    Build UART TX live:
    - 3-block FSM: IDLE → START → DATA → STOP
    - Baud rate counter (parameterized)
    - Shift register for data bits
    - Show synthesis: "This is just an FSM + counter + shift register —
      modules you already know."

    ### 🤝 We Do (15 min)
    Together: add configurable baud rate parameter. Simulate with the
    baseline D11 testbench. Verify timing in GTKWave.

    ### 🧪 You Do (25 min)
    - **Exercise 1:** Parameterize UART TX for different baud rates
      (9600, 19200, 115200). Simulate each — verify bit timing.
    - **Exercise 2:** Deploy to Go Board. Send your name to PC terminal
      via USB-UART bridge. See characters appear.
    - **Exercise 3 (Stretch):** Implement UART RX from pre-class video
      spec — 16× oversampling, center sampling, frame detection.

    ### 🤖 AI Protocol Verification (20 min)
    - Prompt AI for a protocol-aware UART TB: "Generate a testbench for
      a UART transmitter with parameterized baud rate. It should verify
      start bit timing, data bit values, and stop bit."
    - Evaluate: Does the AI check baud timing precisely? Does it verify
      all 8 data bits? What about back-to-back transmissions?
    - Annotate corrections.

    ---

    ## 🔧 Fortify (15 min)

    **🔧 What Did the Tool Build?**
    Synthesize UART TX at 9600 baud vs 115200 baud. Compare `yosys stat`:
    LUTs, FFs. What changes? (The baud counter width.) What doesn't?
    (The FSM and shift register.)

    **🧠 How You Learn:** "You just built a complete serial transmitter from
    scratch. Three weeks ago you couldn't write a module. What changed in
    your mental model of hardware?"

    ---

    ## 🔗 Transfer (10 min)

    "You've designed a communication interface from the ground up — FSM,
    timing, verification. Tomorrow: SystemVerilog gives you sharper tools
    for everything you've learned so far."

    **Homework:** Watch D13 pre-class video (SV Design, 45 min).

    ---

    ## What's Different from Baseline

    | Baseline D11+D12 Content | Barcelona Status |
    |--------------------------|------------------|
    | UART TX design + lab | ✅ Full coverage |
    | UART TX testbench (AI) | ✅ Full coverage |
    | UART TX Go Board deploy | ✅ Full coverage |
    | UART RX (16× oversampling) | 📹 Pre-class video + stretch exercise |
    | UART loopback (TX→RX echo) | ❌ Dropped |
    | SPI Master | ❌ Dropped |

    **Starter code:** Use baseline D11 lab package. D12 UART RX starter is
    available as stretch material but not required.
    """)

# ── Rescoped project spec ────────────────────────────────────────────────────
BARCELONA_PROJECT = dedent("""\
    # Final Project — Barcelona Abroad Edition

    ## Overview

    Design, simulate, and demonstrate a digital system on the Nandland Go Board.
    You have one structured build day (Tue 6/16) plus independent work time to
    complete your project. Demos are Thursday 6/18.

    ---

    ## Project Options (choose one)

    | # | Project | Key Concepts | Difficulty |
    |---|---------|-------------|------------|
    | 1 | **UART Command Parser** | FSM + UART TX + string matching + LED control | ★★ |
    | 2 | **Digital Clock / Timer** | Counters + 7-seg multiplexing + button FSM | ★★ |
    | 3 | **Pattern Generator** | Shift registers + LFSR + LED sequencing + parameterization | ★☆ |
    | 4 | **Reaction Time Game** | FSM + counter + random delay + 7-seg display | ★★ |
    | 5 | **Tone Generator** | Counter-based frequency synthesis + button UI + 7-seg | ★★ |
    | 6 | **Conway's Game of Life** | Memory + neighbor logic + VGA/LED display + FSM | ★★ |

    You may propose a custom project with instructor approval. Custom projects
    must exercise at least: one FSM, one parameterized module, and one testbench.

    ---

    ## Timeline

    | Date | Milestone |
    |------|-----------|
    | **Thu 6/4** | Project selection due |
    | **Mon 6/8** | Block diagram + module list (1-page sketch) |
    | **Thu 6/11** | Core module compiles + simulates; testbench started |
    | Fri 6/12 – Mon 6/15 | Independent work (weekend + Metro visit day afternoon) |
    | **Tue 6/16** | Build day: integration, PPA, AI-assisted TB polish |
    | Wed 6/17 afternoon | Independent polish (after RISC-V lecture) |
    | **Thu 6/18** | Demo day — 5-min demo + 2-min Q&A; all deliverables due |

    ---

    ## Deliverables

    1. **Working hardware demo** (5 min) — deployed on Go Board, demonstrated live
    2. **Source code** — clean, commented, following course conventions
       (`r_`/`w_`/`i_`/`o_` prefixes, parameterized where appropriate)
    3. **One self-checking testbench** — for the core module. May be manual
       or AI-generated-then-corrected.
    4. **PPA snapshot** — `yosys stat` for top-level: LUT count, FF count,
       % iCE40 utilization. Two sentences on what uses the most resources.
    5. **AI interaction log** — one AI testbench/code generation example
       with annotations: prompt, output, corrections.

    ---

    ## Grading

    | Component | Weight |
    |-----------|--------|
    | Working hardware demo | 35% |
    | Code quality & conventions | 20% |
    | Testbench + verification | 20% |
    | PPA snapshot + AI log | 15% |
    | Live demo presentation | 10% |

    ---

    ## Tips

    - **Start with the FSM.** Every project has a control FSM. Get that
      working first, then add data path and I/O.
    - **Reuse course modules.** `debounce`, `hex_to_7seg`, `counter_mod_n`,
      `uart_tx` — these are in the shared library. Copy them into your
      project directory.
    - **Test early.** A testbench for your FSM catches 80% of bugs before
      you ever touch hardware.
    - **Ask the AI.** Use AI to generate test stimulus, not design code.
      You learn more by designing yourself and verifying with AI.
    """)

# ── Visit prep materials ────────────────────────────────────────────────────
VISIT_PREPS = {
    "semidynamics": dedent("""\
        # Academic Visit: Semidynamics

        **Date:** Monday, June 1 · 4:00–5:30 PM
        **Address:** Avinguda de Josep Tarradelles, 20, Barcelona
        **Meet:** 3:50 PM at Semidynamics entrance

        ---

        ## About Semidynamics

        Founded in 2016 in Barcelona, Semidynamics designs RISC-V processors
        optimized for AI workloads. Their customizable CPU cores cut memory
        bottlenecks so machine learning models run faster with less energy.
        Everything is built on the open RISC-V standard.

        ---

        ## Pre-Visit Framing (covered in morning class)

        🌍 **Connection to today's class:** "The counters, shift registers, and
        testbenches you built this morning are the same building blocks inside
        every RISC-V pipeline stage Semidynamics ships."

        ---

        ## Observation Questions

        As you tour, look for answers to:

        1. **Where are the FSMs?** Ask about pipeline control, bus arbitration,
           or cache controllers. What states do they have?
        2. **How do they verify?** What fraction of their effort is verification
           vs. design? Do they use simulation, formal methods, or both?
        3. **What's parameterized?** RISC-V is modular — how do they configure
           cores for different customers?

        ---

        ## CRAFT Reflection (due before next class)

        Write 1 page max:

        1. 🌍 **What did you see?** Describe one system or process.
        2. ⚠️ **What surprised you?** What contradicted your expectations?
        3. 🔧 **What connects?** Which course concepts did you recognize?
        4. 🔗 **What's next?** How does this shift your thinking?
        """),

    "hp": dedent("""\
        # Academic Visit: Hewlett Packard Customer Center

        **Date:** Tuesday, June 2 · Afternoon (time TBD)
        **Meet:** Outside HP Barcelona office

        ---

        ## About HP Barcelona

        HP's Customer Center showcases AI-driven tools and solutions
        transforming work — from intelligent print management to
        AI-assisted productivity across office, home, and mobile.

        ---

        ## Pre-Visit Framing (covered in morning class)

        🌍 **Connection to today's class:** "We just used AI to transform how
        we write testbenches. HP is using AI to transform how people work.
        Same pattern: human expertise + AI scaffolding."

        ---

        ## Observation Questions

        1. **Where is AI assisting, not replacing?** What decisions do humans
           still make?
        2. **What's the hardware underneath?** HP ships physical products —
           where does digital design fit?
        3. **How do they validate?** When AI makes a recommendation, how do
           they verify it's correct?

        ---

        ## CRAFT Reflection (due before next class)

        1. 🌍 **What did you see?**
        2. ⚠️ **What surprised you?**
        3. 🔧 **What connects?**
        4. 🔗 **What's next?**
        """),

    "metro": dedent("""\
        # Academic Visit: Barcelona Metro Control Room

        **Date:** Monday, June 15 · 10:00 AM
        **Location:** Sagrera neighborhood (exact address provided by API)

        ---

        ## About the Metro Control Room

        The operational brain of Barcelona's Metro network. Specialists
        monitor and manage all train lines — both conventional and fully
        automated — 24/7 to ensure safety and service regularity.

        ---

        ## Pre-Visit Framing (assigned end of Thu 6/11 class)

        🌍 **Connection to course:** "The Metro's automated lines run on
        digital control systems. Everything you've built — FSMs, serial
        communication, memory, timing — is running a city's transit."

        ---

        ## Observation Questions

        1. **Where are the FSMs?** Train door control, signal systems,
           route switching — what states do they have?
        2. **Where is serial communication?** Train-to-control-center
           links, sensor networks, display systems.
        3. **Where is memory?** Schedules, real-time position data,
           historical logs.
        4. **What happens when timing fails?** Ask about safety interlocks
           and fail-safe modes.

        ---

        ## CRAFT Reflection (due at start of Tue 6/16 class)

        1. 🌍 **What did you see?**
        2. ⚠️ **What surprised you?**
        3. 🔧 **What connects?** — name at least 3 specific course concepts
        4. 🔗 **What's next?**
        """),

    "riscv_lecture": dedent("""\
        # Guest Lecture: RISC-V — David Castells Rufas

        **Date:** Wednesday, June 17 · 10:00 AM
        **Location:** IL3 classroom
        **Speaker:** David Castells Rufas, Dept. of Microelectronics and
        Electronic Systems, Universitat Autònoma de Barcelona

        ---

        ## About the Speaker

        David is a RISC-V expert in the Department of Microelectronics and
        Electronic Systems at UAB. His research focuses on RISC-V
        applications and implementations.

        ---

        ## Pre-Lecture Prep (assigned end of Tue 6/16 class)

        🌍 **Connection to course:** "David designs RISC-V processors in
        the same HDL you've been writing for four weeks. This lecture is
        where your skills connect to processor architecture."

        Come with **2 prepared questions** about how course concepts apply
        to processor design. Examples:
        - "How do you use parameterized modules in your RISC-V cores?"
        - "What does your verification flow look like?"
        - "How do you make area/performance trade-offs?"

        ---

        ## During the Lecture

        Note connections to course concepts:
        - [ ] FSMs (pipeline control, instruction decode)
        - [ ] Parameterization (configurable cores)
        - [ ] Memory (register file, caches)
        - [ ] Timing (pipeline stages, clock frequency)
        - [ ] Verification (how they test)

        ---

        ## Role in CRAFT Arc

        This is the course's **capstone 🌍 Contextualize + 🔗 Transfer
        moment.** "You now have the foundation to understand and contribute
        to what David does. The path from your first `hello_led` module to
        a RISC-V core is a matter of scale, not fundamentally different
        skills."
        """),
}

# ── CRAFT overlay per teaching day ──────────────────────────────────────────
# Short annotations that reference baseline content + add CRAFT framing
def craft_overlay(day_label, date, contextualize, reframe, key_insight,
                  check_the_machine, transfer, visit_note=""):
    """Generate a CRAFT overlay markdown for one teaching day."""
    visit_section = ""
    if visit_note:
        visit_section = f"\n---\n\n## Visit/Activity Connection\n\n{visit_note}\n"
    return dedent(f"""\
        # CRAFT Overlay — {day_label}

        **Date:** {date}

        ---

        ## 🌍 Contextualize

        {contextualize}

        ## ⚠️ Reframe

        {reframe}

        ## 🔑 Key Insight

        {key_insight}

        ## 🤖 Check the Machine

        {check_the_machine}

        ## 🔗 Transfer

        {transfer}
        {visit_section}
        ---

        *This overlay supplements the baseline daily plan. All lab exercises
        and lecture content come from the baseline D-day materials.*
        """)

CRAFT_OVERLAYS = {
    "day01": craft_overlay(
        "D1 — Welcome to Hardware Thinking", "Mon 5/25",
        '"You\'re learning HDL in a city built by Gaudí — an architect who thought in parallel structures and modular repetition. Hardware description is the same discipline: you describe things that exist simultaneously."',
        '"If You\'re Thinking Like a Programmer: HDL is just another programming language. **Reframe:** HDL describes physical hardware that runs in parallel. Every `assign` is a wire. Every `always` block is a circuit."',
        '"In software, instructions execute one at a time. In hardware, everything happens at once. This is the single most important shift in thinking for this course."',
        '(None — Day 1 is pre-AI-thread. Introduce the concept: "Starting Day 4, we\'ll use AI as a verification tool.")',
        '"Tomorrow: the building blocks — data types, vectors, operators. The vocabulary of hardware description."',
    ),
    "day02": craft_overlay(
        "D2 — Data Types, Vectors & Operators", "Tue 5/26",
        '"Binary data is in everything digital around you — your phone, the metro ticket reader, the airport baggage scanner. Today you learn how HDL represents that data."',
        '"If You\'re Thinking Like a Programmer: variables are storage boxes you put values into. **Reframe:** `wire` is a physical connection — it doesn\'t store anything. `reg` is a storage element, not a variable."',
        '"In Verilog, the name `reg` is misleading. It doesn\'t mean register — it means \'the simulator needs to remember this value.\' SystemVerilog fixes this with `logic`."',
        '(None — pre-AI-thread)',
        '"Tomorrow: combinational logic — making decisions in hardware with `always @(*)`, `if`, and `case`. Plus you\'ll see your first synthesis output."',
    ),
    "day03": craft_overlay(
        "D3 — Combinational Logic & always@(*)", "Wed 5/27",
        '"Real-time decision systems use combinational logic — the kind that produces an output the instant inputs change. The structural calculations that kept the Sagrada Familia standing? Combinational. You\'ll see it this afternoon."',
        '"If You\'re Thinking Like a Programmer: `if/else` is the same as in C. **Reframe:** `if/else` synthesizes to priority-encoded mux chains. `case` synthesizes to parallel muxes. They have different hardware costs — see it in the Yosys schematic."',
        '"Incomplete sensitivity lists and missing else branches cause latch inference — the #1 synthesis bug for beginners. `always @(*)` and full case coverage prevent it."',
        '(None — pre-AI-thread)',
        '"Friday: clocked logic — the `posedge` that makes sequential circuits possible. After that, you can build anything."',
        visit_note="**PM: Sagrada Familia** — Gaudí's structural models were essentially combinational: load in, shape out, no memory of sequence. Notice the branching geometry — it's a physical if/else tree."
    ),
    "day04": craft_overlay(
        "D4 — Clocked Logic & RTL Thinking", "Fri 5/29",
        '"Clocked systems are everywhere in Barcelona: the traffic lights you cross, the Metro schedule, the airport departure boards. Every one runs on a clock edge."',
        '"If You\'re Thinking Like a Programmer: code executes top to bottom. **Reframe:** Everything inside an `always @(posedge clk)` block describes what happens on a single clock edge — simultaneously. The order of nonblocking assignments doesn\'t matter."',
        '"Blocking (`=`) vs. nonblocking (`<=`) is not a style choice. Use `=` in combinational, `<=` in sequential. Mixing them causes simulation-synthesis mismatch."',
        '"Ask an AI to explain the difference between blocking and nonblocking assignments. Does its explanation match what you just learned? Where is it imprecise?"',
        '"You can now build anything that happens on a clock edge. This weekend, watch the D5+D6 pre-class videos (counters + testbenches). Monday: build sequential circuits AND verify them."',
    ),
    "day07": craft_overlay(
        "D7 — Finite State Machines", "Tue 6/2",
        '"FSMs control everything from vending machines to the Metro\'s automated train doors. The HP engineers you\'ll visit this afternoon use FSMs in their product firmware."',
        '"If You\'re Thinking Like a Programmer: an FSM is a switch statement in a while loop. **Reframe:** An FSM is physical flip-flops holding state + combinational logic computing next state + combinational logic computing outputs. The 3-block pattern separates these three concerns."',
        '"The 3-block FSM pattern (state register, next-state logic, output logic) isn\'t just a coding style — it maps directly to the three physical components of the circuit."',
        '"Prompt AI: \'Generate a Verilog FSM for a traffic light controller with pedestrian button.\' Does it use the 3-block pattern? If not, what pattern does it use? Refactor it."',
        '"Tomorrow: hierarchy and parameters — making your FSMs and counters reusable. Then memory on Thursday."',
        visit_note="**PM: HP Barcelona** — Ask about AI-assisted design tools. How is AI changing their product development workflow?"
    ),
    "day08": craft_overlay(
        "D8 — Hierarchy, Parameters & Generate", "Wed 6/3",
        '"Parameterized design is how companies build IP libraries. Semidynamics doesn\'t redesign their RISC-V core for each customer — they parameterize it."',
        '"If You\'re Thinking Like a Programmer: copy-paste is reuse. **Reframe:** Parameterized modules + `generate` create hardware at elaboration time, not at runtime. `generate for` unrolls into parallel hardware."',
        '"`generate` doesn\'t loop at runtime — it creates hardware at synthesis time. A `generate for` with N=4 creates 4 physical instances, not one instance used 4 times."',
        '"Prompt AI to generate a parameterized N-bit comparator with `generate`. Does it use `generate` correctly? Synthesize at WIDTH=8, 16, 32 and compare `yosys stat` — is area scaling linear?"',
        '"Tomorrow: memory — where your data lives. ROM, RAM, and the coding patterns that make Yosys infer block RAM instead of burning all your LUTs."',
        visit_note="**Evening: Cooking Workshop** — A recipe is sequential (step by step). A kitchen with multiple cooks is parallel — like HDL."
    ),
    "day09": craft_overlay(
        "D9 — Memory: RAM, ROM & Block RAM", "Thu 6/4",
        '"Memory is in every system you interact with. Your phone\'s frame buffer, the Metro\'s schedule lookup tables, the airport\'s flight display. Today you learn how to describe memory in HDL."',
        '"If You\'re Thinking Like a Programmer: memory is just an array. **Reframe:** Memory has physical constraints — read latency (synchronous vs async), port count (single vs dual), initialization (`$readmemh`). And coding patterns determine whether Yosys infers efficient block RAM (EBR) or wastes all your LUTs on distributed RAM."',
        '"The iCE40 has 16 EBR blocks — that\'s 64 Kbits of free, fast memory. But only if your code matches the inference pattern: synchronous read, registered address."',
        '"Prompt AI: \'Write a dual-port RAM in Verilog for Lattice iCE40.\' Does it produce code that Yosys will infer as EBR? Synthesize and check `yosys stat` for `SB_RAM40_4K` instances."',
        '"This weekend: watch the D10 video on timing and numerical architectures. Monday: the constraints that make real systems work — setup, hold, Fmax, and PPA."',
    ),
    "day10": craft_overlay(
        "D10 — Timing, Numerical Architectures & PPA", "Mon 6/8",
        '"Every interface you\'ll build this week depends on timing. The Barcelona Metro you\'ll visit next week runs on precisely timed digital control — a missed deadline means a safety stop."',
        '"If You\'re Thinking Like a Programmer: faster clock = better. **Reframe:** Your design has a maximum clock frequency (Fmax) determined by the longest combinational path. Timing closure means every path must meet setup and hold constraints."',
        '"PPA — Power, Performance, Area — is the fundamental trade-off in all digital design. You can always trade area for speed (pipeline) or speed for area (resource sharing). `yosys stat` + `nextpnr` Fmax give you the numbers."',
        '"Synthesize two versions of a multiplier: combinational (`a * b`) and shift-and-add (sequential FSM). Compare PPA. Which wins on area? Which on Fmax? When would you choose each?"',
        '"Tomorrow: UART — your first communication interface. You\'ll use everything: FSMs, counters, shift registers, and timing."',
    ),
    "day12_sv_design": craft_overlay(
        "D12 — SystemVerilog for Design", "Wed 6/10",
        '"SystemVerilog is what you\'ll write in your first hardware job. Every major EDA tool, every ASIC flow, every FPGA vendor supports it. Today you upgrade your toolkit."',
        '"If You\'re Thinking Like a Programmer: SV is a different language I have to learn from scratch. **Reframe:** SV is Verilog with guardrails. `always_ff` doesn\'t change what the hardware does — it catches mistakes sooner. `logic` replaces both `wire` and `reg` and eliminates a whole class of confusion."',
        '"`always_comb` and `always_ff` are not just style — they\'re *intent declarations*. The tool checks that your code matches your intent. A latch in `always_comb` is an error, not a warning."',
        '"Refactor your traffic light FSM to SystemVerilog. Then prompt AI to refactor a different module. Compare: did the AI use `enum` for states? Did it add `default` cases? Did it use `always_ff` correctly?"',
        '"Tomorrow: SV for verification — assertions, coverage, and the tools that tell you when you\'re done testing."',
        visit_note="**PM: Park Güell** — Gaudí's modular tile system = parameterized design. Repeating patterns with variation = `generate` blocks."
    ),
    "day13_sv_verif": craft_overlay(
        "D13 — SystemVerilog for Verification", "Thu 6/11",
        '"Assertions are executable specifications. In industry, the verification engineer writes assertions *before* the designer writes RTL. When the design violates a property, the assertion fires immediately — not after hours of waveform debugging."',
        '"If You\'re Thinking Like a Programmer: testing is something you do at the end. **Reframe:** Assertions live *inside* your design. They fire the instant something goes wrong. They\'re not tests — they\'re contracts."',
        '"An assertion that never fires might mean your design is correct — or it might mean your testbench never exercises that path. Coverage tells you which."',
        '"Prompt AI to add 5 assertions to your UART TX module. Run them. Do any fire? Then ask AI to generate stimulus that *should* trigger each assertion. This is constraint-based testing."',
        '"Next week: Metro visit Monday, project build Tuesday, RISC-V lecture Wednesday, demos Thursday. Your project scope is locked — start building tonight."',
    ),
}


# ── File creation ───────────────────────────────────────────────────────────

def write_file(path: Path, content: str):
    """Write file (or print in dry-run mode)."""
    if DRY_RUN:
        print(f"  [DRY RUN] Would create: {path.relative_to(REPO)}")
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        print(f"  Created: {path.relative_to(REPO)}")


def main():
    mode = "DRY RUN" if DRY_RUN else "APPLYING"
    print(f"\n{'='*60}")
    print(f"  Barcelona Overlay Scaffold — {mode}")
    print(f"{'='*60}\n")

    # ── 1. Barcelona overlay directory ──────────────────────────────
    print("1. Creating barcelona/ overlay structure...")
    bcn = REPO / "barcelona"

    # Schedule overview (the adaptation doc)
    write_file(bcn / "README.md",
        "# Barcelona Abroad Adaptation\n\n"
        "This directory contains all Barcelona-specific overlay materials.\n"
        "The baseline 16-day course is not modified.\n\n"
        "See `barcelona_adaptation_v2.md` in this directory for the full\n"
        "adaptation plan, CRAFT mapping, and assessment adjustments.\n")

    # Merged session plans
    write_file(bcn / "sessions" / "d05_d06_merged_plan.md", D5_D6_MERGED_PLAN)
    write_file(bcn / "sessions" / "d11_condensed_plan.md", D11_CONDENSED_PLAN)

    # Visit prep materials
    for name, content in VISIT_PREPS.items():
        write_file(bcn / "visits" / f"{name}.md", content)

    # CRAFT overlays per teaching day
    for day_key, content in CRAFT_OVERLAYS.items():
        write_file(bcn / "craft" / f"{day_key}_craft.md", content)

    # CRAFT session template (shared reference)
    write_file(bcn / "craft" / "session_template.md", CRAFT_SESSION_TEMPLATE)

    # ── 2. MkDocs-accessible source files ──────────────────────────
    print("\n2. Creating MkDocs source files in docs/...")

    # Barcelona schedule page (symlinked into docs_src by prep_mkdocs)
    schedule_md = dedent("""\
        # Barcelona Schedule

        ## Summer 2026 — HDL for Digital System Design Abroad

        This page shows the Barcelona-adapted course calendar. The baseline
        16-day curriculum maps onto 14 teaching sessions plus academic visits
        and a guest lecture.

        For the full adaptation plan, see the
        [Barcelona Adaptation Document](https://github.com/ucf-draco-mike/hdl-for-dsd/blob/main/barcelona/README.md).

        ---

        ## Calendar Overview

        ### Week 1: Verilog Foundations (May 25–29)

        | Date | Type | Session |
        |------|------|---------|
        | Mon 5/25 | Class | D1: Welcome to Hardware Thinking |
        | Tue 5/26 | Class | D2: Data Types, Vectors & Operators |
        | Wed 5/27 | Class | D3: Combinational Logic · PM: Sagrada Familia |
        | Thu 5/28 | Excursion | Montserrat Day Trip |
        | Fri 5/29 | Class | D4: Clocked Logic & RTL Thinking |

        ### Week 2: Sequential Design & Verification (Jun 1–5)

        | Date | Type | Session |
        |------|------|---------|
        | Mon 6/1 | **Merged** | D5+D6: Counters, Testbenches & AI Verif · PM: Semidynamics |
        | Tue 6/2 | Class | D7: FSMs · PM: HP Barcelona |
        | Wed 6/3 | Class | D8: Hierarchy & Parameters · Eve: Cooking |
        | Thu 6/4 | Class | D9: Memory Systems |
        | Fri 6/5 | **Free** | Independent study / explore Barcelona |

        ### Week 3: Timing, UART & SystemVerilog (Jun 8–12)

        | Date | Type | Session |
        |------|------|---------|
        | Mon 6/8 | Class | D10: Timing & Numerical Architectures |
        | Tue 6/9 | **Condensed** | D11: UART TX (RX = stretch) · Eve: Flamenco |
        | Wed 6/10 | Class | D12: SV for Design · PM: Park Güell |
        | Thu 6/11 | Class | D13: SV for Verification |
        | Fri 6/12 | **Free** | Independent project work |

        ### Week 4: Integration & Demonstration (Jun 15–19)

        | Date | Type | Session |
        |------|------|---------|
        | Mon 6/15 | Visit | Barcelona Metro Control Room |
        | Tue 6/16 | Class | D14: Project Build Day |
        | Wed 6/17 | Guest | RISC-V Lecture — David Castells Rufas |
        | Thu 6/18 | Class | D15: Demos & Course Wrap |
        | Fri 6/19 | **Free** | Departure / free day |

        ---

        ## Key Dates

        - **Project selection:** Thu 6/4
        - **Core module due:** Thu 6/11
        - **Build day:** Tue 6/16
        - **Demo day:** Thu 6/18
        """)
    write_file(REPO / "docs" / "barcelona_schedule.md", schedule_md)
    write_file(REPO / "docs" / "barcelona_project.md", BARCELONA_PROJECT)

    # ── 3. prep_mkdocs.py patch instructions ───────────────────────
    print("\n3. Patch instructions for prep_mkdocs.py:")
    print("""
    Add these to the top-level symlink list in prep_mkdocs.py
    (inside the `for name, src in [...]` block):

        ("barcelona-schedule.md", REPO / "docs" / "barcelona_schedule.md"),
        ("barcelona-project.md",  REPO / "docs" / "barcelona_project.md"),

    Add to mkdocs.yml nav:

        - Barcelona:
            - Schedule: barcelona-schedule.md
            - Project Spec: barcelona-project.md
    """)

    # ── 4. Summary ─────────────────────────────────────────────────
    bcn_files = list(bcn.rglob("*.md")) if not DRY_RUN else []
    docs_files = [REPO / "docs" / "barcelona_schedule.md",
                  REPO / "docs" / "barcelona_project.md"]

    print(f"\n{'='*60}")
    print(f"  Summary")
    print(f"{'='*60}")
    print(f"  barcelona/ overlay files:  {len(CRAFT_OVERLAYS) + len(VISIT_PREPS) + 4}")
    print(f"  docs/ MkDocs sources:      2")
    print(f"  Merged session plans:      2 (D5+D6, D11 condensed)")
    print(f"  Visit prep materials:      {len(VISIT_PREPS)}")
    print(f"  CRAFT overlays:            {len(CRAFT_OVERLAYS)}")
    print(f"  Manual patches needed:     2 (prep_mkdocs.py + mkdocs.yml)")

    if DRY_RUN:
        print(f"\n  Re-run with --apply to create files.")
    else:
        print(f"\n  All files created. Now:")
        print(f"  1. Copy barcelona_adaptation_v2.md into barcelona/")
        print(f"  2. Apply the prep_mkdocs.py + mkdocs.yml patches above")
        print(f"  3. Run: python3 scripts/prep_mkdocs.py")
        print(f"  4. Run: mkdocs serve")
    print()


if __name__ == "__main__":
    main()
