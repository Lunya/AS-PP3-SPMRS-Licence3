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

int fileno(FILE*);
%}

%option noinput nounput

%x TEXT

%%

\"	{ printf("DQ\n");return DOUBLE_QUOTE;}

[[:space:]]+	{ printf("SPACE\n");return SPACE; }


[[:alpha:]][[:alnum:]_'.]*|_[[:alnum:]_'.]+	{
	/*
	 * si le nom de l'étiquette est au moins de longueur 3 caracères
	 * alors vérifier si elle commence ou non par "XML" sans respecter
	 * la casse.
	 */
	 printf("MotL : %s\n", yytext);
	if (strlen(yytext) >= 3)
	{
		//Ps : Penser à le traiter d'une autre façon, et je pense que le traiter
		//directement dans l'expression regulière serait mieux.
		if ((yytext[0] == 'x' || yytext[0] == 'X') &&\
			(yytext[1] == 'm' || yytext[1] == 'M') &&\
			(yytext[2] == 'l' || yytext[2] == 'L'))
		{
			//
		}
	}
	// penser a liberer la mémoire dans le ".y"
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char));
	strcpy(yylval.text, yytext);
	return LABEL; // NOM BALISE
}

[[:alnum:]]+ { 
	yylval.text = malloc((strlen(yytext) + 1) * sizeof(char)); 
	strcpy(yylval.text, yytext);
	printf("MotW : %s\n", yytext);
	return WORD;
	} 
	
[[:digit:]]+	{
	yylval.number = atoi(yytext);
	return NUMBER;
}




"{"		{ return LEFT_BRACKET; }

"}"		{ return RIGHT_BRACKET; }

"["		{ return LEFT_SQUARE_BRACKET; }

"]"		{ return RIGHT_SQUARE_BRACKET; }

"("		{ return LEFT_PARENTHESIS; }

")"		{ return RIGHT_PARENTHESIS; }

"="		{ return EQUAL; }



"/"		{ return SLASH;}


%%
