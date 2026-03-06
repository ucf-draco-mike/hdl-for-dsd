# Auto-generated Makefile
TOP      = tb_uart_tx_ai
SRCS     = tb_uart_tx_ai.sv ../../ex1_uart_assertions/starter/uart_tx_asserted.sv
IVFLAGS  = -g2012 -Wall

sim: $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave dump.vcd &

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
