# Auto-generated dispatcher Makefile — week2_day06
# Routes targets into per-example subdirectories.
#
# Usage:
#   make ex1            # default target for ex1 (stat or sim)
#   make ex1_sim        # simulate
#   make ex1_stat       # synth report
#   make ex1_synth      # synth to JSON
#   make ex1_prog       # full bitstream + iceprog
#   make ex1_clean      # clean

EXAMPLES := d06_s1_ex1

ex1:
	$(MAKE) -C d06_s1_ex1 sim

clean:
	$(MAKE) -C d06_s1_ex1 clean

ex%_sim:
	$(MAKE) -C $(wildcard d06_s*_ex$*) sim

ex%_wave:
	$(MAKE) -C $(wildcard d06_s*_ex$*) wave

ex%_stat:
	$(MAKE) -C $(wildcard d06_s*_ex$*) stat

ex%_synth:
	$(MAKE) -C $(wildcard d06_s*_ex$*) synth

ex%_prog:
	$(MAKE) -C $(wildcard d06_s*_ex$*) prog

ex%_clean:
	$(MAKE) -C $(wildcard d06_s*_ex$*) clean

.PHONY: clean ex1 ex1_sim ex1_stat ex1_synth ex1_prog ex1_wave ex1_clean
