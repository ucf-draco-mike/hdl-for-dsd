# =============================================================================
# Makefile — week4_day13 (dispatcher)
# Delegates to per-exercise directories. Run from day directory.
# =============================================================================

ex1:
	$(MAKE) -C ex1_alu_refactor/starter sim

ex2:
	$(MAKE) -C ex2_fsm_refactor/starter sim

ex3:
	$(MAKE) -C ex3_uart_refactor/starter sim

clean:
	$(MAKE) -C ex1_alu_refactor/starter clean
	$(MAKE) -C ex2_fsm_refactor/starter clean
	$(MAKE) -C ex3_uart_refactor/starter clean

.PHONY: ex1 ex2 ex3 clean
