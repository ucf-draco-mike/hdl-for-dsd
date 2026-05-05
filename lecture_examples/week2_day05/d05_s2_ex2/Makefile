# Auto-generated Makefile — lecture example week2_day05/d05_s2_ex2
# Demo: shift_reg_sipo  (segment s2, example 2)
#
# This folder contains both shift register variants discussed in the lecture:
#   - day05_ex02_shift_reg_sipo.v  (Serial-In, Parallel-Out — used in live demo)
#   - day05_ex02_shift_reg_piso.v  (Parallel-In, Serial-Out — "We Do" content)
#
# The default `make sim` runs the SIPO testbench to mirror the slide demo.
# Use `make sim_piso` / `make stat_piso` to exercise the PISO variant.
TOP      = shift_reg_sipo
SRCS     = day05_ex02_shift_reg_sipo.v day05_ex02_shift_reg_piso.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim:
	iverilog $(IVFLAGS) -o sim_sipo.vvp tb_shift_reg_sipo.v day05_ex02_shift_reg_sipo.v
	vvp sim_sipo.vvp

sim_piso:
	iverilog $(IVFLAGS) -o sim_piso.vvp tb_shift_reg_piso.v day05_ex02_shift_reg_piso.v
	vvp sim_piso.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth:
	yosys -p "read_verilog day05_ex02_shift_reg_sipo.v; synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat:
	yosys -p "read_verilog day05_ex02_shift_reg_sipo.v; synth_ice40 -top $(TOP); stat"

stat_piso:
	yosys -p "read_verilog day05_ex02_shift_reg_piso.v; synth_ice40 -top shift_reg_piso; stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim sim_piso wave synth prog stat stat_piso clean
