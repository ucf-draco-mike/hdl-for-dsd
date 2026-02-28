# Lab 7 Makefile — Accelerated HDL Course
PROJECT  = traffic_light
TOP      = traffic_light
PCF      = ../../../../shared/pcf/go_board.pcf

SRCS     = $(filter-out tb_%.v, $(wildcard *.v))
TB       = tb_$(PROJECT).v

DEVICE   = hx1k
PACKAGE  = vq100

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
	iverilog -g2012 -Wall -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp
	@echo "\n=== Open waveforms: gtkwave dump.vcd ==="

wave: sim
	gtkwave dump.vcd &

show: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); show"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd

.PHONY: all prog sim wave show clean
