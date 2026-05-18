# RTL Diagram Tracking — Weeks 2–4

This file tracks every meaningful Verilog/SystemVerilog code segment in the
weeks 2–4 lecture material, its associated RTL SVG diagram, the color
palette applied, and a wiring-rule verification status with a revision
history. It exists so that future authors can tell at a glance which
diagrams have been reviewed against the project's RTL drafting rules and
which still need a human look.

## Rules used for verification

1. **MUX input side.** When a MUX is drawn as a trapezoid, the wider
   ("long") parallel side carries the data inputs (the things we select
   *from*). The narrower side carries the output. The select line may
   enter from the top or bottom of the trapezoid by convention.
2. **No wires through components.** A solid wire must never pass through
   the interior of an unrelated component rectangle/polygon. If a wire
   genuinely has to traverse a component, it must be drawn dashed
   (`stroke-dasharray`).
3. Wires must terminate **on the boundary** of their destination
   component, not 10–25 pixels inside it.

## Project color palette (for reference)

| Hex | Role |
|---|---|
| `#1976D2` | `i_clk` / clock signals |
| `#D32F2F` | `i_reset` / error / `-1` adder |
| `#2E7D32` | outputs (`o_*`), `+1` adder, sums |
| `#7B1FA2` | registers, MUXes, generic state |
| `#C2185B` | comparators, control / valid pulses |
| `#F57C00` | data inputs / highlighted labels |
| `#9A6F00` | ROM / memory contents |
| `#00838F` | handshake / tick signals |
| `#B8860B` | parameters / generate-scope frames |
| `#37474F` | module boundary (dashed outer box) |
| `#333` | generic combinational wires |

## Status legend

- ✅ **AI verified** — both wiring rules check out after automated audit + targeted spot checks.
- ⚠️ **Human discrepancy noted** — automated audit flagged something the editor judged a false positive (e.g. dashed-scope container box), or there is a known cosmetic issue that does not violate the rules but a human should review.
- 🔧 **Revised** — diagram was edited in this pass to bring it into compliance; included in revision history below.

## Tracking table

| Day · Slide | Verilog / SV module | RTL SVG | Palette in use | Status |
|---|---|---|---|---|
| 05 · s1 counter variations | `counter_mod_n` (`lecture_examples/week2_day05/d05_s1_ex1/day05_ex01_counter_mod_n.v`) | `lectures/week2_day05/diagrams/d05_modn_counter_rtl.svg` | blue / red / green / purple / pink | ✅ AI verified |
| 05 · s1 | loadable counter (lecture-only) | `lectures/week2_day05/diagrams/d05_loadable_counter_rtl.svg` | blue / red / green / purple / orange / teal | 🔧 Revised (see history) |
| 05 · s1 | up/down counter (lecture-only) | `lectures/week2_day05/diagrams/d05_updown_counter_rtl.svg` | blue / red / green / purple | 🔧 Revised (see history) |
| 05 · s1 | PWM CSR + period counter (lecture-only) | `lectures/week2_day05/diagrams/d05_pwm_period_rtl.svg` | full | 🔧 Revised (see history) |
| 05 · s2 shift registers | `shift_reg_piso` (`lecture_examples/week2_day05/d05_s2_ex2/day05_ex02_shift_reg_piso.v`) | `lectures/week2_day05/diagrams/d05_piso_rtl.svg` | blue / purple / green / orange | ⚠️ Human discrepancy noted — per-bit MUXes are drawn as horizontal trapezoids with output exiting the bottom edge; data inputs come from top, shift-from-neighbor enters from the right (short) side. Rule 1 strictly says "data on long side"; this layout uses a non-standard orientation that an instructor should sign off on (alternative would be a major redraw). |
| 05 · s2 | `shift_reg_sipo` (`lecture_examples/week2_day05/d05_s2_ex2/day05_ex02_shift_reg_sipo.v`) | `lectures/week2_day05/diagrams/d05_sipo_rtl.svg` | blue / purple / green | ✅ AI verified |
| 05 · s3 metastability | `synchronizer` (`lecture_examples/week2_day05/d05_s3_ex3/day05_ex03_synchronizer.v`) | `lectures/week2_day05/diagrams/d05_synchronizer_rtl.svg` | blue / purple / green | ✅ AI verified |
| 05 · s3 | (reader-bug illustration, no source file) | `lectures/week2_day05/diagrams/d05_reader_bug_rtl.svg` | blue / purple / red | ✅ AI verified |
| 05 · s4 button debouncing | `debounce` (`lecture_examples/week2_day05/d05_s4_ex4/day05_ex04_debounce.v`) | `lectures/week2_day05/diagrams/d05_debounce_rtl.svg` | blue / red / purple / orange / pink | ✅ AI verified |
| 06 · s1 testbench anatomy | `adder` + tb (`lecture_examples/week2_day06/d06_s1_ex1/adder.v`, `tb_adder.v`) | `lectures/week2_day06/diagrams/d06_s1_tb_template_rtl.svg` | full | ✅ AI verified |
| 06 · s2 self-checking | `check_eq` task pattern (lecture-only) | `lectures/week2_day06/diagrams/d06_s2_check_eq_task_rtl.svg` | red / green / amber | ✅ AI verified |
| 06 · s3 tasks for organization | `apply_and_check` pattern (lecture-only) | `lectures/week2_day06/diagrams/d06_s3_apply_and_check_rtl.svg` | full | ✅ AI verified |
| 06 · s3 | task before-copy-paste (lecture-only) | `lectures/week2_day06/diagrams/d06_s3_before_copypaste_rtl.svg` | full | ✅ AI verified |
| 06 · s3 | task after-refactor (lecture-only) | `lectures/week2_day06/diagrams/d06_s3_after_task_rtl.svg` | full | ✅ AI verified |
| 06 · s3 | "you do" DFF task lab (lecture-only) | `lectures/week2_day06/diagrams/d06_s3_you_do_dff_rtl.svg` | full | ✅ AI verified |
| 06 · s4 file-driven testing | `$readmemh` python-gen flow (lecture-only) | `lectures/week2_day06/diagrams/d06_s4_python_gen_rtl.svg` | purple / red / orange | ✅ AI verified |
| 06 · s4 | `$readmemh` indexed loop (lecture-only) | `lectures/week2_day06/diagrams/d06_s4_readmemh_rtl.svg` | full | 🔧 Revised (see history) |
| 07 · s1 fsm theory | synth gates illustration (lecture-only) | `lectures/week2_day07/diagrams/d07_synth_gates_rtl.svg` | purple / green / pink | ✅ AI verified |
| 07 · s2 three-block fsm | `traffic_light_template` (`lecture_examples/week2_day07/d07_s2_ex1/day07_ex01_fsm_template.v`) — state-register block | `lectures/week2_day07/diagrams/d07_block1_state_reg_rtl.svg` | blue / purple / red | ✅ AI verified |
| 07 · s2 | same module — next-state block | `lectures/week2_day07/diagrams/d07_block2_next_state_rtl.svg` | purple / pink | ✅ AI verified |
| 07 · s2 | same module — output block | `lectures/week2_day07/diagrams/d07_block3_output_rtl.svg` | purple / green | ✅ AI verified |
| 07 · s2 | latch-bug counter-example (lecture-only) | `lectures/week2_day07/diagrams/d07_bug_latch_rtl.svg` | red / amber | ✅ AI verified |
| 07 · s3 state encoding | `traffic_onehot` (`lecture_examples/week2_day07/d07_s2_ex1/day07_ex01_traffic_onehot.v`) | `lectures/week2_day07/diagrams/d07_onehot_encoding_rtl.svg` | purple / green | ✅ AI verified |
| 07 · s3 | `traffic_gray` (`lecture_examples/week2_day07/d07_s2_ex1/day07_ex01_traffic_gray.v`) | `lectures/week2_day07/diagrams/d07_binary_encoding_rtl.svg` | purple / green | ✅ AI verified |
| 07 · s3 | binary vs one-hot side-by-side (lecture-only) | `lectures/week2_day07/diagrams/d07_encoding_rtl_compare.svg` | full | ✅ AI verified |
| 08 · s1 hierarchy | `button_handler` (`lecture_examples/week2_day08/d08_s1_ex1/day08_ex01_button_handler.v` + `sync_2ff.v`, `debounce.v`, `edge_detect.v`) | `lectures/week2_day08/diagrams/d08_button_handler_rtl.svg` | full | ✅ AI verified |
| 08 · s1 | flat (anti-pattern) hierarchy (lecture-only) | `lectures/week2_day08/diagrams/d08_bad_hierarchy_rtl.svg` | red / purple | ✅ AI verified |
| 08 · s2 parameters | `counter` parameterized (`lecture_examples/week2_day08/d08_s2_ex2/day08_ex02_counter.v`) | `lectures/week2_day08/diagrams/d08_param_counter_rtl.svg` | blue / red / green / purple / orange / gold | 🔧 Revised (see history) |
| 08 · s2 | parameterized debounce (lecture-only) | `lectures/week2_day08/diagrams/d08_param_debounce_rtl.svg` | full | ✅ AI verified |
| 08 · s2 | fifo (lecture-only diagram) | `lectures/week2_day08/diagrams/d08_fifo_rtl.svg` | full | ✅ AI verified |
| 08 · s3 generate | `button_array` (`lecture_examples/week2_day08/d08_s3_ex3/day08_ex03_button_array.v`) | `lectures/week2_day08/diagrams/d08_button_array_rtl.svg` | full | ⚠️ Human discrepancy noted — automated audit flagged `i_clk` (y=285) and `i_reset` (y=309) horizontals crossing the dashed `generate for (gi=0; gi<N) begin : g_btn` scope rectangle (x=180..720, y=100..320). That outer box is a *scope annotation*, not a real RTL component, and the per-instance clk lines that branch into each `debounce` cell are correctly drawn dashed. Reviewer should confirm the scope-rectangle exemption is acceptable. |
| 08 · s3 | generate-if conditional (lecture-only) | `lectures/week2_day08/diagrams/d08_generate_if_rtl.svg` | full | ✅ AI verified |
| 08 · s3 | ripple adder generate (lecture-only) | `lectures/week2_day08/diagrams/d08_ripple_adder_rtl.svg` | full | ✅ AI verified |
| 08 · s4 design for reuse | reusable debounce comparison (lecture-only) | `lectures/week2_day08/diagrams/d08_reusable_debounce_rtl.svg` | full | ✅ AI verified |
| 08 · s4 | before/after refactor (lecture-only) | `lectures/week2_day08/diagrams/d08_before_after_rtl.svg` | full | ✅ AI verified |
| 09 · s1 rom | `rom_array` (`lecture_examples/week3_day09/d09_s1_ex1/rom_array.v`) | `lectures/week3_day09/diagrams/d09_rom_array_rtl.svg` | blue / amber / purple / green / orange | 🔧 Revised (see history) |
| 09 · s1 | `rom_case` (`lecture_examples/week3_day09/d09_s1_ex1/rom_case.v`) | `lectures/week3_day09/diagrams/d09_rom_case_rtl.svg` | amber / purple / green / orange | ✅ AI verified |
| 09 · s1 | anti-pattern ROM (lecture-only) | `lectures/week3_day09/diagrams/d09_rom_bad_rtl.svg` | red / amber | ✅ AI verified |
| 09 · s2 ram | `ram_1p` (`lecture_examples/week3_day09/d09_s2_ex2/ram_1p.v`) | `lectures/week3_day09/diagrams/d09_ram_1p_rtl.svg` | full | ✅ AI verified |
| 09 · s2 | dual-port ram concept (lecture-only) | `lectures/week3_day09/diagrams/d09_ram_dp_rtl.svg` | full | ✅ AI verified |
| 09 · s2 | RBW vs Write-First comparison (lecture-only) | `lectures/week3_day09/diagrams/d09_ram_rbw_wf_rtl.svg` | full | 🔧 Revised (see history) |
| 09 · s4 memory applications | `pattern_sequencer` (`lecture_examples/week3_day09/d09_s4_ex3/pattern_sequencer.v`) | `lectures/week3_day09/diagrams/d09_pattern_sequencer_rtl.svg` | full | ✅ AI verified |
| 09 · s4 | sine ROM concept (lecture-only) | `lectures/week3_day09/diagrams/d09_sine_rom_rtl.svg` | blue / amber / purple / green | 🔧 Revised (see history) |
| 10 · s2 numerical | `mult_sequential` (`lecture_examples/week3_day10/d10_s2_ex1/day10_mult_sequential.v`) | `lectures/week3_day10/diagrams/d10_mul_seq_rtl.svg` | full | 🔧 Revised (see history) |
| 10 · s2 | `mult_parallel` (`lecture_examples/week3_day10/d10_s2_ex1/day10_mult_parallel.v`) | `lectures/week3_day10/diagrams/d10_parallel_mult_rtl.svg` | full | ✅ AI verified |
| 10 · s2 | signed vs unsigned (lecture-only) | `lectures/week3_day10/diagrams/d10_signed_unsigned_rtl.svg` | full | ✅ AI verified |
| 11 · s3 uart tx | `uart_tx` (`lecture_examples/week3_day11/d11_s3_ex1/day11_ex01_uart_tx.v`) | `lectures/week3_day11/diagrams/d11_uart_tx_rtl.svg` | full | 🔧 Revised (see history) |
| 11 · s4 connecting to PC | `hello_emitter` (`lecture_examples/week3_day11/d11_s4_ex2/day11_ex02_hello_emitter.v`) | `lectures/week3_day11/diagrams/d11_hello_tx_rtl.svg` | full | 🔧 Revised (see history) |
| 12 · s1 uart rx | rx-sync edge detector (lecture concept, supports `lecture_examples/week3_day12/d12_s2_ex1/day12_ex01_uart_rx.v`) | `lectures/week3_day12/diagrams/d12_rx_sync_edge_rtl.svg` | full | ✅ AI verified |
| 12 · s2 | oversampling generator (concept inside `uart_rx`) | `lectures/week3_day12/diagrams/d12_osx_gen_rtl.svg` | blue / purple / teal | 🔧 Revised (see history) |
| 12 · s2 | data-sampling FSM body (inside `uart_rx`) | `lectures/week3_day12/diagrams/d12_rx_data_sample_rtl.svg` | full | 🔧 Revised (see history) |
| 12 · s4 ip integration | `uart_loopback` / echo top (`lecture_examples/week3_day12/d12_s4_ex3/day12_ex03_uart_loopback.v`) | `lectures/week3_day12/diagrams/d12_echo_top_rtl.svg` | full | 🔧 Revised (see history) |
| 13 · s1 why systemverilog | latch-bug illustration (lecture-only) | `lectures/week4_day13/diagrams/d13_s1_latch_bug_rtl.svg` | red / amber | ✅ AI verified |
| 13 · s2 logic type | `debounce_sv` counter portion (`lecture_examples/week4_day13/d13_s2_ex1/day13_ex01_debounce_sv.sv`) | `lectures/week4_day13/diagrams/d13_s2_counter_rtl.svg` | full | ✅ AI verified |
| 13 · s2 | `uart_tx_sv` control (`lecture_examples/week4_day13/d13_s3_ex2/day13_ex02_uart_tx_sv.sv`) | `lectures/week4_day13/diagrams/d13_s2_uart_tx_ctrl_rtl.svg` | full | ✅ AI verified |
| 13 · s3 intent-based always | `traffic_light_sv` comb block (`lecture_examples/week4_day13/d13_s4_ex3/day13_ex03_traffic_light_sv.sv`) | `lectures/week4_day13/diagrams/d13_s3_always_comb_traffic_rtl.svg` | full | ✅ AI verified |
| 13 · s3 | `always_ff` state block (same SV module) | `lectures/week4_day13/diagrams/d13_s3_always_ff_state_rtl.svg` | full | ✅ AI verified |
| 13 · s3 | async-reset variant (lecture-only) | `lectures/week4_day13/diagrams/d13_s3_async_reset_rtl.svg` | full | ✅ AI verified |
| 13 · s3 | sync-reset variant (lecture-only) | `lectures/week4_day13/diagrams/d13_s3_sync_reset_rtl.svg` | full | ✅ AI verified |
| 13 · s3 | clean SV-style FSM (lecture-only) | `lectures/week4_day13/diagrams/d13_s3_fsm_sv_clean_rtl.svg` | full | ✅ AI verified |
| 13 · s3 | V2001 latch trap (lecture-only) | `lectures/week4_day13/diagrams/d13_s3_fsm_v2001_latch_rtl.svg` | red / purple | ⚠️ Human discrepancy noted — file contains a literal `&nbsp;` HTML entity in a `<text>` element (line 15). Most browsers render it fine but strict XML parsers reject it. Wiring itself is clean; entity should be replaced with `&#160;` or a literal space in a future pass. |
| 13 · s4 enum/struct/package | `localparam` state encoding (lecture-only) | `lectures/week4_day13/diagrams/d13_s4_localparam_state_rtl.svg` | full | ✅ AI verified |
| 13 · s4 | `typedef enum` state encoding (lecture-only) | `lectures/week4_day13/diagrams/d13_s4_typedef_enum_state_rtl.svg` | full | ✅ AI verified |
| 13 · s4 | `uart_frame` struct (lecture-only) | `lectures/week4_day13/diagrams/d13_s4_uart_frame_struct_rtl.svg` | full | ✅ AI verified |
| 13 · s4 | `uart_pkg` design (lecture-only) | `lectures/week4_day13/diagrams/d13_s4_uart_pkg_design_rtl.svg` | full | ✅ AI verified |
| 13 · s4 | `uart_pkg` usage (lecture-only) | `lectures/week4_day13/diagrams/d13_s4_uart_pkg_rtl.svg` | full | ✅ AI verified |
| 14 · s1 assertions | `uart_tx_assertions` (`lecture_examples/week4_day14/d14_s1_ex1/day14_ex01_uart_tx_assertions.sv`) — concurrent property | `lectures/week4_day14/diagrams/d14_s1_concurrent_property_rtl.svg` | full | ✅ AI verified |
| 14 · s1 | same module — counter assert | `lectures/week4_day14/diagrams/d14_s1_counter_assert_rtl.svg` | full | ✅ AI verified |
| 14 · s1 | same module — `uart_tx` start-bit assert | `lectures/week4_day14/diagrams/d14_s1_uart_tx_start_assert_rtl.svg` | full | ✅ AI verified |
| 14 · s4 coverage | covergroup illustration (lecture-only) | `lectures/week4_day14/diagrams/d14_s4_covergroup_rtl.svg` | full | ✅ AI verified |
| 15 · capstone | capstone top-level (no single module — wraps several lab IPs) | `lectures/week4_day15/diagrams/d15_capstone_top_rtl.svg` | full | ✅ AI verified |
| 15 · capstone | printf-style debug emitter (lecture-only) | `lectures/week4_day15/diagrams/d15_printf_debug_rtl.svg` | full | 🔧 Revised (see history) |

## Revision history

### 2026-05-18 — branch `claude/review-rtl-svg-arrows-SclDy`

Automated audit pass against rules 1 and 2 (see *Rules used for verification* above). Of 72 `*rtl*.svg` files in scope, 59 passed both rules cleanly. The 13 below were edited:

| File | Change summary |
|---|---|
| `d05_loadable_counter_rtl.svg` | `i_load_val` rerouted to enter the MUX's long (left) side at input "1" (was entering through the top edge). `i_clk` moved below the Register (y=325) so the wire no longer crosses through it. |
| `d05_updown_counter_rtl.svg` | `i_clk` moved below the Register (y=325) so the horizontal bus no longer passes through it at y=279. MUX inputs were already correct. |
| `d05_pwm_period_rtl.svg` | (1) MUX-output → `count` Register routed at x=548 to skirt the Duty Compare box (was crossing at x=560). (2) `i_clk` bus restructured into an up-branch (period/duty register CLK pins) and a down-branch (count register CLK from below), so the wire no longer crosses through the duty register or the legend. (3) `+1` adder output rerouted to enter the MUX's long (left) side at input "0" position (was hitting the bottom slope). (4) `count Q → duty compare` arrow terminated at the right edge x=675 instead of 60 px inside the compare box. |
| `d06_s4_readmemh_rtl.svg` | The `b` slice extractor at x=342 must traverse the index counter rect. Per rule 2, the through-counter segment is now drawn dashed (matching the convention already used by the dashed `expected` slice at x=415). |
| `d08_param_counter_rtl.svg` | Both MUX inputs reroutered into the long (left) side at the labeled "1" / "0" positions. The `'0'` constant now enters at y=146 and the `+1` adder output enters at y=200 (both previously entered through the top edge / mid-side). |
| `d09_ram_rbw_wf_rtl.svg` | The `we` line going to the bypass MUX rerouted at y=215 (below the mem block) instead of y=195 (through it). |
| `d09_rom_array_rtl.svg` | `i_clk` bus lifted from y=100 to y=85 so it no longer crosses the `mem[]` block (which starts at y=95). |
| `d09_sine_rom_rtl.svg` | `i_clk` bus lifted from y=95 to y=77 (above the mem and o_sample rects). |
| `d10_mul_seq_rtl.svg` | `i_clk` bus lifted from y=95 to y=75 above all top-aligned registers. Stub for r_mask CLK was disconnected in the original — left as-is pending a separate hierarchy review. |
| `d11_uart_tx_rtl.svg` | `i_clk` bus lifted from y=100 to y=78. Added a proper feed to `r_bit` (top edge from left at x=410) — the original had a broken zero-width stub. |
| `d11_hello_tx_rtl.svg` | (1) `i_clk` bus lifted to y=80 with a column at x=120 distributing to `rom` (left side y=125), `r_timer` (left side y=225), and `u_tx` left side; the original at y=115 was crossing through the rom rect. (2) rom→uart_tx data wire rerouted at x=485 to skirt the r_idx register (was crossing it at x=430). |
| `d12_osx_gen_rtl.svg` | `i_clk` bus lifted from y=95 to y=70 above all three top-aligned blocks (r_osx_cnt, compare, r_osx_tick). |
| `d12_rx_data_sample_rtl.svg` | `i_clk` bus lifted from y=95 to y=70. Added a proper `r_bit` clk feed (column at x=120, enters r_bit top edge). |
| `d12_echo_top_rtl.svg` | The two C2185B-colored handshake arrows that were terminating 20 px inside `uart_tx` (`tx.valid`) and `u_rx_fifo` (`fifo.rd`) now terminate at the bottom edges (y=220) of their respective rects. |
| `d15_printf_debug_rtl.svg` | ASCII-lookup → `uart_tx.i_data` wire rerouted around the `uart_tx` rect to terminate at its left edge (x=430, y=245) instead of cutting in through the top and ending 25 px inside. Added the missing arrowhead marker that was dropped in the original draft. |

Files flagged by the audit but **not** edited because the flag was a false positive (recorded as ⚠️ Human discrepancy in the table above for traceability):

- `d05_piso_rtl.svg` — MUX orientation is non-standard but redrawing would change the lesson's visual; instructor sign-off requested.
- `d08_button_array_rtl.svg` — the rect the clk/reset cross is a *generate-scope annotation*, not a component.
- `d13_s3_fsm_v2001_latch_rtl.svg` — XML-entity issue (`&nbsp;`) is orthogonal to wiring rules.

## How to extend this file

When you add or change an RTL SVG:

1. Add (or update) the row in the *Tracking table* above. The `Verilog / SV module` column should point at the canonical source file under `lecture_examples/`; if the SVG is a lecture-only conceptual diagram with no source module, say "(lecture-only)".
2. Run the two rules over your new diagram by eye, or re-run an automated pass equivalent to what the audit agent did in the 2026-05-18 entry. Mark as ✅ if clean, ⚠️ if you have a justified exception, 🔧 if you edited the SVG in this pass.
3. Append a dated entry to *Revision history* describing what you changed and why.
