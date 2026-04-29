# Makefile — PPA Analysis Helpers
# Day 14, Exercise 4
#
# Quick synthesis stat targets for common modules.
# Adjust paths to match your repo layout.

SHARED = ../../../../shared/lib

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

# Counter at multiple widths
stat_counter_8:
	yosys -q -p "read_verilog -DWIDTH=8 $(SHARED)/counter_mod_n.v; synth_ice40 -top counter_mod_n; stat"

stat_counter_16:
	yosys -q -p "read_verilog -DWIDTH=16 $(SHARED)/counter_mod_n.v; synth_ice40 -top counter_mod_n; stat"

stat_counter_32:
	yosys -q -p "read_verilog -DWIDTH=32 $(SHARED)/counter_mod_n.v; synth_ice40 -top counter_mod_n; stat"

# UART TX from shared lib
stat_uart_tx:
	yosys -q -p "read_verilog $(SHARED)/uart_tx.v; synth_ice40 -top uart_tx; stat"

# UART TX with parity (from exercise 2)
stat_uart_parity_off:
	yosys -q -p "read_verilog -sv -DPARITY_EN=0 ../ex2_uart_parity/starter/uart_tx_parity.sv; synth_ice40 -top uart_tx_parity; stat"

stat_uart_parity_on:
	yosys -q -p "read_verilog -sv ../ex2_uart_parity/starter/uart_tx_parity.sv; synth_ice40 -top uart_tx_parity; stat"

# Run all
stat_all: stat_counter_8 stat_counter_16 stat_counter_32 stat_uart_tx stat_uart_parity_off stat_uart_parity_on

clean:
	rm -f *.json *.log

.PHONY: stat_counter_8 stat_counter_16 stat_counter_32 stat_uart_tx stat_uart_parity_off stat_uart_parity_on stat_all clean sim wave
