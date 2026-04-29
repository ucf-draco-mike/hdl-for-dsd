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

IVFLAGS ?= -g2012 -Wall

sim:
	@tb=$$(ls tb_*.v 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo ""; \
		echo "[sim] No testbench present in $$(pwd)."; \
		echo ""; \
		echo "      To add one, create 'tb_<top_module>.v' in this directory."; \
		echo "      Skeleton:"; \
		echo ""; \
		echo "        \`timescale 1ns/1ps"; \
		echo "        module tb_<top_module>;"; \
		echo "          // declare regs/wires, instantiate the DUT,"; \
		echo "          // drive stimulus, dump VCD via \$$dumpfile/\$$dumpvars,"; \
		echo "          // and call \$$finish when done."; \
		echo "        endmodule"; \
		echo ""; \
		echo "      Then re-run: make sim"; \
		echo ""; \
	else \
		srcs=$$(ls *.v 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		echo "iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs"; \
		iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

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

.PHONY: stat_rc8 stat_rc16 stat_beh8 stat_beh16 stat_all show_rc8 show_beh8 clean sim wave
