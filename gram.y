/* SC A Spreadsheet Calculator
 * Command and expression parser
 *
 * original by James Gosling, September 1982
 * modified by Mark Weiser and Bruce Israel,
 * University of Maryland
 *
 * more mods Robert Bond 12/86
 *
 */

%{
#include <curses.h>
#include "sc.h"
%}

%union {
	int ival;
	double fval;
	struct ent *ent;
	struct enode *enode;
	char *sval;
	RANGE_S rval;
}

%type <ent> var
%type <fval> num
%type <rval> range
%type <enode> e term
%token <sval> STRING
%token <ival> NUMBER
%token <fval> FNUMBER
%token <rval> RANGE
%token <sval> WORD
%token <ival> COL
%token S_FORMAT
%token S_LABEL
%token S_LEFTSTRING
%token S_RIGHTSTRING
%token S_GET
%token S_PUT
%token S_MERGE
%token S_LET
%token S_WRITE
%token S_TBL
%token S_COPY
%token S_SHOW
%token S_ERASE
%token S_FILL
%token S_GOTO
%token S_DEFINE
%token S_UNDEFINE

%token K_FIXED
%token K_SUM
%token K_PROD
%token K_AVG
%token K_STDDEV
%token K_ACOS
%token K_ASIN
%token K_ATAN
%token K_CEIL
%token K_COS
%token K_EXP
%token K_FABS
%token K_FLOOR
%token K_HYPOT
%token K_LN
%token K_LOG
%token K_PI
%token K_POW
%token K_SIN
%token K_SQRT
%token K_TAN
%token K_DTR
%token K_RTD
%token K_MAX
%token K_MIN
%token K_RND

%left '?' ':'
%left '|'
%left '&'
%nonassoc '<' '=' '>'
%left '+' '-'
%left '*' '/'
%left '^'

%%
command: S_LET var '=' e { let ($2, $4); }
	| S_LABEL var '=' STRING
		{ label ($2, $4, 0); }
	| S_LEFTSTRING var '=' STRING
		{ label ($2, $4, -1); }
	| S_RIGHTSTRING var '=' STRING
		{ label ($2, $4, 1); }
	| S_FORMAT COL ':' COL NUMBER NUMBER
		{ int i;
		for(i = $2; i<=$4; i++)
			fwidth[i] = $5, precision[i] = $6;
		FullUpdate++;
		modflg++;}
	| S_FORMAT COL NUMBER NUMBER
		{ fwidth[$2] = $3;
		FullUpdate++;
		modflg++;
		precision[$2] = $4; }
	| S_GET STRING { readfile ($2,1); }
	| S_MERGE STRING { readfile ($2,0); }
	| S_PUT STRING { (void) writefile ($2); }
	| S_WRITE STRING { printfile ($2); }
	| S_TBL STRING { tblprintfile ($2); }
	| S_SHOW COL ':' COL { showcol( $2, $4); }
	| S_SHOW NUMBER ':' NUMBER { showrow( $2, $4); }
	| S_COPY var range { copy($2, $3.left, $3.right); }
	| S_ERASE range { eraser($2.left, $2.right); }
	| S_FILL range num num { fill($2.left, $2.right, $3, $4); }
	| S_GOTO var {moveto($2); }
	| S_DEFINE STRING range { add_range($2, $3.left, $3.right); }
	| S_DEFINE STRING var { add_range($2, $3, $3); }
	| S_UNDEFINE range { del_range($2.left, $2.right); }
	| /* nothing */
	| error;

term: var { $$ = new_var('v', $1); }
	| K_FIXED term { $$ = new ('f', (struct enode *)0, $2); }
	| '@' K_SUM '(' range ')'
		{ $$ = new (O_REDUCE('+'),
		(struct enode *)$4.left,
		(struct enode *)$4.right); }
	| '@' K_PROD '(' range ')'
		{ $$ = new (O_REDUCE('*'),
		(struct enode *)$4.left,
		(struct enode *)$4.right); }
	| '@' K_AVG '(' range ')'
		{ $$ = new (O_REDUCE('a'),
		(struct enode *)$4.left,
		(struct enode *)$4.right); }
	| '@' K_STDDEV '(' range ')'
		{ $$ = new (O_REDUCE('s'),
		(struct enode *)$4.left,
		(struct enode *)$4.right); }
	| '@' K_MAX '(' range ')'
		{ $$ = new (O_REDUCE(MAX),
		(struct enode *)$4.left,
		(struct enode *)$4.right); }
	| '@' K_MIN '(' range ')'
		{ $$ = new (O_REDUCE(MIN),
		(struct enode *)$4.left,
		(struct enode *)$4.right); }
	| '@' K_ACOS '(' e ')' { $$ = new(ACOS, (struct enode *)0, $4); }
	| '@' K_ASIN '(' e ')' { $$ = new(ASIN, (struct enode *)0, $4); }
	| '@' K_ATAN '(' e ')' { $$ = new(ATAN, (struct enode *)0, $4); }
	| '@' K_CEIL '(' e ')' { $$ = new(CEIL, (struct enode *)0, $4); }
	| '@' K_COS '(' e ')' { $$ = new(COS, (struct enode *)0, $4); }
	| '@' K_EXP '(' e ')' { $$ = new(EXP, (struct enode *)0, $4); }
	| '@' K_FABS '(' e ')' { $$ = new(FABS, (struct enode *)0, $4); }
	| '@' K_FLOOR '(' e ')' { $$ = new(FLOOR, (struct enode *)0, $4); }
	| '@' K_HYPOT '(' e ',' e ')' { $$ = new(HYPOT, $4, $6); }
	| '@' K_LN '(' e ')' { $$ = new(LOG, (struct enode *)0, $4); }
	| '@' K_LOG '(' e ')' { $$ = new(LOG10, (struct enode *)0, $4); }
	| '@' K_POW '(' e ',' e ')' { $$ = new(POW, $4, $6); }
	| '@' K_SIN '(' e ')' { $$ = new(SIN, (struct enode *)0, $4); }
	| '@' K_SQRT '(' e ')' { $$ = new(SQRT, (struct enode *)0, $4); }
	| '@' K_TAN '(' e ')' { $$ = new(TAN, (struct enode *)0, $4); }
	| '@' K_DTR '(' e ')' { $$ = new(DTR, (struct enode *)0, $4); }
	| '@' K_RTD '(' e ')' { $$ = new(RTD, (struct enode *)0, $4); }
	| '@' K_RND '(' e ')' { $$ = new(RND, (struct enode *)0, $4); }
	| '(' e ')' { $$ = $2; }
	| '+' term { $$ = $2; }
	| '-' term { $$ = new ('m', (struct enode *)0, $2); }
	| NUMBER { $$ = new_const('k', (double) $1); }
	| FNUMBER { $$ = new_const('k', $1); }
	| K_PI { $$ = new_const('k', (double)3.14159265358979323846); }
	| '~' term { $$ = new ('~', (struct enode *)0, $2); }
	| '!' term { $$ = new ('~', (struct enode *)0, $2); }
	;

e: e '+' e { $$ = new ('+', $1, $3); }
	| e '-' e { $$ = new ('-', $1, $3); }
	| e '*' e { $$ = new ('*', $1, $3); }
	| e '/' e { $$ = new ('/', $1, $3); }
	| e '^' e { $$ = new ('^', $1, $3); }
	| term
	| e '?' e ':' e { $$ = new ('?', $1, new(':', $3, $5)); }
	| e '<' e { $$ = new ('<', $1, $3); }
	| e '=' e { $$ = new ('=', $1, $3); }
	| e '>' e { $$ = new ('>', $1, $3); }
	| e '&' e { $$ = new ('&', $1, $3); }
	| e '|' e { $$ = new ('|', $1, $3); }
	| e '<' '=' e { $$ = new ('~', (struct enode *)0,
		new ('>', $1, $4)); }
	| e '!' '=' e { $$ = new ('~', (struct enode *)0,
		new ('=', $1, $4)); }
	| e '>' '=' e { $$ = new ('~', (struct enode *)0,
		new ('<', $1, $4)); }
	;

range: var ':' var { $$.left = $1;
		$$.right = $3; }
	| RANGE { $$ = $1; }
	;

var: COL NUMBER { $$ = lookat($2 , $1); }
	| RANGE { $$ = $1.left; }
	;

num: NUMBER { $$ = (double) $1; }
	| FNUMBER { $$ = $1; }
	| '-' num { $$ = -$2; }
	| '+' num { $$ = $2; }
	;