# Where to Go From Here

## What You Built in 4 Weeks

### Module Library (~20-25 verified modules)

**Week 1 — Foundations:** mux_2to1, mux_4to1, alu_4bit, hex_to_7seg, d_flip_flop, register_N

**Week 2 — Robustness:** debounce, edge_detect, shift_reg_*, counter_mod_n, FSM templates, generate-based input pipeline

**Week 3 — Memory & Communication:** rom_sync, ram_sp, uart_tx, uart_rx, pattern_sequencer, baud_gen

**Week 4 — SystemVerilog & Integration:** Refactored modules with logic/always_ff/enum, assertion-enhanced RTL, final project system

### Skills Progression

| Skill | Week 1 | Week 2 | Week 3 | Week 4 |
|---|---|---|---|---|
| Design | Gates, muxes, FFs | FSMs, counters, shift regs | Memory, protocols | SV, integration |
| Verification | Waveforms | Self-checking TBs | Protocol-aware TBs | Assertions, coverage |
| Tools | iverilog, GTKWave | yosys, nextpnr | icepll, terminal | Verilator, full flow |
| Hardware | LED blink | Debounced buttons | UART to PC | Complete system |

---

## Keep Building

The Go Board is yours. Try next:

- **VGA output:** 640×480 character display with resistor-DAC or VGA PMOD
- **Audio synthesis:** PWM/delta-sigma through PMOD, generate tones from ROM
- **Pong:** VGA + button controls — classic FPGA project
- **Logic analyzer:** Capture and display digital signals via UART
- **RISC-V core:** Minimal RV32I (tight fit on HX1K — see PicoRV32)

## Open-Source Resources

- **Nandland.com** — Go Board tutorials (Russell Merrick, board creator)
- **fpga4fun.com** — Practical projects (UART, VGA, audio, SPI)
- **ZipCPU blog** — Deep technical articles (formal verification, buses, UART)
- **Lattice iCE40 docs** — Official datasheet and programming guide

## Career Pathways

| Path | What It Is | What You Need Next |
|---|---|---|
| **FPGA Engineering** | Digital systems on FPGAs — DSP, networking, defense | Larger FPGAs (Xilinx/Intel), vendor tools, high-speed I/O |
| **ASIC Design** | Chips in silicon — processors, GPUs, AI accelerators | Deep SV, synthesis theory, STA, physical design, DFT |
| **Verification** | Proving designs correct before manufacturing | UVM, constrained random, formal verification, coverage |
| **Hardware Security** | Side-channel attacks, fault injection, trojans | Crypto implementations, power analysis (DPA/CPA), secure design |
| **Embedded Systems** | HW/SW co-design — microcontrollers, SoCs, firmware | ARM Cortex-M, RTOS, bus protocols (AXI, Wishbone) |

## Recommended Next Courses

| Interest | Course | Why |
|---|---|---|
| Chip design | Computer Architecture | Pipelines, caches, memory hierarchy |
| FPGA engineering | Advanced Digital Design | Complex FSMs, DSP, high-speed I/O |
| Verification | Formal Methods | SVA, model checking, UVM |
| Security | Hardware Security | Side-channel analysis, secure design |
| Embedded | Embedded Systems | HW/SW co-design, RTOS |

## Connecting to Research

These course skills directly apply to: side-channel analysis hardware, hardware trojan detection, secure processor design, AI/ML hardware accelerators, and post-quantum cryptography implementations.

---

*The open-source FPGA toolchain you used was built by volunteers who believed this technology should be accessible to everyone. Pay it forward. Share what you've built. Help the next person stuck on their first testbench.*
