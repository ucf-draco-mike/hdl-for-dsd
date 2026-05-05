# Auto-generated Makefile — lecture example week2_day05/d05_s4_ex4
# Demo: debounce  (segment s4, example 4)
#
# Two synthesis targets are available:
#   - debounce   (the module under test, used by `make sim` / `make stat`)
#   - ex04_top   (Go Board pipeline: sync -> debounce -> edge -> LED counter,
#                 used by `make prog`)
TOP        = ex04_top
DEB_SRC    = day05_ex04_debounce.v
TOP_SRCS   = day05_ex04_top.v $(DEB_SRC)
PCF        = ../go_board.pcf
DEVICE     = hx1k
PACKAGE    = vq100
IVFLAGS    = -g2012 -Wall

sim:
	iverilog $(IVFLAGS) -o sim.vvp tb_debounce.v $(DEB_SRC)
	vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

# `make stat` reports the bare debounce module so that the LUT/flop counts
# match the figures in the slide ("What Did the Tool Build?").
stat:
	yosys -p "read_verilog $(DEB_SRC); synth_ice40 -top debounce; stat"

# `make synth` builds the Go Board top wrapper (sync + debounce + edge +
# counter) for placement and bitstream generation.
synth:
	yosys -p "read_verilog $(TOP_SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean
