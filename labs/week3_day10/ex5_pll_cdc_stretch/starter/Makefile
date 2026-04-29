# Makefile — PLL & CDC Stretch Exercises
# Day 10, Exercise 5

PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100

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

pll: top_pll_demo.v
	yosys -p "synth_ice40 -top top_pll_demo -json pll.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json pll.json --asc pll.asc --freq 50
	icepack pll.asc pll.bin

prog_pll: pll
	iceprog pll.bin

cdc: top_cdc_demo.v hex_to_7seg.v debounce.v
	yosys -p "synth_ice40 -top top_cdc_demo -json cdc.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json cdc.json --asc cdc.asc --freq 50
	icepack cdc.asc cdc.bin

prog_cdc: cdc
	iceprog cdc.bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: pll prog_pll cdc prog_cdc clean sim wave
