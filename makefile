CFLAGS=-std=c99 -Wall
CFLAGS2=-std=c99 -g -pedantic -Wall -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
LDLIBS= -lfl -ly -lm
INCLUDES=color_print.c node.c
CC=gcc
LEX=flex
YACC=bison -d -v --graph
OUT=spmrs
TESTS_SOURCES=$(wildcard tests/*.jhtml)

spmrs: main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(OUT) $(INCLUDES) $^ $(LDLIBS)



debug: main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS2) -o $(OUT) $(INCLUDES) $^ $(LDLIBS)

lex.yy.c: analyseur.l analyseur.tab.h
	$(LEX) -o $@ $<

analyseur.tab.h analyseur.tab.c: analyseur.y
	$(YACC) $^
	dot -Tpng analyseur.dot -o analyseur.png

.PHONY: all test clean check 

all: $(OUT)

test: $(OUT) analyseur.input
	./$< < analyseur.input

check: all
	for i in $(TESTS_SOURCES); do \
		echo -e "\033[1;30;46mtest of: $$i\033[0m"; \
		if ./$(OUT) < $$i $$? -eq 0; then \
			echo -e "\033[42mtest OK\033[0m"; \
		else \
			echo -e "\033[41mtest NOT really OK\033[0m"; \
		fi \
	done

errorcheck: all
	for i in $(TESTS_SOURCES); do \
		echo -e "\033[1;30;46mtest of: $$i\033[0m"; \
		if gdb -ex=r --args ./$(OUT) < $$i $$? -eq 0; then \
			echo -e "\033[42error test OK\033[0m"; \
		else \
			echo -e "\033[41error test NOT really OK\033[0m"; \
		fi \
	done

clean:
	rm analyseur.output lex.yy.c analyseur.tab.c analyseur.tab.h
