# Auto-generated Makefile
SRCS     = ex2_priority_encoder.v
TB       = tb_priority_encoder.v
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
