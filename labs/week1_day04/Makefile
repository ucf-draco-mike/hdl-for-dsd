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

.PHONY: ex1 ex2 ex3 ex4 ex5 ex6 clean
