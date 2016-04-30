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
//extern struct env * initial_env;
struct env * e = NULL;
struct closure * cl = NULL;
struct stack * st = NULL;
struct machine * m = NULL;

struct ast * root = NULL;
/*

struct closure * cl = NULL;
struct env * e = initial_env;
*/

int yylex(void);
void yyerror(const char*);

%}

%union {
	int number;
	char * text;
    struct ast * node;
    struct attributes * attribute;
    struct pattern * pattern;
    struct patterns * patterns;
}

%left bPLUS bMINUS
%left bMULT bDIV
%left ';'
%token LET IN WHERE FUNT ARROW REC IF THEN ELSE bMATCH WITH END UNDERSCORE_LEFT_BRACKET
%token <number> NUMBER
%token bLEQ bLE bGEQ bGE bEQ bOR bAND bNOT bEMIT bNEQ
%token <text> STRING STRING_SPACES SPACES LABEL LABEL_LEFT_SQUARE_BRACKET LABEL_LEFT_BRACKET STRING_ATTRIBUTE
%type <node> tag tags string content numexp exprtag ite cond decl args decls file conds match params
%type <attribute> attribute
%type <pattern> patterns pattern pvar wildcard
%type <patterns> filters
%right STRING STRING_SPACES // verifier si pas %left
%start file
%error-verbose
%%


file:
    decls tags
    {
        printf("decls tags\n");
        $$ = mk_app( $1, $2 );
        root = $$;
        show_ast( root, "tests/tartine.dot" );
        process_instruction($$, e);
    }
    | decls
    {
        printf("decls\n");
        $$ = $1;
        //$$ = mk_forest( false, $1, NULL );
        root = $$;
        show_ast( root, "tests/tartine.dot" );
        process_instruction($$, e);
    }
    | tags
    {
        printf("tags\n");
        //$$ = $1;
        $$ = mk_forest( false, NULL, $1 );
        //cl = process_content( $1, e );
        //m = mk_machine(cl, )
        root = $$;
        show_ast( root, "tests/tartine.dot" );
        //process_instruction($$, e);
        process_instruction($$, e);
    }
    | %empty
    {
        printf("empty\n");
        $$ = mk_forest( false, NULL, NULL );
        //$$ = NULL;
        root = $$;
        show_ast( root, "tests/tartine.dot" );
        //process_instruction($$, e);
    }
    ;

decls: 
    decl ';' decls
    {
        $$ = mk_app( $1, $3 );
    }
    | decl ';'
    {
        $$ = $1;
    }
    ;

decl:
    LET LABEL '=' tags
    {
        //$$ = mk_fun( $2, $4 );
        $$ = mk_fun( $2, $4 );
        e = process_binding_instruction($2, $4, e);
    }
    | LET LABEL '=' numexp
    {
        //$$ = mk_fun( $2, $4 );
        $$ = mk_fun( $2, $4 );
        e = process_binding_instruction($2, $4, e);
    }
    | LET LABEL args '=' tags
    {
        struct ast * iterator = $3;
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        iterator->node->fun->body = mk_fun( $2, $5 );
        
        $$ = $3;
        //e = process_binding_instruction($2, $5, e);
        //$$ = mk_fun($2, $5);
    }
    | LET LABEL '=' FUNT args ARROW tags
    {
        
        struct ast * iterator = $5;
        while (iterator->node->fun->body != NULL){
            iterator = iterator->node->fun->body;
        }
        iterator->node->fun->body = mk_fun( $2, $7);
        $$ = $5;
        //e = process_binding_instruction($2, $5, e);
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
        iterator->node->fun->body = mk_fun( $2, $8 );
        $$ = $3;
        e = process_binding_instruction($2, $3, e);
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
        iterator->node->fun->body = mk_fun( $3, $9 );
        $$ = $4;
        e = process_binding_instruction($3, $4, e);
    }
    | bEMIT STRING tags
    {
       $$ = mk_app(
            mk_app( mk_binop(EMIT), mk_word($2) ), $3
            );
        //emit($2, $3);
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
    IF conds THEN tags ELSE tags 
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
        $$ = mk_integer( $1 );
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
            $$ = mk_forest( false, $1, $2 );
        else
            $$ = NULL;
	}
	| tag
	{
		if ($1 != NULL)
            $$ = mk_forest( false, $1, NULL);
		else
            $$ = NULL;
	}
	| '{' tags '}'
	{

		if ($2 != NULL)
            $$ = mk_forest( false, $2, NULL);
		else
		    $$ = NULL;
	}
	| '{' tags '}' tags
	{

		if ($2 != NULL)
            $$ = mk_forest( false, $2, $4);
		else
            $$ = NULL;
	}
	| exprtag
	{
	    $$ = mk_forest( false, $1, NULL);
	}
	/*
	| exprtag tags
	{
	    if ($1 != NULL)
            $$ = mk_forest( false, $1, $2 );
        else
            $$ = NULL;
	}
	*/
	| match
	{
	    $$ = $1;
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
            mk_fun( $3, mk_forest( false, $1, NULL) ), mk_forest( false, $5, NULL)
            );
    }
	| ite 
	{
	    $$ = $1;
	}
	| LABEL
	{
	    $$ = mk_var( $1 );
	}
	| LABEL params
	{
	    struct ast * iterator = $2;
        while (iterator->node->app->fun != NULL){
            iterator = iterator->node->app->fun;
        }
        fprintf(stderr, "%s\n", $1);
        iterator->node->app->fun = mk_fun($1, NULL);
        //iterator->node->app->fun = mk_forest(false, mk_word($1), NULL);
        $$ = $2;
	}
;


params:
    tag params
	{
	    $$ = mk_app( $2, $1 );
	}
	| tag
	{
	    $$ = mk_app( NULL, $1 );
	}
	| LABEL params
	{
	    $$ = mk_app( $2, mk_word($1) );
	}
	| LABEL
	{
	    $$ = mk_app( NULL, mk_word($1) );
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
    LABEL '=' STRING
    {
        $$ = mk_attributes( $1, $3, NULL );
    
    }
    | LABEL '=' STRING attribute
    {
        $$ = mk_attributes( $1, $3, $4 );
    }
	;

//Contenu d'une balise : Ensemble de textes, de balises ou de balises autofermantes.
content:
    string content
    {
        $$ = mk_forest( false, $1, $2 );
    }
    | tag content
    {
        $$ = mk_forest( false, $1, $2 );
    }
    | string
    {
        $$ = mk_forest(false, $1, NULL);
    }
    | tag
    {
        $$ = mk_forest(false, $1, NULL);
    }
    | exprtag
    {
        $$ = mk_forest(false, $1, NULL);
    }
    | exprtag ',' content
    {
        $$ = mk_forest( false, $1, $3);
    }
    | '{' content '}'
    {
        //$$ = mk_forest( false, $2, NULL );
        $$ = $2;
    }
	;


match:
    bMATCH tags WITH filters END
    {
        $$ = mk_match($2, $4);
    }
;


filters:
    '|' LABEL_LEFT_BRACKET patterns '}' ARROW tags filters
    {
        $$ = mk_patterns(mk_ptree($2, false, $3), $6, $7);
    }
    | '|' LABEL_LEFT_BRACKET '}' ARROW tags filters
    {
        $$ = mk_patterns(mk_ptree($2, true, NULL), $5, $6);
    }
    | '|' UNDERSCORE_LEFT_BRACKET patterns '}' ARROW tags filters
    {
        $$ = mk_patterns(mk_anytree(false, $3), $6, $7);
    }
    | '|' UNDERSCORE_LEFT_BRACKET '}' ARROW tags filters
    {
        $$ = mk_patterns(mk_anytree(true, NULL), $5, $6);
    }
	| '|' LABEL_LEFT_BRACKET patterns '}' ARROW tags
	{
        $$ = mk_patterns(mk_ptree($2, false, $3), $6, NULL);
	}
	| '|' LABEL_LEFT_BRACKET '}' ARROW tags
    {
        $$ = mk_patterns(mk_ptree($2, true, NULL), $5, NULL);
    }
    | '|' UNDERSCORE_LEFT_BRACKET patterns '}' ARROW tags
    {
        $$ = mk_patterns(mk_anytree(false, $3), $6, NULL);
    }
    | '|' UNDERSCORE_LEFT_BRACKET '}' ARROW tags
    {
        $$ = mk_patterns(mk_anytree(true, NULL), $5, NULL);
    }
    ;

patterns:
	pattern patterns
	{
	    $$ = mk_pforest($1, $2);
	}
	| pattern
	{
	    $$ = mk_pforest($1, NULL);
	}
	;

pattern:
    wildcard
    {
        $$ = $1 ;
    }
    | LABEL_LEFT_BRACKET patterns '}'
    {
        $$ = mk_ptree($1, false, $2 );
    }
    | LABEL_LEFT_BRACKET '}'
    {
        $$ = mk_ptree($1, true, NULL );
    }        
	| '*' STRING '*'
    {
        $$ = mk_pstring($2);
    }	
    | pvar
    {
        $$ = $1;
    }    
    | '{' patterns '}'
    {
        $$ = $2;
    }
    | UNDERSCORE_LEFT_BRACKET patterns '}'
    {
        $$ = mk_anytree(false, $2);
    }   
    | UNDERSCORE_LEFT_BRACKET '}'
    {
        $$ = mk_anytree(true, NULL);
    }       
    ;
    
pvar:
	LABEL
    {
        $$ = mk_pattern_var($1, TREEVAR);
    }	
	| '*' LABEL '*'
    {
        $$ = mk_pattern_var($2, STRINGVAR);
    }	
	| '/' LABEL '/'
    {
        $$ = mk_pattern_var($2, FORESTVAR);
    }	
	| '{' LABEL '}'
    {
        $$ = mk_pattern_var($2, ANYVAR);
    }
    ;
	
wildcard:
    '_'
    {
        $$ = mk_wildcard(ANY);
    }
    | '*' '_' '*'
    {
        $$ = mk_wildcard(ANYSTRING);
    }
	| '/' '_' '/'
	{
        $$ = mk_wildcard(ANYFOREST);
    }
    | '{' '_' '}' 
    {
        $$ = mk_wildcard(ANYSEQ);
    }
    ;


// Ensemble de mot
string: // tester avec un espace juste après les "
    STRING string
    {
        $$ = mk_forest( false, mk_word( $1 ), $2 );
    }
	| STRING_SPACES string
    {
        //$2->node->forest->head = add_space( $2->node->forest->head );
        //Gestion des espaces entre les mots fonctionnent mal.
        $2->node->forest->head = $2->node->forest->head;
        //$<node>0->node->forest->head = add_space( $<node>0->node->forest->head );
        //printf("add space to |%s|\n", $2->node->forest->head->node->str);
        $$ = $2;
    }
    | STRING
    {
        $$ = mk_forest( false, mk_word( $1 ), NULL );
    }
    | STRING_SPACES
    {
        //printf("add space to ||\n");
        char * void_string = malloc(1);
        void_string[0] = '\0';
        //$$ = mk_forest( false, add_space( mk_word( void_string ) ), NULL );
        $$ = mk_forest( false, mk_word( void_string ), NULL );
    }
	;

%%

void yyerror(const char * err)
{
	fflush(stdout);
	fprintfC(stderr, BACKGROUND_RED|TEXT_WHITE, "%s\n", err);
}
