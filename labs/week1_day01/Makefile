# =============================================================================
# Makefile — week1_day01 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_led_on/starter prog

ex2:
	$(MAKE) -C ex2_buttons_to_leds/starter prog

ex3:
	$(MAKE) -C ex3_button_logic/starter prog

ex4:
	$(MAKE) -C ex4_active_low_clean/starter prog

ex5:
	$(MAKE) -C ex5_xor_pattern/starter prog

clean:
	$(MAKE) -C ex1_led_on/starter clean
	$(MAKE) -C ex2_buttons_to_leds/starter clean
	$(MAKE) -C ex3_button_logic/starter clean
	$(MAKE) -C ex4_active_low_clean/starter clean
	$(MAKE) -C ex5_xor_pattern/starter clean

# Per-exercise sub-targets, e.g. `make ex1_stat` -> `make -C ex1_*/starter stat`
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

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
