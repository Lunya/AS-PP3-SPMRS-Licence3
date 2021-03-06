#ifndef AST_H
#define AST_H

#include <stdbool.h>
#include "chemin.h"
#include "pattern.h"

enum ast_type {
    INTEGER,  // L'expression est un entier
    BINOP,    // L'expression est un operateur (addition, multiplication, comparaison,
    // operateur logique ...)
    UNARYOP,  // L'expression est un operateur unaire (ici, nous n'avons que la
    // negation logique)
    VAR,      // L'expression est une variable
    IMPORT,   // L'expression est correspond a une importation de fichier
    APP,      // L'expression est une application de fonction
    WORD,     // L'expression est un mot
    TREE,     // L'expression est un arbre
    FOREST,   // L'expression est une foret
    FUN,      // L'expression est une fonction
    MATCH,    // L'expression est un filtre
    COND,      // L'expression est une conditionnelle
    DECLREC   // Declarations recursives (let rec ... where rec ...)
};

enum binop{ PLUS, MINUS, MULT, DIV, LEQ, LE, GEQ, GE, EQ, NEQ, OR, AND, EMIT };

enum unaryop { NOT, NEG };

struct ast;

struct app{
    struct ast *fun;
    struct ast *arg;
};

struct attributes{
    struct ast * key;
    struct ast * value;
    struct attributes * next;
};

struct tree{
    char * label;
    bool is_value;
    bool nullary;
    struct attributes * attributes;
    struct ast * child;
};

struct forest{
    bool is_value;
    struct ast * head;
    struct ast * tail;
};

struct fun{
    char *id;
    struct ast *body;
};

struct patterns{
    struct pattern * pattern; //filtre
    struct ast * res;         //resultat si le filtre accepte
    struct patterns * next;   //filtres suivants si ce filtre echoue
};

struct match {
    struct ast * ast; // expression filtree
    struct patterns * patterns; // liste des filtres
};

struct cond{
    struct ast *cond;
    struct ast *then_br;
    struct ast *else_br;
};

struct declrec{
    char * id;
    struct ast * body;
};

union node{
    int num;
    enum binop binop;
    enum unaryop unaryop;
    char * str;
    struct path * chemin;
    struct app * app;
    struct tree * tree;
    struct forest * forest;
    struct fun * fun;
    struct match * match;
    struct cond * cond;
};

struct ast{
    enum  ast_type type;
    union node * node;
};

struct ast * mk_node(void);
struct ast * mk_integer(int n);
struct ast * mk_binop(enum binop binop);
struct ast * mk_unaryop(enum unaryop unaryop);
struct ast * mk_var(char * var);
struct ast * mk_import(struct path * chemin);
struct ast * mk_app(struct ast * fun, struct ast * arg);
struct ast * mk_word(char * str);
struct ast * mk_tree(char * label, bool is_value, bool nullary,
                     struct attributes * att, struct ast * child);
struct ast * mk_forest(bool is_value, struct ast * head, struct ast * tail);
struct ast * mk_fun(char * id, struct ast * body);
struct ast * mk_match(struct ast * ast, struct patterns * patterns);
struct ast * mk_cond(struct ast * cond, struct ast * then_br, struct ast * else_br);
struct ast * mk_declrec(char * id, struct ast * body);

struct patterns * mk_patterns( struct pattern * pattern, struct ast * res, struct patterns * next);

struct attributes * mk_attributes(char * key, char * value , struct attributes * next);
struct ast * add_space(struct ast * word);
struct ast * mk_forest(bool is_value, struct ast * head, struct ast * tail);

void show_ast(const struct ast * tree, const char * file_name);

void generate_html( struct ast * tree, const char * file_name);






void print_ast_type( enum ast_type);

#endif // AST_H