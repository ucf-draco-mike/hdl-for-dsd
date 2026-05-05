# Auto-generated Makefile — lecture example week2_day08/d08_s3_ex3
# Demo: button_array (segment s3, example 3)
#
# Supports an N=... override on the command line for the d08_s3 demo's
# PPA sweep:  make stat N=4 / 8 / 16,  make sim N=4.
# Default N=4 keeps a no-arg invocation reasonable.
TOP      = button_array
SRCS     = day08_ex03_button_array.v debounce.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

N ?= 4

sim:
	@tb=$$(ls tb_*.v tb_*.sv 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo "[sim] No testbench (tb_*.v) in $$(pwd) — add one to simulate."; \
	else \
		srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		iverilog $(IVFLAGS) -DTB_N=$(N) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); chparam -set N $(N) $(TOP); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); chparam -set N $(N) $(TOP); synth_ice40 -top $(TOP); stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean
