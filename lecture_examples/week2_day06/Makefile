# Dispatcher Makefile — week2_day06
# Routes targets into per-example subdirectories.
#
# This day is a pure testbench template (tb_alu) — not synthesizable on its
# own — so only simulation targets are wired up. There are no stat/synth/prog
# targets here.
#
# Examples in this day:
#   ex1 -> d06_s1_ex1  (tb_alu testbench template, segment s1)
#
# Targets:
#   make ex1          # default: sim (iverilog + vvp)
#   make ex1_sim      # iverilog + vvp simulation
#   make ex1_wave     # run sim, then open VCD in gtkwave
#   make ex1_clean    # remove build artifacts in that example
#   make clean        # clean every example in this day

EXAMPLES := d06_s1_ex1
EX_NUMS  := 1

ex1:
	$(MAKE) -C d06_s1_ex1 sim

clean:
	$(MAKE) -C d06_s1_ex1 clean

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(wildcard d06_s*_ex$*) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(wildcard d06_s*_ex$*) wave
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(wildcard d06_s*_ex$*) clean

.PHONY: clean ex1 $(SIM_TARGETS) $(WAVE_TARGETS) $(CLEAN_TARGETS)
