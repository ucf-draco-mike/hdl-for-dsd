# Auto-generated Makefile
TOP      = led_on
SRCS     = ex1_led_on.v
PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim:
	@tb=$$(ls tb_*.v 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo ""; \
		echo "[sim] No testbench present in $$(pwd)."; \
		echo ""; \
		echo "      To add one, create 'tb_<top_module>.v' in this directory."; \
		echo "      Skeleton:"; \
		echo ""; \
		echo "        \`timescale 1ns/1ps"; \
		echo "        module tb_<top_module>;"; \
		echo "          // declare regs/wires, instantiate the DUT,"; \
		echo "          // drive stimulus, dump VCD via \$$dumpfile/\$$dumpvars,"; \
		echo "          // and call \$$finish when done."; \
		echo "        endmodule"; \
		echo ""; \
		echo "      Then re-run: make sim"; \
		echo ""; \
	else \
		srcs=$$(ls *.v 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		echo "iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs"; \
		iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP) -json $(TOP).json" $(SRCS)

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP); stat" $(SRCS)

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

# CTF gating — see scripts/lab_ctf/README.md
CTF_DIR := ../../../../scripts/lab_ctf

# Run the published testbench against your DUT. On a passing run, prints
# the per-exercise flag (which unlocks the next exercise's reference).
test:
	@bash $(CTF_DIR)/check_solution.sh

# Decrypt this exercise's reference DUT into ../solution/ref/.
# For ex1 (start of the chain) pass COURSE_KEY=...; for later exercises
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
