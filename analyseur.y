%{
/*
 * Projet d'ASPP3 de troisième année de licence informatique
 * Contributeurs :
 *     - Moreau Corentin
 *     - Prestat Dimitri
 *     - Rivalier Antoine
 *     - San Nicolas Ludovic
 *     - Sarain Shervin
 * Copyright (c) 2015-2016
*/
#include <stdio.h>

int yylex(void);
void yyerror(char*);
%}

%union {
	int number;
	char* text;
}

%token SPACE LABEL LEFT_BRACKET RIGHT_BRACKET LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS EQUAL END_OF_FILE DOUBLE_QUOTE SLASH
%token <number> NUMBER
%token <text> TEXT WORD

%start TAG
%%

TAG:
			LABEL ATTRIBUTES CONTENTS {printf("TAG\n");}
			| LABEL SPACE ATTRIBUTES CONTENTS {printf("TAG\n");}
			| LABEL ATTRIBUTES SPACE CONTENTS {printf("TAG\n");}
			| LABEL SPACE ATTRIBUTES SPACE CONTENTS {printf("TAG\n");}
			| LABEL CONTENTS {printf("TAG\n");}
			| LABEL SPACE CONTENTS {printf("TAG\n");}
;

ATTRIBUTES:
			LEFT_SQUARE_BRACKET ATTRIBUTE RIGHT_SQUARE_BRACKET {printf("ATTRIBUTES\n");}
			| LEFT_SQUARE_BRACKET SPACE ATTRIBUTE RIGHT_SQUARE_BRACKET {printf("ATTRIBUTES\n");}
			| LEFT_SQUARE_BRACKET ATTRIBUTE SPACE RIGHT_SQUARE_BRACKET {printf("ATTRIBUTES\n");}
			| LEFT_SQUARE_BRACKET SPACE ATTRIBUTE SPACE RIGHT_SQUARE_BRACKET {printf("ATTRIBUTES\n");}
;

ATTRIBUTE:
			LABEL EQUAL TEXTCONTENT {printf("ATTRIBUTE\n");}
			| LABEL SPACE EQUAL TEXTCONTENT {printf("ATTRIBUTE\n");}
			| LABEL EQUAL SPACE TEXTCONTENT {printf("ATTRIBUTE\n");}
			| LABEL SPACE EQUAL SPACE TEXTCONTENT {printf("ATTRIBUTE\n");}
			| ATTRIBUTE ATTRIBUTE {printf("ATTRIBUTE\n");}
			| ATTRIBUTE SPACE ATTRIBUTE {printf("ATTRIBUTE\n");}
;

CONTENTS:
			LEFT_BRACKET CONTENT RIGHT_BRACKET {printf("CONTENTS\n");}
			| LEFT_BRACKET SPACE CONTENT RIGHT_BRACKET {printf("CONTENTS\n");}
			| LEFT_BRACKET CONTENT SPACE RIGHT_BRACKET {printf("CONTENTS\n");}
			| LEFT_BRACKET SPACE CONTENT SPACE RIGHT_BRACKET {printf("CONTENTS\n");}
;

CONTENT:
			TEXTCONTENT CONTENT {printf("CONTENT\n");}
			| TEXTCONTENT SPACE CONTENT {printf("CONTENT\n");}
			| TAG CONTENT {printf("CONTENT\n");}
			| TAG SPACE CONTENT {printf("CONTENT\n");}
			| ATAG CONTENT {printf("CONTENT\n");}
			| ATAG SPACE CONTENT {printf("CONTENT\n");}
			| TEXTCONTENT {printf("CONTENT\n");}
			| TAG {printf("CONTENT\n");}
			| ATAG {printf("CONTENT\n");}
;

TEXTCONTENT:
			DOUBLE_QUOTE TEXTGROUP DOUBLE_QUOTE {printf("TEXTCONTENT\n");}
			| DOUBLE_QUOTE SPACE TEXTGROUP DOUBLE_QUOTE {printf("TEXTCONTENT\n");}
			| DOUBLE_QUOTE TEXTGROUP SPACE DOUBLE_QUOTE {printf("TEXTCONTENT\n");}
			| DOUBLE_QUOTE SPACE TEXTGROUP SPACE DOUBLE_QUOTE {printf("TEXTCONTENT\n");}
;

TEXTGROUP:
			WORD TEXTGROUP {printf("TEXTGROUP\n");}
			| WORD SPACE TEXTGROUP {printf("TEXTGROUP\n");}
			| LABEL SPACE TEXTGROUP {printf("TEXTGROUPWS\n");}
			| WORD SPACE TEXTGROUP SPACE {printf("TEXTGROUP\n");}
			| LABEL SPACE TEXTGROUP SPACE {printf("TEXTGROUPS\n");}
			| WORD {printf("TEXTGROUP\n");}
			| LABEL {printf("TEXTGROUP\n");}
			| WORD SPACE {printf("TEXTGROUP\n");}
			| LABEL SPACE {printf("TEXTGROUP\n");}
;

ATAG:
	LABEL SLASH {printf("ATAB\n");}
;
%%
