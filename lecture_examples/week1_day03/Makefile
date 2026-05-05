# Dispatcher Makefile — week1_day03
# Routes targets into per-example subdirectories.
#
# Examples in this day:
#   ex1 -> d03_s1_ex1  (assign vs always — same hardware,  segment s1)
#   ex2 -> d03_s2_ex1  (alu_4bit,                          segment s2)
#   ex3 -> d03_s3_ex2  (latch_demo,                        segment s3)
#   ex4 -> d03_s3_ex3  (latch_fixed,                       segment s3)
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

EXAMPLES := d03_s1_ex1 d03_s2_ex1 d03_s3_ex2 d03_s3_ex3
EX_NUMS  := 1 2 3 4

ex1:
	$(MAKE) -C d03_s1_ex1 stat

ex2:
	$(MAKE) -C d03_s2_ex1 stat

ex3:
	$(MAKE) -C d03_s3_ex2 stat

ex4:
	$(MAKE) -C d03_s3_ex3 stat

clean:
	$(MAKE) -C d03_s1_ex1 clean
	$(MAKE) -C d03_s2_ex1 clean
	$(MAKE) -C d03_s3_ex2 clean
	$(MAKE) -C d03_s3_ex3 clean

# Map ex<N> to its directory.
EX1_DIR := d03_s1_ex1
EX2_DIR := d03_s2_ex1
EX3_DIR := d03_s3_ex2
EX4_DIR := d03_s3_ex3

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
STAT_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_stat)
SYNTH_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_synth)
PROG_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_prog)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(EX$*_DIR) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(EX$*_DIR) wave
$(STAT_TARGETS):  ex%_stat:  ; $(MAKE) -C $(EX$*_DIR) stat
$(SYNTH_TARGETS): ex%_synth: ; $(MAKE) -C $(EX$*_DIR) synth
$(PROG_TARGETS):  ex%_prog:  ; $(MAKE) -C $(EX$*_DIR) prog
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(EX$*_DIR) clean

.PHONY: clean ex1 ex2 ex3 ex4 $(SIM_TARGETS) $(WAVE_TARGETS) $(STAT_TARGETS) $(SYNTH_TARGETS) $(PROG_TARGETS) $(CLEAN_TARGETS)
