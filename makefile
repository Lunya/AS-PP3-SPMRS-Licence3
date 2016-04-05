CFLAGS=-Wall
CFLAGS2=-std=c99 -g -pedantic -Wall -Wshadow -Wpointer-arith -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes
LDLIBS= -lfl -ly -lm
CC=gcc
LEX=flex
YACC=bison -d -v

all: main.c analyseur.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o spmrs $^ $(LDLIBS)

debug:
	$(CC) $(CFLAGS2) -o spmrs $^ $(LDLIBS)

lex.yy.c: analyseur.l y.tab.h
	$(LEX) -o $@ $<

y.tab.h y.tab.c: analyseur.y
	$(YACC) $^

clean:
	rm analyseur.output lex.yy.c analyseur.tab.c analyseur.tab.h *.o
