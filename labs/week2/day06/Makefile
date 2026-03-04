# =============================================================================
# Makefile — Day 6: Testbenches & Simulation-Driven Development
# Accelerated HDL for Digital System Design · UCF ECE
# =============================================================================

PROJECT  ?= alu_4bit
TOP      ?= $(PROJECT)
PCF      ?= go_board.pcf
SRCS     ?= $(wildcard *.v)
TB       ?= tb_$(PROJECT).v
DEVICE   = hx1k
PACKAGE  = vq100

YOSYS_FLAGS   = -p "synth_ice40 -top $(TOP) -json $(PROJECT).json"
NEXTPNR_FLAGS = --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) \
                --json $(PROJECT).json --asc $(PROJECT).asc
IVERILOG_FLAGS = -g2012 -Wall

all: $(PROJECT).bin

$(PROJECT).json: $(SRCS)
	yosys $(YOSYS_FLAGS) $(SRCS)

$(PROJECT).asc: $(PROJECT).json $(PCF)
	nextpnr-ice40 $(NEXTPNR_FLAGS)

$(PROJECT).bin: $(PROJECT).asc
	icepack $< $@

prog: $(PROJECT).bin
	iceprog $<

sim: $(TB) $(SRCS)
	iverilog $(IVERILOG_FLAGS) -o sim.vvp $(TB) $(filter-out $(TB) $(wildcard top_*.v),$(SRCS))
	vvp sim.vvp
	@echo ""
	@echo "=== Simulation complete. Open waveforms: gtkwave dump.vcd ==="

wave: sim
	gtkwave dump.vcd &

show: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); show"

stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: all prog sim wave show stat clean
