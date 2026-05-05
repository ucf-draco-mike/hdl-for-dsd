# Lecture example — week3_day09/d09_s4_ex3
# Demo: pattern_sequencer (segment s4)
# Composition: step timer + address counter + rom_array (BRAM-inferred ROM).
# Edit pattern.hex and rebuild for a new animation — RTL is unchanged.
#
# Targets:
#   make sim     # iverilog + vvp self-check (walks all 16 steps + wrap)
#   make wave    # run sim, then open tb_pattern_sequencer.vcd in gtkwave
#   make stat    # yosys synth_ice40 stat for pattern_sequencer
#   make synth   # synth pattern_sequencer + rom_array submodule to JSON
#   make prog    # full nextpnr → icepack → iceprog flow (board demo)
#   make clean   # remove build artifacts

CORE_SRCS = pattern_sequencer.v rom_array.v
BOARD_SRCS = top.v $(CORE_SRCS)
TB        = tb_pattern_sequencer.v
PCF       = ../go_board.pcf
DEVICE    = hx1k
PACKAGE   = vq100
IVFLAGS   = -g2012 -Wall

# `stat` reports the headline result on the core sequencer (matches the slide).
# `synth`/`prog` use top.v to map the 8-bit o_leds onto the 4 Go Board LEDs.

sim: $(TB) $(CORE_SRCS) pattern.hex
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(CORE_SRCS)
	vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave tb_pattern_sequencer.vcd & else echo "[wave] No VCD produced."; fi

stat: $(CORE_SRCS) pattern.hex
	yosys -p "read_verilog $(CORE_SRCS); synth_ice40 -top pattern_sequencer; stat"

synth: $(BOARD_SRCS) pattern.hex
	yosys -p "read_verilog $(BOARD_SRCS); synth_ice40 -top top -json top.json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json top.json --asc top.asc --freq 25
	icepack top.asc top.bin
	iceprog top.bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave stat synth prog clean
