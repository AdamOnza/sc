/* VC A Table Calculator
 * Common definitions
 *
 * original by James Gosling, September 1982
 * modified by Mark Weiser and Bruce Israel,
 * University of Maryland
 *
 */

#define MAXROWS 200
#define MAXCOLS 40
#define error move(1,0), clrtoeol(), printw

typedef struct range_s {
	struct ent *left, *right;
} RANGE_S;

/*
 * If you want to save room, make row and col below into unsigned
 * chars and make sure MAXROWS and MAXCOLS above are both less
 * than 256. (128 if your compiler doesn't support unsigned char).
 */

struct ent {
	double v;
	char *label;
	struct enode *expr;
	short flags;
	short row, col;
	struct ent *next;
};

struct range {
	struct ent *r_left, *r_right;
	char *r_name;
	struct range *r_next, *r_prev;
};

struct enode {
	int op;
	union {
		double k;
		struct ent *v;
		struct {
			struct enode *left, *right;
		} o;
	} e;
};

/* op values */
#define O_VAR 'v'
#define O_CONST 'k'
#define O_REDUCE(c) (c+0200)

#define ACOS 0
#define ASIN 1
#define ATAN 2
#define CEIL 3
#define COS 4
#define EXP 5
#define FABS 6
#define FLOOR 7
#define HYPOT 8
#define LOG 9
#define LOG10 10
#define POW 11
#define SIN 12
#define SQRT 13
#define TAN 14
#define DTR 15
#define RTD 16
#define MIN 17
#define MAX 18
#define RND 19

/* flag values */
#define is_valid 0001
#define is_changed 0002
#define is_lchanged 0004
#define is_leftflush 0010
#define is_deleted 0020

#define ctl(c) ('c'&037)

extern struct ent *tbl[MAXROWS][MAXCOLS];

extern int strow, stcol;
extern int currow, curcol;
extern int savedrow, savedcol;
extern int FullUpdate;
extern int maxrow, maxcol;
extern int fwidth[MAXCOLS];
extern int precision[MAXCOLS];
extern char col_hidden[MAXCOLS];
extern char row_hidden[MAXROWS];
extern char line[1000];
extern int linelim;
extern int changed;
extern struct ent *to_fix;
extern struct enode *new();
extern struct enode *new_const();
extern struct enode *new_var();
extern struct ent *lookat();
extern struct enode *copye();
extern char *coltoa();
extern FILE *openout();
extern struct range *find_range();
extern char *v_name();
extern int modflg;
extern int Crypt;

#if BSD42 || SYSIII
#define cbreak crmode
#define nocbreak nocrmode
#endif
