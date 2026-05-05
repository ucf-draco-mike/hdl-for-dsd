# Auto-generated Makefile — lecture example week1_day02/d02_s3_ex5
# Demo: width_bugs (slide d02_s3 "Width Mismatch — Compiler & Synthesis Warnings")
#
# This example exists to surface the warnings the slide talks about, and to
# show the matching silent wrong answers at runtime. Three targets, three
# moments of the demo:
#
#   make lint        # iverilog -Wall — compiler width warnings
#   make synth-warn  # yosys synth_ice40 — synthesis width warnings
#   make sim         # runs tb_width_bugs.v — prints expected vs got
#
# `make stat` and `make synth` exist for completeness (LUT counts, JSON).
TOP      = width_bugs
SRCS     = width_bugs.v
TB       = tb_width_bugs.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

# `lint` is the slide's headline demo: -Wall surfaces every width warning.
# We compile-only (-o /dev/null) and let iverilog return nonzero on errors —
# warnings still print but don't fail the target, which is what we want here.
lint: $(SRCS)
	@echo "==== iverilog -Wall — width warnings ===="
	-iverilog $(IVFLAGS) -o /dev/null $(SRCS)

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
