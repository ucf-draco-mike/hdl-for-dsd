# =============================================================================
# Makefile — Day 2: Combinational Building Blocks
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

# ---- Exercise 1: Vector Operations ----
ex1: $(SRC_DIR)/ex1_vector_ops.v
	yosys -q -p "synth_ice40 -top vector_ops -json build/w1d2_ex1.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d2_ex1.json --asc build/w1d2_ex1.asc -q
	icepack build/w1d2_ex1.asc build/w1d2_ex1.bin
	iceprog build/w1d2_ex1.bin

# ---- Exercise 2: Mux Hierarchy ----
ex2: $(SRC_DIR)/ex2_mux2to1.v $(SRC_DIR)/ex2_mux4to1.v $(SRC_DIR)/ex2_top_mux.v
	yosys -q -p "synth_ice40 -top top_mux -json build/w1d2_ex2.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d2_ex2.json --asc build/w1d2_ex2.asc -q
	icepack build/w1d2_ex2.asc build/w1d2_ex2.bin
	iceprog build/w1d2_ex2.bin

ex2_show: $(SRC_DIR)/ex2_mux2to1.v $(SRC_DIR)/ex2_mux4to1.v $(SRC_DIR)/ex2_top_mux.v
	yosys -p "read_verilog $^; synth_ice40 -top top_mux; show"

# ---- Exercise 3: Ripple-Carry Adder ----
ex3: $(SRC_DIR)/ex3_full_adder.v $(SRC_DIR)/ex3_ripple_adder_4bit.v $(SRC_DIR)/ex3_top_adder.v
	yosys -q -p "synth_ice40 -top top_adder -json build/w1d2_ex3.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d2_ex3.json --asc build/w1d2_ex3.asc -q
	icepack build/w1d2_ex3.asc build/w1d2_ex3.bin
	iceprog build/w1d2_ex3.bin

# ---- Exercise 4: 7-Segment Decoder ----
ex4: $(SRC_DIR)/ex4_hex_to_7seg.v $(SRC_DIR)/ex4_top_7seg.v
	yosys -q -p "synth_ice40 -top top_7seg -json build/w1d2_ex4.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d2_ex4.json --asc build/w1d2_ex4.asc -q
	icepack build/w1d2_ex4.asc build/w1d2_ex4.bin
	iceprog build/w1d2_ex4.bin

# ---- Exercise 5 (Stretch): Adder + Display ----
ex5: $(SRC_DIR)/ex3_full_adder.v $(SRC_DIR)/ex3_ripple_adder_4bit.v $(SRC_DIR)/ex4_hex_to_7seg.v $(SRC_DIR)/ex5_top_adder_display.v
	yosys -q -p "synth_ice40 -top top_adder_display -json build/w1d2_ex5.json" $^
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d2_ex5.json --asc build/w1d2_ex5.asc -q
	icepack build/w1d2_ex5.asc build/w1d2_ex5.bin
	iceprog build/w1d2_ex5.bin

clean:
	rm -rf build

.PHONY: ex1 ex2 ex3 ex4 ex5 ex2_show clean
$(shell mkdir -p build)
