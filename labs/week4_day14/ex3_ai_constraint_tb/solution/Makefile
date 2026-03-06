# Makefile — day14/ex3 AI constraint TB (solution)
SRCS     = tb_uart_tx_ai.sv
LIB      = ../../../../shared/lib
IVFLAGS  = -g2012 -Wall -y $(LIB)

sim: $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave dump.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
