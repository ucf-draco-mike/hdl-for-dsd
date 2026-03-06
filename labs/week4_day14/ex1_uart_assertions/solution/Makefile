# Makefile — uart_tx_asserted
PROJECT  = uart_tx_asserted
TOP      = uart_tx_asserted
PCF      = ../../go_board.pcf
SRCS     = uart_tx_asserted.sv
TB       = tb_uart_tx_asserted.sv

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
