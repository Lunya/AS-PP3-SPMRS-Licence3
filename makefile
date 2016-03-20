CFLAGS=-std=c99 -g -pedantic -Wall -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
LDLIBS=-lfl -ly -lm
CC=gcc
LEX=flex
YACC=bison -d -v


all: y.tab.h lex.yy.c
	$(CC) $(FLAGS) y.tab.h lex.yy.c main.c -o spmrs.exe

lex.yy.c: analyseur.l
	$(LEX) analyseur.l

y.tab.h: analyseur.y
	$(YACC) analyseur.y

clean:
	rm y.output lex.yy.c y.tab.h