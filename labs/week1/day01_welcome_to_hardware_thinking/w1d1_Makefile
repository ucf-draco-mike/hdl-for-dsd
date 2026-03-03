# =============================================================================
# Makefile — Day 1: Welcome to Hardware Thinking
# Accelerated HDL for Digital System Design · UCF ECE
# =============================================================================
DEVICE   = hx1k
PACKAGE  = vq100
PCF      = ../../../shared/pcf/go_board.pcf
IFLAGS   = -g2012 -Wall

# Per-exercise targets — each builds from starter/ by default
# Override with SOL=1 to build from solutions/
SRC_DIR = starter
ifeq ($(SOL),1)
  SRC_DIR = solutions
endif

# ---- Exercise 1: LED On ----
ex1: $(SRC_DIR)/ex1_led_on.v
	yosys -q -p "synth_ice40 -top led_on -json build/w1d1_ex1.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d1_ex1.json --asc build/w1d1_ex1.asc -q
	icepack build/w1d1_ex1.asc build/w1d1_ex1.bin
	iceprog build/w1d1_ex1.bin

ex1_stat: $(SRC_DIR)/ex1_led_on.v
	yosys -p "synth_ice40 -top led_on; stat" $<

# ---- Exercise 2: Buttons to LEDs ----
ex2: $(SRC_DIR)/ex2_buttons_to_leds.v
	yosys -q -p "synth_ice40 -top buttons_to_leds -json build/w1d1_ex2.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d1_ex2.json --asc build/w1d1_ex2.asc -q
	icepack build/w1d1_ex2.asc build/w1d1_ex2.bin
	iceprog build/w1d1_ex2.bin

# ---- Exercise 3: Button Logic ----
ex3: $(SRC_DIR)/ex3_button_logic.v
	yosys -q -p "synth_ice40 -top button_logic -json build/w1d1_ex3.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d1_ex3.json --asc build/w1d1_ex3.asc -q
	icepack build/w1d1_ex3.asc build/w1d1_ex3.bin
	iceprog build/w1d1_ex3.bin

# ---- Exercise 4: Active-Low Clean ----
ex4: $(SRC_DIR)/ex4_active_low_clean.v
	yosys -q -p "synth_ice40 -top active_low_clean -json build/w1d1_ex4.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d1_ex4.json --asc build/w1d1_ex4.asc -q
	icepack build/w1d1_ex4.asc build/w1d1_ex4.bin
	iceprog build/w1d1_ex4.bin

ex4_stat: $(SRC_DIR)/ex4_active_low_clean.v
	yosys -p "synth_ice40 -top active_low_clean; stat" $<

# ---- Exercise 5 (Stretch): XOR Pattern ----
ex5: $(SRC_DIR)/ex5_xor_pattern.v
	yosys -q -p "synth_ice40 -top xor_pattern -json build/w1d1_ex5.json" $<
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json build/w1d1_ex5.json --asc build/w1d1_ex5.asc -q
	icepack build/w1d1_ex5.asc build/w1d1_ex5.bin
	iceprog build/w1d1_ex5.bin

# ---- Utilities ----
build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: ex1 ex2 ex3 ex4 ex5 ex1_stat ex4_stat clean

# Ensure build directory exists before any target
$(shell mkdir -p build)
