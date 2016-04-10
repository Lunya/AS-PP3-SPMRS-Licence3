#include "node.h"
#include "color_print.h"

struct tree * createNode(char * label, bool nullary, bool space, enum type tp)
{
	struct tree * newNode = malloc(sizeof(struct tree));
	newNode->label = label;
	newNode->nullary = nullary;
	newNode->space = space;
	newNode->tp = tp;
	newNode->attr = NULL;
	newNode->daughters = NULL;
	newNode->right = NULL;
	return newNode;
}

struct attributes * createAttribute(char * key, char * value)
{
	struct attributes * newAttr = malloc(sizeof(struct attributes));
	newAttr->key = key;
	newAttr->value = value;
	newAttr->next = NULL;
	return newAttr;
}

void addAttribute(struct tree * node, struct attributes * attr)
{
	if (node->attr==NULL)
	{
		node->attr = attr;
	}
	else
	{
		struct attributes * attrIterator = node->attr;
		while (attrIterator->next!=NULL)
			attrIterator = attrIterator->next;
		attrIterator->next = attr;
	}
}

void addAttributeBrother(struct attributes * attr, struct attributes * brother)
{
	if (attr->next==NULL)
	{
		attr->next = brother;
	}
	else
	{
		struct attributes * brotherIterator = attr->next;
		while (brotherIterator->next!=NULL)
			brotherIterator = brotherIterator->next;
		brotherIterator->next = brother;
	}
}

void addChild(struct tree * node, struct tree * daughter)
{
	if (node->daughters==NULL)
	{
		node->daughters = daughter;
	}
	else
	{
		struct tree * daughterIterator = node->daughters;
		while (daughterIterator->right!=NULL)
			daughterIterator = daughterIterator->right;
		daughterIterator->right = daughter;
	}
}

void addBrother(struct tree * node, struct tree * brother)
{
	if (node->right==NULL)
	{
		node->right = brother;
	}
	else
	{
		struct tree * brotherIterator = node->right;
		while (brotherIterator->right!=NULL)
			brotherIterator = brotherIterator->right;
		brotherIterator->right = brother;
	}
}

void addSpace(struct tree * node)
{
	node->space = true;
}

void printNodeRec(struct tree *, int);
void printNode(struct tree * node)
{
	printNodeRec(node, 0);
}

void printNodeRec(struct tree * node, int level)
{
	char tabs[level+1];
	tabs[level] = '\0';
	for (int i = 0; i < level; i++)
		tabs[i] = '\t';

	printfC(TEXT_RED, "%s%s", tabs, node->label);
	if (node->space)
	{
		printfC(BACKGROUND_BLUE, " ");
	}
	if (node->nullary)
	{
		printfC(TEXT_MAGENTA, "/\n");
	}
	else
	{
		if (node->attr != NULL)
		{
			printfC(TEXT_MAGENTA, "[ ");
			struct attributes * iteratorAttribute = node->attr;
			while (iteratorAttribute != NULL)
			{
				printfC(TEXT_YELLOW, "%s", iteratorAttribute->key);
				printfC(TEXT_MAGENTA, " = ");
				printfC(TEXT_GREEN, "%s ", iteratorAttribute->value);
				iteratorAttribute = iteratorAttribute->next;
			}
			printfC(TEXT_MAGENTA, "]");
		}
		printfC(TEXT_MAGENTA, "\n%s{\n", tabs);
		if (node->daughters != NULL)
		{
			struct tree * iteratorNode = node->daughters;
			while (iteratorNode!=NULL)
			{
				printNodeRec(iteratorNode, level + 1);
				iteratorNode = iteratorNode->right;
			}
		}
		printfC(TEXT_MAGENTA, "%s}\n", tabs);
	}
}

unsigned int nodeCounter;
unsigned int attributeCounter;
void printNodeGraphRec(struct tree *, FILE *, unsigned int);
void printNodeGraph(struct tree * node, char * out)
{
	nodeCounter = 1;
	attributeCounter = 1;
	FILE * fd = fopen(out, "w");
	fprintf(fd, "/*\n\
Usage : dot -Tpng %s -o graph.png\n\
*/\n\
digraph G {\n\
\tsize=\"10,10\";\n\
\tedge [arrowhead=empty];\n",
		out);
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
\t\t<tr><td port=\"e1\"> </td></tr>\n\
\t\t<tr><td port=\"e2\"> </td></tr>\n\
\t\t<tr><td port=\"e3\"> </td></tr>\n\
\t\t<tr><td port=\"e4\"> </td></tr>\n\
\t\t<tr><td port=\"e5\"> </td></tr>\n\
\t\t</table>>,];\n\
\t\tkey1:e1:e -> key2:e1:w [color=\"#ff8800\"];\n\
\t\tkey1:e2:e -> key2:e2:w [color=\"#ff0000\"];\n\
\t\tkey1:e3:e -> key2:e3:w [color=\"#ff8800\", style=dotted];\n\
\t\tkey1:e4:e -> key2:e4:w [color=\"#0088ff\"];\n\
\t\tkey1:e5:e -> key2:e5:w [color=\"#0088ff\", style=dotted];\n\
\t\t{rank = same; key1; key2}\n\
\t}\n");
	printNodeGraphRec(node, fd, nodeCounter);
	fprintf(fd, "}");
	fclose(fd);
}

void printNodeGraphRec(struct tree * node, FILE * fd, unsigned int parent)
{
	unsigned int actualId = nodeCounter;
	fprintf(fd, "\t\"node%d\" [shape=\"box\", label=\"%s\"];\n", nodeCounter, node->label);
	fprintf(fd, "\t\"node%d\" [shape=none, label=<<table border=\"0\" cellspacing=\"0\">\
<tr><td border=\"1\"><font color=\"#880000\">Type: %s</font></td></tr>\
<tr><td border=\"1\"><font color=\"#0000ff\">Label: %s</font></td></tr>\
<tr><td border=\"1\"><font color=\"#880088\">Space: %s</font></td></tr>\
<tr><td border=\"1\"><font color=\"#880088\">Nullary: %s</font></td></tr>\
</table>>];\n",
		nodeCounter,
		node->tp == TREE ? "TREE" : "WORD",
		node->label,
		node->space ? "Yes" : "No",
		node->nullary ? "Yes" : "No");

	if (node->attr != NULL)
	{
		fprintf(fd, "\t\"node%d\" -> \"attribute%d\" [color=\"#0088ff\"];\n",
			actualId, attributeCounter);
		fprintf(fd, "\t\"node%d\" -> \"attribute%d\" [color=\"#0088ff\", style=dotted];\n",
			actualId, attributeCounter);
		fprintf(fd, "\t\"attribute%d\" [label=<<table border=\"0\" cellspacing=\"0\">\
<tr><td border=\"1\"><font color=\"#008800\">%s</font></td></tr>\
<tr><td border=\"1\">%s</td></tr></table>>, shape=none];\n",
			attributeCounter, node->attr->key, node->attr->value);
		struct attributes * iteratorAttribute = node->attr->next;
		while (iteratorAttribute != NULL)
		{
			attributeCounter ++;
			fprintf(fd, "\t\"attribute%d\" -> \"attribute%d\" [color=\"#0088ff\"];\n",
				attributeCounter - 1, attributeCounter);
			fprintf(fd, "\t\"node%d\" -> \"attribute%d\" [color=\"#0088ff\", style=dotted];\n",
				actualId, attributeCounter);
			fprintf(fd, "\t\"attribute%d\" [label=<<table border=\"0\" cellspacing=\"0\">\
<tr><td border=\"1\"><font color=\"#008800\">%s</font></td></tr>\
<tr><td border=\"1\">%s</td></tr></table>>, shape=none];\n",
				attributeCounter, iteratorAttribute->key, iteratorAttribute->value);
			/*fprintf(fd, "\t\"attribute%d\" -> \"attribute%d\" [color=\"#ff0088\", label=\"%s\"];\n",
				attributeCounter, attributeCounter + 2, iteratorAttribute->value);*/
			iteratorAttribute = iteratorAttribute->next;
		}
	}
	if (node->daughters != NULL)
	{
		struct tree * iteratorNode = node->daughters;
		unsigned int precId = actualId;
		do
		{
			fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\", style=dotted];\n", actualId, ++nodeCounter);
			if (precId == actualId) // son
				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff8800\"];\n", precId, nodeCounter);
			else // brother
				fprintf(fd, "\t\"node%d\" -> \"node%d\" [color=\"#ff0000\"];\n", precId, nodeCounter);
			precId = nodeCounter;
			printNodeGraphRec(iteratorNode, fd, actualId);
			iteratorNode = iteratorNode->right;
		}
		while (iteratorNode!=NULL);
	}
}