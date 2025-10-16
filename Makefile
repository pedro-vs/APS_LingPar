
---
```make
# Makefile — APS CoffeeLang (Entrega #2)
CC      := gcc
FLEX    := flex
BISON   := bison

SRC_DIR := src
VM_DIR  := vm
BIN     := coffeelang

LEX     := $(SRC_DIR)/coffee.l
YACC    := $(SRC_DIR)/coffee.y
MAIN    := $(SRC_DIR)/main.c

# Saídas geradas
SCAN_C  := $(SRC_DIR)/scanner.c
PARSER_C:= $(SRC_DIR)/parser.c
PARSER_H:= $(SRC_DIR)/parser.h

CFLAGS  := -Wall -Wextra -O2
LDFLAGS := -lfl

all: $(BIN)

$(BIN): $(SCAN_C) $(PARSER_C) $(MAIN) $(VM_DIR)/coffee_vm.c $(VM_DIR)/coffee_vm.h
	$(CC) $(CFLAGS) -o $@ $(PARSER_C) $(SCAN_C) $(MAIN) $(VM_DIR)/coffee_vm.c $(LDFLAGS)

$(SCAN_C): $(LEX) $(PARSER_H)
	$(FLEX) -o $@ $(LEX)

$(PARSER_C) $(PARSER_H): $(YACC)
	$(BISON) -d -o $(PARSER_C) $(YACC)

run: all
	./$(BIN) < examples/ok.coffee

clean:
	rm -f $(BIN) $(SCAN_C) $(PARSER_C) $(PARSER_H)

.PHONY: all run clean
