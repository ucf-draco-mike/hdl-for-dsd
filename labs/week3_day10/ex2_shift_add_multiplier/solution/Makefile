# Makefile — Shift-and-Add Multiplier
# Day 10, Exercise 2

PROJECT  = shift_add_mult
TOP      = shift_add_mult
PCF      = ../../go_board.pcf
SRCS     = shift_add_mult.v
TB       = tb_shift_add_mult.v

DEVICE   = hx1k
PACKAGE  = vq100
IVERILOG_FLAGS = -g2012 -Wall

all: sim

sim: $(TB) $(SRCS)
	iverilog $(IVERILOG_FLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp
	@echo "=== Simulation complete ==="

wave: sim
	gtkwave shift_add_mult.vcd &

stat_seq:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top shift_add_mult; stat"

stat_comb:
	yosys -p "read_verilog $(SRCS); synth_ice40 -top comb_mult; stat"

stat_all: stat_seq stat_comb

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: all sim wave stat_seq stat_comb stat_all clean
