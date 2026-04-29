# =============================================================================
# Makefile — week1_day02 (dispatcher)
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
	$(MAKE) -C ex1_vector_ops/$(VARIANT) prog

ex2:
	$(MAKE) -C ex2_mux_hierarchy/$(VARIANT) prog

ex3:
	$(MAKE) -C ex3_ripple_adder/$(VARIANT) prog

ex4:
	$(MAKE) -C ex4_7seg_decoder/$(VARIANT) prog

ex5:
	$(MAKE) -C ex5_top_adder_display/$(VARIANT) prog

clean:
	$(MAKE) -C ex1_vector_ops/$(VARIANT) clean
	$(MAKE) -C ex2_mux_hierarchy/$(VARIANT) clean
	$(MAKE) -C ex3_ripple_adder/$(VARIANT) clean
	$(MAKE) -C ex4_7seg_decoder/$(VARIANT) clean
	$(MAKE) -C ex5_top_adder_display/$(VARIANT) clean

# Per-exercise sub-targets, e.g. `make ex2_show` -> `make -C ex2_*/$(VARIANT) show`
ex%_stat:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) stat

ex%_sim:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) sim

ex%_synth:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) synth

ex%_wave:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) wave

ex%_show:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) show

ex%_prog:
	$(MAKE) -C $(wildcard ex$*_*)/$(VARIANT) prog

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
