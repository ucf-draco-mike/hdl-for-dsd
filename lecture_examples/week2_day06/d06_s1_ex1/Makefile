# Auto-generated Makefile — lecture example week2_day06/d06_s1_ex1
#
# Hosts the four "testbench-evolution" Live Demos for Day 6:
#   d06_s1: tb_adder.v          — bare-bones, print-only testbench
#   d06_s2: tb_adder_before.v   — print-only "before" snapshot
#           tb_adder_after.v    — self-checking "after" snapshot
#   d06_s3: tb_before.v         — monolithic before refactor
#           tb_after.v          — task-based after refactor
#   d06_s4: tb_adder_file.v     — file-driven 1000-vector test
#                                 (reads vectors.hex from gen_vectors.py)
#   Lab:    day06_ex01_tb_alu_template.v — self-checking ALU TB seed
#
# Quick usage:
#   make sim          # default = tb_adder_after (the canonical s2 result)
#   make sim TB=tb_adder.v
#   make sim TB=tb_after.v
#   make sim_file     # generates vectors.hex first, then runs the file TB
#   make sim_alu      # runs the ALU template testbench
#   make wave         # gtkwave on the most recent VCD

DUT      = adder.v
TB      ?= tb_adder_after.v
IVFLAGS  = -g2012 -Wall

sim:
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(DUT) && vvp sim.vvp

sim_file: vectors.hex
	iverilog $(IVFLAGS) -o sim_file.vvp tb_adder_file.v $(DUT) && vvp sim_file.vvp

sim_alu:
	iverilog $(IVFLAGS) -o sim_alu.vvp day06_ex01_tb_alu_template.v && vvp sim_alu.vvp

vectors.hex: gen_vectors.py
	python3 gen_vectors.py

wave:
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced — run make sim first."; fi

clean:
	rm -f *.vvp *.vcd *.log vectors.hex

.PHONY: sim sim_file sim_alu wave clean
