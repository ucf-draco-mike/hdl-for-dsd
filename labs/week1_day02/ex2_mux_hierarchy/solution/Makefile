# Auto-generated Makefile
SRCS     = ex2_mux2to1.v ex2_mux4to1.v
TB       = tb_mux.v
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
