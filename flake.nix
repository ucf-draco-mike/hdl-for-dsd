{
  description = "Accelerated HDL for Digital System Design — Course Environment";

  # Auto-enable experimental features so students don't need to configure Nix manually.
  # This takes effect when using `nix develop`, `nix build`, etc. on this flake.
  nixConfig = {
    extra-experimental-features = "nix-command flakes";
  };

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
          coreutils          # timeout, etc. (explicit for macOS compat)

          # Serial terminal (UART — Week 3+)
          screen
          minicom
        ];

        # ---------- Linux-only packages ----------
        linuxPkgs = with pkgs; pkgs.lib.optionals pkgs.stdenv.isLinux [
          usbutils           # lsusb for FTDI detection
          glibcLocales        # provides en_US.UTF-8 and other locales
        ];

        # ---------- locale fix (Linux only) ----------
        localeHook = if pkgs.stdenv.isLinux then ''
          export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
        '' else "";

        # ---------- shared shell hook ----------
        baseShellHook = localeHook + ''

          # Version check with 3-second timeout — prevents hang from
          # tools that probe X11/Wayland (gtkwave) or spin up servers (jupyter).
          __ver() {
            local label="$1"; shift
            local result
            result=$(timeout 3 "$@" 2>&1 | head -1) 2>/dev/null
            if [ $? -eq 124 ]; then
              printf "  %-10s %s\n" "$label" "installed (version check timed out)"
            elif [ -n "$result" ]; then
              printf "  %-10s %s\n" "$label" "$result"
            else
              printf "  %-10s %s\n" "$label" "installed"
            fi
          }

          echo ""
          echo "╔══════════════════════════════════════════════════╗"
          echo "║  HDL for Digital System Design — Environment    ║"
          echo "╚══════════════════════════════════════════════════╝"
          echo ""
          __ver yosys    yosys --version
          __ver nextpnr  nextpnr-ice40 --version
          __ver icestorm icepack
          __ver iverilog iverilog -V
          __ver gtkwave  gtkwave --version
          __ver jupyter  jupyter --version
          echo ""
          echo "  Run 'make sim' in any lab directory to simulate."
          echo "  Run 'make prog' to synthesize and program the Go Board."
          echo "  Run 'jupyter lab' to open JupyterLab in your browser."
          echo ""
          unset -f __ver
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
            echo "  ┌─ Site building tools also available ──────┐"
            printf "  │  %-10s %s\n" "mkdocs" "$(timeout 3 mkdocs --version 2>&1 | head -1)"
            echo "  │                                           │"
            echo "  │  Build:  ./scripts/build_all.sh           │"
            echo "  │  Serve:  ./scripts/build_all.sh --serve   │"
            echo "  └───────────────────────────────────────────┘"
            echo ""
          '';
        };
      }
    );
}
