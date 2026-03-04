# Makefile — AI Constraint-Based Testbench
# Day 14, Exercise 3
#
# Students: set TOP, SRCS, and TB to your project module files.

TOP    ?= your_module
SRCS   ?= your_module.sv
TB     ?= tb_your_module.sv
IVERILOG_FLAGS = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVERILOG_FLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp
	@echo "=== Simulation complete ==="

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
