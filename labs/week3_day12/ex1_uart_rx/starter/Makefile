# Makefile — uart_rx
PROJECT  = uart_rx
TOP      = uart_rx
PCF      = ../../go_board.pcf

FETCH_FROM_SHARED   := uart_tx.v
FETCH_FROM_SOLUTION := tb_uart_rx.v
include ../../../auto_fetch.mk

SRCS     = uart_rx.v $(FETCH_FROM_SHARED)
TB       = tb_uart_rx.v

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

.PHONY: all sim wave clean
