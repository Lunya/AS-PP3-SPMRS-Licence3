#include "node.h"

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

void printNode(struct tree * node)
{
	/*
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
	*/
}

