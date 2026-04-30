# Auto-generated dispatcher Makefile — week3_day11
# Routes targets into per-example subdirectories.
#
# Usage:
#   make ex1            # default target for ex1 (stat or sim)
#   make ex1_sim        # simulate
#   make ex1_stat       # synth report
#   make ex1_synth      # synth to JSON
#   make ex1_prog       # full bitstream + iceprog
#   make ex1_clean      # clean

EXAMPLES := d11_s3_ex1

ex1:
	$(MAKE) -C d11_s3_ex1 stat

clean:
	$(MAKE) -C d11_s3_ex1 clean

ex%_sim:
	$(MAKE) -C $(wildcard d11_s*_ex$*) sim

ex%_wave:
	$(MAKE) -C $(wildcard d11_s*_ex$*) wave

ex%_stat:
	$(MAKE) -C $(wildcard d11_s*_ex$*) stat

ex%_synth:
	$(MAKE) -C $(wildcard d11_s*_ex$*) synth

ex%_prog:
	$(MAKE) -C $(wildcard d11_s*_ex$*) prog

ex%_clean:
	$(MAKE) -C $(wildcard d11_s*_ex$*) clean

.PHONY: clean ex1 ex1_sim ex1_stat ex1_synth ex1_prog ex1_wave ex1_clean
