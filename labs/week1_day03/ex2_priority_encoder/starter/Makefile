# Auto-generated Makefile
TOP      = top_encoder
SRCS     = ex2_priority_encoder.v ex2_top_encoder.v
TB       = tb_priority_encoder.v
PCF      = ../../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

sim: $(TB) $(SRCS)
	iverilog $(IVFLAGS) -o sim.vvp $(TB) $(SRCS)
	vvp sim.vvp

wave: sim
	gtkwave *.vcd &

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
