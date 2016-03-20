%{
/*
 * Projet d'ASPP3 de troisième année de licence informatique
 * Contributeurs :
 *     - Moreau Corentin
 *     - Prestat Dimitri
 *     - Rivalier Antoine
 *     - San Nicolas Ludovic
 *     - Sarain Shervin
 * Copyright (c) 2015-2016
*/
#include <stdio.h>

int yylex(void);
void yyerror(char*);
%}

%union {
	int number;
	char* text;
}

%token SPACE
%token LABEL
%token <number> NUMBER
%token <text> TEXT
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token LEFT_SQUARE_BRACKET
%token RIGHT_SQUARE_BRACKET
%token LEFT_PARENTHESIS
%token RIGHT_PARENTHESIS
%token EQUAL
%token END_OF_FILE

%output "y.tab.c"
%output "y.tab.h"

%%

fin:		machin END_OF_FILE { printf("fin\n"); }
			| END_OF_FILE { printf("fin\n"); }
			;

machin:		machin truc { printf("|\n"); }
			| truc	{ printf(">\n"); }
			;

truc:		SPACE { printf("SPACE\n"); }
			|
			LABEL { printf("LABEL\n"); }
			|
			NUMBER { printf("NUMBER\n"); }
			|
			TEXT { printf("TEXT\n"); }
			|
			LEFT_BRACKET { printf("LEFT_BRACKET\n"); }
			|
			RIGHT_BRACKET { printf("RIGHT_BRACKET\n"); }
			|
			LEFT_SQUARE_BRACKET { printf("LEFT_SQUARE_BRACKET\n"); }
			|
			RIGHT_SQUARE_BRACKET { printf("RIGHT_SQUARE_BRACKET\n"); }
			|
			LEFT_PARENTHESIS { printf("LEFT_PARENTHESIS\n"); }
			|
			RIGHT_PARENTHESIS { printf("RIGHT_PARENTHESIS\n"); }
			|
			EQUAL { printf("EQUAL\n"); }
			;

%%