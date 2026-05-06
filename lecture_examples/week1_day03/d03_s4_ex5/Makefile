# Auto-generated Makefile — lecture example week1_day03/d03_s4_ex5
# Demo: combinational capstone — baseline ALU vs extended ALU (XOR + variable shift)
#
# Two modules live side-by-side so each can be synthesized on its own and the
# resulting LUT/CARRY counts compared:
#   alu_4bit.v      -> make stat-baseline   (expect ~25 LUT4, 8 CARRY)
#   alu_4bit_ext.v  -> make stat-ext        (expect ~43 LUT4, 8 CARRY)
TOP          = alu_4bit_ext
BASE_SRC     = alu_4bit.v
EXT_SRC      = alu_4bit_ext.v
SRCS         = $(BASE_SRC) $(EXT_SRC)
PCF          = ../go_board.pcf
DEVICE       = hx1k
PACKAGE      = vq100
IVFLAGS      = -g2012 -Wall

sim:
	@tb=$$(ls tb_*.v tb_*.sv 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo "[sim] No testbench (tb_*.v) in $$(pwd) — add one to simulate."; \
	else \
		srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(EXT_SRC)
	yosys -p "read_verilog $(EXT_SRC); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

# Synthesize each ALU on its own so the cell count reflects only that variant.
# `make stat` runs both back-to-back for the side-by-side comparison.
stat-baseline: $(BASE_SRC)
	@echo "=== alu_4bit (baseline: ADD/SUB/AND/OR) ==="
	yosys -p "read_verilog $(BASE_SRC); synth_ice40 -top alu_4bit; stat"

stat-ext: $(EXT_SRC)
	@echo "=== alu_4bit_ext (+ XOR + variable SHL) ==="
	yosys -p "read_verilog $(EXT_SRC); synth_ice40 -top alu_4bit_ext; stat"

stat: stat-baseline stat-ext

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat stat-baseline stat-ext clean
