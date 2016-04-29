#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"
#include "import.h"

extern struct env * initial_env;

struct ast * mk_node(void){
    struct ast *e = malloc(sizeof(struct ast));
    e->node = malloc(sizeof(union node));
    return e;
}

struct ast * mk_integer(int n){
    struct ast * e = mk_node();
    e->type = INTEGER;
    e->node->num = n;
    return e;
}
struct ast * mk_binop(enum binop binop){
    struct ast * e = mk_node();
    e->type = BINOP;
    e->node->binop = binop;
    return e;
}
struct ast * mk_unaryop(enum unaryop unaryop){
    struct ast * e = mk_node();
    e->type = UNARYOP;
    e->node->unaryop = unaryop;
    return e;
}
struct ast * mk_var(char * var){
    struct ast * e = mk_node();
    e->type = VAR;
    e->node->str = var;
    return e;

}
struct ast * mk_import(struct path * chemin){
    struct ast * e = mk_node();
    e->type = IMPORT;
    e->node->chemin = chemin;
    return e;
}
struct ast * mk_app(struct ast * fun, struct ast * arg){
    struct ast * e = mk_node();
    e->type = APP;
    e->node->app = malloc(sizeof(struct app));
    e->node->app->fun = fun;
    e->node->app->arg = arg;
    return e;
}
struct ast * mk_word(char * str){
    struct ast * e = mk_node();
    e->type = WORD;
    e->node->str = str;
    return e;
}
struct ast * mk_tree(char * label, bool is_value, bool nullary,
                     struct attributes * att, struct ast * child){
    struct ast * e = mk_node();
    e->type = TREE;
    e->node->tree = malloc(sizeof(struct tree));
    e->node->tree->label = label;
    e->node->tree->is_value=is_value;
    e->node->tree->nullary=nullary;
    e->node->tree->attributes=att;
    e->node->tree->child=child;
    return e;
}
struct ast * mk_forest(bool is_value, struct ast * head, struct ast * tail){
    struct ast * e = mk_node();
    e->type = FOREST;
    e->node->forest = malloc(sizeof(struct forest));
    e->node->forest->is_value = is_value;
    e->node->forest->head=head;
    e->node->forest->tail=tail;
    return e;
}
struct ast * mk_fun(char * id, struct ast * body){
    struct ast * e = mk_node();
    e->type = FUN;
    e->node->fun = malloc(sizeof(struct fun));
    e->node->fun->id = id;
    e->node->fun->body=body;
    return e;
}
struct ast * mk_match(struct ast * ast, struct patterns * patterns){
    struct ast * e = mk_node();
    e->type = MATCH;
    e->node->match = malloc(sizeof(struct match));
    e->node->match->ast = ast;
    e->node->match->patterns=patterns;
    return e;
}
struct ast * mk_cond(struct ast * cond, struct ast * then_br, struct ast * else_br){
    struct ast * e = mk_node();
    e->type = COND;
    e->node->cond = malloc(sizeof(struct cond));
    e->node->cond->cond = cond;
    e->node->cond->then_br=then_br;
    e->node->cond->else_br=else_br;
    return e;
}

struct ast * mk_declrec(char * id, struct ast * body){
    struct ast * e = mk_node();
    e->type = DECLREC;
    e->node->fun=malloc(sizeof(struct fun));
    e->node->fun->id = id;
    e->node->fun->body=body;
    return e;
}

struct attributes * mk_attributes(char * key, char * value , struct attributes * next){
	struct attributes *e = malloc(sizeof(struct attributes));
	e->key = mk_word(key);
	e->value = mk_word(value);
	e->next = next;
	return e;
}

struct ast * add_space(struct ast * word){
	if (word->type == WORD)
	{
	    int str_len = strlen( word->node->str );
	    char * new_str = malloc( str_len + 2 );
	    strcpy( new_str, word->node->str );
	    new_str[str_len] = ' ';
	    new_str[str_len + 1] = '\0';
	    word->node->str = new_str;
	}
	return word;
}

int iterations;
void show_ast_rec(FILE *, const struct ast *, unsigned int, unsigned int *, unsigned int *);
void show_ast(const struct ast * tree, const char * file_name)
{
	FILE * fd = fopen(file_name, "w");
	fprintf(fd, "/*\n\
Usage : dot -Tpng %s -o graph.png\n\
*/\n\
digraph G {\n\
\tedge [arrowhead=empty];\n",
	file_name);
	fprintf(fd, "\tsubgraph cluster_legend {\n\
\t\tlabel = <<font point-size=\"20\">Legend</font>>;\n\
\t\tnode [shape=plaintext];\n\
\t\trankdir=LR;\n\
\t\tkey1 [label=<<table border=\"0\">\n\
\t\t<tr><td port=\"e1\">C son pointer</td></tr>\n\
\t\t<tr><td port=\"e2\">C brother pointer</td></tr>\n\
\t\t<tr><td port=\"e3\">tree representation</td></tr>\n\
\t\t<tr><td port=\"e4\">C attribute pointer</td></tr>\n\
\t\t<tr><td port=\"e5\">tree representation</td></tr>\n\
\t\t</table>>,];\n\
\t\tkey2 [label=<<table border=\"0\">\n\
\t\t<tr><td port=\"e1\">-</td></tr>\n\
\t\t<tr><td port=\"e2\">-</td></tr>\n\
\t\t<tr><td port=\"e3\">-</td></tr>\n\
\t\t<tr><td port=\"e4\">-</td></tr>\n\
\t\t<tr><td port=\"e5\">-</td></tr>\n\
\t\t</table>>,];\n\
\t\tkey1:e1:e -> key2:e1:w [color=\"#ff8800\"];\n\
\t\tkey1:e2:e -> key2:e2:w [color=\"#ff0000\"];\n\
\t\tkey1:e3:e -> key2:e3:w [color=\"#ff8800\", style=dotted];\n\
\t\tkey1:e4:e -> key2:e4:w [color=\"#0088ff\"];\n\
\t\tkey1:e5:e -> key2:e5:w [color=\"#0088ff\", style=dotted];\n\
\t\t{rank = same; key1; key2}\n\
\t}\n");
	fprintf(fd, "\t\"node0\" [shape=none, label=\"\"]\n");
	unsigned int id = 1;
	unsigned int attr = 1;
	iterations = 0;
	show_ast_rec(fd, tree, 0, &id, &attr);
	fprintf(fd, "}\n");
	fclose(fd);
}

void show_ast_rec(FILE * fd, const struct ast * tree, unsigned int parent, unsigned int * id, unsigned int * attr)
{
    if (iterations < 1000)
    {
        iterations ++;
    	unsigned int actual_node = *id;
    	unsigned int actual_attributes = *attr;
    	if (tree != NULL)
    	{
    		switch (tree->type)
    		{
    			case INTEGER:
    			{
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: INTEGER</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880000\">num: %d</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					tree->node->num
    				);
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ffff00\"];\n",
    					parent,
    					actual_node
    				);
    				break;
    			}
    			case BINOP:
    			{
    			    char * text;
    			    switch (tree->node->binop)
    			    {
                        case PLUS: text = "PLUS"; break;
                        case MINUS: text = "MINUS"; break;
                        case MULT: text = "MUL"; break;
                        case DIV: text = "DIV"; break;
                        case LEQ: text = "LEQ"; break;
                        case LE: text = "LE"; break;
                        case GEQ: text = "GEQ"; break;
                        case GE: text = "GE"; break;
                        case EQ: text = "EQ"; break;
                        case NEQ: text = "NEQ"; break;
                        case OR: text = "OR"; break;
                        case AND: text = "AND"; break;
                        case EMIT: text = "EMIT"; break;
                        default: text = "bad value";
    			    }
    			    fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: BINOP</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880000\">value: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					text
    				);
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ffff00\"];\n",
    					parent,
    					actual_node
    				);
    				break;
    			}
    			case UNARYOP:
    			{
    			    char * text;
    			    switch (tree->node->unaryop)
    			    {
                        case NOT: text = "NOT"; break;
                        case NEG: text = "NEG"; break;
                        default: text = "bad value";
    			    }
    			    fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: UNARYOP</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880000\">value: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					text
    				);
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ffff00\"];\n",
    					parent,
    					actual_node
    				);
    				break;
    			}
    			case VAR:
    			{
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: VAR</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880000\">str: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					tree->node->str
    				);
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ffff00\"];\n",
    					parent,
    					actual_node
    				);
    				break;
    			}
    			case IMPORT:
    			{
    				break;
    			}
    			case APP:
    			{
    				struct app * a = tree->node->app;
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: APP</font></td></tr>\
    					</table>>];\n",
    					actual_node
    				);
    				
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\"];\n",
    					parent,
    					actual_node
    				);
    				
    				(*id) ++;
    				show_ast_rec(fd, a->fun, actual_node, id, attr);
    				(*id) ++;
    				show_ast_rec(fd, a->arg, actual_node, id, attr);
    				break;
    			}
    			case WORD:
    			{
    				char * w = tree->node->str;
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: WORD</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#0000ff\">String: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					w
    				);
    
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#00ff00\"];\n",
    					parent,
    					actual_node
    				);
    				break;
    			}
    			case TREE:
    			{
    				struct tree * t = tree->node->tree;
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: TREE</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#0000ff\">Label: %s</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880088\">Is value: %s</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880088\">Nullary: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					t->label,
    					t->is_value ? "Yes" : "No",
    					t->nullary ? "Yes" : "No"
    				);
    
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\"];\n",
    					parent,
    					actual_node
    				);
    				
    				struct attributes * iterator_attr = t->attributes;
    				while (iterator_attr != NULL)
    				{
    					fprintf(fd, "\t\"attribute%d\" [label=<<table border=\"0\" cellspacing=\"0\">\
    						<tr><td border=\"1\"><font color=\"#008800\">%s</font></td></tr>\
    						<tr><td border=\"1\">%s</td></tr></table>>, shape=none];\n",
    						*attr,
    						iterator_attr->key->node->str,
    						iterator_attr->value->node->str
    					);
    					if (actual_attributes == *attr) {
    						fprintf(fd, "\t\"node%d\" -> \"attribute%d\" [color=\"#0088ff\"];\n",
    							actual_node,
    							*attr
    						);
    					} else {
    						fprintf(fd, "\t\"attribute%d\" -> \"attribute%d\" [color=\"#0088ff\"];\n",
    							(*attr) - 1,
    							*attr
    						);
    					}
    					fprintf(fd, "\t\"node%d\" -> \"attribute%d\" [color=\"#0088ff\", style=dotted];\n",
    						actual_node,
    						*attr
    					);
    					(*attr) ++;
    					iterator_attr = iterator_attr->next;
    				}
    				(*id) ++;
    				show_ast_rec(fd, t->child, actual_node, id, attr);
    				break;
    			}
    			case FOREST:
    			{
    				struct forest * f = tree->node->forest;
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: FOREST</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880088\">Is value: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					f->is_value ? "Yes" : "No"
    				);
    
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\"];\n",
    					parent,
    					actual_node
    				);
    
    				(*id) ++;
    				show_ast_rec(fd, f->head, actual_node, id, attr);
    				(*id) ++;
    				show_ast_rec(fd, f->tail, actual_node, id, attr);
    				break;
    			}
    			case FUN:
    			{
    				struct fun * f = tree->node->fun;
    				fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: FUN</font></td></tr>\
    					<tr><td border=\"1\"><font color=\"#880088\">id: %s</font></td></tr>\
    					</table>>];\n",
    					actual_node,
    					f->id
    				);
    				
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\"];\n",
    					parent,
    					actual_node
    				);
    				
    				(*id) ++;
    				show_ast_rec(fd, f->body, actual_node, id, attr);
    				break;
    			}
    			case MATCH:
    			{
    				break;
    			}
    			case COND:
    			{
    			    struct cond * c = tree->node->cond;
    			    
    			    fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
    					<tr><td border=\"1\"><font color=\"#880000\">Type: COND</font></td></tr>\
    					</table>>];\n",
    					actual_node
    				);
    				
    				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\"];\n",
    					parent,
    					actual_node
    				);
    				
    				(*id) ++;
    				show_ast_rec(fd, c->cond, actual_node, id, attr);
    				(*id) ++;
    				show_ast_rec(fd, c->then_br, actual_node, id, attr);
    				(*id) ++;
    				show_ast_rec(fd, c->else_br, actual_node, id, attr);
    				break;
    			}
    			case DECLREC:
    			{
    				break;
    			}
    			default:
    				printf("unknown tree type %d\n", tree->type);
    		}
    	}
    }
}


void generate_html_rec(FILE *, const struct ast *, unsigned int, bool *);
void generate_html(const struct ast * tree, const char * file_name)
{
	FILE * fd = fopen(file_name, "w");
	fprintf(fd, "<!DOCTYPE HTML>\n");
	bool prev_text = false;
	generate_html_rec(fd, tree, 0, &prev_text);
	fclose(fd);
}

void generate_html_rec(FILE * fd, const struct ast * tree, unsigned int level, bool * prev_node_is_text)
{
	if (tree != NULL)
	{
		char indent[level + 1];
		for (unsigned int i = 0; i < level; i++)
			indent[i] = '\t';
		indent[level] = '\0';
		switch (tree->type)
		{
			case INTEGER:
			{
				break;
			}
			case BINOP:
			{
				break;
			}
			case UNARYOP:
			{
				break;
			}
			case VAR:
			{
			    fprintf(stderr, "%s", tree->node->str );
				break;
			}
			case IMPORT:
			{
				break;
			}
			case APP:
			{
				break;
			}
			case WORD:
			{
				fprintf( fd, "%s", tree->node->str );
				*prev_node_is_text = true;
				break;
			}
			case TREE:
			{
				struct tree * t = tree->node->tree;
				*prev_node_is_text = false;
				if ( *prev_node_is_text )
				    fprintf( fd, "%s", indent );
				if ( t->nullary )
				{
					fprintf( fd, "%s<%s />\n", indent, t->label );
				}
				else
				{
					struct attributes * iterator_attr = t->attributes;
					fprintf( fd, "%s<%s", indent, t->label );
					while (iterator_attr != NULL)
					{
						fprintf( fd,
							" %s=\"%s\"",
							iterator_attr->key->node->str,
							iterator_attr->value->node->str
						);
						iterator_attr = iterator_attr->next;
					}
					fprintf( fd, ">\n" );
					fprintf( fd, "%s", indent );
					generate_html_rec( fd, t->child, level + 1, prev_node_is_text );
					fprintf( fd, "%s</%s>\n", indent, t->label );
				}
				break;
			}
			case FOREST:
			{
				struct forest * f = tree->node->forest;
				generate_html_rec( fd, f->head, level, prev_node_is_text );
				generate_html_rec( fd, f->tail, level, prev_node_is_text );
				break;
			}
			case FUN:
			{
				struct fun * f = tree->node->fun;
				struct env * e = initial_env;
				e = process_binding_instruction( f->id, f->body, e );
				break;
			}
			case MATCH:
			{
				break;
			}
			case COND:
			{
				break;
			}
			case DECLREC:
			{
				break;
			}
			default:
				printf("unknown tree type %d\n", tree->type);
		}
	}
}