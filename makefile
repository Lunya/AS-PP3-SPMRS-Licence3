CFLAGS=-std=c99 -Wall
CFLAGS2=-std=c99 -g -pedantic -Wall -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
LDLIBS= -lfl -ly -lm
INCLUDES=color_print.c ast.c variables.c pattern.c import.c machine.c pattern_matching.c
CC=gcc
LEX=flex
YACC=bison -d -v --graph
OUT=spmrs
TESTS_SOURCES=$(basename $(wildcard tests/*.jhtml))

$(OUT): $(INCLUDES) main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(OUT) $^ $(LDLIBS)
	
debug: main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS2) -o $(OUT) $(INCLUDES) $^ $(LDLIBS)

lex.yy.c: analyseur.l analyseur.tab.h
	$(LEX) -o $@ $<

analyseur.tab.h analyseur.tab.c: analyseur.y
	$(YACC) $^
#	dot -Tsvg analyseur.dot -o analyseur.svg
#	rm analyseur.dot

.PHONY: all test clean check 

all: $(OUT)

test: $(OUT) analyseur.input
	./$< < analyseur.input

check: all
	for i in $(TESTS_SOURCES); do \
		echo -e "\033[1;30;46mtest of: $$i\033[0m"; \
		if ./$(OUT) $(addsuffix .jhtml, $$i) $(addsuffix .dot, $$i) $$? -eq 0; then \
			echo -e "\033[42mtest OK\033[0m"; \
		else \
			echo -e "\033[41mtest NOT really OK\033[0m"; \
		fi; \
		dot -Tsvg $(addsuffix .dot, $$i) -o $(addsuffix .svg, $$i); \
		rm $(addsuffix .dot, $$i); \
	done

check_emit: check
	for i in $(TESTS_SOURCES); do \
		echo -e "\033[1;30;46mtest of: $$i.html\033[0m"; \
		if cmp $(addsuffix .html, $$i) $(addsuffix _expected.html, $$i) $$? -eq 0; then \
			echo -e "\033[42mgenerated file is good\033[0m"; \
		else \
			echo -e "\033[41msomething xent xrong in generated file\033[0m"; \
		fi; \
	done

errorcheck: all
	for i in $(TESTS_SOURCES); do \
		echo -e "\033[1;30;46mtest of: $$i\033[0m"; \
		if gdb -ex=r --args ./$(OUT) $(addsuffix .jhtml, $$i) $$? -eq 0; then \
			echo -e "\033[42error test OK\033[0m"; \
		else \
			echo -e "\033[41error test NOT really OK\033[0m"; \
		fi \
	done

clean:
	rm analyseur.output lex.yy.c analyseur.tab.c analyseur.tab.h tests/*.svg
