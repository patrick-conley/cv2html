all: cv2html

cv2html: lex.yy.c cv2html.tab.c
	gcc $^ -o $@

clean:
	rm lex.yy.c cv2html.tab.c cv2html.tab.h cv2html.output

lex.yy.c: cv2html.l
	flex $^

cv2html.tab.c: cv2html.y
	bison -W -v -d $^

