# Makefile — top_cdc_demo
PROJECT  = top_cdc_demo
TOP      = top_cdc_demo
PCF      = ../go_board.pcf
SRCS     = top_cdc_demo.v hex_to_7seg.v debounce.v
TB       = tb_top_cdc_demo.v

DEVICE   = hx1k
PACKAGE  = vq100

IVERILOG_FLAGS = -g2012 -Wall

all: $(PROJECT).bin

$(PROJECT).json: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP) -json $@" $(SRCS)

$(PROJECT).asc: $(PROJECT).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

$(PROJECT).bin: $(PROJECT).asc
	icepack $< $@

prog: $(PROJECT).bin
	iceprog $<

sim: $(TB) $(SRCS)
	iverilog $(IVERILOG_FLAGS) -o sim.vvp $(TB) $(filter-out $(TB),$(SRCS))
	vvp sim.vvp
	@echo "=== Simulation complete ==="

wave: sim
	gtkwave *.vcd &

stat: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP); stat" $(SRCS)

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: all prog sim wave stat clean
