# Makefile — UART TX Parity Extension
# Day 14, Exercise 2

SRCS     = uart_tx_parity.sv
TB       = tb_uart_tx_parity.sv
PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVERILOG_FLAGS = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVERILOG_FLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp
	@echo "=== Simulation complete ==="

wave: sim
	gtkwave uart_parity.vcd &

# PPA comparison: synthesize both configurations
stat_no_parity:
	@echo "=== PARITY_EN=0 ==="
	yosys -p "read_verilog -sv -DPARITY_EN=0 $(SRCS); synth_ice40 -top uart_tx_parity; stat"

stat_even_parity:
	@echo "=== PARITY_EN=1, PARITY_TYPE=0 (even) ==="
	yosys -p "read_verilog -sv $(SRCS); synth_ice40 -top uart_tx_parity; stat"

stat_both: stat_no_parity stat_even_parity

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

# CTF gating — see scripts/lab_ctf/README.md
CTF_DIR := ../../../../scripts/lab_ctf

# Run the published testbench against your DUT. On a passing run, prints
# the per-exercise flag (which unlocks the next exercise's reference).
test:
	@bash $(CTF_DIR)/check_solution.sh

# Decrypt this exercise's reference DUT into ../solution/ref/.
# For the first sealed exercise, pass COURSE_KEY=...; for later exercises
# pass FLAG=... (the flag emitted by the previous exercise's `make test`).
unlock:
	@key="$(FLAG)$(COURSE_KEY)"; \
	if [ -z "$$key" ]; then \
		echo "Usage: make unlock FLAG=<flag>     (chain unlock)"; \
		echo "       make unlock COURSE_KEY=<k>  (first exercise only)"; \
		exit 2; \
	fi; \
	bash $(CTF_DIR)/unlock_solution.sh "$$key"

.PHONY: sim wave synth prog stat clean test unlock all
