# Dispatcher Makefile — week1_day01
# Routes targets into per-example subdirectories.
#
# Examples in this day:
#   ex1 -> d01_s3_ex1  (led_driver,   segment s3 demo 1)
#   ex2 -> d01_s3_ex2  (button_logic, segment s3 demo 2)
#   ex3 -> d01_s4_ex1  (gates_demo,   segment s4 "Gates in Verilog")
#
# Targets (replace N with the example number, e.g. 1, 2, or 3):
#   make exN          # default: stat (synth report)
#   make exN_sim      # iverilog + vvp simulation
#   make exN_wave     # run sim, then open VCD in gtkwave
#   make exN_stat     # yosys synth_ice40 stat report
#   make exN_synth    # synth to JSON (yosys)
#   make exN_prog     # JSON -> nextpnr -> icepack -> iceprog (full flow)
#   make exN_clean    # remove build artifacts in that example
#   make clean        # clean every example in this day

EXAMPLES := d01_s3_ex1 d01_s3_ex2 d01_s4_ex1
EX_NUMS  := 1 2 3

ex1:
	$(MAKE) -C d01_s3_ex1 stat

ex2:
	$(MAKE) -C d01_s3_ex2 stat

ex3:
	$(MAKE) -C d01_s4_ex1 stat

clean:
	$(MAKE) -C d01_s3_ex1 clean
	$(MAKE) -C d01_s3_ex2 clean
	$(MAKE) -C d01_s4_ex1 clean

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
STAT_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_stat)
SYNTH_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_synth)
PROG_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_prog)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

# ex1/ex2 live under d01_s3_ex*, ex3 lives under d01_s4_ex* — both globs
# expand to a single matching dir, so a wildcard search is enough.
$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(wildcard d01_s*_ex$*) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(wildcard d01_s*_ex$*) wave
$(STAT_TARGETS):  ex%_stat:  ; $(MAKE) -C $(wildcard d01_s*_ex$*) stat
$(SYNTH_TARGETS): ex%_synth: ; $(MAKE) -C $(wildcard d01_s*_ex$*) synth
$(PROG_TARGETS):  ex%_prog:  ; $(MAKE) -C $(wildcard d01_s*_ex$*) prog
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(wildcard d01_s*_ex$*) clean

.PHONY: clean ex1 ex2 ex3 $(SIM_TARGETS) $(WAVE_TARGETS) $(STAT_TARGETS) $(SYNTH_TARGETS) $(PROG_TARGETS) $(CLEAN_TARGETS)
