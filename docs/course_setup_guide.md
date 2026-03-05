# Toolchain Setup Guide

## Accelerated HDL for Digital System Design

This course uses a **single Nix-based development environment** that provides identical tool versions on Linux, macOS, and Windows (via WSL2). Complete the OS-specific prerequisites below, then install Nix and enter the course shell — all tools will be available automatically.

> **Time estimate:** 15–30 minutes depending on platform and internet speed.

---

## Step 0: OS-Specific Prerequisites

Before installing Nix, your operating system needs a few things in place. Find your platform below and complete **only that section**.

---

### Linux (Ubuntu / Debian / Fedora)

**What you need:** `curl`, `xz-utils`, and USB permissions for the Go Board.

```bash
# 1. Install prerequisites (most systems already have these)
sudo apt update && sudo apt install -y curl xz-utils   # Debian/Ubuntu
# or: sudo dnf install -y curl xz                       # Fedora

# 2. Set up USB permissions for the Go Board FTDI chip
#    This avoids needing sudo every time you program the board.
sudo tee /etc/udev/rules.d/99-fpga-boards.rules > /dev/null << 'EOF'
# Nandland Go Board / iCEstick / iCE40 — FTDI FT2232H
ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

# 3. Verify FTDI detection (plug in the Go Board first)
lsusb | grep -i ftdi
# Expected: "Future Technology Devices International" or similar
```

**GTKWave note:** On headless or Wayland-only systems, GTKWave needs an X11 display. If you're using a standard desktop environment (GNOME, KDE, XFCE), this works out of the box.

**Done.** Proceed to [Step 1: Install Nix](#step-1-install-nix).

---

### macOS (Intel or Apple Silicon)

**What you need:** Xcode Command Line Tools and a few system settings.

```bash
# 1. Install Xcode Command Line Tools (provides git, curl, etc.)
xcode-select --install
# Follow the dialog that appears. If already installed, you'll see a message saying so.

# 2. Allow apps from "identified developers" (needed for GTKWave)
#    System Settings → Privacy & Security → Security → Allow
#    (You may be prompted again the first time you launch GTKWave)
```

**USB driver note:** macOS recognizes the Go Board FTDI chip natively via the built-in AppleUSBFTDI driver. No additional drivers are needed. Verify with:

```bash
# Plug in the Go Board, then:
ls /dev/cu.usbserial*
# Expected: /dev/cu.usbserial-<something>
```

**Apple Silicon (M1/M2/M3/M4) note:** Nix and all course tools support `aarch64-darwin` natively. No Rosetta needed.

**Done.** Proceed to [Step 1: Install Nix](#step-1-install-nix).

---

### Windows

Windows support works through **WSL2** (Windows Subsystem for Linux). You'll run an Ubuntu environment inside Windows and use Nix there.

```powershell
# ── Run these in PowerShell (as Administrator) ──

# 1. Install WSL2 with Ubuntu (reboot if prompted)
wsl --install

# 2. After reboot, open "Ubuntu" from the Start menu.
#    Set your UNIX username and password when prompted.
```

Now **inside the Ubuntu/WSL2 terminal**:

```bash
# 3. Update packages
sudo apt update && sudo apt install -y curl xz-utils
```

**USB passthrough (required for programming the Go Board):**

WSL2 does not have native USB access. You need `usbipd-win` to forward the FTDI device.

```powershell
# ── Back in PowerShell (as Administrator) ──

# 4. Install usbipd-win
winget install usbipd

# 5. List USB devices (plug in the Go Board first)
usbipd list
# Find the line with "FTDI" or "USB Serial Converter" — note its BUSID (e.g., 2-1)

# 6. Bind and attach to WSL (repeat step 6b each time you reconnect the board)
usbipd bind --busid <BUSID>       # one-time: makes device shareable
usbipd attach --wsl --busid <BUSID>  # each session: forwards to WSL
```

Then **inside WSL2**:

```bash
# 7. Verify the device appeared
ls /dev/ttyUSB*
# Expected: /dev/ttyUSB0 or /dev/ttyUSB1

# 8. Set up udev rules (same as Linux)
sudo tee /etc/udev/rules.d/99-fpga-boards.rules > /dev/null << 'EOF'
ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
```

**GTKWave on WSL2:** Waveform viewing requires a GUI. Two options:
- **WSLg (default on Windows 11):** GUI apps work automatically — just run `gtkwave` from the terminal.
- **Windows 10 or WSLg disabled:** Install an X server like [VcXsrv](https://sourceforge.net/projects/vcxsrv/) and set `export DISPLAY=:0` in your `~/.bashrc`.

**Done.** Continue in the WSL2 Ubuntu terminal for all remaining steps.

---

## Step 1: Install Nix

We use the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer), which enables Flakes by default and handles the multi-user daemon setup cleanly on all platforms.

```bash
# Works on Linux, macOS, and WSL2
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Follow any prompts (you may need to approve sudo access).
# When finished, open a NEW terminal (or source the shell config):
source /etc/profile.d/nix.sh 2>/dev/null || true

# Verify Nix is working
nix --version
# Expected: nix (Nix) 2.x.x
```

> **What just happened?** Nix installed a package manager in `/nix/store` that keeps all course tools completely isolated from your system. It won't interfere with your existing `apt`, `brew`, or other package managers.

> **Already have Nix installed?** If you used the official Nix installer (not Determinate Systems), you'll need to enable Flakes manually. Create or edit `~/.config/nix/nix.conf` and add:
>
> ```
> experimental-features = nix-command flakes
> ```
>
> Then restart your terminal. Without this, you'll get `error: experimental Nix feature 'nix-command' is disabled`.

---

## Step 2: Clone the Course Repository

```bash
# Clone the repo (replace with the actual URL your instructor provides)
git clone https://github.com/<org>/hdl-course.git
cd hdl-course
```

---

## Step 3: Enter the Development Shell

```bash
nix develop
```

The first time you run this, Nix will download and build the toolchain. This takes **5–15 minutes** depending on your internet connection (subsequent runs are instant — everything is cached).

You should see:

```
╔══════════════════════════════════════════════════╗
║  HDL for Digital System Design — Environment    ║
╚══════════════════════════════════════════════════╝

  yosys      Yosys 0.4x (...)
  nextpnr    nextpnr-ice40 ...
  icestorm   installed
  iverilog   Icarus Verilog version 1x.x
  gtkwave    installed

  Run 'make sim' in any lab directory to simulate.
  Run 'make prog' to synthesize and program the Go Board.
```

**Every time you work on course material**, `cd` into the repo and run `nix develop` to activate the environment. When you're done, just type `exit` or close the terminal.

> **Optional: Automatic activation with direnv**
>
> If you'd like the shell to activate automatically whenever you `cd` into the repo:
> ```bash
> nix profile install nixpkgs#direnv nixpkgs#nix-direnv
> echo 'eval "$(direnv hook bash)"' >> ~/.bashrc   # or ~/.zshrc
> mkdir -p ~/.config/direnv && echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
> cd hdl-course && direnv allow
> ```
> After this, the tools are available the moment you enter the directory.

---

## Step 4: Verify Everything Works

Run the built-in verification script from inside the Nix shell:

```bash
# Make sure you're in the Nix shell (run 'nix develop' if you haven't)

# ── Test 1: Synthesis ──
mkdir -p /tmp/hdl-verify && cd /tmp/hdl-verify

cat > test.v << 'EOF'
module test (output wire o_led);
    assign o_led = 1'b0;
endmodule
EOF

yosys -p "synth_ice40 -top test -json test.json" test.v
echo "✅ Yosys synthesis — OK"

# ── Test 2: Place & Route ──
nextpnr-ice40 --hx1k --package vq100 --json test.json --asc test.asc 2>&1 || true
echo "✅ nextpnr place & route — OK"

# ── Test 3: Simulation ──
cat > tb_test.v << 'EOF'
module tb_test;
    wire w_led;
    test uut (.o_led(w_led));
    initial begin
        #10;
        if (w_led === 1'b0) $display("PASS: LED driven low as expected");
        else $display("FAIL: unexpected LED value");
        $finish;
    end
endmodule
EOF

iverilog -o sim.vvp tb_test.v test.v && vvp sim.vvp
echo "✅ Icarus Verilog simulation — OK"

# ── Test 4: Waveform viewer ──
echo "Launching GTKWave (close the window to continue)..."
gtkwave --version && echo "✅ GTKWave — OK"

# ── Test 5: Bitstream tools ──
icepack test.asc test.bin && echo "✅ icepack — OK"

# ── Test 6: JupyterLab ──
jupyter --version > /dev/null 2>&1 && echo "✅ JupyterLab — OK"

# ── Cleanup ──
cd ~ && rm -rf /tmp/hdl-verify

echo ""
echo "════════════════════════════════════════"
echo "  All tools verified. You're ready."
echo "════════════════════════════════════════"
```

---

## Step 5: Go Board Connection Test

1. Connect the Go Board to your computer via USB.
2. Verify the FTDI device is recognized:

   | Platform | Command | Expected output |
   |----------|---------|-----------------|
   | Linux | `lsusb \| grep -i ftdi` | "Future Technology Devices International" |
   | macOS | `ls /dev/cu.usbserial*` | `/dev/cu.usbserial-XXXXXXXX` |
   | WSL2 | `ls /dev/ttyUSB*` | `/dev/ttyUSB0` (after usbipd attach) |

3. **First-program test** (after verification above):
   ```bash
   cd /tmp/hdl-verify  # or wherever you built test.bin
   iceprog test.bin
   ```
   If this completes without errors, your full synthesis → program pipeline is working.

---

## Text Editor Setup

Any editor works. Here are recommended setups for Verilog syntax highlighting:

| Editor | Plugin/Mode |
|--------|-------------|
| **VS Code** | [Verilog-HDL/SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL) extension |
| **Vim / Neovim** | Built-in syntax highlighting; optionally [verilog_systemverilog.vim](https://github.com/vhda/verilog_systemverilog.vim) |
| **Emacs** | `verilog-mode` (built-in) |
| **Sublime Text** | [SystemVerilog](https://packagecontrol.io/packages/SystemVerilog) package |

> **VS Code + WSL2:** Install the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension to edit and run everything inside WSL seamlessly.

---

## Serial Terminal (UART — Week 3+)

Starting Day 11, you'll communicate with the Go Board over UART. The serial tools (`screen`, `minicom`) are included in the Nix shell. Settings for all terminals:

**115200 baud · 8 data bits · No parity · 1 stop bit (8N1) · No flow control**

| Platform | Command |
|----------|---------|
| Linux | `screen /dev/ttyUSB0 115200` |
| macOS | `screen /dev/cu.usbserial-* 115200` |
| WSL2 | `screen /dev/ttyUSB0 115200` (after usbipd attach) |

To exit `screen`: press `Ctrl-A` then `K`, confirm with `Y`.

---

## AI Tools for Verification (Week 2+)

Starting Day 6, you'll use AI tools to assist with testbench generation. No installation required — use any of these through their web interfaces:

- **Claude** (claude.ai)
- **ChatGPT** (chat.openai.com)
- **GitHub Copilot** (VS Code extension, if available)

You'll submit your AI prompts and corrected outputs as part of lab deliverables. The emphasis is on **reviewing and debugging** AI-generated Verilog, not on which tool you use.

---

## JupyterLab & Course Site

The course website includes a **Code & Notebooks** page for each day with direct links to starter code, solution zips, and JupyterLab. This section explains how the pieces fit together.

### Running JupyterLab

JupyterLab is included in the Nix development environment — no separate install needed. Launch it from the repo root so that all file paths resolve correctly:

```bash
cd hdl-for-dsd
nix develop
jupyter lab
```

This opens JupyterLab in your browser with the full repository tree. You can:

- Edit Verilog, SystemVerilog, and testbench files in the built-in text editor
- Open the `.ipynb` lab notebooks for an interactive guided experience
- Use the terminal panel to run simulations (`make sim`) or program the board (`make prog`)

### Code & Notebooks Pages

Each day's page on the course site includes a **Code & Notebooks** card with:

- **Download All Starter Code (.zip)** — a single zip with every exercise's starter files for that day
- **Per-exercise starter and solution zips**
- **GitHub links** — view each file directly on GitHub
- **Open in Jupyter links** — open each file directly in your running JupyterLab instance
- **Lab Notebook (.ipynb)** — the full lab guide as a Jupyter notebook (auto-generated via `jupytext`)

> **How the "Open in Jupyter" links work:** The links point to `http://localhost:8888/lab/tree/<path>`, which is the default JupyterLab address when launched from the repo root. If JupyterLab starts on a different port, adjust the URL or navigate to the file manually in JupyterLab's file browser.

### Configuring a Custom URL

If you run JupyterLab on a different port, or your institution provides a shared JupyterHub, override the base URL when building the site:

```bash
# Custom local port
export HDL_JUPYTER_BASE="http://localhost:9999/lab/tree"

# Institutional JupyterHub
export HDL_JUPYTER_BASE="https://jupyter.cecs.ucf.edu/hub/user-redirect/lab/tree/hdl-for-dsd"

# Then rebuild
./scripts/build_all.sh --quick
```

### Browsing the Course Site Locally

The static course site is built with MkDocs. To preview it locally:

```bash
nix develop .#full
./scripts/build_all.sh --serve
# Open: http://127.0.0.1:8000
```

### Building the Course Site

To build the full course site (with download zips, notebooks, and all pages), use the `full` dev shell which adds MkDocs, jupytext, and dependencies:

```bash
nix develop .#full

# Full build: notebooks → MkDocs source → static site
./scripts/build_all.sh

# Or individual steps:
./scripts/build_all.sh --notebooks  # only regenerate .ipynb files
./scripts/build_all.sh --quick      # skip standalone site (build_site.py)
./scripts/build_all.sh --serve      # build then live-preview at localhost:8000
```

The `build_all.sh` script runs each step in order:

1. **Notebooks** — converts every lab `README.md` to `.ipynb` via `jupytext` (incremental: skips unchanged files)
2. **MkDocs prep** — generates `docs_src/` with code pages, download zips, and day navigation
3. **Standalone site** — builds `site/` via `build_site.py` (skipped with `--quick`)
4. **MkDocs build** — produces the final `_site/` directory with slides and downloads copied in

---

## Quick Reference

```bash
# ── Enter the course environment ──
cd hdl-course && nix develop

# ── Simulation ──
iverilog -o sim.vvp -g2012 tb_module.v module.v
vvp sim.vvp
gtkwave dump.vcd

# ── Synthesis → Program (Go Board) ──
yosys -p "synth_ice40 -top top_module -json top.json" top.v sub1.v sub2.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json top.json --asc top.asc
icepack top.asc top.bin
iceprog top.bin

# ── JupyterLab (edit & browse in browser) ──
jupyter lab

# ── Resource analysis ──
yosys -p "read_verilog module.v; synth_ice40 -top module; stat"

# ── Schematic visualization ──
yosys -p "read_verilog module.v; synth_ice40 -top module; show"

# ── SystemVerilog simulation (use -g2012 flag) ──
iverilog -g2012 -o sim.vvp tb_module.sv module.sv
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `nix: command not found` | Open a **new terminal** after installing Nix, or run `source /etc/profile.d/nix.sh` |
| `nix develop` is slow the first time | Normal — it's downloading the toolchain. Subsequent runs use the cache. |
| `error: experimental feature 'flakes' is disabled` | You may have used the default Nix installer. Reinstall with the Determinate Systems installer (see Step 1), or add `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf` |
| `iceprog: Permission denied` (Linux) | Check udev rules (see Linux prerequisites) or use `sudo iceprog` as a temporary workaround |
| WSL2 can't see USB device | Run `usbipd attach --wsl --busid <BUSID>` from PowerShell (see Windows prerequisites) |
| GTKWave won't open on macOS | Allow in System Settings → Privacy & Security → Security |
| GTKWave won't open on WSL2 (Win 10) | Install VcXsrv and set `export DISPLAY=:0` in `~/.bashrc` |
| `iverilog` rejects SystemVerilog syntax | Ensure you pass the `-g2012` flag |
| Serial terminal shows garbled text | Verify baud rate is 115200 and settings are 8N1, no flow control |
| `screen` won't release serial port | Detach with `Ctrl-A` then `K`, confirm with `Y` |
| Nix store using too much disk space | Run `nix store gc` to garbage-collect unused packages |
| "Open in Jupyter" links go to wrong page | Make sure JupyterLab is running (`jupyter lab`) from the repo root. If it's on a different port than 8888, set `HDL_JUPYTER_BASE` and rebuild |
| JupyterLab can't find Icarus Verilog | Open a terminal inside JupyterLab and run `nix develop` to enter the course environment before running `make sim` |

---

## Uninstalling (after the course)

If you want to remove Nix and reclaim disk space:

```bash
/nix/nix-installer uninstall
```

This cleanly removes the Nix daemon, store, and configuration. Your system packages are unaffected.
