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

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
