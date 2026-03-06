# =============================================================================
# Makefile — week3_day10 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_adder_comparison/starter stat_all

ex2:
	$(MAKE) -C ex2_shift_add_multiplier/starter sim

ex3:
	$(MAKE) -C ex3_fixed_point/starter sim

ex4:
	@echo "Exercise 4 is a timing worksheet — see ex4_timing_exercise/starter/README.md"

ex5:
	$(MAKE) -C ex5_pll_cdc_stretch/starter prog_cdc

clean:
	$(MAKE) -C ex1_adder_comparison/starter clean
	$(MAKE) -C ex2_shift_add_multiplier/starter clean
	$(MAKE) -C ex3_fixed_point/starter clean
	$(MAKE) -C ex5_pll_cdc_stretch/starter clean

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
