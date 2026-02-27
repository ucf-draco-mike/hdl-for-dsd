# Toolchain Setup Guide

## Accelerated HDL for Digital System Design — UCF ECE

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

1. Connect the Go Board to your computer via USB
2. Verify the FTDI device is recognized:
   - **Linux:** `lsusb | grep -i ftdi`
   - **macOS:** `ls /dev/cu.usbserial*`
   - **Windows:** Check Device Manager for "USB Serial Port"
3. Test programming: `iceprog test.bin` (after building a bitstream)

---

## Text Editor Recommendations

Any editor works. Recommended setups for Verilog:

| Editor | Verilog Plugin |
|--------|---------------|
| **VS Code** | [Verilog-HDL/SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL) |
| **Vim/Neovim** | Built-in syntax; [verilog_systemverilog.vim](https://github.com/vhda/verilog_systemverilog.vim) |
| **Emacs** | `verilog-mode` (built-in) |
| **Sublime Text** | [SystemVerilog](https://packagecontrol.io/packages/SystemVerilog) |

---

## Terminal Emulator (for UART in Week 3)

You'll need a serial terminal for UART communication starting Day 11:

| Platform | Tool | Command |
|----------|------|---------|
| Linux | `screen` or `minicom` | `screen /dev/ttyUSB0 115200` |
| macOS | `screen` | `screen /dev/cu.usbserial-* 115200` |
| Windows | PuTTY or Tera Term | Configure: COMx, 115200, 8N1 |

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
