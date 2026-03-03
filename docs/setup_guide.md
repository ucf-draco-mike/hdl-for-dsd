# Toolchain Setup Guide

## Accelerated HDL for Digital System Design

This guide walks you through installing the open-source FPGA toolchain and simulation tools for the Nandland Go Board (Lattice iCE40 HX1K).

---

## Required Tools

| Tool | Purpose | Version |
|------|---------|---------|
| **Yosys** | Synthesis (Verilog → netlist) | ≥ 0.30 |
| **nextpnr-ice40** | Place & Route | ≥ 0.6 |
| **icepack** / **iceprog** | Bitstream generation & FPGA programming | Part of IceStorm |
| **Icarus Verilog** | Simulation | ≥ 12.0 |
| **GTKWave** | Waveform viewer | ≥ 3.3 |
| **Make** | Build automation | Any |
| **Git** | Version control | Any |

---

## Installation by Platform

### Ubuntu / Debian Linux (Recommended)

```bash
# Update package list
sudo apt update

# Install all tools in one command
sudo apt install -y yosys nextpnr-ice40 fpga-icestorm \
                    iverilog gtkwave git make

# Verify installation
yosys --version
nextpnr-ice40 --version
iverilog -V
gtkwave --version
iceprog

# USB permissions for programming (avoids needing sudo for iceprog)
sudo cp 99-icestick.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Create `/etc/udev/rules.d/99-icestick.rules`:
```
# Nandland Go Board / iCEstick / iCE40 FTDI device
ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666"
```

### macOS (Homebrew)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install yosys icestorm nextpnr
brew install icarus-verilog
brew install --cask gtkwave

# Verify
yosys --version
nextpnr-ice40 --version
iverilog -V
```

### Windows

**Option A: WSL2 (Recommended)**
1. Install WSL2 with Ubuntu: `wsl --install`
2. Follow the Ubuntu instructions above inside WSL
3. For USB passthrough to WSL, install [usbipd-win](https://github.com/dorssel/usbipd-win)

**Option B: Native Windows via oss-cad-suite**
1. Download [oss-cad-suite](https://github.com/YosysHQ/oss-cad-suite-build/releases) for Windows
2. Extract to `C:\oss-cad-suite`
3. Add `C:\oss-cad-suite\bin` to your PATH
4. Download [GTKWave for Windows](https://gtkwave.sourceforge.net/)

---

## Verification

After installation, verify everything works:

```bash
# Create a test directory
mkdir -p ~/hdl_test && cd ~/hdl_test

# Create a minimal Verilog file
cat > test.v << 'EOF'
module test (output wire o_led);
    assign o_led = 1'b0;
endmodule
EOF

# Test synthesis
yosys -p "synth_ice40 -top test -json test.json" test.v
echo "✓ Yosys works"

# Test place & route (will warn about missing PCF — that's fine)
nextpnr-ice40 --hx1k --package vq100 --json test.json --asc test.asc 2>&1 || true
echo "✓ nextpnr works"

# Test simulation
cat > tb_test.v << 'EOF'
module tb_test;
    wire w_led;
    test uut (.o_led(w_led));
    initial begin
        #10;
        if (w_led === 1'b0) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
EOF

iverilog -o sim.vvp tb_test.v test.v && vvp sim.vvp
echo "✓ Icarus Verilog works"

# Cleanup
cd ~ && rm -rf ~/hdl_test
```

---

## Go Board Connection

1. Connect the Go Board to your computer via USB.
2. Verify the FTDI device is recognized:
   - **Linux:** `lsusb | grep -i ftdi`
   - **macOS:** `ls /dev/cu.usbserial*`
   - **Windows:** Check Device Manager for "USB Serial Port"
3. Test programming: `iceprog test.bin` (after building a bitstream)

---

## Text Editor Recommendations

Any editor works. Recommended setups for Verilog and SystemVerilog:

| Editor | Verilog Plugin |
|--------|---------------|
| **VS Code** | [Verilog-HDL/SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL) |
| **Vim/Neovim** | Built-in syntax; [verilog_systemverilog.vim](https://github.com/vhda/verilog_systemverilog.vim) |
| **Emacs** | `verilog-mode` (built-in) |
| **Sublime Text** | [SystemVerilog](https://packagecontrol.io/packages/SystemVerilog) |

---

## Terminal Emulator (for UART — Week 3)

You'll need a serial terminal for UART communication starting Day 11:

| Platform | Tool | Command |
|----------|------|---------|
| Linux | `screen` or `minicom` | `screen /dev/ttyUSB0 115200` |
| macOS | `screen` | `screen /dev/cu.usbserial-* 115200` |
| Windows | PuTTY or Tera Term | Configure: COMx, 115200, 8N1 |

Settings: **115200 baud, 8 data bits, No parity, 1 stop bit (8N1), no flow control.**

---

## AI Tools for Verification (Week 2+)

Starting on Day 6, students use AI tools to assist with testbench generation. No special installation is required — use any of the following through their web interfaces:

- **Claude** (claude.ai)
- **ChatGPT** (chat.openai.com)
- **GitHub Copilot** (VS Code extension, if available)

Students submit AI prompts and corrected outputs as part of lab deliverables. The emphasis is on **reviewing and debugging** AI-generated Verilog, not on which tool is used.

---

## Toolchain Quick Reference

```bash
# Simulation (Icarus Verilog + GTKWave)
iverilog -o sim.vvp -g2012 tb_module.v module.v
vvp sim.vvp
gtkwave dump.vcd

# Synthesis & Programming (iCE40 open-source flow)
yosys -p "synth_ice40 -top top_module -json top.json" top.v sub1.v sub2.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json top.json --asc top.asc
icepack top.asc top.bin
iceprog top.bin

# PPA analysis
yosys -p "read_verilog module.v; synth_ice40 -top module; stat"

# Schematic visualization
yosys -p "read_verilog module.v; synth_ice40 -top module; show"

# Timing analysis
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
  --json top.json --asc top.asc --report timing_report.json

# SystemVerilog simulation (use -g2012 flag)
iverilog -g2012 -o sim.vvp tb_module.sv module.sv
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `iceprog: command not found` | Ensure IceStorm is installed: `sudo apt install fpga-icestorm` |
| `iceprog: Permission denied` | Add udev rules (see Linux section) or use `sudo iceprog` |
| `nextpnr: No such device` | Check USB connection; try a different USB port/cable |
| GTKWave won't open on macOS | Allow in System Preferences → Security & Privacy |
| `iverilog: No such file or directory` | Check PATH; on macOS try `brew link icarus-verilog` |
| WSL2 can't see USB device | Install and configure [usbipd-win](https://github.com/dorssel/usbipd-win) |
| `yosys: read_verilog -sv` fails | Update Yosys to ≥ 0.30 for SystemVerilog support |
| iverilog rejects SV syntax | Ensure you pass the `-g2012` flag |
| Serial terminal shows garbled text | Check baud rate (115200) and settings (8N1, no flow control) |
| `screen` won't release serial port | Detach with `Ctrl-A` then `K`, confirm with `Y` |
