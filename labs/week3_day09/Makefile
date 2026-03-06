# =============================================================================
# Makefile — week3_day09 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_rom_sequencer/starter prog

ex2:
	$(MAKE) -C ex2_sync_ram/starter sim

ex3:
	$(MAKE) -C ex3_initialized_ram/starter sim

ex4:
	$(MAKE) -C ex4_dual_display/starter prog

ex5:
	$(MAKE) -C ex5_register_file/starter sim

clean:
	$(MAKE) -C ex1_rom_sequencer/starter clean
	$(MAKE) -C ex2_sync_ram/starter clean
	$(MAKE) -C ex3_initialized_ram/starter clean
	$(MAKE) -C ex4_dual_display/starter clean
	$(MAKE) -C ex5_register_file/starter clean

.PHONY: ex1 ex2 ex3 ex4 ex5 clean
