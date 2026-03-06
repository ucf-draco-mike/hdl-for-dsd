# =============================================================================
# Makefile — week4_day14 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_uart_assertions/starter sim

ex2:
	$(MAKE) -C ex2_uart_parity/starter sim

ex3:
	$(MAKE) -C ex3_ai_constraint_tb/starter sim

ex4:
	$(MAKE) -C ex4_ppa_analysis/starter stat_all

clean:
	$(MAKE) -C ex1_uart_assertions/starter clean
	$(MAKE) -C ex2_uart_parity/starter clean
	$(MAKE) -C ex3_ai_constraint_tb/starter clean
	$(MAKE) -C ex4_ppa_analysis/starter clean

.PHONY: ex1 ex2 ex3 ex4 clean
