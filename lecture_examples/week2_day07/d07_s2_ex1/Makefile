# Auto-generated Makefile — lecture example week2_day07/d07_s2_ex1
# Demo: traffic_light  (segment s2, example 1)
#
# Files:
#   day07_ex01_fsm_template.v   binary-encoded traffic light  (module: traffic_light)
#   day07_ex01_traffic_onehot.v one-hot variant               (module: traffic_light_onehot)
#   day07_ex01_traffic_gray.v   Gray-code variant             (module: traffic_light_gray)
#   tb_traffic_light.v          self-checking testbench
#
# Common targets:
#   make sim          # iverilog + vvp on the binary FSM
#   make wave         # GTKWave on the dumped VCD
#   make stat         # default = stat_binary
#   make stat_binary  # synth report for binary  encoding
#   make stat_onehot  # synth report for one-hot encoding
#   make stat_gray    # synth report for gray    encoding
#   make stat_all     # all three side-by-side, written to stats/*.txt
#   make synth        # binary encoding -> JSON
#   make prog         # full flow: synth -> nextpnr -> icepack -> iceprog
#   make clean

TOP      = traffic_light
SRCS     = day07_ex01_fsm_template.v
PCF      = traffic_light.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall -DSIMULATION

sim:
	@tb=$$(ls tb_*.v tb_*.sv 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo "[sim] No testbench (tb_*.v) in $$(pwd) — add one to simulate."; \
	else \
		iverilog $(IVFLAGS) -o sim.vvp $$tb $(SRCS) && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

# ---- Encoding-comparison targets (Topic 7.3 demo) ----
stat: stat_binary

stat_binary: $(SRCS)
	@mkdir -p stats
	yosys -p "read_verilog $(SRCS); synth_ice40 -top traffic_light -nofsm; stat" \
	    | tee stats/binary.txt

stat_onehot: day07_ex01_traffic_onehot.v
	@mkdir -p stats
	yosys -p "read_verilog day07_ex01_traffic_onehot.v; synth_ice40 -top traffic_light_onehot -nofsm; stat" \
	    | tee stats/onehot.txt

stat_gray: day07_ex01_traffic_gray.v
	@mkdir -p stats
	yosys -p "read_verilog day07_ex01_traffic_gray.v; synth_ice40 -top traffic_light_gray -nofsm; stat" \
	    | tee stats/gray.txt

stat_all: stat_binary stat_onehot stat_gray
	@echo ""
	@echo "=== Encoding comparison summary ==="
	@for f in stats/binary.txt stats/onehot.txt stats/gray.txt; do \
	    echo "--- $$f ---"; \
	    grep -E 'SB_DFF|SB_LUT4|Number of cells' $$f || true; \
	done

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log
	rm -rf stats

.PHONY: sim wave synth prog stat stat_binary stat_onehot stat_gray stat_all clean
