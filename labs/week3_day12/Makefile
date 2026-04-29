# =============================================================================
# Makefile — week3_day12 (dispatcher)
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
	$(MAKE) -C ex1_uart_rx/$(VARIANT) sim

ex2:
	$(MAKE) -C ex2_loopback/$(VARIANT) prog

ex3:
	$(MAKE) -C ex3_spi_master/$(VARIANT) sim

clean:
	$(MAKE) -C ex1_uart_rx/$(VARIANT) clean
	$(MAKE) -C ex2_loopback/$(VARIANT) clean
	$(MAKE) -C ex3_spi_master/$(VARIANT) clean

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

.PHONY: ex1 ex2 ex3 clean
