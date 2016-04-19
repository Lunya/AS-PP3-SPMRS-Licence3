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

%token LET IN WHERE FUNT ARROW REC
%token <number> NUMBER
%token <text> STRING STRING_SPACES SPACES LABEL
%type <node> tag tags string content
%type <attribute> attribute
%right STRING STRING_SPACES // verifier si pas %left
%start decl
%error-verbose
%%
//TODO : Enlever tous ces token d'espaces
decl:
	LET LABEL '=' tags ';' decl 				{printf("TODO : Affect 'tag' to the variable 'label' \n");}
	| LET LABEL SPACES '=' SPACES tags ';' SPACES decl 	{printf("TODO : Affect 'tag' to the variable 'label' \n");}
	| LET LABEL '=' tags IN tags ';' 			{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| LET LABEL SPACES '=' SPACES tags IN tags ';' 		{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| tags WHERE LABEL '=' tags ';'				{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| tags WHERE LABEL SPACES '=' SPACES tags ';' 		{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| LET LABEL args '=' func ';' {}
	| LET LABEL '=' FUNT args ARROW func ';' {}
	| LET LABEL args '=' FUNT args ARROW func ';' {}
	| LET REC LABEL args '=' FUNT args ARROW func ';' {}
	| tags {}
	| %empty {}
	;

args:
	LABEL args {}
	| LABEL {}
	;

func:
	%empty {}
	;
	
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
	| '{'  tags  '}'
	{

		if ($2 != NULL)
                { $$ = mk_forest(1, $2, NULL); }
		else
		{ $$ = NULL;}
		root = $$;
	}
	| '{'  tags  '}' tags
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
	LABEL '[' attribute ']' '{' content '}'
	{
                $$ = mk_tree($1, false, false, $3, $6);
	}
	| LABEL '[' attribute ']' SPACES '{' content '}'
	{
                $$ = mk_tree($1, false, false, $3, $7);
	}
	| LABEL '[' attribute ']' '/'
	{
                $$ = mk_tree($1, false, true, $3, NULL);
	} 
	| LABEL '{' content '}'
        {
                $$ = mk_tree($1, false, false, NULL, $3);
	}
	| '{' '}' {$$ = NULL;}
	| LABEL '/'
        {
                $$ = mk_tree($1, false, true, NULL, NULL);
	}
	;

//Un ensemble d'attributs
attribute:
        LABEL '=' string { $$ = mk_attributes($1, $3->node->forest->head->node->word->str, NULL); }
        | LABEL '=' string attribute { $$ = mk_attributes($1, $3->node->forest->head->node->word->str, $4); }
	| SPACES { $$ = NULL; }
	| SPACES attribute { $$ = $2; }
	;

//Contenu d'une balise : Ensemble de textes, de balises ou de balises autofermantes.
content:
        string content { $$ = mk_forest(1, $1, $2); }
        | tag content {  $$ = mk_forest(1, $1, $2); }
        | string   { mk_forest(1, $1, NULL); }
        | tag      { mk_forest(1, $1, NULL); }
        | LABEL	   {printf("TODO : Get Tree from var name.\n");}
        | LABEL	content   {printf("TODO : Get Tree from var name.\n");}
        | '{' content '}'    { mk_forest(1, $2, NULL); }
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
