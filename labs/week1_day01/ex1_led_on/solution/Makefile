# Solution Makefile — operates on the ref/ + tb/ split introduced by the
# CTF gating scheme. Reference DUTs live in ref/, testbench in tb/.
TOP      = led_on
SRCS     = $(wildcard ref/*.v)
TB_SRCS  = $(wildcard tb/tb_*.v)
PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim:
	@if [ -z "$(TB_SRCS)" ]; then \
		echo "[sim] No testbench in tb/ — nothing to simulate."; \
	else \
		echo "iverilog $(IVFLAGS) -o sim.vvp $(TB_SRCS) $(SRCS)"; \
		iverilog $(IVFLAGS) -o sim.vvp $(TB_SRCS) $(SRCS) && vvp sim.vvp; \
	fi

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

synth: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP) -json $(TOP).json" $(SRCS)

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

stat: $(SRCS)
	yosys -p "synth_ice40 -top $(TOP); stat" $(SRCS)

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat clean all
