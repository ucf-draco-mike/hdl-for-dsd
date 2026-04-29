# =============================================================================
# Makefile — week1_day04 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_d_ff/starter sim

ex2:
	$(MAKE) -C ex2_register/starter sim

ex3:
	$(MAKE) -C ex3_led_blinker/starter prog

ex4:
	$(MAKE) -C ex4_seg_counter/starter prog

ex5:
	$(MAKE) -C ex5_dual_blinker/starter prog

ex6:
	$(MAKE) -C ex6_updown_counter/starter prog

clean:
	$(MAKE) -C ex1_d_ff/starter clean
	$(MAKE) -C ex2_register/starter clean
	$(MAKE) -C ex3_led_blinker/starter clean
	$(MAKE) -C ex4_seg_counter/starter clean
	$(MAKE) -C ex5_dual_blinker/starter clean
	$(MAKE) -C ex6_updown_counter/starter clean

# Per-exercise sub-targets, e.g. `make ex1_sim` -> `make -C ex1_*/starter sim`
ex%_stat:
	$(MAKE) -C $(wildcard ex$*_*)/starter stat

ex%_sim:
	$(MAKE) -C $(wildcard ex$*_*)/starter sim

ex%_synth:
	$(MAKE) -C $(wildcard ex$*_*)/starter synth

ex%_wave:
	$(MAKE) -C $(wildcard ex$*_*)/starter wave

ex%_prog:
	$(MAKE) -C $(wildcard ex$*_*)/starter prog

.PHONY: ex1 ex2 ex3 ex4 ex5 ex6 clean
