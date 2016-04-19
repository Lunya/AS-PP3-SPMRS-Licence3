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
#include "ast.h"
#include <stdio.h>

struct ast * root = NULL;

int yylex(void);
void yyerror(const char*);
%}

%union {
	int number;
	char * text;
        struct ast * node;
	struct attributes * attribute;
}

%token LEFT_BRACKET RIGHT_BRACKET LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS EQUAL SLASH
%token <number> NUMBER
%token <text> STRING STRING_SPACES SPACES LABEL
%type <node> tag tags string content
%type <attribute> attribute
%right STRING STRING_SPACES // verifier si pas %left
//%left LEFT_BRACKET RIGHT_BRACKET LABEL
%start tags
%error-verbose
%%
//Une forêt de balises
tags:
	tag tags
	{
                if ($1 != NULL)
                { $$ = mk_forest(1, $1, $2); }
                else
                { $$ = NULL; }
		root = $$;
	}
	| tag
	{
		if ($1 != NULL)
                { $$ = mk_forest(1, $1, NULL); }
		else
                { $$ = NULL; }
		root = $$;
	}
	| LEFT_BRACKET  tags  RIGHT_BRACKET
	{

		if ($2 != NULL)
                { $$ = mk_forest(1, $2, NULL); }
		else
		{ $$ = NULL;}
		root = $$;
	}
	| LEFT_BRACKET  tags  RIGHT_BRACKET tags
	{

		if ($2 != NULL)
                { $$ = mk_forest(1, $2, $4); }
		else
                { $$ = NULL; }
		root = $$;
	}
	| SPACES tags
	{
                if ($2 != NULL)
                { $$ = mk_forest(1, $2, NULL); }
		else
                { $$ = NULL; }
		root = $$;
	}
	| SPACES { $$ = NULL; root = $$;}
	;
//Balise
tag:
	LABEL LEFT_SQUARE_BRACKET attribute RIGHT_SQUARE_BRACKET LEFT_BRACKET content RIGHT_BRACKET
	{
                $$ = mk_tree($1, false, false, $3, $6);
	}
	| LABEL LEFT_SQUARE_BRACKET attribute RIGHT_SQUARE_BRACKET SPACES LEFT_BRACKET content RIGHT_BRACKET
	{
                $$ = mk_tree($1, false, false, $3, $7);
	}
	| LABEL LEFT_SQUARE_BRACKET attribute RIGHT_SQUARE_BRACKET SLASH
	{
                $$ = mk_tree($1, false, true, $3, NULL);
	} 
	| LABEL LEFT_BRACKET content RIGHT_BRACKET
        {
                $$ = mk_tree($1, false, false, NULL, $3);
	}
	| LEFT_BRACKET RIGHT_BRACKET {$$ = NULL;}
	| LABEL SLASH
        {
                $$ = mk_tree($1, false, true, NULL, NULL);
	}
	;

//Un ensemble d'attributs
attribute:
        LABEL EQUAL string { $$ = mk_attributes($1, $3->node->forest->head->node->word->str, NULL); }
        | LABEL EQUAL string attribute { $$ = mk_attributes($1, $3->node->forest->head->node->word->str, $4); }
	| SPACES { $$ = NULL; }
	| SPACES attribute { $$ = $2; }
	;

//Contenu d'une balise : Ensemble de textes, de balises ou de balises autofermantes.
content:
        string content { $$ = mk_forest(1, $1, $2); }
        | tag content {  $$ = mk_forest(1, $1, $2); }
        | string   { mk_forest(1, $1, NULL); }
        | tag      { mk_forest(1, $1, NULL); }
        | LEFT_BRACKET content RIGHT_BRACKET    { mk_forest(1, $2, NULL); }
        | SPACES content { mk_forest(1, $2, NULL); }
	| SPACES { $$ = NULL; }
	;

// Ensemble de mot
string: // tester avec un espace juste après les "
        STRING string { $$ = mk_forest(1, mk_word($1), $2); }
	| STRING_SPACES string
        {
                $$ = $2;
                add_space($$);
        }
        | STRING { $$ = mk_forest(1, mk_word($1), NULL); }
        | STRING_SPACES { $$ = mk_forest(1, add_space(mk_word("")), NULL); }
	;

%%

void yyerror(const char * err)
{
	fflush(stdout);
	fprintfC(stderr, BACKGROUND_RED|TEXT_WHITE, "%s\n", err);
}
