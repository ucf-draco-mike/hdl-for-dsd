# Makefile — top_pipeline
PROJECT  = top_pipeline
TOP      = top_pipeline
PCF      = ../go_board.pcf
SRCS     = top_pipeline.v
TB       = tb_top_pipeline.v

DEVICE   = hx1k
PACKAGE  = vq100

IVERILOG_FLAGS = -g2012 -Wall

all: sim

sim: $(TB) $(SRCS)
	iverilog $(IVERILOG_FLAGS) -o sim.vvp $(TB) $(filter-out $(TB),$(SRCS))
	vvp sim.vvp
	@echo "=== Simulation complete ==="

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: all prog sim wave stat clean
