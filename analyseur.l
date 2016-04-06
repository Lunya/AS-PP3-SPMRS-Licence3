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

#include "analyseur.tab.h"
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int fileno(FILE*);

/*
	check if the text starts with XML (case insensitive)
	return true if the string start with XML, false otherwise 
*/
bool start_with_xml(char *, int);

%}

%option noinput nounput

%x TEXT

LABEL [[:alpha:]][[:alnum:]_'.]*|_[[:alnum:]_'.]+
WORD [^[:space:]{\[\]}="]+

%%

\"	{ return DOUBLE_QUOTE;}




	
[[:digit:]]+	{
	yylval.number = atoi(yytext);
	return NUMBER;
}




"{"		{ printf("LB\n");return LEFT_BRACKET; }

"}"		{ printf("RB\n");return RIGHT_BRACKET; }

"["		{ return LEFT_SQUARE_BRACKET; }

"]"		{ printf("RSB\n");return RIGHT_SQUARE_BRACKET; }

"("		{ return LEFT_PARENTHESIS; }

")"		{ return RIGHT_PARENTHESIS; }

"="		{ return EQUAL; }

"/"		{ return SLASH;}

({LABEL})\{ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
		strcpy(yylval.text, yytext);
		printf("LLB |%s|\n", yytext);
		return LABEL_LEFT_BRACKET;
	}
}

({LABEL})\[ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
		strcpy(yylval.text, yytext);
		printf("LLSB (%s)\n", yytext);
		return LABEL_LEFT_SQUARE_BRACKET;
	}
}

({LABEL})[[:space:]]*\= {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
		strcpy(yylval.text, yytext);
		printf("LE (%s)\n", yytext);
		return LABEL_EQUAL;
	}
}
    
{WORD} { 
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
	strcpy(yylval.text, yytext);
	fprintf(stderr, "Salut\n");
	printf("MotW : %s\n", yytext);
	return WORD;
	} 
	
{WORD}[[:space:]]+ { 
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
	strcpy(yylval.text, yytext);
	printf("MotWS : %s\n", yytext);
	return WORD_SPACE;
	} 

. {printf("| %s |\n",yytext);}
%%


bool start_with_xml(char * text, int length)
{
	if (length >= 3)
	{
		if (text[0] == 'x' || text[0] == 'X')
		{
			if (text[0] == 'x' || text[0] == 'X')
			{
				if (text[0] == 'x' || text[0] == 'X')
					return false;
			}
			return false;
		}
		return false;
	}
	return false;
}