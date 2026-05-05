# Dispatcher Makefile — week2_day07
# Routes targets into per-example subdirectories.
#
# Examples in this day:
#   ex1 -> d07_s2_ex1  (traffic_light,    segment s2 — used by slides 1, 2, 3)
#   ex2 -> d07_s4_ex2  (pattern_detector, segment s4)
#
# Targets (replace N with the example number: 1 or 2):
#   make exN              # default: stat (synth report)
#   make exN_sim          # iverilog + vvp simulation
#   make exN_wave         # run sim, then open VCD in gtkwave
#   make exN_stat         # yosys synth_ice40 stat report
#   make exN_synth        # synth to JSON (yosys)
#   make exN_prog         # JSON -> nextpnr -> icepack -> iceprog (full flow)
#   make exN_clean        # remove build artifacts in that example
#   make clean            # clean every example in this day
#
# Encoding comparison (slide 3 demo, ex1 only):
#   make ex1_stat_binary  # binary  encoding
#   make ex1_stat_onehot  # one-hot encoding
#   make ex1_stat_gray    # gray    encoding
#   make ex1_stat_all     # side-by-side summary

EXAMPLES := d07_s2_ex1 d07_s4_ex2
EX_NUMS  := 1 2

ex1:
	$(MAKE) -C d07_s2_ex1 stat

ex2:
	$(MAKE) -C d07_s4_ex2 stat

clean:
	$(MAKE) -C d07_s2_ex1 clean
	$(MAKE) -C d07_s4_ex2 clean

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
STAT_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_stat)
SYNTH_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_synth)
PROG_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_prog)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(wildcard d07_s*_ex$*) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(wildcard d07_s*_ex$*) wave
$(STAT_TARGETS):  ex%_stat:  ; $(MAKE) -C $(wildcard d07_s*_ex$*) stat
$(SYNTH_TARGETS): ex%_synth: ; $(MAKE) -C $(wildcard d07_s*_ex$*) synth
$(PROG_TARGETS):  ex%_prog:  ; $(MAKE) -C $(wildcard d07_s*_ex$*) prog
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(wildcard d07_s*_ex$*) clean

# ---- Encoding-comparison passthroughs (ex1 only) ----
ex1_stat_binary:
	$(MAKE) -C d07_s2_ex1 stat_binary

ex1_stat_onehot:
	$(MAKE) -C d07_s2_ex1 stat_onehot

ex1_stat_gray:
	$(MAKE) -C d07_s2_ex1 stat_gray

ex1_stat_all:
	$(MAKE) -C d07_s2_ex1 stat_all

.PHONY: clean ex1 ex2 \
        ex1_stat_binary ex1_stat_onehot ex1_stat_gray ex1_stat_all \
        $(SIM_TARGETS) $(WAVE_TARGETS) $(STAT_TARGETS) \
        $(SYNTH_TARGETS) $(PROG_TARGETS) $(CLEAN_TARGETS)
