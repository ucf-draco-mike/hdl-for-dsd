# =============================================================================
# Makefile — week1_day03 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
#
# Routes to the starter/ folder by default. Pass SOLUTION=1 (or
# VARIANT=solution) to route to the solution/ folder instead.
#
#   make ex1                 # build starter for exercise 1
#   make ex1 SOLUTION=1      # build solution for exercise 1
#   make ex2_sim SOLUTION=1  # simulate exercise 2 from solution/
# =============================================================================

VARIANT ?= starter
ifeq ($(SOLUTION),1)
VARIANT := solution
endif

ex1:
	$(MAKE) -C ex1_latch_bugs/$(VARIANT) synth

ex2:
	$(MAKE) -C ex2_priority_encoder/$(VARIANT) prog

ex3:
	$(MAKE) -C ex3_alu/$(VARIANT) prog

ex4:
	$(MAKE) -C ex4_bcd_7seg/$(VARIANT) prog

ex5:
	$(MAKE) -C ex5_top_alu_display/$(VARIANT) prog

clean:
	$(MAKE) -C ex1_latch_bugs/$(VARIANT) clean
	$(MAKE) -C ex2_priority_encoder/$(VARIANT) clean
	$(MAKE) -C ex3_alu/$(VARIANT) clean
	$(MAKE) -C ex4_bcd_7seg/$(VARIANT) clean
	$(MAKE) -C ex5_top_alu_display/$(VARIANT) clean

# Per-exercise sub-targets, e.g. `make ex1_synth` -> `make -C ex1_*/$(VARIANT) synth`
ex%_stat:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) stat

ex%_sim:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) sim

ex%_synth:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) synth

ex%_wave:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) wave

ex%_prog:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) prog

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
