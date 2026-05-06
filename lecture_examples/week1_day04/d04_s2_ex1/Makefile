# Auto-generated Makefile — lecture example week1_day04/d04_s2_ex1
# Demo: blocking vs nonblocking 3-stage shift register
#
# The two coding styles live in separate files so each can be synthesized
# on its own and the resulting flop count compared:
#   shift_blocking.v     -> make stat-blocking      (expect SB_DFF: 1)
#   shift_nonblocking.v  -> make stat-nonblocking   (expect SB_DFF: 3)
TOP      = shift_nonblocking
BLOCK_SRC    = shift_blocking.v
NONBLOCK_SRC = shift_nonblocking.v
SRCS     = $(BLOCK_SRC) $(NONBLOCK_SRC)
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim:
	@tb=$$(ls tb_*.v tb_*.sv 2>/dev/null | head -n 1); \
	if [ -z "$$tb" ]; then \
		echo "[sim] No testbench (tb_*.v) in $$(pwd) — add one to simulate."; \
	else \
		srcs=$$(ls *.v *.sv 2>/dev/null | grep -v '^tb_' | tr '\n' ' '); \
		iverilog $(IVFLAGS) -o sim.vvp $$tb $$srcs && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(NONBLOCK_SRC)
	yosys -p "read_verilog $(NONBLOCK_SRC); synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

# Synthesize each module on its own so the flop count reflects only that
# coding style. `make stat` runs both back-to-back for the side-by-side.
stat-blocking: $(BLOCK_SRC)
	@echo "=== shift_blocking (= inside posedge clk) ==="
	yosys -p "read_verilog $(BLOCK_SRC); synth_ice40 -top shift_blocking; stat"

stat-nonblocking: $(NONBLOCK_SRC)
	@echo "=== shift_nonblocking (<= inside posedge clk) ==="
	yosys -p "read_verilog $(NONBLOCK_SRC); synth_ice40 -top shift_nonblocking; stat"

stat: stat-blocking stat-nonblocking

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat stat-blocking stat-nonblocking clean
