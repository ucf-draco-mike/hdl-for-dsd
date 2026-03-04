# Makefile — PLL & CDC Stretch Exercises
# Day 10, Exercise 5

PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100

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

.PHONY: pll prog_pll cdc prog_cdc clean
