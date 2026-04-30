# Dispatcher Makefile — week2_day05
# Routes targets into per-example subdirectories.
#
# Examples in this day:
#   ex1 -> d05_s1_ex1  (counter_mod_n,  segment s1)
#   ex2 -> d05_s2_ex2  (shift_reg_piso, segment s2)
#   ex3 -> d05_s3_ex3  (synchronizer,   segment s3)
#   ex4 -> d05_s4_ex4  (debounce,       segment s4)
#
# Targets (replace N with the example number: 1, 2, 3, or 4):
#   make exN          # default: stat (synth report)
#   make exN_sim      # iverilog + vvp simulation
#   make exN_wave     # run sim, then open VCD in gtkwave
#   make exN_stat     # yosys synth_ice40 stat report
#   make exN_synth    # synth to JSON (yosys)
#   make exN_prog     # JSON -> nextpnr -> icepack -> iceprog (full flow)
#   make exN_clean    # remove build artifacts in that example
#   make clean        # clean every example in this day

EXAMPLES := d05_s1_ex1 d05_s2_ex2 d05_s3_ex3 d05_s4_ex4
EX_NUMS  := 1 2 3 4

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

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
STAT_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_stat)
SYNTH_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_synth)
PROG_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_prog)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(wildcard d05_s*_ex$*) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(wildcard d05_s*_ex$*) wave
$(STAT_TARGETS):  ex%_stat:  ; $(MAKE) -C $(wildcard d05_s*_ex$*) stat
$(SYNTH_TARGETS): ex%_synth: ; $(MAKE) -C $(wildcard d05_s*_ex$*) synth
$(PROG_TARGETS):  ex%_prog:  ; $(MAKE) -C $(wildcard d05_s*_ex$*) prog
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(wildcard d05_s*_ex$*) clean

.PHONY: clean ex1 ex2 ex3 ex4 $(SIM_TARGETS) $(WAVE_TARGETS) $(STAT_TARGETS) $(SYNTH_TARGETS) $(PROG_TARGETS) $(CLEAN_TARGETS)
