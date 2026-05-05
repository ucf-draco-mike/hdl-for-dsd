# Lecture example — week3_day09/d09_s2_ex2
# Demo: single-port synchronous RAM (segment s2)
# Module: ram_1p (1024 x 8 — should infer 2 SB_RAM40_4K EBRs on iCE40)
#
# Targets:
#   make sim     # iverilog + vvp self-check (64 random writes/reads)
#   make wave    # run sim, then open tb_ram_1p.vcd in gtkwave
#   make stat    # yosys synth_ice40 stat — look for SB_RAM40_4K
#   make synth   # synth ram_1p to JSON
#   make prog    # full nextpnr → icepack → iceprog flow (for board demo)
#   make clean   # remove build artifacts

TOP      = ram_1p
SRCS     = ram_1p.v
TB       = tb_ram_1p.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave tb_ram_1p.vcd & else echo "[wave] No VCD produced."; fi

stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); stat"

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave stat synth prog clean
