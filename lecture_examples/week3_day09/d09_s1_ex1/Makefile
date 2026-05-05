# Lecture example — week3_day09/d09_s1_ex1
# Demo: case-based vs array-based ROM (segment s1)
# Modules: rom_case (combinational, LUTs)  +  rom_array (synchronous, EBR)
#
# Targets:
#   make sim         # iverilog + vvp (tb_rom.v over both modules)
#   make wave        # run sim, then open tb_rom.vcd in gtkwave
#   make stat_case   # yosys synth_ice40 stat for rom_case (top)
#   make stat_array  # yosys synth_ice40 stat for rom_array (top) — look for SB_RAM40_4K
#   make stat        # alias for stat_array (the "headline" demo result)
#   make synth       # synth rom_array to JSON
#   make prog        # full nextpnr → icepack → iceprog flow for rom_array
#   make clean       # remove build artifacts

CASE_SRC  = rom_case.v
ARRAY_SRC = rom_array.v
TB        = tb_rom.v

PCF       = ../go_board.pcf
DEVICE    = hx1k
PACKAGE   = vq100
IVFLAGS   = -g2012 -Wall

# Default to array because it's the headline result for the demo.
TOP       = rom_array
SRCS      = $(ARRAY_SRC)

sim: $(TB) $(CASE_SRC) $(ARRAY_SRC) hello.hex
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(CASE_SRC) $(ARRAY_SRC)
	vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave tb_rom.vcd & else echo "[wave] No VCD produced."; fi

stat_case: $(CASE_SRC)
	yosys -p "read_verilog $(CASE_SRC); synth_ice40 -top rom_case; stat"

stat_array: $(ARRAY_SRC) hello.hex
	yosys -p "read_verilog $(ARRAY_SRC); synth_ice40 -top rom_array; stat"

stat: stat_array

synth: $(ARRAY_SRC) hello.hex
	yosys -p "read_verilog $(ARRAY_SRC); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave stat stat_case stat_array synth prog clean
