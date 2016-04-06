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
%token <number> NUMBER
%token <text> text WORD LABEL_LEFT_BRACKET LABEL_LEFT_SQUARE_BRACKET LABEL_ATAG BR_SL

%start tags
%%
//Une forêt de balises
tags:                     %empty 
			| tags tag                                     {printf("mtags\n");}
                        | tags textcontent{}
                        | tags atag{}
                        | tags '{' tags '}'                            {printf("sstags\n");}
                        ;
//Balise
tag:
			  LABEL_LEFT_SQUARE_BRACKET attributes '{' tags '}' {printf("Atag\n");}
			| LABEL_LEFT_BRACKET  tags '}'                   {printf("Wtag\n");}
                        ;
//L'ensemble d'attributs encadré par des crochets
attributes:
			  attribute ']'               {printf("attributes\n");}
                        ;
//Un ensemble d'attributs
attribute:
			  WORD '=' stringcontent             {printf("attribute\n");}
			| WORD '=' stringcontent attribute   {printf("attribute\n");}
                        ;

// L'ensemble de mot entouré de double quotes
textcontent:
			  '"' textgroup '"'               {printf("textcontent\n");}
                        ;

// Ensemble de mot
textgroup:
			  WORD textgroup                  {printf("textgroup\n");}		       
			| WORD                            {printf("textgroup\n");}		
                        ;

//Même chose qu'au dessus sans créer des arbres
stringcontent:
			  '"' stringgroup '"'               {printf("stringcontent\n");}
                        ;

stringgroup:
			  WORD stringgroup             {printf("stringgroup\n");}			
			| WORD                        {printf("stringgroup\n");}			
                        ;
//Balise autofermante
atag:
                          LABEL_ATAG {printf("atag autof");}
                        | LABEL_LEFT_BRACKET attributes BR_SL {printf("atag autof");}
                        ;
%%
