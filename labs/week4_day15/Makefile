# =============================================================================
# Makefile — week4_day15 (project build day)
# Use: make PROJECT=reaction_game prog
# =============================================================================

PROJECT ?= reaction_game

prog:
	$(MAKE) -C project_templates/$(PROJECT) prog

sim:
	$(MAKE) -C project_templates/$(PROJECT) sim

stat:
	$(MAKE) -C project_templates/$(PROJECT) stat

clean:
	$(MAKE) -C project_templates/$(PROJECT) clean

.PHONY: prog sim stat clean
