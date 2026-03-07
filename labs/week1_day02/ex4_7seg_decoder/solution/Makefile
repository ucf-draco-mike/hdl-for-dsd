# Auto-generated Makefile
SRCS     = ex4_hex_to_7seg.v
TB       = tb_hex_to_7seg.v
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
