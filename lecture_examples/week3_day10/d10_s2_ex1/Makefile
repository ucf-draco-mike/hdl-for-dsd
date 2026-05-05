# Auto-generated Makefile — lecture example week3_day10/d10_s2_ex1
# Demos referenced by Day 10 slides:
#   s1: `make timing`           — adder_slow vs adder_fast Fmax demo
#   s2: `make stat WIDTH=N`     — parallel multiplier LUT scaling
#   s2: `make stat_seq WIDTH=N` — sequential (shift-and-add) multiplier
#
# Default WIDTH=8 keeps a no-arg invocation reasonable.
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

WIDTH ?= 8

# ---- Default: parallel multiplier @ WIDTH ----
TOP_PAR  = mult_parallel
SRC_PAR  = day10_mult_parallel.v
TOP_SEQ  = mult_sequential
SRC_SEQ  = day10_mult_sequential.v
TOP_SLOW = adder_slow
TOP_FAST = adder_fast
SRC_SLOW = adder_slow.v
SRC_FAST = adder_fast.v

# ---- Generic targets (operate on parallel multiplier by default) ----
sim: sim_par

# Parallel-mult sanity sim (drives a few hand-checked cases via $display).
sim_par:
	iverilog $(IVFLAGS) -DWIDTH=$(WIDTH) -o sim_par.vvp tb_adder_widths.v day10_adder_widths.v && vvp sim_par.vvp

# Sequential-mult testbench.
sim_seq:
	iverilog $(IVFLAGS) -DTB_W=$(WIDTH) -o sim_seq.vvp tb_mult_sequential.v $(SRC_SEQ) && vvp sim_seq.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

# ---- s2: parallel multiplier LUT scaling ----
stat: $(SRC_PAR)
	yosys -p "read_verilog -DWIDTH=$(WIDTH) $(SRC_PAR); synth_ice40 -top $(TOP_PAR); stat"

synth: $(SRC_PAR)
	yosys -p "read_verilog -DWIDTH=$(WIDTH) $(SRC_PAR); synth_ice40 -top $(TOP_PAR) -json $(TOP_PAR).json"

# ---- s2: sequential multiplier LUT/cycle trade-off ----
stat_seq: $(SRC_SEQ)
	yosys -p "read_verilog -DWIDTH=$(WIDTH) $(SRC_SEQ); synth_ice40 -top $(TOP_SEQ); stat"

# ---- s1: timing comparison — slow vs fast adder ----
timing: $(SRC_SLOW) $(SRC_FAST)
	@echo "==> Synth + place&route adder_slow (single-cycle wide add)"
	yosys -p "read_verilog $(SRC_SLOW); synth_ice40 -top $(TOP_SLOW) -json $(TOP_SLOW).json"
	-nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP_SLOW).json --asc $(TOP_SLOW).asc --freq 25 2>&1 | tail -n 20
	@echo
	@echo "==> Synth + place&route adder_fast (pipelined)"
	yosys -p "read_verilog $(SRC_FAST); synth_ice40 -top $(TOP_FAST) -json $(TOP_FAST).json"
	-nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP_FAST).json --asc $(TOP_FAST).asc --freq 25 2>&1 | tail -n 20

# ---- Original adder-width LUT scaling (kept for the s2 LUT-table refresher) ----
stat_adders: day10_adder_widths.v
	yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_4bit;  stat"
	yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_8bit;  stat"
	yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_16bit; stat"
	yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_32bit; stat"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP_PAR).json --asc $(TOP_PAR).asc --freq 25
	icepack $(TOP_PAR).asc $(TOP_PAR).bin
	iceprog $(TOP_PAR).bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim sim_par sim_seq wave stat stat_seq stat_adders timing synth prog clean
