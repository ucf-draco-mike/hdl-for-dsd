# =============================================================================
# Makefile — Day 4: Sequential Logic Fundamentals
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

# ---- Exercise 1: D Flip-Flop (simulation only) ----
ex1_sim: $(SRC_DIR)/ex1_d_ff.v $(SRC_DIR)/ex1_tb_d_ff.v
	iverilog $(IFLAGS) -o build/w1d4_ex1.vvp $^
	vvp build/w1d4_ex1.vvp
	@echo "Open waveforms: gtkwave build/w1d4_ex1.vcd"

# ---- Exercise 2: Loadable Register (simulation only) ----
ex2_sim: $(SRC_DIR)/ex2_register_4bit.v $(SRC_DIR)/ex2_tb_register.v
	iverilog $(IFLAGS) -o build/w1d4_ex2.vvp $^
	vvp build/w1d4_ex2.vvp

# ---- Exercise 3: LED Blinker ----
ex3: $(SRC_DIR)/ex3_led_blinker.v
	yosys -q -p "synth_ice40 -top led_blinker -json build/w1d4_ex3.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d4_ex3.json --asc build/w1d4_ex3.asc -q
	icepack build/w1d4_ex3.asc build/w1d4_ex3.bin
	iceprog build/w1d4_ex3.bin

# ---- Exercise 4: 7-Seg Counter ----
ex4: $(SRC_DIR)/ex4_seg_counter.v
	yosys -q -p "synth_ice40 -top seg_counter -json build/w1d4_ex4.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d4_ex4.json --asc build/w1d4_ex4.asc -q
	icepack build/w1d4_ex4.asc build/w1d4_ex4.bin
	iceprog build/w1d4_ex4.bin

# ---- Exercise 5: Dual-Speed Blinker ----
ex5: $(SRC_DIR)/ex5_dual_blinker.v
	yosys -q -p "synth_ice40 -top dual_blinker -json build/w1d4_ex5.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d4_ex5.json --asc build/w1d4_ex5.asc -q
	icepack build/w1d4_ex5.asc build/w1d4_ex5.bin
	iceprog build/w1d4_ex5.bin

# ---- Exercise 6 (Stretch): Up/Down Counter ----
ex6: $(SRC_DIR)/ex6_updown_counter.v
	yosys -q -p "synth_ice40 -top updown_counter -json build/w1d4_ex6.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d4_ex6.json --asc build/w1d4_ex6.asc -q
	icepack build/w1d4_ex6.asc build/w1d4_ex6.bin
	iceprog build/w1d4_ex6.bin

clean:
	rm -rf build

.PHONY: ex1_sim ex2_sim ex3 ex4 ex5 ex6 clean
$(shell mkdir -p build)
