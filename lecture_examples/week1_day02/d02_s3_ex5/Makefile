# Auto-generated Makefile — lecture example week1_day02/d02_s3_ex5
# Demo: width_bugs (slide d02_s3 "Width Mismatch — Compiler & Synthesis Warnings")
#
# This example exists to surface the warnings the slide talks about, and to
# show the matching silent wrong answers at runtime. Three targets, three
# moments of the demo:
#
#   make lint        # verilator --lint-only -Wall — compiler width warnings
#   make synth-warn  # yosys synth_ice40 — synthesis width warnings
#   make sim         # runs tb_width_bugs.v — prints expected vs got
#
# Note: iverilog has no width-mismatch warning category, so `iverilog -Wall`
# compiles this file silently. Verilator does flag WIDTHEXPAND/WIDTHTRUNC,
# which is exactly what the slide is illustrating.
#
# `make stat` and `make synth` exist for completeness (LUT counts, JSON).
TOP      = width_bugs
SRCS     = width_bugs.v
TB       = tb_width_bugs.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall
VLTFLAGS = --lint-only -Wall

# `lint` is the slide's headline demo: verilator surfaces every width warning.
# We use --lint-only (no compile output) and let the dash prefix swallow the
# nonzero exit so warnings still print without failing the target.
lint: $(SRCS)
	@echo "==== verilator --lint-only -Wall — width warnings ===="
	-verilator $(VLTFLAGS) --top-module $(TOP) $(SRCS)

sim: $(SRCS) $(TB)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

# `synth-warn` is the yosys half of the slide demo: read the source, run
# synth_ice40, grep the log for the width-related lines.
synth-warn: $(SRCS)
	@echo "==== yosys synth_ice40 — width warnings ===="
	@yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP)" 2>&1 \
	    | grep -iE 'warn|truncat|widen' \
	    || echo "(no width warnings surfaced — check yosys version)"

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: lint sim wave synth synth-warn stat clean
