# Auto-generated Makefile — lecture example week1_day04/d04_s3_ex2
#
# Hosts two demos:
#   - d04_s1: bare D flip-flop  (tb_d_flip_flop.v drives day04_ex01_d_flip_flop.v)
#   - d04_s3: 4-bit reset+enable register
#             (tb_reg_4bit_rst_en.v drives day04_ex01b_reg_4bit_rst_en.v)
#
# `make sim`  runs both testbenches sequentially.
# `make stat` reports yosys synth_ice40 stats for both modules.
TOP      = d_flip_flop
PCF      = ../go_board.pcf
DEVICE   = hx1k
PACKAGE  = vq100
IVFLAGS  = -g2012 -Wall

# ---- simulate both testbenches ----
sim: sim_dff sim_reg

sim_dff:
	@echo "--- d04_s1: bare D flip-flop ---"
	iverilog $(IVFLAGS) -o sim_dff.vvp tb_d_flip_flop.v day04_ex01_d_flip_flop.v
	vvp sim_dff.vvp

sim_reg:
	@echo "--- d04_s3: 4-bit reg with sync reset + enable ---"
	iverilog $(IVFLAGS) -o sim_reg.vvp tb_reg_4bit_rst_en.v day04_ex01b_reg_4bit_rst_en.v
	vvp sim_reg.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

# ---- yosys stat: report both modules ----
stat:
	@echo "--- d04_s1: bare D flip-flop ---"
	yosys -p "read_verilog day04_ex01_d_flip_flop.v; synth_ice40 -top d_flip_flop; stat"
	@echo "--- d04_s3: 4-bit reg with sync reset + enable ---"
	yosys -p "read_verilog day04_ex01b_reg_4bit_rst_en.v; synth_ice40 -top reg_4bit_rst_en; stat"

# Default synth target = bare DFF (smallest, used in d04_s1 demo)
synth: day04_ex01_d_flip_flop.v
	yosys -p "read_verilog day04_ex01_d_flip_flop.v; synth_ice40 -top $(TOP) -json $(TOP).json"

prog: synth
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $(TOP).json --asc $(TOP).asc --freq 25
	icepack $(TOP).asc $(TOP).bin
	iceprog $(TOP).bin

clean:
	rm -f *.json *.asc *.bin *.vvp *.vcd *.log

.PHONY: sim sim_dff sim_reg wave synth prog stat clean
