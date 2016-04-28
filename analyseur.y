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
%token bLEQ bLE bGEQ bGE bEQ bOR bAND bNOT
%token <text> STRING STRING_SPACES SPACES LABEL LABEL_LEFT_SQUARE_BRACKET LABEL_LEFT_BRACKET
%type <node> tag tags string content numexp exprtag ite cond decl
%type <attribute> attribute
%right STRING STRING_SPACES // verifier si pas %left
%start file
%error-verbose
%%

file:
    decls tags
    {}
    | decls
    {}
    | tags
    {}
    | %empty
    {}
    ;

decls: 
    decl ';' decls
    {
        
    }
    //| decl where ';'
    | decl ';'
    {
        
    }
    ;

decl:
    //LET LABEL '=' val
    LET LABEL '=' tag
    {
        mk_fun( $2, $4 );
    }
    | LET LABEL '=' numexp
    {
        $$ = mk_fun( $2, $4 );
    }
    //| LET LABEL '=' LABEL
    | LET LABEL '=' exprtag
    {
        $$ = mk_fun( $2, $4 );
    }
    | LET LABEL args '=' func
    {
        
    }
    | LET LABEL '=' FUNT args ARROW func
    {
        
    }
    | LET LABEL args '=' FUNT args ARROW func
    {
        
    }
    | LET REC LABEL args '=' FUNT args ARROW func
    {
        
    }
	;
	

/*
where:
    WHERE LABEL '=' tag
    {}
    | WHERE LABEL '=' numexp
    {}
    | WHERE LABEL args '=' func
    {}
    | WHERE LABEL '=' FUNT args ARROW func
    {}
    | WHERE LABEL args '=' FUNT args ARROW func
    {}
    | WHERE REC LABEL args '=' FUNT args ARROW func
*/
    
//val:
//    tag
//    | numexp
//    | ite
//    | LABEL
    //| funapp


args:
	args LABEL
	{}
	| LABEL
	{}
	;
	
//L’expression e qui sert à choisir la branche de la conditionnelle à exécuter 
//devra s’évaluer ou bien en un entier ou alors en un arbre. Si l’entier est 
//différent de 0 ou si l’arbre est non vide, alors la branche « then » sera 
//exécutée, sinon ce sera la branche « else ».
cond:
    NUMBER 
    {
        $$ = mk_integer( $1 );
    }
    | tags
    {
        $$ = $1;
    }
    | LABEL
    {
        $$ = mk_var( $1 );
    }
    | NUMBER '>' NUMBER
    {
        $$ = mk_app(
            mk_app( mk_binop( GE ), mk_integer( $1 ) ), mk_integer( $3 )
            );
    }
    | NUMBER '<' NUMBER
    {
        $$ = mk_app(
            mk_app( mk_binop( LE ), mk_integer( $1 ) ), mk_integer( $3 )
            );
    }
    | NUMBER bGEQ NUMBER
    {
        $$ = mk_app(
            mk_app( mk_binop( GEQ ), mk_integer( $1 ) ), mk_integer( $3 )
            );
    }
    | NUMBER bLEQ NUMBER
    {
        $$ = mk_app(
            mk_app( mk_binop( LEQ ), mk_integer( $1 ) ), mk_integer( $3 )
            );
    }
    | NUMBER bEQ NUMBER
    {
        $$ = mk_app(
            mk_app( mk_binop( EQ ), mk_integer( $1 ) ), mk_integer( $3 )
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
;

ite:
    IF cond THEN exprtag ELSE exprtag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | IF cond THEN tag ELSE exprtag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | IF cond THEN exprtag ELSE tag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | IF cond THEN tag ELSE tag 
    {
        $$ = mk_cond( $2, $4, $6 );
    }
    | '(' ite ')'
    {
        $$ = $2;
    }
    ;

//Pour l'instant, le contenu d'une fonction n'est pas traite, mais pour tout de 
//même traite le reste de la grammaire, temporairement, je dis que le contenu
//d'une fonction est 'fun'
//fonction est soit une expression numerique, soit une operation de comparaison
func:
	FUNT
	{}
	| %empty
	{}
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
    LET LABEL '=' tag IN tag
    {
        $$ = mk_app( 
            mk_fun( $2, $6 ), $4
            );
    }
    | LET LABEL '=' exprtag IN tag
    {
        $$ = mk_app( 
            mk_fun( $2, $6 ), $4
            );
    }
    | LET LABEL '=' tag IN exprtag
    {
        $$ = mk_app( 
            mk_fun( $2, $6 ), $4
            );
    }
    | LET LABEL '=' exprtag IN exprtag
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
	;

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
    | exprtag ','
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
