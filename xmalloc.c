/*
 * A safer saner malloc, for careless programmers
 * (I guess I qualify! - rgb)
 */

#include <stdio.h>
#include <curses.h>

extern char *malloc();

char *
xmalloc(n)
unsigned n;
{
	register char *ptr;

	if ((ptr = malloc(n + sizeof(int))) == NULL)
		fatal("xmalloc: no memory");
	*((int *) ptr) = 12345; /* magic number */
	return(ptr + sizeof(int));
}

xfree(p)
char *p;
{
	if (p == NULL)
		fatal("xfree: NULL");
	p -= sizeof(int);
	if (*((int *) p) != 12345)
		fatal("xfree: storage not malloc'ed");
	free(p);
}

fatal(str)
char *str;
{
	deraw();
	fprintf(stderr,"%s\n", str);
	exit(1);
}