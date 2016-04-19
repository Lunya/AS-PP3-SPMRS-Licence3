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

#include <stdio.h>

extern struct tree * root;

int main(int argc, char **argv)
{
	int retCode;
	retCode = yyparse();
    //printNode(root);
    //printNodeGraph(root, argv[1]);
	return retCode;
}
