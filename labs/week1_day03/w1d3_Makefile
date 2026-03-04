# =============================================================================
# Makefile — Day 3: Procedural Combinational Logic
# Accelerated HDL for Digital System Design · UCF ECE
# =============================================================================
DEVICE   = hx1k
PACKAGE  = vq100
PCF      = ../../../shared/pcf/go_board.pcf
IFLAGS   = -g2012 -Wall

SRC_DIR = starter
ifeq ($(SOL),1)
  SRC_DIR = solutions
endif

# ---- Exercise 1: Latch Hunting ----
ex1_synth: $(SRC_DIR)/ex1_latch_bugs.v
	yosys -p "read_verilog $<; synth_ice40 -top latch_bugs"

# ---- Exercise 2: Priority Encoder ----
ex2: $(SRC_DIR)/ex2_priority_encoder.v $(SRC_DIR)/ex2_top_encoder.v
	yosys -q -p "synth_ice40 -top top_encoder -json build/w1d3_ex2.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d3_ex2.json --asc build/w1d3_ex2.asc -q
	icepack build/w1d3_ex2.asc build/w1d3_ex2.bin
	iceprog build/w1d3_ex2.bin

# ---- Exercise 3: ALU ----
ex3: $(SRC_DIR)/ex3_alu_4bit.v $(SRC_DIR)/ex3_top_alu.v
	yosys -q -p "synth_ice40 -top top_alu -json build/w1d3_ex3.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d3_ex3.json --asc build/w1d3_ex3.asc -q
	icepack build/w1d3_ex3.asc build/w1d3_ex3.bin
	iceprog build/w1d3_ex3.bin

# ---- Exercise 4: BCD-to-7-Seg ----
ex4: $(SRC_DIR)/ex4_bcd_to_7seg.v $(SRC_DIR)/ex4_top_bcd.v
	yosys -q -p "synth_ice40 -top top_bcd -json build/w1d3_ex4.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d3_ex4.json --asc build/w1d3_ex4.asc -q
	icepack build/w1d3_ex4.asc build/w1d3_ex4.bin
	iceprog build/w1d3_ex4.bin

# ---- Exercise 5 (Stretch): ALU + Display ----
ex5: $(SRC_DIR)/ex3_alu_4bit.v ../day02_combinational_building_blocks/solutions/w1d3_ex4_hex_to_7seg.v $(SRC_DIR)/ex5_top_alu_display.v
	yosys -q -p "synth_ice40 -top top_alu_display -json build/w1d3_ex5.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d3_ex5.json --asc build/w1d3_ex5.asc -q
	icepack build/w1d3_ex5.asc build/w1d3_ex5.bin
	iceprog build/w1d3_ex5.bin

clean:
	rm -rf build

.PHONY: ex1_synth ex2 ex3 ex4 ex5 clean
$(shell mkdir -p build)
