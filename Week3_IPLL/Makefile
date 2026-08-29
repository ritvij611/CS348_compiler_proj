# Makefile for nanoC lexer

LEX = flex
CC = gcc
CFLAGS = -lfl

TARGET = lexer

all: $(TARGET)

$(TARGET): lex.yy.c
	$(CC) lex.yy.c -o $(TARGET) $(CFLAGS)

lex.yy.c: a3_230101085.l
	$(LEX) a3_230101085.l

run: $(TARGET)
	./$(TARGET) < a3_230101085_test.nc

clean:
	rm -f lex.yy.c $(TARGET) a3_230101085_token.txt a3_230101085_st.txt