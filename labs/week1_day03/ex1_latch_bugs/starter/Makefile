# Auto-generated Makefile
TOP      = latch_bugs
SRCS     = ex1_latch_bugs.v
TB       = tb_latch_bugs.v
PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

all: stat

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP)"

stat: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP); stat" $(SRCS)

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean all
