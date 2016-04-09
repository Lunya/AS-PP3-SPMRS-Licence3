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
#include "color_print.h"
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

%x STRINGS ATTRIBUTES STRINGS_ATTRIBUTES

%%

	
[[:digit:]]+ {
	printfC(TEXT_LIGHT_GRAY, "%s", yytext);
	yylval.number = atoi(yytext);
	return NUMBER;
}



"/"	{
	printfC(TEXT_MAGENTA, "/");
	return SLASH;
}

"{"	{
	printfC(TEXT_MAGENTA, "{");
	return LEFT_BRACKET;
}

"}"	{
	printfC(TEXT_MAGENTA, "}");
	return RIGHT_BRACKET;
}

"["	{
	printfC(TEXT_MAGENTA, "[");
	BEGIN ATTRIBUTES;
	 return LEFT_SQUARE_BRACKET;
}

<INITIAL,ATTRIBUTES>"]"	{
	printfC(TEXT_MAGENTA, "]");
	BEGIN INITIAL;
	return RIGHT_SQUARE_BRACKET;
}

"("	{
	printfC(TEXT_MAGENTA, "(");
	return LEFT_PARENTHESIS;
}

")"	{
	printfC(TEXT_MAGENTA, ")");
	return RIGHT_PARENTHESIS;
}

<INITIAL,ATTRIBUTES>"="	{
	printfC(TEXT_MAGENTA, "=");
	return EQUAL;
}



<INITIAL,ATTRIBUTES>[[:alpha:]][[:alnum:]_'.]*|_[[:alnum:]_'.]+ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
		strcpy(yylval.text, yytext);
		printfC(TEXT_YELLOW, "%s", yytext);
		return LABEL;
	}
}

[[:space:]]+ {
	printfC(BACKGROUND_BLUE, "%s", yytext);
	return SPACES;
}

\" {
	printfC(TEXT_BLUE, "\"");
	BEGIN STRINGS;
}

<STRINGS>\" {
	printfC(TEXT_BLUE, "\"");
	BEGIN INITIAL;
}

<STRINGS>[^[:space:]\"]+ {
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
	strcpy(yylval.text, yytext);
	printfC(TEXT_GREEN, "%s", yytext);
	return STRING;
}
<STRINGS>[[:space:]]+ {
	printfC(BACKGROUND_CYAN, "%s", yytext);
	return STRING_SPACES;
}

<ATTRIBUTES>\" {
	printfC(TEXT_BLUE, "\"");
	BEGIN STRINGS_ATTRIBUTES;
}

<STRINGS_ATTRIBUTES>\" {
	printfC(TEXT_BLUE, "\"");
	BEGIN ATTRIBUTES;
}

<STRINGS_ATTRIBUTES>[^\"]* {
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
	strcpy(yylval.text, yytext);
	printfC(TEXT_GREEN, "%s", yytext);
	return STRING;
}

. {printfC(TEXT_RED, "<< %s >>",yytext);}

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