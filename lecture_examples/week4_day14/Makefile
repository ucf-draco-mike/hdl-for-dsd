# Dispatcher Makefile — week4_day14
# Routes targets into per-example subdirectories.
#
# Examples in this day:
#   ex1 -> d14_s1_ex1  (uart_tx_asserted, SystemVerilog assertions, segment s1)
#
# Targets:
#   make ex1          # default: stat (synth report)
#   make ex1_sim      # iverilog + vvp simulation
#   make ex1_wave     # run sim, then open VCD in gtkwave
#   make ex1_stat     # yosys synth_ice40 stat report
#   make ex1_synth    # synth to JSON (yosys)
#   make ex1_prog     # JSON -> nextpnr -> icepack -> iceprog (full flow)
#   make ex1_clean    # remove build artifacts in that example
#   make clean        # clean every example in this day

EXAMPLES := d14_s1_ex1
EX_NUMS  := 1

ex1:
	$(MAKE) -C d14_s1_ex1 stat

clean:
	$(MAKE) -C d14_s1_ex1 clean

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
STAT_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_stat)
SYNTH_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_synth)
PROG_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_prog)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(wildcard d14_s*_ex$*) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(wildcard d14_s*_ex$*) wave
$(STAT_TARGETS):  ex%_stat:  ; $(MAKE) -C $(wildcard d14_s*_ex$*) stat
$(SYNTH_TARGETS): ex%_synth: ; $(MAKE) -C $(wildcard d14_s*_ex$*) synth
$(PROG_TARGETS):  ex%_prog:  ; $(MAKE) -C $(wildcard d14_s*_ex$*) prog
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(wildcard d14_s*_ex$*) clean

.PHONY: clean ex1 $(SIM_TARGETS) $(WAVE_TARGETS) $(STAT_TARGETS) $(SYNTH_TARGETS) $(PROG_TARGETS) $(CLEAN_TARGETS)
