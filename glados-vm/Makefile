##
## EPITECH PROJECT, 2025
## glados-vm [WSL: Ubuntu]
## File description:
## Makefile
##

EXE ?= glados-vm-exe
OUT ?= glados-vm
WASM ?= ./test.wasm

.PHONY: help build vm install run run-stack clean distclean

help:
	@echo "Targets:"
	@echo "  make build             # stack build (no copy)"
	@echo "  make vm                # build and copy binary to ./$(OUT)"
	@echo "  make run WASM=path     # run ./$(OUT) on a .wasm file"
	@echo "  make run-stack WASM=path  # run via 'stack run -- ...' (no copy)"
	@echo "  make clean             # stack clean and remove ./$(OUT)"
	@echo ""
	@echo "Variables:"
	@echo "  EXE=<name>     # actual stack/cabal exe name (default: $(EXE))"
	@echo "  OUT=<name>     # output binary name at repo root (default: $(OUT))"
	@echo "  WASM=<file>    # wasm file to run (default: $(WASM))"
	@echo ""
	@echo "Example:"
	@echo "  make vm && ./$(OUT) my_file.wasm"

build:
	stack build

vm install:
	stack install --local-bin-path .
	@if [ "$(EXE)" != "$(OUT)" ]; then \
		if [ -f "$(EXE)" ]; then mv -f "$(EXE)" "$(OUT)"; fi; \
	fi
	@chmod +x "$(OUT)"

run: vm
	./$(OUT) $(WASM)

run-stack:
	stack run -- $(WASM)

clean:
	stack clean
	rm -f "$(OUT)" "$(EXE)"

distclean: clean