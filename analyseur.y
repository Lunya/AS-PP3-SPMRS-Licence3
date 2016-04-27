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
/*
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
  */
struct ast * root = NULL;

int yylex(void);
void yyerror(const char*);

%}

%union {
	int number;
	char * text;
	enum binop;
    struct ast * node;
    struct attributes * attribute;
}

%token LET IN WHERE FUNT ARROW REC IF THEN ELSE
%token <number> NUMBER
%left <binop> bPLUS bMINUS
%left <binop> bMULT bDIV
%token <binop> bLEQ bLE bGEQ bGE bEQ bOR bAND bNOT
//trouver un moyen de declarer ces variables dans bison sans erreur a la compilation
%token <text> STRING STRING_SPACES SPACES LABEL LABEL_LEFT_SQUARE_BRACKET LABEL_LEFT_BRACKET
%type <node> tag tags string content
%type <attribute> attribute
%right STRING STRING_SPACES // verifier si pas %left
%start file
%error-verbose
%%

//a modifier: declaration peut prendre soit une valeur numerique (fonction numerique possible) soit un arbre/foret
//sujet indique que les declarations de variables et fonctions sont toujours avant les forets, a priori pas de melange possible
//dclaration est forcement suivie d'un point virgule si il reste des elements a evaluer apres celle ci
//-> declaration sans point virgule possible que en fin de fichier

file:
    decls tags { }
    | decls{ }
    | tags
    | %empty
    ;

decls: 
    decl ';' decls
    | decl ';'
    //| decl
    ;

decl:
    LET LABEL '=' tag 	{  }
    | LET LABEL '=' numexp { }
    | LET LABEL '=' exprtag { }
    | LET LABEL args '=' func {  }
    | LET LABEL '=' FUNT args ARROW func { }
    | LET LABEL args '=' FUNT args ARROW func {  }
    | LET REC LABEL args '=' FUNT args ARROW func {  }
	;

args:
	args LABEL {}
	| LABEL {}
	;
//L’expression e qui sert à choisir la branche de la conditionnelle à exécuter 
//devra s’évaluer ou bien en un entier ou alors en un arbre. Si l’entier est 
//différent de 0 ou si l’arbre est non vide, alors la branche « then » sera 
//exécutée, sinon ce sera la branche « else ».
ITE:
    IF NUMBER THEN exprtag ELSE exprtag 
    {
        
    }
    | IF tags THEN exprtag ELSE exprtag 
    {
        
    }
    | '(' ITE ')'
;

//Pour l'instant, le contenu d'une fonction n'est pas traite, mais pour tout de 
//même traite le reste de la grammaire, temporairement, je dis que le contenu
//d'une fonction est 'fun'
//fonction est soit une expression numerique, soit une operation de comparaison
func:
	FUNT {}
	| %empty {}
        ;

//operation numerique (stocker l'operation en tant que arbre de donnees, ne pas evaluer)
numexp:
        NUMBER                      {     }
        | numexp bPLUS numexp        {     }
        | numexp bMINUS numexp       {     }
        | numexp bMULT numexp        {     }
        | numexp bDIV numexp         {     }
        | '(' numexp ')'            {     }

//comparaison LEQ, LE, GEQ, GE, EQ, OR, AND entre valeur numeriques | arbres | forets (tester les deux elements du meme type)
//NOT renvoie le contraire de l'evaluation
//compexp:


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
	| exprtag
	;
//Si quelqu'un a un moyen pour limiter les règles
exprtag:
    LET LABEL '=' tag IN tag	{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
    | LET LABEL '=' exprtag IN tag	{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
    | LET LABEL '=' tag IN exprtag	{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
    | LET LABEL '=' exprtag IN exprtag	{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
    | tag WHERE LABEL '=' tag	{printf("TODO : Affect 'tag' locally to the variable 'LABEL' to the tags 'TAGS' [IN] \n");}
	| ITE {}
	| LABEL {printf("TODO : Get Tree from var name.\n");}
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
        | exprtag ','	   {}
        | exprtag	',' content   {}
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
