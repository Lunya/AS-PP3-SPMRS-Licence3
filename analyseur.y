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

%token SPACE LABEL LEFT_BRACKET RIGHT_BRACKET LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS EQUAL END_OF_FILE DOUBLE_QUOTE SLASH
%token <number> NUMBER
%token <text> text WORD

%start tags
%%

tags:
			tag tags                                       {printf("mtags\n");}
			| tag SPACE tags                               {printf("mtags\n");}
			| tag                                          {printf("otags\n");}
			| LEFT_BRACKET  SPACE tags RIGHT_BRACKET       {printf("stags\n");}
			| LEFT_BRACKET  tags  RIGHT_BRACKET            {printf("stags\n");}
                        ;

tag:
			LABEL attributes contents               {printf("tag\n");}
			| LABEL attributes SPACE contents       {printf("tag\n");}
			| LABEL contents                        {printf("tag\n");}
			| LABEL SPACE contents                  {printf("tag\n");}
                        ;

attributes:
			LEFT_SQUARE_BRACKET attribute RIGHT_SQUARE_BRACKET               {printf("attributes\n");}
			| LEFT_SQUARE_BRACKET SPACE attribute RIGHT_SQUARE_BRACKET       {printf("attributes\n");}
			| LEFT_SQUARE_BRACKET attribute SPACE RIGHT_SQUARE_BRACKET       {printf("attributes\n");}
			| LEFT_SQUARE_BRACKET SPACE attribute SPACE RIGHT_SQUARE_BRACKET {printf("attributes\n");}  
                        ;

attribute:
			LABEL EQUAL stringcontent               {printf("attribute\n");}
			| LABEL SPACE EQUAL stringcontent       {printf("attribute\n");}
			| LABEL EQUAL SPACE stringcontent       {printf("attribute\n");}
			| LABEL SPACE EQUAL SPACE stringcontent {printf("attribute\n");}
			| attribute attribute                   {printf("attribute\n");}
			| attribute SPACE attribute             {printf("attribute\n");}
                        ;

contents:
			LEFT_BRACKET content RIGHT_BRACKET               {printf("contents\n");}
			| LEFT_BRACKET SPACE content RIGHT_BRACKET       {printf("contents\n");}
			| LEFT_BRACKET content SPACE RIGHT_BRACKET       {printf("contents\n");}
			| LEFT_BRACKET SPACE content SPACE RIGHT_BRACKET {printf("contents\n");}
                        | LEFT_BRACKET RIGHT_BRACKET                     {printf("contents\n");}
                        ;

content:
			textcontent content         {printf("content\n");}
			| textcontent SPACE content {printf("content\n");}
			| tag content               {printf("content\n");}
			| tag SPACE content         {printf("content\n");}
			| atag content              {printf("content\n");}
			| atag SPACE content        {printf("content\n");}
			| textcontent               {printf("content\n");}
			| tag                       {printf("content\n");}
			| atag                      {printf("content\n");}
                        ;

// L'ensemble de mot entouré de double quotes
textcontent:
			DOUBLE_QUOTE textgroup DOUBLE_QUOTE               {printf("textcontent\n");}
			| DOUBLE_QUOTE SPACE textgroup DOUBLE_QUOTE       {printf("textcontent\n");}
			| DOUBLE_QUOTE textgroup SPACE DOUBLE_QUOTE       {printf("textcontent\n");}
			| DOUBLE_QUOTE SPACE textgroup SPACE DOUBLE_QUOTE {printf("textcontent\n");}
                        ;

// Ensemble de mot
textgroup:
			WORD textgroup                {printf("textgroup\n");}
			| WORD SPACE textgroup        {printf("textgroup\n");}
			| LABEL SPACE textgroup       {printf("textgroupWS\n");}
			| WORD SPACE textgroup SPACE  {printf("textgroup\n");}
			| LABEL SPACE textgroup SPACE {printf("textgroupS\n");}
			| WORD                        {printf("textgroup\n");}
			| LABEL                       {printf("textgroup\n");}
			| WORD SPACE                  {printf("textgroup\n");}
			| LABEL SPACE                 {printf("textgroup\n");}
                        ;

//Même chose qu'au dessus sans créer des arbres
stringcontent:
			DOUBLE_QUOTE stringgroup DOUBLE_QUOTE               {printf("stringcontent\n");}
			| DOUBLE_QUOTE SPACE stringgroup DOUBLE_QUOTE       {printf("stringcontent\n");}
			| DOUBLE_QUOTE stringgroup SPACE DOUBLE_QUOTE       {printf("stringcontent\n");}
			| DOUBLE_QUOTE SPACE stringgroup SPACE DOUBLE_QUOTE {printf("stringcontent\n");}
                        ;

stringgroup:
			WORD stringgroup                {printf("stringgroup\n");}
			| WORD SPACE stringgroup        {printf("stringgroup\n");}
			| LABEL SPACE stringgroup       {printf("stringgroup\n");}
			| WORD SPACE stringgroup SPACE  {printf("stringgroup\n");}
			| LABEL SPACE stringgroup SPACE {printf("stringgroupS\n");}
			| WORD                          {printf("stringgroup\n");}
			| LABEL                         {printf("stringgroup\n");}
			| WORD SPACE                    {printf("stringgroup\n");}
			| LABEL SPACE                   {printf("stringgroup\n");}
                        ;

atag:
                  	LABEL SLASH {printf("ATAB\n");}
                        ;
%%
