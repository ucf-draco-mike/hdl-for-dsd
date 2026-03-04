# Makefile — Adder Architecture Comparison
# Day 10, Exercise 1
#
# This exercise is primarily about synthesis comparison, not board programming.
# Use 'make stat_rc8' etc. to compare resource utilization across variants.

SRCS     = adder_comparison.v
PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVERILOG_FLAGS = -g2012 -Wall

# ── Synthesis stats for each variant ──

stat_rc8:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top ripple_carry_8; stat"

stat_rc16:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top ripple_carry_16; stat"

stat_beh8:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top behavioral_8; stat"

stat_beh16:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top behavioral_16; stat"

stat_all: stat_rc8 stat_rc16 stat_beh8 stat_beh16

# ── Schematic comparison ──

show_rc8:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top ripple_carry_8; show"

show_beh8:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top behavioral_8; show"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: stat_rc8 stat_rc16 stat_beh8 stat_beh16 stat_all show_rc8 show_beh8 clean
