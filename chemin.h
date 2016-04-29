#ifndef CHEMIN_H
#define CHEMIN_H

enum descr {DIR, FILENAME, DECLNAME};

struct dir{
	char * str;
	enum descr descr;
	struct dir * dir;
};

struct path{
	int n;					// nombre de répertoires a remonter pour trouver le fichier (../)
	struct dir * dir;		// liste chainée représentant le répertoire, fichier, fonction
};

/*
../../../../../file/app/foo.jhtml
$.....file/app/foo.jhtml->func
$ on jette
..... devient 5 dans path->n
file/, app/ deviennent des dir avec descr a DIR
foo.jhtml devent filename
-> on jette
func devient declname
*/

#endif // CHEMIN_H