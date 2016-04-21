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
#include <stdlib.h>
#include <string.h>

//Gestion des variables
struct env {
    struct ast * root;
    char * var;
    struct env * tail;
  };
struct env * environment = NULL;
int push_var(char * var, struct ast * root) {
    struct env * celltoFind =  NULL;
    struct env * cell = environment;
    while (cell != NULL){
        if(!strcmp(var,cell->var)) {
	    celltoFind = cell;
	    cell = NULL;
	}
        else{
	    cell=cell->tail;
	}
    }
    if (celltoFind!=NULL) {
        celltoFind->root = root;
        return 0;
    }
    else {
        struct env * cell = malloc(sizeof(struct env));
        cell->var = var;
        cell->root = root;
        cell->tail = environment;
        environment = cell;
        return 1;
    }
}
struct ast * search_var(char* var) {
    struct env * cell = environment;
    while (cell != NULL) {
        if(!strcmp(var,cell->var)) {
            return cell->root;
        }
        else {
            cell=cell->tail;
        }
    }
    printf("Variable %s non initialisé\n", var);
    return NULL;
}

void free_all() {
    struct env * currentCell = environment;
    while (currentCell != NULL){
        struct env * lastCell = currentCell;
        currentCell=currentCell->tail;
        free(lastCell->var);
        free(lastCell);
        environment = currentCell;
    }
}
  
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
%token <text> STRING STRING_SPACES SPACES LABEL LABEL_LEFT_SQUARE_BRACKET LABEL_LEFT_BRACKET
%type <node> tag tags string content
%type <attribute> attribute
%right STRING STRING_SPACES // verifier si pas %left
%start decl
%error-verbose
%%
//TODO : Enlever tous ces token d'espaces
decl:
	LET LABEL '=' tags 				{printf("TODO : Affect 'tag' to the variable 'label' \n");}
	| LET LABEL '=' tags IN tags 		{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| tags WHERE LABEL '=' tags 				{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| LET LABEL args '=' func {}
	| LET LABEL '=' FUNT args ARROW func {}
	| LET LABEL args '=' FUNT args ARROW func {}
	| LET REC LABEL args '=' FUNT args ARROW func {}
	| tags {}
	| decl ';' decl
	| %empty
	;

args:
	LABEL LABEL {}
	| LABEL {}
	;
//Pour l'instant, le contenu d'une fonction n'est pas traite, mais pour tout de 
//même traite le reste dela grammaire, temporairement, je dis que le contenu 
//d'une fonction est 'fun'
func:
	FUNT {}
	| %empty {}
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
	;
//Balise
tag:
	LABEL_LEFT_SQUARE_BRACKET attribute ']' '{' content '}'
	{
                $$ = mk_tree($1, false, false, $2, $5);
	}
	| LABEL_LEFT_SQUARE_BRACKET attribute ']' '/'
	{
                $$ = mk_tree($1, false, true, $2, NULL);
	} 
	| LABEL_LEFT_BRACKET content '}'
        {
                $$ = mk_tree($1, false, false, NULL, $2);
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
