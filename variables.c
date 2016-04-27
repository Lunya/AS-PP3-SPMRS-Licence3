#include "variables.h"

#include <stdlib.h>
#include <string.h>


struct vars * vars_create( void )
{
    struct vars * v = malloc(sizeof(struct vars));
    v->list = NULL;
    v->next = NULL;
    return v;
}

void vars_delete(struct vars * v)
{
    struct vars * iterator_vars = v, * tmp_vars = NULL;
    struct var * iterator_var, * tmp_var = NULL;
    while (iterator_vars != NULL)
    {
        iterator_var = iterator_vars->list;
        while (iterator_var != NULL)
        {
            tmp_var = iterator_var;
            iterator_var = iterator_var->next;
            free(tmp_var);
        }
        tmp_vars = iterator_vars;
        iterator_vars = iterator_vars->next;
        free(tmp_vars);
    }
}

void vars_add_level( struct vars * v)
{
    struct vars * new_level = malloc(sizeof(struct vars));
    new_level->list = NULL;
    new_level->next = NULL;
    struct vars * iterator = v;
    while (iterator->next != NULL)
        iterator = iterator->next;
    iterator->next = new_level;
}

void vars_del_level( struct vars * v)
{
    struct var * iterator_var = NULL, * tmp = NULL;
    struct vars * iterator_vars = v, * prev_iterator = NULL;
    while (iterator_vars->next != NULL)
    {
        prev_iterator = iterator_vars;
        iterator_vars = iterator_vars->next;
    }
    iterator_var = iterator_vars->list;
    while (iterator_var != NULL)
    {
        tmp = iterator_var;
        free(tmp->name);
        iterator_var = tmp->next;
        free(tmp);
    }
    prev_iterator->next = NULL;
    free(iterator_vars);
}

struct ast * vars_add_var( struct vars * v, char * name, struct ast * value)
{
    struct vars * iterator_vars = v;
    struct var * iterator_var = NULL;
    struct ast * actual_value = NULL;
    bool var_exist = false;
    
    while (iterator_vars->next != NULL)
        iterator_vars = iterator_vars->next;
    iterator_var = iterator_vars->list;
    while (iterator_var != NULL && !iterator_var)
    {
        if (strcmp(iterator_var->name, name) == 0)
            var_exist = true;
        iterator_var = iterator_var->next;
    }
    
    if (var_exist)
    {
        actual_value = iterator_var->value;
        iterator_var->value = value;
    }
    else
    {
        struct var * new_var = malloc(sizeof(struct var));
        new_var->name = malloc(strlen(name) + 1);
        strcpy(new_var->name, name);
        new_var->value = value;
        new_var->next = iterator_vars->list;
        iterator_vars->list = new_var;
    }
    return actual_value;
}

bool vars_var_exist( struct vars * v, char * name)
{
    bool exists = false;
    struct vars * iterator_vars = v;
    struct var * iterator_var = NULL;
    while (iterator_vars != NULL)
    {
        iterator_var = iterator_vars->list;
        while (iterator_var != NULL && !exists)
        {
            if (strcmp(name, iterator_var->name) == 0)
                exists = true;

            iterator_var = iterator_var->next;
        }
        iterator_vars = iterator_vars->next;
    }
    return exists;
}

struct ast * vars_get( struct vars * v, char * name)
{
    struct vars * iterator_vars = v;
    struct var * iterator_var = NULL;
    struct ast * value = NULL;
    while (iterator_vars != NULL)
    {
        iterator_var = iterator_vars->list;
        while (iterator_var != NULL)
        {
            if (strcmp(name, iterator_var->name) == 0)
                value = iterator_var->value;
            iterator_var = iterator_var->next;
        }
        iterator_vars = iterator_vars->next;
    }
    return value;
}