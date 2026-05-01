# Auto-generated Makefile — lecture example week1_day02/d02_s2_ex2
# Demo: 4:1 Mux + Cost Comparison  (segment s2 + s3 width-mismatch demo)
#
# Three top-level designs share this directory:
#   mux_2to1          — Day 2 baseline 2:1 multiplexer
#   mux_4to1_nested   — d02_s2 4:1 mux via nested ?:
#   mux_4to1_case     — d02_s2 4:1 mux via always @(*) + case
#   width_bugs        — d02_s3 deliberate width-mismatch demo
#
# `make stat` reports on `mux_4to1_case` by default — change TOP below to
# inspect any of the others (the SRCS list compiles all four together so the
# `width_bugs` warnings still fire).
TOP      = mux_4to1_case
SRCS     = day02_ex02_mux_2to1.v day02_ex02_mux_4to1.v width_bugs.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

# Explicit testbench so `make sim` always runs the unified mux demo.
TB       = tb_mux_demo.v

sim:
	@srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $$srcs && vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean
