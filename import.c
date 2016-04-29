#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "import.h"

char * from_path_to_name(struct path * chemin){
    int file_length = chemin->n * 3;
    char * file_name = malloc(sizeof(char) * file_length);
    for ( int i = 0; i < chemin->n; i ++ )
    {
        file_name[i * 3] = '.';
        file_name[(i * 3) + 1] = '.';
        file_name[(i * 3) + 2] = '/';
    }
    struct dir * iterator = chemin->dir;
    while ( iterator != NULL )
    {
        if ( iterator->descr == DIR || iterator->descr == FILENAME )
        {
            int prec_length = file_length;
            file_name = realloc( file_name, sizeof(char) * (file_length += strlen(iterator->str) + 1 ));
            for ( int i = prec_length; i < file_length; i ++ )
            {
                file_name[i] = iterator->str[i - prec_length];
            }
        }
        switch ( iterator->descr )
        {
            case DIR:
                file_name[file_length - 1] = '/';
                break;
            case FILENAME:
                file_name[file_length - 1] = '\0';
                break;
            case DECLNAME:
                break;
        }
    }
    return file_name;
}

struct closure * retreive_tree(struct path * chemin,struct files * f){
    char * name = from_path_to_name(chemin);
    struct files * tmp = f;
    while(tmp!=NULL){
        if(!strcmp(name, f->file_name)){
            return tmp->cl;
        }
        else{
            tmp=tmp->next;
        }
    }
    return NULL;
}

struct closure * retrieve_name(struct path * chemin, char * name, struct files * f){
    struct closure * cl = retreive_tree(chemin,f);
    struct env * e = cl->env;
    while(e!=NULL){
        if(!strcmp(name,e->var)){
            return  e->value;
        }
        else{
            e=e->next;
        }
    }
    fprintf(stderr,
            "Variable %s du fichier %s non trouvÃ©e",
            name, from_path_to_name(chemin));
    exit(1);
}

struct env * initial_env = NULL;

struct env * process_binding_instruction(char * name, struct ast * a, struct env * e){
    struct machine * m = malloc(sizeof(struct machine));
    m->closure = mk_closure(a,e);
    m->stack=NULL;
    compute(m);
    //free(m);
    //should free stack...
    return mk_env(name,m->closure,e);
}
    

void process_instruction(struct ast * a, struct env * e){
    struct machine * m = malloc(sizeof(struct machine));
    m->closure = mk_closure(a,e);
    m->stack=NULL;
    compute(m);
    free(m);
}

struct closure * process_content(struct ast * a, struct env * e){
    struct machine * m = malloc(sizeof(struct machine));
    m->closure = mk_closure(a,e);
    m->stack=NULL;
    compute(m);
    if(m->closure->value->type==TREE || m->closure->value->type==FOREST){
        free(m);
        return m->closure;
    }
    else{
        fprintf(stderr,"Le contenu d'un fichier doit Ãªtre un arbre ou une forÃªt");
        exit(1);
    }
}

struct files * add_file(struct path * chemin, struct closure * cl, struct files * f){
    struct files * res = malloc(sizeof(struct files));
    res->file_name = from_path_to_name(chemin);
    res ->cl = cl;
    res->next = f;
    return res;
}
