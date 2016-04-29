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

#include "analyseur.tab.h"
#include "ast.h"
#include "variables.h"
#include "color_print.h"
#include "machine.h"

#include <stdlib.h>
#include <stdio.h>

extern FILE * yyin;
extern struct ast * root;
extern struct closure * cl;
//extern struct env * env;

int main(int argc, char **argv)
{
	int retCode = EXIT_SUCCESS;
	if (argc <= 1)
	{
	    printfC( TEXT_RED, "Le programme n'a pas de fichier sur lequel travailler, passer un nom de fichier en paramètre au programme pour qu'il puisse démarer\n" );
	}
	else
	{
	    FILE * input_file = fopen(argv[1], "r");
	    if (input_file == NULL)
	    {
	        printfC( TEXT_RED, "Le fichier <%s> n'a pas pu être ouvert, est introuvable ou vous n'avez pas les permissions d'accès a celui ci\n", argv[1] );
	        retCode = EXIT_FAILURE;
	    }
	    else
	    {
	        //cl = mk_closure( root, env );
	        yyin = input_file;
	        retCode = yyparse();
	        fclose( input_file );
	        show_ast(root, argv[2]);
	    }
        //printNode(root);
        
        //free_all();
	}
	return retCode;
}
