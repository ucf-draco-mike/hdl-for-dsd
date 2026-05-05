# Auto-generated Makefile — lecture example week1_day02/d02_s2_ex2
# Demo: Operator Cost Showdown  (segment s2)
#
# Top-level designs in this directory:
#   bitwise_and       — d02_s2 cost demo: per-bit AND (cheap)
#   adder             — d02_s2 cost demo: ripple add (moderate)
#   multiplier        — d02_s2 cost demo: N×N multiply (expensive)
#   mux_2to1          — Day 2 baseline 2:1 multiplexer (We Do warmup)
#   mux_4to1_nested   — d02_s2 4:1 mux via nested ?:    (We Do warmup)
#   mux_4to1_case     — d02_s2 4:1 mux via always @(*) + case (We Do warmup)
#
# (The s3 width-mismatch demo lives in ../d02_s3_ex5/.)
#
# `make stat-ops` is the s2 live demo: synthesizes all three operator
# modules and prints the LUT/carry counts side by side. `make stat`
# reports on a single TOP (defaults to `multiplier`).
TOP      = multiplier
OP_SRCS  = op_compare.v
MUX_SRCS = day02_ex02_mux_2to1.v day02_ex02_mux_4to1.v
SRCS     = $(OP_SRCS) $(MUX_SRCS)
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

# Explicit testbench so `make sim` always runs the unified mux demo.
TB       = tb_mux_demo.v

sim:
	@srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $$srcs && vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); stat"

# Operator Cost Showdown — synth each of bitwise_and / adder / multiplier
# in turn so the LUT/carry numbers print side by side. Headers make the
# three blocks easy to scan during the live demo.
stat-ops: $(OP_SRCS)
	@for top in bitwise_and adder multiplier; do \
	  echo ""; \
	  echo "==================== $$top (8-bit) ===================="; \
	  yosys -p "read_verilog $(OP_SRCS); synth_ice40 -top $$top; stat" 2>&1 \
	    | grep -E '(SB_LUT4|SB_CARRY)[[:space:]]+[0-9]+|Number of cells' || true; \
	done

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat stat-ops clean
