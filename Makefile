CC     = gcc
CFLAGS = -Wall -Wextra -O2

# alvos padrão
all: coffeelang coffee_vm

# --------------------------------------------------------------------
# COMPILADOR CODEPRESSO
# --------------------------------------------------------------------

coffeelang: src/main.o src/parser.o src/scanner.o
	$(CC) $(CFLAGS) -o coffeelang src/main.o src/parser.o src/scanner.o

src/main.o: src/main.c src/parser.h
	$(CC) $(CFLAGS) -c src/main.c -o src/main.o

src/parser.o: src/parser.c src/parser.h
	$(CC) $(CFLAGS) -c src/parser.c -o src/parser.o

src/scanner.o: src/scanner.c src/parser.h
	$(CC) $(CFLAGS) -c src/scanner.c -o src/scanner.o

# gera parser.c e parser.h a partir do coffee.y
src/parser.c src/parser.h: src/coffee.y
	bison -d -o src/parser.c src/coffee.y

# --------------------------------------------------------------------
# MÁQUINA VIRTUAL CODEPRESSO
# --------------------------------------------------------------------

coffee_vm: vm/coffee_vm.c vm/coffee_vm.h
	$(CC) $(CFLAGS) -o coffee_vm vm/coffee_vm.c

# --------------------------------------------------------------------
# LIMPEZA
# --------------------------------------------------------------------

clean:
	rm -f coffeelang coffee_vm
	rm -f src/*.o
	rm -f src/parser.c src/parser.h src/coffee.tab.c src/coffee.tab.h
