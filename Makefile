all: lex.yy.c resume.tab.c
	gcc lex.yy.c resume.tab.c -o res2html

clean:
	rm lex.yy.c resume.tab.c resume.tab.h resume.output

lex.yy.c: resume.l
	flex resume.l

resume.tab.c: resume.y
	bison -W -v -d resume.y

