---
hide:
  - toc
title: "Get Started"
---

# :material-rocket-launch: Get Started

<p class="subtitle">Your Day 0 checklist — everything you need before the first class session</p>

<div class="card-grid card-grid--2" markdown>

<div class="feature-card" markdown>
**:material-clock-fast: Estimated time**

30–45 minutes (depending on internet speed and platform)
</div>

<div class="feature-card" markdown>
**:material-check-all: End result**

A working toolchain that can simulate, synthesize, and program the Go Board
</div>

</div>

---

## :material-numeric-1-circle: Get the Hardware

You need one piece of hardware: the **Nandland Go Board** (Lattice iCE40 HX1K).

[:octicons-arrow-right-16: Nandland Go Board](https://nandland.com/the-go-board/){ .md-button .md-button--primary target=_blank }

You'll keep the board after the course.

---

## :material-numeric-2-circle: Set Up Your Computer

The entire toolchain installs through a single command using [Nix](https://nixos.org/). No manual package installs, no version conflicts, no license servers.

=== "Linux"

    ```bash
    # Prerequisites
    sudo apt update && sudo apt install -y curl xz-utils

    # USB permissions for the Go Board
    sudo tee /etc/udev/rules.d/99-fpga-boards.rules > /dev/null << 'EOF'
    ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666"
    EOF
    sudo udevadm control --reload-rules && sudo udevadm trigger
    ```

=== "macOS"

    ```bash
    # Prerequisites
    xcode-select --install
    ```

=== "Windows (WSL2)"

    ```powershell
    # In PowerShell (as Administrator)
    wsl --install
    winget install usbipd
    ```

    Then open **Ubuntu** from the Start menu and continue in that terminal.

    ```bash
    # Inside WSL2
    sudo apt update && sudo apt install -y curl xz-utils
    ```

[:octicons-arrow-right-16: Full platform details](setup.md){ .md-button }

---

## :material-numeric-3-circle: Install Nix & Clone the Repo

```bash
# Install Nix (all platforms)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Open a NEW terminal, then:
git clone https://github.com/ucf-draco-mike/hdl-for-dsd.git
cd hdl-for-dsd
nix develop          # first run: ~5-15 min download; instant after that
```

---

## :material-numeric-4-circle: Verify

```bash
yosys --version && nextpnr-ice40 --version && iverilog -V
```

All three should print version numbers without errors.

---

## :material-numeric-5-circle: First Build

Plug in the Go Board via USB, then:

```bash
cd labs/week1_day01
make prog
```

If an LED lights up on the board — **you're ready for Day 1**.

!!! success "You're set"
    If all five steps completed successfully, you have a fully working environment.
    Head to [Day 1 →](days/day01/) when the course begins.

!!! failure "Something broke?"
    Check the [Troubleshooting section](setup.md#troubleshooting) in the full setup guide, or ask in the course channel.

---

## :material-map-outline: How This Site Works

Every day in this course has its own section with four resources:

| Resource | What it is | When to use it |
|----------|-----------|---------------|
| **Pre-Class Video + Slides** | Recorded lecture segments | Watch *before* class |
| **Pre-Class Quiz** | Self-check questions with hidden answers | After watching the video |
| **Lab Guide** | Step-by-step exercises with starter code | During class |
| **Daily Plan** | Session timeline and instructor notes | Reference / review |

Use the **Week tabs** at the top of the page to navigate, or jump to any day from the [Course Overview](index.md).

[:octicons-arrow-right-16: Full site guide](site-guide.md){ .md-button }
