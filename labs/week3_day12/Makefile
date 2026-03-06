# =============================================================================
# Makefile — week3_day12 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_uart_rx/starter sim

ex2:
	$(MAKE) -C ex2_loopback/starter prog

ex3:
	$(MAKE) -C ex3_spi_master/starter sim

clean:
	$(MAKE) -C ex1_uart_rx/starter clean
	$(MAKE) -C ex2_loopback/starter clean
	$(MAKE) -C ex3_spi_master/starter clean

.PHONY: ex1 ex2 ex3 clean
