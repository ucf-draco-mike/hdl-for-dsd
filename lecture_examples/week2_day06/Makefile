# Dispatcher Makefile — week2_day06
# Routes targets into per-example subdirectories.
#
# Day 6's four Live Demos all converge on a single example dir
# (d06_s1_ex1) — the demo IS the testbench, evolving across the four
# slide segments. The dir hosts every variant the demos reference plus
# the lab's self-checking ALU testbench template:
#
#   d06_s1: tb_adder.v          — bare-bones, print-only testbench
#   d06_s2: tb_adder_before.v   — print-only "before" snapshot
#           tb_adder_after.v    — self-checking "after" snapshot
#   d06_s3: tb_before.v         — monolithic before refactor
#           tb_after.v          — task-based after refactor
#   d06_s4: tb_adder_file.v     — file-driven 1000-vector test
#                                 (reads vectors.hex from gen_vectors.py)
#   Lab:    day06_ex01_tb_alu_template.v — self-checking ALU TB seed
#
# This day is a pure testbench progression — no synthesizable top — so
# only simulation targets are wired up. There are no stat/synth/prog
# targets here.
#
# Targets:
#   make ex1            # default: sim (tb_adder_after.v)
#   make ex1_sim        # iverilog + vvp simulation (defaults to tb_adder_after.v)
#   make ex1_sim_file   # generate vectors.hex, then run tb_adder_file.v
#   make ex1_sim_alu    # run the self-checking ALU template testbench
#   make ex1_wave       # run sim, then open VCD in gtkwave
#   make ex1_clean      # remove build artifacts in that example
#   make clean          # clean every example in this day

EXAMPLES := d06_s1_ex1
EX_NUMS  := 1

ex1:
	$(MAKE) -C d06_s1_ex1 sim

clean:
	$(MAKE) -C d06_s1_ex1 clean

SIM_TARGETS      := $(foreach n,$(EX_NUMS),ex$(n)_sim)
SIM_FILE_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_sim_file)
SIM_ALU_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_sim_alu)
WAVE_TARGETS     := $(foreach n,$(EX_NUMS),ex$(n)_wave)
CLEAN_TARGETS    := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):      ex%_sim:      ; $(MAKE) -C $(wildcard d06_s*_ex$*) sim
$(SIM_FILE_TARGETS): ex%_sim_file: ; $(MAKE) -C $(wildcard d06_s*_ex$*) sim_file
$(SIM_ALU_TARGETS):  ex%_sim_alu:  ; $(MAKE) -C $(wildcard d06_s*_ex$*) sim_alu
$(WAVE_TARGETS):     ex%_wave:     ; $(MAKE) -C $(wildcard d06_s*_ex$*) wave
$(CLEAN_TARGETS):    ex%_clean:    ; $(MAKE) -C $(wildcard d06_s*_ex$*) clean

.PHONY: clean ex1 $(SIM_TARGETS) $(SIM_FILE_TARGETS) $(SIM_ALU_TARGETS) $(WAVE_TARGETS) $(CLEAN_TARGETS)
