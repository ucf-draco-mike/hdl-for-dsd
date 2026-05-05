# Auto-generated Makefile -- lecture example week4_day14/d14_s3_ex2
# Demo: pipelined_adder PPA sweep (segment s3, example 2)
#
# Sweep usage (matches the d14_s3 LIVE DEMO slide):
#   make clean
#   for p in 0 1 2 4; do make all PIPE=$p; done
#   python scripts/plot_ppa.py logs/report_pipe*.txt

PIPE     ?= 0
TOP      = pipelined_adder
SRCS     = day14_ex02_pipelined_adder.v
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

LOG_DIR  = logs
REPORT   = $(LOG_DIR)/report_pipe$(PIPE).txt
JSON     = $(TOP)_pipe$(PIPE).json
ASC      = $(TOP)_pipe$(PIPE).asc

# `make all PIPE=N` -- run synth + place-and-route, capture report.
all: $(REPORT)

$(LOG_DIR):
	@mkdir -p $(LOG_DIR)

$(REPORT): $(SRCS) | $(LOG_DIR)
	@echo "=== Pipelined Adder PPA report (PIPE=$(PIPE)) ===" > $(REPORT)
	@yosys -q -p "read_verilog $(SRCS); chparam -set PIPE $(PIPE) $(TOP); synth_ice40 -top $(TOP) -json $(JSON); stat" \
	    >> $(REPORT) 2>&1 || true
	@nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) \
	    --json $(JSON) --asc $(ASC) --freq 200 \
	    >> $(REPORT) 2>&1 || true
	@echo "" >> $(REPORT)
	@echo "--- Summary (PIPE=$(PIPE)) ---" >> $(REPORT)
	@grep -E "Number of cells|Max frequency" $(REPORT) >> $(REPORT) 2>/dev/null || true
	@echo "[stat+pnr] PIPE=$(PIPE) -> $(REPORT)"
	@grep -E "Number of cells|Max frequency for clock" $(REPORT) || true

# Quick synth-only stat (no PnR, no log file).
stat: $(SRCS)
	yosys -p "read_verilog $(SRCS); chparam -set PIPE $(PIPE) $(TOP); synth_ice40 -top $(TOP); stat"

# Synthesize to JSON only.
synth: $(SRCS)
	yosys -p "read_verilog $(SRCS); chparam -set PIPE $(PIPE) $(TOP); synth_ice40 -top $(TOP) -json $(JSON)"

# Full bitstream + program (single PIPE value).
prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(JSON) --asc $(ASC) --freq 25
	icepack $(ASC) $(TOP).bin
	iceprog $(TOP).bin

# Iverilog simulation with current PIPE.
sim:
	@tb=$$(ls tb_*.v tb_*.sv 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo "[sim] No testbench (tb_*.v) in $$(pwd)"; \
	else \
		srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		iverilog $(IVFLAGS) -DPIPE=$(PIPE) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

# Sweep convenience: builds reports for PIPE=0,1,2,4 in one command.
sweep:
	@for p in 0 1 2 4; do $(MAKE) --no-print-directory all PIPE=$$p; done
	@echo "[sweep] Reports in $(LOG_DIR)/"

clean:
	rm -rf $(LOG_DIR) *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: all sim wave synth prog stat sweep clean
