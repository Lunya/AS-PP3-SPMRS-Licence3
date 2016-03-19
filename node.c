#include "node.h"

struct tree * createNode(char * label)
{
	struct tree * newNode = malloc(sizeof(struct tree));
	newNode->label = label;
	return newNode;
}

struct attributes * createAttribute(char * key, char * value)
{
	struct attributes * newAttr = malloc(sizeof(struct attributes));
	newAttr->key = key;
	newAttr->value = value;
	return newAttr;
}

void addAttribute(struct tree * node, struct attribute * attr)
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
		daughterIterator->right = attr;
	}
}

void printNode(struct tree * node)
{
	printf("%s",node->label);
	if (node->space)
	{
		printf(" ");
	}
	if (node->nullary)
	{
		printf("/");
	}
	else
	{
		if (node->attr != NULL)
		{
			printf("[");
			struct attributes iteratorAttribute = node->attr;
			while (iteratorAttribute != NULL)
			{
				printf("%s=%s ", iteratorAttribute->key, iteratorAttribute->value);
				iteratorAttribute = iteratorAttribute->next;
			}
			printf("]");
		}
		if (node->daughters != NULL)
		{
			printf("{\n");
			struct tree iteratorNode = node->daughters;
			while (iteratorNode!=NULL)
			{
				printNode(iteratorNode);
				iteratorNode = iteratorNode->right;
			}
			printf("}\n");
		}
	}
}

