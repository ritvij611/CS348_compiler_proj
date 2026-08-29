.PHONY: all run run-lexer-error run-parser-error show-token show-st clean

all: parser

parser: y.tab.c lex.yy.c
	gcc -o parser y.tab.c lex.yy.c

y.tab.c y.tab.h: a4_230101085.y
	yacc -d -o y.tab.c a4_230101085.y

lex.yy.c: a4_230101085.l y.tab.h
	flex -o lex.yy.c a4_230101085.l

run: parser
	./parser < a4_230101085_test.nc

run-lexer-error: parser
	./parser < a4_230101085_lexer_error_test.nc

run-parser-error: parser
	./parser < a4_230101085_parser_error_test.nc

show-token:
	cat a4_230101085_token.txt

show-st:
	cat a4_230101085_st.txt

clean:
	rm -f parser lex.yy.c y.tab.c y.tab.h a4_230101085_token.txt a4_230101085_st.txt
