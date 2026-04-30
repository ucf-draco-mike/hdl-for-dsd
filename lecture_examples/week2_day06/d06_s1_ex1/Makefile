# Auto-generated Makefile — lecture example week2_day06/d06_s1_ex1
# Pure testbench template (tb_alu); not synthesizable on its own.
TOP      = tb_alu
SRCS     = day06_ex01_tb_alu_template.v
IVFLAGS  = -g2012 -Wall

sim:
	iverilog $(IVFLAGS) -o sim.vvp $(SRCS) && vvp sim.vvp

wave: sim
	@if ls *.vcd >/dev/null 2>&1; then gtkwave *.vcd & else echo "[wave] No VCD produced."; fi

clean:
	rm -f *.vvp *.vcd *.log

.PHONY: sim wave clean
