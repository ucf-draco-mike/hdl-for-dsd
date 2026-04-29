# auto_fetch.mk — included by per-exercise lab Makefiles
#
# Lets a lab folder pull common helper modules (uart_tx, uart_rx, debounce,
# hex_to_7seg, ...) from shared/lib/ — and starter testbenches from the
# sibling solution/ — without checking duplicate copies into git. The
# including Makefile declares:
#
#   FETCH_FROM_SHARED   := uart_tx.v uart_rx.v ...
#   FETCH_FROM_SOLUTION := tb_foo.v ...
#   include ../../../auto_fetch.mk
#
# Files are copied (not symlinked) so this works identically on every
# host the course supports — Linux, macOS, and WSL2. The rules only
# fire when the target is missing locally, so a student's edits to a
# starter DUT (e.g. their uart_tx.v in ex2_uart_tx) are never clobbered.

_AUTO_FETCH_MK := $(lastword $(MAKEFILE_LIST))
REPO_ROOT      ?= $(abspath $(dir $(_AUTO_FETCH_MK))..)
SHARED_LIB     ?= $(REPO_ROOT)/shared/lib

$(FETCH_FROM_SHARED):
	@if [ ! -f "$(SHARED_LIB)/$@" ]; then \
		echo "ERROR: $@ not found in $(SHARED_LIB)" >&2; exit 1; \
	fi
	@echo "==> fetching $@ from shared/lib"
	@cp "$(SHARED_LIB)/$@" "./$@"

$(FETCH_FROM_SOLUTION):
	@if [ ! -f "../solution/$@" ]; then \
		echo "ERROR: $@ not found in ../solution/" >&2; exit 1; \
	fi
	@echo "==> fetching $@ from ../solution"
	@cp "../solution/$@" "./$@"

clean-deps:
	@rm -f $(FETCH_FROM_SHARED) $(FETCH_FROM_SOLUTION)
	@echo "==> removed fetched dependencies"

.PHONY: clean-deps
