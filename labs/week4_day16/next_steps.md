# Where to Go From Here

## Get a Go Board — Projects to Try

| Project | What You'll Learn | Difficulty |
|---------|-------------------|-----------|
| VGA character display | Timing generators, character ROM, frame buffer | ★★★ |
| Audio synthesizer | PWM/delta-sigma DAC, frequency generation, PMOD | ★★☆ |
| Pong on VGA | Game FSM, VGA timing, collision detection | ★★★ |
| Logic analyzer | Signal capture, trigger logic, UART streaming | ★★★ |
| RISC-V soft core | Instruction set architecture, pipelining (tight fit on HX1K) | ★★★★ |
| SPI flash reader | SPI master, flash protocol, data display | ★★☆ |

## Open-Source FPGA Resources

| Resource | URL | Best For |
|----------|-----|----------|
| Nandland | nandland.com | Go Board tutorials (by the board's creator) |
| fpga4fun | fpga4fun.com | Practical project tutorials (VGA, audio, SPI) |
| ZipCPU blog | zipcpu.com | Deep technical articles, formal verification |
| Lattice iCE40 docs | latticesemi.com | Official FPGA datasheet and programming guide |
| Project IceStorm | clifford.at/icestorm | Open-source toolchain documentation |
| Amaranth HDL | amaranth-lang.org | Python-based HDL (next-gen alternative) |
| LiteX | github.com/enjoy-digital/litex | SoC builder framework |

## Career Pathways

### FPGA Engineering
Digital systems on FPGAs — DSP, networking, defense, medical, data centers.

**Next steps:** Larger FPGAs (AMD/Xilinx or Intel/Altera), vendor tools (Vivado,
Quartus), high-speed I/O, embedded processors (MicroBlaze, RISC-V soft cores).

### ASIC Design
Chips in silicon — processors, GPUs, AI accelerators, wireless, SoCs.

**Next steps:** Deep SystemVerilog, logic synthesis theory, static timing analysis,
physical design (floorplanning, clock tree, power), DFT, standard cell libraries.

### Verification Engineering
Proving chip designs correct before manufacturing. The majority of engineering
effort on any serious chip project.

**Next steps:** UVM methodology, constrained random verification, functional
coverage, formal verification (SVA, model checking), emulation/prototyping.

### Hardware Security
Side-channel attacks, fault injection, reverse engineering, supply chain
threats, hardware trojans.

**Next steps:** Cryptographic hardware implementations, power analysis (DPA/CPA),
electromagnetic analysis, fault injection, secure design methodologies.

### Embedded Systems
Hardware meets software — microcontrollers, SoCs, firmware, real-time systems.

**Next steps:** ARM Cortex-M programming, RTOS, HW/SW co-design, bus protocols
(AXI, Wishbone, AHB), peripheral design.

## Recommended Next Courses

| Interest | Course | Why |
|----------|--------|-----|
| Chip design | Computer Architecture | Pipelines, caches, memory hierarchy |
| FPGA work | Advanced Digital Design | Complex FSMs, DSP, high-speed I/O |
| Verification | Formal Methods | SVA, model checking, UVM |
| Security | Hardware Security | Side-channel analysis, secure design |
| Embedded | Embedded Systems | HW/SW co-design, RTOS |

## Connecting to Research

Course skills directly apply to: side-channel analysis hardware, hardware
trojan detection, secure processor design, AI/ML hardware accelerators,
and post-quantum cryptography implementations.

---

*The open-source FPGA toolchain you used was built by volunteers who believed
this technology should be accessible to everyone. Pay it forward. Share what
you've built. Help the next person stuck on their first testbench.*
