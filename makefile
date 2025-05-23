
# Specify the name of the program.
# All documentation and installation keys on this value.
#
name=sc
NAME=SC

# This is where the install step puts it.
EXDIR=/a/rgb/bin

# This is where the man page goes.
MANDIR=/usr/man/man1

# All of the source files
SRC=sc.h sc.c lex.c gram.y interp.c cmds.c crypt.c xmalloc.c range.c eres.sed\
sres.sed makefile cvt.sed

# The documents in the Archive
DOCS=README $(name).man sc.doc

# Set SIMPLE for lex.c if you don't want arrow keys or lex.c blows up
#SIMPLE=-DSIMPLE

# Set QUICK if you want to enter numbers without "=" first
#QUICK=-DQUICK

# Use this for system V.2
#CFLAGS= -O -DSYSV2
#LDFLAGS=
#LIB=-lm -lcurses

# Use this for system V.3
#CFLAGS= -O -DSYSV3
#LDFLAGS=
#LIB=-lm -lcurses

# Use this for BSD 4.2
#CFLAGS= -O -DBSD42
#LDFLAGS=
#LIB=-lm -lcurses -ltermcap

# Use this for BSD 4.3
CFLAGS= -O -DBSD43
LDFLAGS=
LIB=-lm -lcurses -ltermcap

# Use this for system III (XENIX)
#CFLAGS= -O -DSYSIII
#LDFLAGS= -i
#LIB=-lm -lcurses -ltermcap

# Use this for VENIX
#CFLAGS= -DVENIX -DBSD42 -DV7
#LDFLAGS= -z -i
#LIB=-lm -lcurses -ltermcap

# The objects
OBJS=sc.o lex.o gram.o interp.o cmds.o crypt.o xmalloc.o range.o

$(name): $(OBJS)
cc ${CFLAGS} ${LDFLAGS} ${OBJS} ${LIB} -o $(name)

diff_to_sc: diff_to_sc.c
cc ${CFLAGS} -o dtv diff_to_sc.c

pvc: pvc.c
cc ${CFLAGS} -o pvc pvc.c
cp pvc $(EXDIR)/pvc

lex.o: sc.h y.tab.h gram.o
cc ${CFLAGS} ${SIMPLE} -c lex.c

sc.o: sc.h sc.c
cc ${CFLAGS} ${QUICK} -c sc.c

interp.o: interp.c sc.h

gram.o: sc.h y.tab.h

cmds.o: cmds.c sc.h

crypt.o: crypt.c sc.h

range.o: range.c sc.h

y.tab.h: gram.y

gram.o: sc.h y.tab.h gram.c
cc ${CFLAGS} -c gram.c
sed<gram.y >experres.h -f eres.sed;sed < gram.y > statres.h -f sres.sed

gram.c: gram.y
yacc -d gram.y; mv y.tab.c gram.c

clean:
rm -f *.o *res.h y.tab.h $(name) debug core gram.c

shar: ${SRC} ${DOCS}
shar -c -m 55000 -f shar ${DOCS} ${SRC}

lint: sc.h sc.c lex.c gram.c interp.c cmds.c crypt.c
lint ${CFLAGS} ${SIMPLE} ${QUICK} sc.c lex.c gram.c interp.c cmds.c crypt.c range.c -lcurses -lm

print: sc.h gram.y sc.c lex.c interp.c cmds.c crypt.c
prc sc.h gram.y sc.c lex.c interp.c cmds.c crypt.c | lpr

$(name).1: sc.doc
sed -e s/pname/$(name)/g -e s/PNAME/$(NAME)/g sc.doc > $(name).1

$(name).man: $(name).1
-mv $(name).man $(name).mold
nroff -man $(name).1 > $(name).man

install: $(EXDIR)/$(name)

inst-man: $(MANDIR)/$(name).1

$(EXDIR)/$(name): $(name)
-mv $(EXDIR)/$(name) $(EXDIR)/$(name).old
strip $(name)
cp $(name) $(EXDIR)

$(MANDIR)/$(name).1: $(name).1
cp $(name).1 $(MANDIR)