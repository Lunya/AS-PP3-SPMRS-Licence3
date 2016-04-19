#ifndef _NODE_H
#define _NODE_H

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

struct tree;
struct attributes;
enum type {TREE, WORD};        //typage des nœuds: permet de savoir si un nœud construit
                               //un arbre ou s'il s'agit simplement de texte

struct attributes{
    char * key;               //nom de l'attribut
    char * value;             //valeur de l'attribut
    struct attributes * next; //attribut suivant
};

struct tree {
    char * label;              //étiquette du nœud
    bool nullary;              //nœud vide, par exemple <br/>
    bool space;                //nœud suivi d'un espace
    enum type tp;              //type du nœud. nullary doit être true s tp vaut word
    struct attributes * attr;  //attributs du nœud
    struct tree * child;   //WORD gauche, qui doit être NULL si nullary est true
    struct tree * right;       //frère droit
};

//struct tree * createNode(char * label, bool nullary, bool space, enum type tp);

//struct attributes * createAttribute(char * key, char * value);

//void addAttributeBrother(struct attributes * attr, struct attributes * brother);

//void addAttribute(struct tree * node, struct attributes * attr);

//void addChild(struct tree * node, struct tree * child);

//void addBrother(struct tree * node, struct tree * brother);

//void addSpace(struct tree * node);

//void printNode(struct tree * node);

//void printNodeGraph(struct tree * node, char * out);

#endif //_NODE_H
