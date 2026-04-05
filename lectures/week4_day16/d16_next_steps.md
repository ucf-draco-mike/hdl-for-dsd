# Where to Go From Here
## Career Pathways & Resources — Accelerated HDL for Digital System Design

---

## Career Pathways

### FPGA Engineering
Move to larger devices (Artix-7, ECP5, Kintex), vendor toolchains (Vivado, Quartus), high-speed I/O (LVDS, SERDES), DDR memory controllers, and real-time signal processing.

### ASIC Design
Standard cell RTL-to-GDSII flow, synthesis with Design Compiler or Genus, timing closure, DFT (scan chains, BIST), physical design (floorplanning, place & route).

### Verification Engineering
UVM methodology, constrained random testing, formal verification (SVA, model checking with JasperGold), coverage-driven workflows. Verification engineers are in extremely high demand.

### Hardware Security
Side-channel analysis (power, EM, timing), fault injection (voltage glitching, laser), logic locking (EPIC, SAT attacks), hardware trojan detection, secure boot and root of trust.

### Embedded Systems
Soft-core processors (RISC-V on FPGA), SoC integration, Linux on FPGA (PetaLinux, Buildroot), hardware/software co-design, real-time systems.

### Open-Source Ecosystem
Amaranth HDL (Python-to-RTL), LiteX (SoC builder), SymbiFlow/F4PGA (open FPGA toolchains for more devices), OpenTitan (open-source silicon root of trust), CHIPS Alliance.

---

## Learning Resources

### Websites & Blogs
- **fpga4fun.com** — Beginner-friendly FPGA tutorials and projects
- **nandland.com** — Go Board tutorials, Verilog/VHDL references
- **zipcpu.com/blog** — Formal verification, UART, SPI, advanced FPGA topics (Dan Gisselquist)
- **asic-world.com** — Comprehensive Verilog/SystemVerilog reference
- **verificationacademy.com** — Mentor/Siemens UVM and verification resources

### Books
- Harris & Harris, *Digital Design and Computer Architecture* (ARM or RISC-V edition)
- Pong Chu, *FPGA Prototyping by Verilog Examples*
- Chris Spear, *SystemVerilog for Verification* (the UVM bible)
- Clifford Cummings papers (sunburst-design.com) — clock domain crossing, coding guidelines

### Tools (all free / open-source)
- **Yosys** — Synthesis (you know this!)
- **nextpnr** — Place and route (you know this!)
- **Verilator** — Fast SystemVerilog simulator and linter
- **Icarus Verilog** — Simulation (you know this!)
- **GTKWave** — Waveform viewer (you know this!)
- **SymbiYosys** — Formal verification frontend for Yosys
- **Cocotb** — Python-based testbench framework for Verilog/VHDL

### Communities
- **r/FPGA** — Reddit community for FPGA engineers
- **1BitSquared Discord** — Open-source hardware community
- **Lattice forums** — iCE40 and ECP5 specific help
- **RISC-V Foundation** — Open ISA ecosystem
- **FOSSi Foundation** — Free and open-source silicon initiative

---

## Project Ideas (Keep Building!)

1. **VGA controller** — Generate VGA timing signals, display patterns or text
2. **RISC-V CPU** — Implement RV32I on the Go Board (tight fit but possible!)
3. **Logic analyzer** — Capture digital signals, send to PC via UART
4. **Audio synthesizer** — PWM-based tone generation with button control
5. **Game** — Pong or Snake on 7-segment + buttons
6. **SPI flash reader** — Read data from an external SPI flash chip
7. **Frequency counter** — Measure external signal frequency, display on 7-seg
8. **I2C controller** — Talk to temperature/accelerometer sensors
9. **PWM motor controller** — Drive a servo or DC motor from button commands
10. **Encryption engine** — AES or lightweight cipher in hardware

---

## Keep exploring


The open-source toolchain you learned was built by volunteers who believed this technology should be accessible to everyone. The tutorials, forum posts, and IP cores you've used were shared by engineers who want to help others learn.

**Pay it forward.** Share what you've built. Help the next person who's stuck on their first testbench. Write up your project for others to learn from.
