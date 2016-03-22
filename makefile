CFLAGS=-Wall
LDLIBS= -lfl -ly -lm
CC=gcc
LEX=flex
YACC=bison -d -v

analyseur.tab.c analyseur.tab.h: analyseur.y
	$(YACC) analyseur.y

lex.yy.c: analyseur.l analyseur.tab.h
	$(LEX) analyseur.l

all: main.c analyseur.tab.o lex.yy.o
	$(CC) $(FLAGS) -o test lex.yy.o analyseur.tab.o main.c $(LDLIBS)
clean:
	rm analyseur.output lex.yy.c analyseur.tab.c analyseur.tab.h *.o
