# shared/lib/Makefile — Run all shared module testbenches
# Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF

IVFLAGS = -g2012 -Wall

MODULES = hex_to_7seg debounce counter_mod_n uart_tx uart_rx baud_gen edge_detect heartbeat

.PHONY: all clean $(MODULES)

all: $(MODULES)
	@echo ""
	@echo "=== All shared library testbenches complete ==="

hex_to_7seg:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

debounce:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

counter_mod_n:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

uart_tx:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v baud_gen.v
	vvp tb_$@.vvp

uart_rx:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

baud_gen:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

edge_detect:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

heartbeat:
	@echo "--- $@ ---"
	iverilog $(IVFLAGS) -o tb_$@.vvp tb_$@.v $@.v
	vvp tb_$@.vvp

clean:
	rm -f *.vvp *.vcd *.log
