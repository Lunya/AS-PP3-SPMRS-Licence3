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
#include "variables.h"
#include "pattern.h"
#include "import.h"
#include "machine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Gestion des variables
//struct vars * environment = NULL;
struct ast * root = NULL;
struct closure * cl = NULL;

int yylex(void);
void yyerror(const char*);

%}

%union {
	int number;
	char * text;
    struct ast * node;
    struct attributes * attribute;
}

%left bPLUS bMINUS
%left bMULT bDIV
%left ';'
%token LET IN WHERE FUNT ARROW REC IF THEN ELSE
%token <number> NUMBER
%token bLEQ bLE bGEQ bGE bEQ bOR bAND bNOT bEMIT bNEQ
%token <text> STRING STRING_SPACES SPACES LABEL LABEL_LEFT_SQUARE_BRACKET LABEL_LEFT_BRACKET
%type <node> tag tags string content numexp exprtag ite cond decl args decls file conds
%type <attribute> attribute
%right STRING STRING_SPACES // verifier si pas %left
%start file
%error-verbose
%%

file:
    decls tags
    {
        mk_forest( false, $1, $2);
    }
    | decls
    {
        $$ = $1;
    }
    | tags
    {
        $$ = $1;
    }
    | %empty
    {
        $$ = NULL;
    }
    ;

decls: 
    decl ';' decls
    {
        mk_forest( false, $1, $3 );
    }
    | decl ';'
    {
        $$ = $1;
    }
    ;

decl:
    LET LABEL '=' tags
    {
        mk_fun( $2, $4 );
    }
    | LET LABEL '=' numexp
    {
        $$ = mk_fun( $2, $4 );
    }
    | LET LABEL args '=' tags
    {
        struct ast * iterator = $3;
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        iterator->node->fun->body = $5;
        $$ = mk_fun($2, $5);
    }
    | LET LABEL '=' FUNT args ARROW tags
    {
        struct ast * iterator = $5;
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        iterator->node->fun->body = $5;
        $$ = mk_fun($2, $5);
    }
    | LET LABEL args '=' FUNT args ARROW tags
    {
        //On prend la première liste d'arguments
        struct ast * iterator = $3;
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        //On concatène la deuxième liste
        iterator->node->fun->body = $6;
        //On ajoute la le body à la fin
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        iterator->node->fun->body = $8;
        $$ = mk_fun($2, $3);
    }
    | LET REC LABEL args '=' FUNT args ARROW tags
    {
        //On prend la première liste d'arguments
        struct ast * iterator = $4;
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        //On concatène la deuxième liste
        iterator->node->fun->body = $7;
        //On ajoute la le body à la fin
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        iterator->node->fun->body = $9;
        $$ = mk_fun($3, $4);
    }
	;

args:
	LABEL args
	{
	    $$ = mk_fun( $1, $2 );
	}
	| LABEL
	{
	    $$ = mk_fun( $1, NULL );
	}
	;
	
//L’expression e qui sert à choisir la branche de la conditionnelle à exécuter 
//devra s’évaluer ou bien en un entier ou alors en un arbre. Si l’entier est 
//différent de 0 ou si l’arbre est non vide, alors la branche « then » sera 
//exécutée, sinon ce sera la branche « else ».
conds:
    cond bOR conds
    {
        $$ = mk_app(
            mk_app( mk_binop( OR ), $1 ), $3
            );
    }
    | cond bAND conds
    {
        $$ = mk_app(
            mk_app( mk_binop( AND ), $1 ), $3
            );
    }
    | cond
    {
        $$ = $1;
    }
    | '!' conds
    {
        $$ = mk_app( mk_unaryop( NOT ), $2 );
    }    
;


cond:
    numexp 
    {
        $$ = $1;
    }
    | tags
    {
        $$ = $1;
    }
    | numexp '>' numexp
    {
        $$ = mk_app(
            mk_app( mk_binop( GE ), $1 ), $3
            );
    }
    | numexp '<' numexp
    {
        $$ = mk_app(
            mk_app( mk_binop( LE ), $1 ), $3
            );
    }
    | numexp bGEQ numexp
    {
        $$ = mk_app(
            mk_app( mk_binop( GEQ ), $1 ), $3
            );
    }
    | numexp bLEQ numexp
    {
        $$ = mk_app(
            mk_app( mk_binop( LEQ ), $1 ), $3
            );
    }
    | numexp bEQ numexp
    {
        $$ = mk_app(
            mk_app( mk_binop( EQ ), $1 ), $3
            );
    }
    | numexp bNEQ numexp
    {
        $$ = mk_app(
            mk_app( mk_binop( NEQ ), $1 ), $3
            );
    }
    | tags '>' tags
    {
        $$ = mk_app(
            mk_app( mk_binop( GE ), $1 ), $3
            );
    }
    | tags '<' tags
    {
        $$ = mk_app(
            mk_app( mk_binop( LE ), $1 ), $3
            );
    }
    | tags bGEQ tags
    {
        $$ = mk_app(
            mk_app( mk_binop( GEQ ), $1 ), $3
            );
    }
    | tags bLEQ tags
    {
        $$ = mk_app(
            mk_app( mk_binop( LEQ ), $1 ), $3
            );
    }
    | tags bEQ tags
    {
        $$ = mk_app(
            mk_app( mk_binop( EQ ), $1 ), $3
            );
    }
    | tags bNEQ tags
    {
        $$ = mk_app(
            mk_app( mk_binop( NEQ ), $1 ), $3
            );
    }
;

ite:
    IF conds THEN exprtag ELSE exprtag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | IF conds THEN tag ELSE exprtag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | IF conds THEN exprtag ELSE tag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | IF conds THEN tag ELSE tag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | '(' ite ')'
    {
        $$ = $2;
    }
    ;

//operation numerique (stocker l'operation en tant que arbre de donnees, ne pas evaluer)
numexp:
    NUMBER
    {
        mk_integer( $1 );
    }
    | numexp bPLUS numexp 
    {
        $$ = mk_app(
            mk_app(
                mk_binop( PLUS ),
                $1),
            $3);
    }
    | numexp bMINUS numexp
    {
        $$ = mk_app(
            mk_app(
                mk_binop( MINUS ),
                $1),
            $3);
    }
    | numexp bMULT numexp
    {
        $$ = mk_app(
            mk_app(
                mk_binop( MULT ),
                $1),
            $3);
    }
    | numexp bDIV numexp
    {
        $$ = mk_app(
            mk_app(
                mk_binop( DIV ),
                $1),
            $3);
    }
    | '(' numexp ')'
    {
        $$ = $2;
    }
    ;

//Une forêt de balises
tags:
	tag tags
	{
        if ($1 != NULL)
            $$ = mk_forest( 1, $1, $2 );
        else
            $$ = NULL;
		root = $$;
	}
	| tag
	{
		if ($1 != NULL)
            $$ = mk_forest(1, $1, NULL);
		else
            $$ = NULL;
		root = $$;
	}
	| '{' tags '}'
	{

		if ($2 != NULL)
            $$ = mk_forest(1, $2, NULL);
		else
		    $$ = NULL;
		root = $$;
	}
	| '{' tags '}' tags
	{

		if ($2 != NULL)
            $$ = mk_forest(1, $2, $4);
		else
            $$ = NULL;
		root = $$;
	}
	| exprtag
	{
	    $$ = mk_forest(1, $1, NULL);
	}
	;
	
//Si quelqu'un a un moyen pour limiter les règles
exprtag:
    LET LABEL '=' tags IN tags
    {
        $$ = mk_app( 
            mk_fun( $2, $6 ), $4
            );
    }
    | tag WHERE LABEL '=' tag
    {
        $$ = mk_app( 
            mk_fun( $3, $1 ), $5
            );
    }
	| ite 
	{
	    $$ = $1;
	}
	| LABEL
	{
	    mk_var( $1 );
	}

/*
match:
    MATCH tag WITH filters END;

filters:    
    
filter:
*/


//Balise
tag:
	LABEL_LEFT_SQUARE_BRACKET attribute ']' '{' content '}'
	{
        $$ = mk_tree( $1, false, false, $2, $5 );
	}
	| LABEL_LEFT_SQUARE_BRACKET attribute ']' '/'
	{
        $$ = mk_tree( $1, false, true, $2, NULL );
	} 
	| LABEL_LEFT_BRACKET content '}'
    {
        $$ = mk_tree( $1, false, false, NULL, $2 );
	}
	| '{' '}'
	{
	    $$ = NULL;
	}
	| LABEL '/'
    {
        $$ = mk_tree( $1, false, true, NULL, NULL );
	}
	;

//Un ensemble d'attributs
attribute:
    LABEL '=' string
    {
        $$ = mk_attributes( $1, $3->node->forest->head->node->str, NULL );
    }
    | LABEL '=' string attribute
    {
        $$ = mk_attributes( $1, $3->node->forest->head->node->str, $4 );
    }
	;

//Contenu d'une balise : Ensemble de textes, de balises ou de balises autofermantes.
content:
    string content
    {
        $$ = mk_forest( 1, $1, $2 );
    }
    | tag content
    {
        $$ = mk_forest( 1, $1, $2 );
    }
    | string
    {
        mk_forest( 1, $1, NULL );
    }
    | tag
    {
        mk_forest( 1, $1, NULL );
    }
    | exprtag
    {
        mk_forest( 1, $1, NULL);
    }
    | exprtag ',' content
    {
        mk_forest( 1, $1, $3);
    }
    | '{' content '}'
    {
        mk_forest( 1, $2, NULL );
    }
	;

// Ensemble de mot
string: // tester avec un espace juste après les "
    STRING string
    {
        $$ = mk_forest( 1, mk_word( $1 ), $2 );
    }
	| STRING_SPACES string
    {
        $$ = $2;
        //add_space( $$ );
    }
    | STRING
    {
        $$ = mk_forest( 1, mk_word( $1 ), NULL );
    }
    | STRING_SPACES {
        //$$ = mk_forest( 1, add_space( mk_word( "" ) ), NULL );
    }
	;

%%

void yyerror(const char * err)
{
	fflush(stdout);
	fprintfC(stderr, BACKGROUND_RED|TEXT_WHITE, "%s\n", err);
}
