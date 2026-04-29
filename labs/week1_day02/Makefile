# =============================================================================
# Makefile — week1_day02 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_vector_ops/starter prog

ex2:
	$(MAKE) -C ex2_mux_hierarchy/starter prog

ex3:
	$(MAKE) -C ex3_ripple_adder/starter prog

ex4:
	$(MAKE) -C ex4_7seg_decoder/starter prog

ex5:
	$(MAKE) -C ex5_top_adder_display/starter prog

clean:
	$(MAKE) -C ex1_vector_ops/starter clean
	$(MAKE) -C ex2_mux_hierarchy/starter clean
	$(MAKE) -C ex3_ripple_adder/starter clean
	$(MAKE) -C ex4_7seg_decoder/starter clean
	$(MAKE) -C ex5_top_adder_display/starter clean

# Per-exercise sub-targets, e.g. `make ex2_show` -> `make -C ex2_*/starter show`
ex%_stat:
	$(MAKE) -C $(wildcard ex$*_*)/starter stat

ex%_sim:
	$(MAKE) -C $(wildcard ex$*_*)/starter sim

ex%_synth:
	$(MAKE) -C $(wildcard ex$*_*)/starter synth

ex%_wave:
	$(MAKE) -C $(wildcard ex$*_*)/starter wave

ex%_show:
	$(MAKE) -C $(wildcard ex$*_*)/starter show

ex%_prog:
	$(MAKE) -C $(wildcard ex$*_*)/starter prog

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
