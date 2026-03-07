# Auto-generated Makefile
SRCS     = ex1_latch_bugs.v
TB       = tb_latch_bugs.v
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
