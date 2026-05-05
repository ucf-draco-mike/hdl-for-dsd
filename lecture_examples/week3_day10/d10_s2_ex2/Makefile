# Auto-generated Makefile — lecture example week3_day10/d10_s2_ex2
# Demo referenced by Day 10 slides:
#   s3: `make ppa_report`  — synth all three traffic-FSM encodings,
#                            place&route, write report.csv
#
# Also keeps the original mult_widths LUT-scaling example available for
# anyone walking through the s2 LUT estimation refresher.
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

FSM_SRCS  = day10_traffic_binary.v day10_traffic_onehot.v day10_traffic_gray.v
FSM_TBS   = tb_traffic_variants.v
MULT_SRCS = day10_mult_widths.v

# ---- s3 PPA demo ----
ppa_report:
	@./ppa_report.sh
	@echo
	@cat report.csv

# ---- testbench for the FSM variants (functional check) ----
sim:
	iverilog $(IVFLAGS) -o sim.vvp $(FSM_TBS) $(FSM_SRCS) && vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

# ---- per-variant synth stat (handy for spot-checks) ----
stat: $(FSM_SRCS)
	yosys -p "read_verilog $(FSM_SRCS); synth_ice40 -top traffic_binary; stat"
	yosys -p "read_verilog $(FSM_SRCS); synth_ice40 -top traffic_onehot; stat"
	yosys -p "read_verilog $(FSM_SRCS); synth_ice40 -top traffic_gray;   stat"

synth: $(FSM_SRCS)
	yosys -p "read_verilog $(FSM_SRCS); synth_ice40 -top traffic_binary -json traffic_binary.json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json traffic_binary.json --asc traffic_binary.asc --freq 25
	icepack traffic_binary.asc traffic_binary.bin
	iceprog traffic_binary.bin

# ---- s2 multiplier-width LUT scaling (kept for reference) ----
sim_mult:
	iverilog $(IVFLAGS) -o sim_mult.vvp tb_mult_widths.v $(MULT_SRCS) && vvp sim_mult.vvp

stat_mult: $(MULT_SRCS)
	yosys -p "read_verilog $(MULT_SRCS); synth_ice40 -top mult_4bit;  stat"
	yosys -p "read_verilog $(MULT_SRCS); synth_ice40 -top mult_8bit;  stat"
	yosys -p "read_verilog $(MULT_SRCS); synth_ice40 -top mult_16bit; stat"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log report.csv

.PHONY: ppa_report sim wave stat synth prog clean sim_mult stat_mult
