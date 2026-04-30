# Auto-generated dispatcher Makefile — week1_day01
# Routes targets into per-example subdirectories.
#
# Usage:
#   make ex1            # default target for ex1 (stat or sim)
#   make ex1_sim        # simulate
#   make ex1_stat       # synth report
#   make ex1_synth      # synth to JSON
#   make ex1_prog       # full bitstream + iceprog
#   make ex1_clean      # clean

EXAMPLES := d01_s3_ex1 d01_s3_ex2

ex1:
	$(MAKE) -C d01_s3_ex1 stat

ex2:
	$(MAKE) -C d01_s3_ex2 stat

clean:
	$(MAKE) -C d01_s3_ex1 clean
	$(MAKE) -C d01_s3_ex2 clean

ex%_sim:
	$(MAKE) -C $(wildcard d01_s*_ex$*) sim

ex%_wave:
	$(MAKE) -C $(wildcard d01_s*_ex$*) wave

ex%_stat:
	$(MAKE) -C $(wildcard d01_s*_ex$*) stat

ex%_synth:
	$(MAKE) -C $(wildcard d01_s*_ex$*) synth

ex%_prog:
	$(MAKE) -C $(wildcard d01_s*_ex$*) prog

ex%_clean:
	$(MAKE) -C $(wildcard d01_s*_ex$*) clean

.PHONY: clean ex1 ex1_sim ex1_stat ex1_synth ex1_prog ex1_wave ex1_clean ex2 ex2_sim ex2_stat ex2_synth ex2_prog ex2_wave ex2_clean
