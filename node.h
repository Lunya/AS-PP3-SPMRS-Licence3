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
    struct tree * daughters;   //fils gauche, qui doit être NULL si nullary est true
    struct tree * right;       //frère droit
};

struct tree * createNode(char * label);

struct attributes * createAttribute(char * key, char * value);



void addAttribute(struct tree * node, struct attribute * attr);

void addChild(struct tree * node, struct tree * daughter);

void printNode(struct tree * node);
