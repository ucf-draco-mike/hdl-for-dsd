# Auto-generated Makefile — lecture example week4_day13/d13_s4_ex2
# Demo: alu_sv  (segment s4, example 2)
TOP      = alu_sv
SRCS     = day13_ex02_alu_sv.sv
PCF      = ../../go_board.pcf
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

synth: $(SRCS)
	yosys -p "read_verilog -sv $(SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat: $(SRCS)
	yosys -p "read_verilog -sv $(SRCS); synth_ice40 -top $(TOP); stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean
