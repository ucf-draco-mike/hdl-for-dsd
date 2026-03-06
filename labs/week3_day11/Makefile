# =============================================================================
# Makefile — week3_day11 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_baud_gen/starter sim

ex2:
	$(MAKE) -C ex2_uart_tx/starter sim

ex3:
	$(MAKE) -C ex3_hardware_verify/starter prog

clean:
	$(MAKE) -C ex1_baud_gen/starter clean
	$(MAKE) -C ex2_uart_tx/starter clean
	$(MAKE) -C ex3_hardware_verify/starter clean

.PHONY: ex1 ex2 ex3 clean
