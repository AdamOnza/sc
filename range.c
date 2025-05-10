
/* SC A Spreadsheet Calculator
 * Range Manipulations
 *
 * Robert Bond, 4/87
 *
 */

#include <stdio.h>
#include <curses.h>
#include <ctype.h>
#include "sc.h"

#ifdef BSD42
#include <strings.h>
#else
#ifndef SYSIII
#include <string.h>
#endif
#endif

char *xmalloc();

static struct range *rng_base;

add_range(name, left, right)
char *name;
struct ent *left, *right;
{
	struct range *r;
	register char *p;
	int len;

	if (find_range(name, strlen(name), (struct ent *)0, (struct ent *)0)) {
		error("Error: range name already defined");
	return;
	}

	if (strlen(name) <=2) {
		error("Invalid range name - too short");
		return;
	}

	for(p=name, len=0; *p; p++, len++)
		if (!((isalpha(*p) && (len<=2)) ||
		    ((isdigit(*p) || isalpha(*p) || (*p == '_')) && (len>2)))) {
			error("Invalid range name - illegal combination");
			return;
		}

	r = (struct range *)xmalloc((unsigned)sizeof(struct range));
	r->r_name = name;
	r->r_left = left;
	r->r_right = right;
	r->r_next = rng_base;
	r->r_prev = 0;
	if (rng_base)
		rng_base->r_prev = r;
	rng_base = r;
}

del_range(left, right)
struct ent *left, *right;
{
	register struct range *r;

	if (!(r = find_range((char *)0, 0, left, right)))
	return;

	if (r->r_next)
		r->r_next->r_prev = r->r_prev;
	if (r->r_prev)
		r->r_prev->r_next = r->r_next;
	else
		rng_base = r->r_next;
	xfree((char *)(r->r_name));
	xfree((char *)r);
}

/* Match on name or lmatch, rmatch */

struct range *
find_range(name, len, lmatch, rmatch)
char *name;
int len;
struct ent *lmatch;
struct ent *rmatch;
{
	struct range *r;
	register char *rp, *np;
	register int c;

	if (name) {
		for (r = rng_base; r; r = r->r_next) {
			for (np = name, rp = r->r_name, c = len;
			     c && *rp && (*rp == *np);
			     rp++, np++, c--) /* */;
			if (!c && !*rp)
				return(r);
		}
		 return(0);
	}

	for (r = rng_base; r; r= r->r_next) {
		if ((lmatch == r->r_left) && (rmatch == r->r_right))
			return(r);
	}
	return(0);
}

sync_ranges()
{
	register struct range *r;

	r = rng_base;
	while(r) {
		r->r_left = lookat(r->r_left->row, r->r_left->col);
		r->r_right = lookat(r->r_right->row, r->r_right->col);
		r = r->r_next;
	}
}

write_range(f)
FILE *f;
{
	register struct range *r;

	for (r = rng_base; r; r = r->r_next) {
		fprintf(f, "define \"%s\" %s%d", r->r_name, coltoa(r->r_left->col),
		r->r_left->row);
		if (r->r_left != r->r_right)
			fprintf(f, ":%s%d\n", coltoa(r->r_right->col), r->r_right->row);
		else
			fprintf(f, "\n");
	}
}

list_range(f)
FILE *f;
{
	register struct range *r;

	for (r = rng_base; r; r = r->r_next) {
		fprintf(f, "%-30s %s%d", r->r_name, coltoa(r->r_left->col),
		r->r_left->row);
		if (r->r_left != r->r_right)
			fprintf(f, ":%s%d\n", coltoa(r->r_right->col), r->r_right->row);
		else
			fprintf(f, "\n");

	}
}

char *
v_name(row, col)
int row, col;
{
	struct ent *v;
	struct range *r;
	static char buf[20];

	v = lookat(row, col);
	if (r = find_range((char *)0, 0, v, v)) {
		return(r->r_name);
	} else {
		sprintf(buf, "%s%d", coltoa(col), row);
		return buf;
	}
}