# =============================================================================
# Makefile — week1_day03 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_latch_bugs/starter synth

ex2:
	$(MAKE) -C ex2_priority_encoder/starter prog

ex3:
	$(MAKE) -C ex3_alu/starter prog

ex4:
	$(MAKE) -C ex4_bcd_7seg/starter prog

ex5:
	$(MAKE) -C ex5_top_alu_display/starter prog

clean:
	$(MAKE) -C ex1_latch_bugs/starter clean
	$(MAKE) -C ex2_priority_encoder/starter clean
	$(MAKE) -C ex3_alu/starter clean
	$(MAKE) -C ex4_bcd_7seg/starter clean
	$(MAKE) -C ex5_top_alu_display/starter clean

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
