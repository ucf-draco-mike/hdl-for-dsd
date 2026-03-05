{
  description = "Accelerated HDL for Digital System Design — Course Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # ---------- Python environment (shared) ----------
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          jupyterlab
          notebook
          jupytext             # markdown ↔ notebook conversion
        ]);

        # ---------- Python environment for site building ----------
        pythonFull = pkgs.python3.withPackages (ps: with ps; [
          jupyterlab
          notebook
          jupytext             # markdown ↔ notebook conversion
          # MkDocs + extensions for building the course site
          mkdocs
          mkdocs-material
          pymdown-extensions
          markdown
        ]);

        # ---------- common packages (all platforms) ----------
        commonPkgs = with pkgs; [
          # Synthesis & PnR
          yosys
          nextpnr
          icestorm          # icepack, iceprog

          # Simulation
          verilog            # Icarus Verilog
          gtkwave

          # Build / version control
          gnumake
          git

          # Serial terminal (UART — Week 3+)
          screen
          minicom
        ];

        # ---------- Linux-only packages ----------
        linuxPkgs = with pkgs; pkgs.lib.optionals pkgs.stdenv.isLinux [
          usbutils           # lsusb for FTDI detection
        ];

        # ---------- shared shell hook ----------
        baseShellHook = ''
          echo ""
          echo "╔══════════════════════════════════════════════════╗"
          echo "║  HDL for Digital System Design — Environment     ║"
          echo "╚══════════════════════════════════════════════════╝"
          echo ""
          echo "  yosys      $(yosys --version 2>&1 | head -1)"
          echo "  nextpnr    $(nextpnr-ice40 --version 2>&1 | head -1)"
          echo "  icestorm   $(icepack 2>&1 | head -1 || echo 'installed')"
          echo "  iverilog   $(iverilog -V 2>&1 | head -1)"
          echo "  gtkwave    $(gtkwave --version 2>&1 | head -1 || echo 'installed')"
          echo "  jupyter    $(jupyter --version 2>&1 | head -1)"
          echo ""
          echo "  Run 'make sim' in any lab directory to simulate."
          echo "  Run 'make prog' to synthesize and program the Go Board."
          echo "  Run 'jupyter lab' to open JupyterLab in your browser."
          echo ""
        '';

      in {
        # Default shell: HDL toolchain + JupyterLab
        # Usage: nix develop
        devShells.default = pkgs.mkShell {
          buildInputs = commonPkgs ++ linuxPkgs ++ [ pythonEnv ];
          shellHook = baseShellHook;
        };

        # Full shell: everything above + MkDocs for building the course site
        # Usage: nix develop .#full
        devShells.full = pkgs.mkShell {
          buildInputs = commonPkgs ++ linuxPkgs ++ [ pythonFull ];
          shellHook = baseShellHook + ''
            echo "  ┌────────── Site building tools also available ────┐"
            echo "  │  mkdocs     $(mkdocs --version 2>&1 | head -1)   |"
            echo "  │                                                  │"
            echo "  │  Build:  python3 scripts/prep_mkdocs.py --build  |"
            echo "  │  Serve:  python3 scripts/prep_mkdocs.py --serve  |"
            echo "  └──────────────────────────────────────────────────┘"
            echo ""
          '';
        };
      }
    );
}
