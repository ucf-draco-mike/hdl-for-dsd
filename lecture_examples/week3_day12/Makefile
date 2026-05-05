# Dispatcher Makefile — week3_day12
# Routes targets into per-example subdirectories.
#
# Examples in this day:
#   ex1 -> d12_s2_ex1  (uart_rx,       segment s2)
#   ex2 -> d12_s3_ex2  (spi_master,    segment s3)
#   ex3 -> d12_s4_ex3  (uart_loopback, segment s4 — Week 3 capstone)
#
# Targets (replace N with the example number: 1, 2 or 3):
#   make exN          # default: stat (synth report)
#   make exN_sim      # iverilog + vvp simulation
#   make exN_wave     # run sim, then open VCD in gtkwave
#   make exN_stat     # yosys synth_ice40 stat report
#   make exN_synth    # synth to JSON (yosys)
#   make exN_prog     # JSON -> nextpnr -> icepack -> iceprog (full flow)
#   make exN_clean    # remove build artifacts in that example
#   make clean        # clean every example in this day

EXAMPLES := d12_s2_ex1 d12_s3_ex2 d12_s4_ex3
EX_NUMS  := 1 2 3

ex1:
	$(MAKE) -C d12_s2_ex1 stat

ex2:
	$(MAKE) -C d12_s3_ex2 stat

ex3:
	$(MAKE) -C d12_s4_ex3 stat

clean:
	$(MAKE) -C d12_s2_ex1 clean
	$(MAKE) -C d12_s3_ex2 clean
	$(MAKE) -C d12_s4_ex3 clean

SIM_TARGETS   := $(foreach n,$(EX_NUMS),ex$(n)_sim)
WAVE_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_wave)
STAT_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_stat)
SYNTH_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_synth)
PROG_TARGETS  := $(foreach n,$(EX_NUMS),ex$(n)_prog)
CLEAN_TARGETS := $(foreach n,$(EX_NUMS),ex$(n)_clean)

$(SIM_TARGETS):   ex%_sim:   ; $(MAKE) -C $(wildcard d12_s*_ex$*) sim
$(WAVE_TARGETS):  ex%_wave:  ; $(MAKE) -C $(wildcard d12_s*_ex$*) wave
$(STAT_TARGETS):  ex%_stat:  ; $(MAKE) -C $(wildcard d12_s*_ex$*) stat
$(SYNTH_TARGETS): ex%_synth: ; $(MAKE) -C $(wildcard d12_s*_ex$*) synth
$(PROG_TARGETS):  ex%_prog:  ; $(MAKE) -C $(wildcard d12_s*_ex$*) prog
$(CLEAN_TARGETS): ex%_clean: ; $(MAKE) -C $(wildcard d12_s*_ex$*) clean

.PHONY: clean ex1 ex2 ex3 $(SIM_TARGETS) $(WAVE_TARGETS) $(STAT_TARGETS) $(SYNTH_TARGETS) $(PROG_TARGETS) $(CLEAN_TARGETS)
