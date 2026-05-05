# Auto-generated Makefile — lecture example week1_day03/d03_s1_ex1
# Demo: assign vs always @(*) — same hardware  (segment s1)
#
# Two equivalent 4:1 muxes synthesized side by side. The `stat` target
# reports each one independently so students can compare LUT counts.
TOP      = mux_always
SRCS     = day03_ex04_mux_assign.v day03_ex05_mux_always.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim:
	@tb=$$(ls tb_*.v tb_*.sv 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo "[sim] No testbench (tb_*.v) in $$(pwd) — add one to simulate."; \
	else \
		srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth:
	yosys -p "read_verilog day03_ex05_mux_always.v; synth_ice40 -top mux_always -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

# Default `stat` reports both modules so the "same hardware" claim is visible.
stat:
	@echo "----- mux_assign (assign / nested ternary) -----"
	yosys -p "read_verilog day03_ex04_mux_assign.v; synth_ice40 -top mux_assign; stat"
	@echo "----- mux_always (always @(*) + case) -----"
	yosys -p "read_verilog day03_ex05_mux_always.v; synth_ice40 -top mux_always; stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean
