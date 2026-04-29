# Auto-generated Makefile
TOP      = top_mux
SRCS     = ex2_mux2to1.v ex2_mux4to1.v ex2_top_mux.v
TB       = tb_mux.v
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

show: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); show"

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim wave synth prog stat show clean all
