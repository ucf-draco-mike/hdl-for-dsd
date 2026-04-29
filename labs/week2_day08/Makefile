# =============================================================================
# Makefile — week2_day08 (dispatcher)
# Day 8: Hierarchy, Parameters & Generate
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
	$(MAKE) -C ex1_parameterized_counter/$(VARIANT) sim

ex2:
	$(MAKE) -C ex2_generate_debounce/$(VARIANT) prog

ex3:
	$(MAKE) -C ex3_capstone_lab_instrument/$(VARIANT) prog

ex4:
	$(MAKE) -C ex4_lfsr_generic/$(VARIANT) prog

clean:
	$(MAKE) -C ex1_parameterized_counter/$(VARIANT) clean
	$(MAKE) -C ex2_generate_debounce/$(VARIANT) clean
	$(MAKE) -C ex3_capstone_lab_instrument/$(VARIANT) clean
	$(MAKE) -C ex4_lfsr_generic/$(VARIANT) clean

# Per-exercise sub-targets, e.g. `make ex1_sim` -> `make -C ex1_*/$(VARIANT) sim`
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

.PHONY: ex1 ex2 ex3 ex4 clean
