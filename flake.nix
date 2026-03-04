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

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = commonPkgs ++ linuxPkgs;

          shellHook = ''
            echo ""
            echo "╔══════════════════════════════════════════════════╗"
            echo "║  HDL for Digital System Design — Environment    ║"
            echo "╚══════════════════════════════════════════════════╝"
            echo ""
            echo "  yosys      $(yosys --version 2>&1 | head -1)"
            echo "  nextpnr    $(nextpnr-ice40 --version 2>&1 | head -1)"
            echo "  icestorm   $(icepack 2>&1 | head -1 || echo 'installed')"
            echo "  iverilog   $(iverilog -V 2>&1 | head -1)"
            echo "  gtkwave    $(gtkwave --version 2>&1 | head -1 || echo 'installed')"
            echo ""
            echo "  Run 'make sim' in any lab directory to simulate."
            echo "  Run 'make prog' to synthesize and program the Go Board."
            echo ""
          '';
        };
      }
    );
}
