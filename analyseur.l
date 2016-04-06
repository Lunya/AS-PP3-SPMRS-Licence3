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
WORD [^[:space:]{\[\]}=\"\/]+

%%

[[:space:]]* {}
	
[[:digit:]]+	{
	yylval.number = atoi(yytext);
	return NUMBER;
}


\"	        { printf("\"\n"); return '"';}

"{"		{ printf("{\n"); return '{'; }

"}"		{ printf("}\n"); return '}'; }

"["		{ printf("[\n"); return '['; }

"]"		{ printf("]\n"); return ']'; }

"("		{ printf("(\n"); return '('; }

")"		{ printf(")\n"); return ')'; }

"="		{ printf("=\n"); return '='; }

"/"		{ printf("/\n"); return '/';}

({LABEL})\{ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = strndup(yytext,yyleng-1);
		printf("LLB |%s|\n", yytext);
		return LABEL_LEFT_BRACKET;
	}
}

({LABEL})\/ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = strndup(yytext,yyleng-1);
		printf("LLB |%s|\n", yytext);
		return LABEL_ATAG;
	}
}

\][[:space:]]*\/  {return BR_SL;}

({LABEL})\[ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = strndup(yytext,yyleng-1);
		printf("LLSB (%s)\n", yytext);
		return LABEL_LEFT_SQUARE_BRACKET;
	}
}

{WORD} { 
	yylval.text = strdup(yytext);
	printf("MotW : %s\n", yytext);
	return WORD;
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
