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

## Project Grading

The final project is worth **35% of the course grade**. Within the
project, components are weighted as follows:

| Component | Weight |
|-----------|--------|
| Working hardware demo | 35% |
| Code quality & conventions | 20% |
| Testbench + verification | 20% |
| PPA snapshot + AI log | 15% |
| Live demo presentation | 10% |

For the full course grading breakdown, see the
[Barcelona Day Plan](../barcelona/).

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
