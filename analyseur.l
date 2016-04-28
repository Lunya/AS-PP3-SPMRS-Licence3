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

\< { return '<';}

\> { return '>';}

\<\= { return bLEQ;}

\>\= { return bGEQ;}

\=\= { return bEQ;}

\, {
	return ',';
}
if {
	return IF;
}

then {
	return THEN;
}

else {
	return ELSE;
}

let[[:space:]]* {
	printfC(TEXT_CYAN, "%s", yytext);
	return LET;
}

[[:space:]]*\-\>[[:space:]]* {
	printfC(TEXT_CYAN, "%s", yytext);
	return ARROW;
}

[[:space:]]*fun[[:space:]]* {
	printfC(TEXT_CYAN, "%s", yytext);
	return FUNT;
}

[[:space:]]*rec[[:space:]]* {
	printfC(TEXT_CYAN, "%s", yytext);
	return REC;
}

[[:space:]]in[[:space:]]* {
	printfC(TEXT_CYAN, "%s", yytext);
	return IN;	
}

[[:space:]]*where[[:space:]]* {
	printfC(TEXT_CYAN, "%s", yytext);
	return WHERE;
}
";" {
	printfC(TEXT_RED, ";");
	return ';';
}

"/"	{
	printfC(TEXT_MAGENTA, "/");
	return '/';
}

"{"[[:space:]]*	{
	printfC(TEXT_MAGENTA, "{");
	return '{';
}

[[:space:]]*"}"	{
	printfC(TEXT_MAGENTA, "}");
	return '}';
}

"["	{
	printfC(TEXT_MAGENTA, "[");
	BEGIN ATTRIBUTES;
	 return '[';
}

<INITIAL,ATTRIBUTES>"]"	{
	printfC(TEXT_MAGENTA, "]");
	BEGIN INITIAL;
	return ']';
}

"("	{
	printfC(TEXT_MAGENTA, "(");
	return '(';
}

")"	{
	printfC(TEXT_MAGENTA, ")");
	return ')';
}

<INITIAL,ATTRIBUTES>"="	{
	printfC(TEXT_MAGENTA, "=");
	return '=';
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

[[:alpha:]][[:alnum:]_'.]*\[|_[[:alnum:]_'.]+\[ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
		//Enlever le crochet
		memcpy(yylval.text, yytext, strlen(yytext) - 1);
		printfC(TEXT_YELLOW, "%s", yytext);
		return LABEL_LEFT_SQUARE_BRACKET;
	}
}

[[:alpha:]][[:alnum:]_'.]*\{|_[[:alnum:]_'.]+\{ {
	if (start_with_xml(yytext, yyleng))
	{
		REJECT;
	}
	else
	{
		yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
		//Enlever l'accolade
		memcpy(yylval.text, yytext, strlen(yytext) - 1);
		printfC(TEXT_YELLOW, "%s", yytext);
		return LABEL_LEFT_BRACKET;
	}
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