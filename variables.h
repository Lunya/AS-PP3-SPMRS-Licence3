#ifndef VARIABLES_H
#define VARIABLES_H

#include <stdbool.h>
#include "ast.h"


struct var;
struct vars {
    struct var * list;              // liste chainée des variables 
    struct vars * next;             // variables du niveau inférieur
};

struct var {
    char * name;                    // nom de la variable
    struct ast * value;             // valeur de la variable
    struct var * next;              // variable suivante dans la chaine
};

/*
    Initialise une structure de variables.
    La gestion de la mémoire associée aux valeurs stockées est laissée a la
    charge del'utilisateur.
*/
struct vars * vars_create( void );

/*
    Détrut une structure de variables proprement en supprimant toutes les
    variables qu'elle contient.
*/
void vars_delete(struct vars * );

/*
    Ajoute un nouveau niveau dans la pile de variables.
*/
void vars_add_level( struct vars * );

/*
    Supprime un niveau de la pile des variables.
    Les variables présentes dans ce niveau sont supprimées.
*/
void vars_del_level( struct vars * );

/*
    Si la variable n'existe pas, la crée puis lui affecte la valeur.
        Retourne NULL
    Si la variable existe, modifie sa valeur.
        Retourne un pointeur vers l'ancienne valeur.
*/
struct ast * vars_add_var( struct vars *, char *, struct ast * );

/*
    Retourne true si la variable est accessible, false sinon.
*/
bool vars_var_exist( struct vars *, char * name);

/*
    Retourne un pointeur sur la valeur de la variable si celle ci existe,
    NULL sinon.
*/
struct ast * vars_get( struct vars *, char * name);

/*
    Retourne le nombre de niveaux empilés dans la structure.
    le niveau de base est 0.
*/
unsigned int vars_get_level( struct vars * );


#endif //VARIABLES_H