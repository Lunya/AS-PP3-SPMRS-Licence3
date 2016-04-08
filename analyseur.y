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
#include "color_print.h"
#include "node.h"
#include <stdio.h>

int yylex(void);
void yyerror(const char*);
%}

%union {
	int number;
	char * text;
	struct tree * node;
	struct attributes * attribute;
}

%token LEFT_BRACKET RIGHT_BRACKET LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS EQUAL SLASH
%token <number> NUMBER
%token <text> STRING SPACES LABEL
%type <node> tag tags string content
%type <attribute> attribute
%start tags
%error-verbose
%%
//Une forêt de balises
tags:
	tag tags                                       
	{
		if ($1 != NULL)
		{
			$$ = $1;
			addBrother($$, $2);
		}
		else
		{
			$$ = NULL;
		}
	}
	| tag {
		if ($1 != NULL)
		{
			$$ = $1;
		}
		else
		{
			$$ = NULL;
		}
	}
	| LEFT_BRACKET  tags  RIGHT_BRACKET {
		if ($2 != NULL)
		{
			$$ = $2;
		}
		else
		{
			$$ = NULL;
		}
	}
	| LEFT_BRACKET  tags  RIGHT_BRACKET tags            
	{
		$$ = $2;
		addBrother($$, $4);
	}
    ;
//Balise
tag:
	LABEL LEFT_SQUARE_BRACKET attribute RIGHT_SQUARE_BRACKET LEFT_BRACKET content RIGHT_BRACKET                
	{
		$$ = createNode($1, false, false, TREE);
		addAttribute($$, $3);
		addChild($$, $6);
	}
	| LABEL LEFT_SQUARE_BRACKET attribute RIGHT_SQUARE_BRACKET SLASH
	{
    	$$ = createNode($1, true, false, TREE);
    	addAttribute($$, $3); //$$ = Node ATAG actuel, $2 = L'attribut.
    } 
	| LABEL LEFT_BRACKET content RIGHT_BRACKET          
	{
		$$ = createNode($1, false, false, TREE);
		addChild($$,$3);
	}
	| LEFT_BRACKET RIGHT_BRACKET {$$ = NULL;}
	| LABEL SLASH {$$ = createNode($1, true, false, TREE);}
    ;

//Un ensemble d'attributs
attribute:
	LABEL EQUAL string               {$$ = createAttribute($1,$3);}
	| LABEL EQUAL string attribute   
	{
		$$ = createAttribute($1,$3);
		addAttributeBrother($$, $4);
	}
    ;
                        
//Contenu d'une balise : Ensemble de textes, de balises ou de balises autofermantes.
content:
	string content         
	{
		$$=$1;
		addBrother($$, $2);
	}
	| tag content               
	{
		$$=$1;
		addBrother($$, $2);
	}
	| string   {$$=$1;}
	| tag                       			{$$=$1;}
	| LEFT_BRACKET content RIGHT_BRACKET    {$$=$2;}
	;

// Ensemble de mot
string:
	STRING string 
	{
		$$ = createNode($1, true, false, WORD);
		addBrother($$, $2);
	}
	| SPACES string
	{
		$$ = $2;
		addSpace($$);
	}
	| STRING {$$ = createNode($1, false, false, WORD);}
	| SPACES {$$ = createNode("", false, true, WORD);}
	;

%%

void yyerror(const char * err)
{
	fflush(stdout);
	fprintfC(stderr, BACKGROUND_RED|TEXT_WHITE, "%s\n", err);
}