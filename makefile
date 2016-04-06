CFLAGS=-Wall
CFLAGS2=-std=c99 -g -pedantic -Wall -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
LDLIBS= -lfl -ly -lm
CC=gcc
LEX=flex
YACC=bison -d -v
OUT=spmrs
TESTS_SOURCES=$(wildcard tests/*.jhtml)

all: main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(OUT) $^ $(LDLIBS)

debug: main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS2) -o $(OUT) $^ $(LDLIBS)

lex.yy.c: analyseur.l analyseur.tab.h
	$(LEX) -o $@ $<

analyseur.tab.h analyseur.tab.c: analyseur.y
	$(YACC) $^

check: all
	for i in $(TESTS_SOURCES); do \
		echo -e "\033[36mtest of: $$i\033[33m"; \
		if ./$(OUT) < $$i $$? -eq 0; then \
			echo -e "\033[32mtest OK\033[0m"; \
		else \
			echo -e "\033[31mtest NOT really OK\033[0m"; \
		fi \
	done

clean:
	rm analyseur.output lex.yy.c analyseur.tab.c analyseur.tab.h *.o
