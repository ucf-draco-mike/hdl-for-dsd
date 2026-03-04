# Day 8 Lab: Hierarchy, Parameters & Generate

## Course: Accelerated HDL for Digital System Design — Week 2, Session 8

---

## Objectives

By the end of this lab, you will:
- Build a parameterized modulo-N counter and test it at 3+ configurations
- Use `generate for` to create multi-channel debounce infrastructure
- Assemble the most complex hierarchical system of the course so far
- (Stretch) Build a generic LFSR with width-dependent tap selection via `generate if`

## Prerequisites

- Watched Day 8 pre-class video (~45 min): hierarchy, parameters, generate
- All modules from Days 2–7 (provided in `starter/` for convenience)

## Deliverables

| # | Exercise | Time | What to Submit |
|---|----------|------|----------------|
| 1 | Parameterized Counter | 25 min | `counter_mod_n.v` + `tb_counter_mod_n.v` — 3 configs pass |
| 2 | Generate Multi-Debounce | 25 min | `go_board_input.v` + testbench |
| 3 | Hierarchical System | 30 min | `top_lab_instrument.v` — all buttons work, both displays |
| 4 | Generic LFSR (stretch) | 20 min | `lfsr_generic.v` — maximal-length at 3 widths |

**Primary deliverable:** Hierarchical design with 3+ levels, parameterized, running on Go Board.

---

## Exercise 1: Parameterized Counter Module (25 min)

**SLOs: 8.2, 8.3, 8.5**

Create `counter_mod_n.v` — a universal modulo-N counter with `$clog2` auto-sizing.

Use the starter file. Test at N=10, N=16, and N=60 in a single testbench.

**Required tests per configuration:**
1. Reset → count is 0
2. Count to max, verify wrap signal asserts at N-1
3. Count rolls over to 0 after wrap
4. Enable test: disable for 5 cycles, verify count holds

```bash
make sim TB=tb_counter_mod_n.v SRCS="counter_mod_n.v"
```

---

## Exercise 2: Generate-Based Multi-Debounce (25 min)

**SLO: 8.4**

Create `go_board_input.v` using `generate for` to stamp out N debounce + edge-detect channels.

Test with a top module that uses all 4 buttons for different counter operations.

---

## Exercise 3: Hierarchical System Integration (30 min)

**SLOs: 8.1, 8.6**

This is the **Week 2 capstone**. Build `top_lab_instrument.v` — a "digital lab instrument" integrating:

```
top_lab_instrument
├── go_board_input (4-channel debounce + edge detect)
│   └── debounce [×4] (via generate)
├── counter_mod_n #(.N(256)) (8-bit main counter)
├── hex_to_7seg (display 1 — lower nibble)
├── hex_to_7seg (display 2 — upper nibble)
├── lfsr_8bit (random number generator)
└── heartbeat LEDs
```

**Behavior:**
- Button 1: reset everything
- Button 2: increment counter
- Button 3: load LFSR value into counter
- Button 4: step LFSR (next random number)
- Display 1: lower 4 bits (hex)
- Display 2: upper 4 bits (hex)

---

## Exercise 4 (Stretch): Parameterized LFSR (20 min)

**SLOs: 8.2, 8.4, 8.5**

Create `lfsr_generic.v` with `generate if` for width-dependent tap selection. Verify maximal-length at WIDTH=4 (15 states), WIDTH=8 (255), WIDTH=16 (65535).
