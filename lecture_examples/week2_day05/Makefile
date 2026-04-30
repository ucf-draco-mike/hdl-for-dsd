# Auto-generated dispatcher Makefile — week2_day05
# Routes targets into per-example subdirectories.
#
# Usage:
#   make ex1            # default target for ex1 (stat or sim)
#   make ex1_sim        # simulate
#   make ex1_stat       # synth report
#   make ex1_synth      # synth to JSON
#   make ex1_prog       # full bitstream + iceprog
#   make ex1_clean      # clean

EXAMPLES := d05_s1_ex1 d05_s2_ex2 d05_s3_ex3 d05_s4_ex4

ex1:
	$(MAKE) -C d05_s1_ex1 stat

ex2:
	$(MAKE) -C d05_s2_ex2 stat

ex3:
	$(MAKE) -C d05_s3_ex3 stat

ex4:
	$(MAKE) -C d05_s4_ex4 stat

clean:
	$(MAKE) -C d05_s1_ex1 clean
	$(MAKE) -C d05_s2_ex2 clean
	$(MAKE) -C d05_s3_ex3 clean
	$(MAKE) -C d05_s4_ex4 clean

ex%_sim:
	$(MAKE) -C $(wildcard d05_s*_ex$*) sim

ex%_wave:
	$(MAKE) -C $(wildcard d05_s*_ex$*) wave

ex%_stat:
	$(MAKE) -C $(wildcard d05_s*_ex$*) stat

ex%_synth:
	$(MAKE) -C $(wildcard d05_s*_ex$*) synth

ex%_prog:
	$(MAKE) -C $(wildcard d05_s*_ex$*) prog

ex%_clean:
	$(MAKE) -C $(wildcard d05_s*_ex$*) clean

.PHONY: clean ex1 ex1_sim ex1_stat ex1_synth ex1_prog ex1_wave ex1_clean ex2 ex2_sim ex2_stat ex2_synth ex2_prog ex2_wave ex2_clean ex3 ex3_sim ex3_stat ex3_synth ex3_prog ex3_wave ex3_clean ex4 ex4_sim ex4_stat ex4_synth ex4_prog ex4_wave ex4_clean
