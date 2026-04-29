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

# Per-exercise sub-targets, e.g. `make ex1_synth` -> `make -C ex1_*/starter synth`
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
