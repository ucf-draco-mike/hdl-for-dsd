# Auto-generated Makefile
SRCS     = ex3_full_adder.v ex3_ripple_adder_4bit.v
TB       = tb_adder.v
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
