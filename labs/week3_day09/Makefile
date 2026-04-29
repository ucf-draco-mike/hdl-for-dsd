# =============================================================================
# Makefile — week3_day09 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
#
# Routes to the starter/ folder by default. Pass SOLUTION=1 (or
# VARIANT=solution) to route to the solution/ folder instead.
#
#   make ex1                 # simulate starter for exercise 1
#   make ex1 SOLUTION=1      # simulate solution for exercise 1
# =============================================================================

VARIANT ?= starter
ifeq ($(SOLUTION),1)
VARIANT := solution
endif

ex1:
	$(MAKE) -C ex1_rom_sequencer/$(VARIANT) sim

ex2:
	$(MAKE) -C ex2_sync_ram/$(VARIANT) sim

ex3:
	$(MAKE) -C ex3_initialized_ram/$(VARIANT) sim

ex4:
	$(MAKE) -C ex4_dual_display/$(VARIANT) sim

ex5:
	$(MAKE) -C ex5_register_file/$(VARIANT) sim

clean:
	$(MAKE) -C ex1_rom_sequencer/$(VARIANT) clean
	$(MAKE) -C ex2_sync_ram/$(VARIANT) clean
	$(MAKE) -C ex3_initialized_ram/$(VARIANT) clean
	$(MAKE) -C ex4_dual_display/$(VARIANT) clean
	$(MAKE) -C ex5_register_file/$(VARIANT) clean

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

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
