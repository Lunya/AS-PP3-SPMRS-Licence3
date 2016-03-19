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

#include <stdlib.h>
#include <string.h>


int yylex(void);
void yyerror(char*);
%}

%option noinput nounput

%x TEXT

%%

[[:space:]]+	{ return SPACE; }

[[:alpha:]][[:alnum:]_'.]*|_[[:alnum:]_'.]+	{
	/*
	 * si le nom de l'étiquette est au moins de longueur 3 caracères
	 * alors vérifier si elle commence ou non par "XML" sans respecter
	 * la casse.
	 */
	if (strlen(yytext) >= 3)
	{
		if ((yytext[0] == 'x' || yytext[0] == 'X') &&\
			(yytext[0] == 'm' || yytext[0] == 'M') &&\
			(yytext[0] == 'l' || yytext[0] == 'L'))
		{
			//
		}
	}
	// penser a liberer la mémoire dans le ".y"
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char));
	strcpy(yylval.text, yytext);
	return LABEL; // NOM BALISE
}

[[:digit:]]+	{
	yylval.nombre = atoi(yytext);
	return NUMBER;
}

\"	{ begin TEXT; }

<TEXT>\"	{ begin INITIAL; }

<TEXT>.+	{
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char));
	strcpy(yylval.text, yytext);
	return TEXT;
}

"{"		{ return LEFT_BRACKET; }

"}"		{ return RIGHT_BRACKET; }

"["		{ return LEFT_SQUARE_BRACKET; }

"]"		{ return RIGHT_SQUARE_BRACKET; }

"("		{ return LEFT_PARENTHESIS; }

")"		{ return RIGHT_PARENTHESIS; }

"="		{ return EQUAL; }

%%