# =============================================================================
# Makefile — week3_day10 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
#
# Routes to the starter/ folder by default. Pass SOLUTION=1 (or
# VARIANT=solution) to route to the solution/ folder instead.
#
#   make ex2                 # simulate starter for exercise 2
#   make ex2 SOLUTION=1      # simulate solution for exercise 2
# =============================================================================

VARIANT ?= starter
ifeq ($(SOLUTION),1)
VARIANT := solution
endif

ex1:
	$(MAKE) -C ex1_adder_comparison/$(VARIANT) stat_all

ex2:
	$(MAKE) -C ex2_shift_add_multiplier/$(VARIANT) sim

ex3:
	$(MAKE) -C ex3_fixed_point/$(VARIANT) sim

ex4:
	@echo "Exercise 4 is a timing worksheet — see ex4_timing_exercise/$(VARIANT)/README.md"

ex5:
	$(MAKE) -C ex5_pll_cdc_stretch/$(VARIANT) prog_cdc

clean:
	$(MAKE) -C ex1_adder_comparison/$(VARIANT) clean
	$(MAKE) -C ex2_shift_add_multiplier/$(VARIANT) clean
	$(MAKE) -C ex3_fixed_point/$(VARIANT) clean
	$(MAKE) -C ex5_pll_cdc_stretch/$(VARIANT) clean

# Per-exercise sub-targets, e.g. `make ex2_sim` -> `make -C ex2_*/$(VARIANT) sim`
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
