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

%token LABEL LEFT_BRACKET RIGHT_BRACKET LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS EQUAL END_OF_FILE DOUBLE_QUOTE SLASH
%token <number> NUMBER
%token <text> text WORD WORD_SPACE LABEL_LEFT_BRACKET LABEL_LEFT_SQUARE_BRACKET

%start tags
%%
//Une forêt de balises
tags:
			tag tags                                       {printf("mtags\n");}
			| tag                                          {printf("otags\n");}
			| LEFT_BRACKET  tags  RIGHT_BRACKET            {printf("stags\n");}
                        ;
//Balise
tag:
			LABEL_LEFT_SQUARE_BRACKET attributes contents               {printf("tag\n");}
			| LABEL_LEFT_BRACKET contents           {printf("tag\n");}
                        ;
//L'ensemble d'attributs encadré par des crochets
attributes:
			attribute RIGHT_SQUARE_BRACKET               {printf("attributes\n");}
                        ;
//Un ensemble d'attributs
attribute:
			WORD EQUAL stringcontent               {printf("attribute\n");}
			| WORD EQUAL stringcontent attribute   {printf("attribute\n");}
                        ;
//Le contenu entre ces accolades
contents:
			content RIGHT_BRACKET               {printf("O contents\n");}
			| LEFT_BRACKET content RIGHT_BRACKET               {printf("A contents\n");}
            | RIGHT_BRACKET                     {printf("?? contents\n");}
                        ;
//Contenu d'une balise : Ensemble de textes, de balises ou de balises autofermantes.
content:
			textcontent content         {printf("content\n");}
			| tag content               {printf("content\n");}
			| atag content              {printf("content\n");}
			| textcontent               {printf("TC content\n");}
			| tag                       {printf("content\n");}
			| atag                      {printf("content\n");}
                        ;

// L'ensemble de mot entouré de double quotes
textcontent:
			DOUBLE_QUOTE textgroup DOUBLE_QUOTE               {printf("textcontent\n");}
                        ;

// Ensemble de mot
textgroup:
			WORD textgroup                {printf("textgroup\n");}
			| WORD_SPACE textgroup		  {printf("textgroup\n");}
			| WORD                        {printf("textgroup\n");}
			| WORD_SPACE				  {printf("textgroup\n");}
                        ;

//Même chose qu'au dessus sans créer des arbres
stringcontent:
			DOUBLE_QUOTE stringgroup DOUBLE_QUOTE               {printf("stringcontent\n");}
                        ;

stringgroup:
			WORD stringgroup              {printf("stringgroup\n");}
			| WORD_SPACE stringgroup	  {printf("stringgroup\n");}
			| WORD                        {printf("stringgroup\n");}
			| WORD_SPACE				  {printf("stringgroup\n");}
                        ;
//Balise autofermante
atag:
                  	WORD SLASH {printf("ATAB\n");}
                        ;
%%
