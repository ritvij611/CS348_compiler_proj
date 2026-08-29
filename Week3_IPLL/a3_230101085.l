%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int line = 1;   // to track line numbers

FILE *token_fp;
FILE *st_fp;

#define MAX_SYMBOLS 1000

char *symtab[MAX_SYMBOLS];
int symcount = 0;

int exists(const char *s) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i], s) == 0) {
            return 1;
        }
    }
    return 0;
}

char *dup_identifier(const char *src) {
    size_t len = strlen(src) + 1;
    char *copy = (char *)malloc(len);
    if (!copy) {
        fprintf(stderr, "Out of memory while storing identifier\n");
        exit(EXIT_FAILURE);
    }
    memcpy(copy, src, len);
    return copy;
}
%}

/* ---------- DEFINITIONS ---------- */
DIGIT            [0-9]
LETTER           [a-zA-Z_]
ID               {LETTER}({LETTER}|{DIGIT})*
NONZERO_DIGIT    [1-9]
DIGIT_SEQ        {DIGIT}+
INTEGER_CONST    (0|{NONZERO_DIGIT}{DIGIT}*)
FRACTIONAL_CONST (({DIGIT_SEQ})?\.{DIGIT_SEQ})|({DIGIT_SEQ}\.)
CCHAR            ([^\'\n]|\\[\'"?\\abfnrtv])
SCHAR            ([^\"\n]|\\[\'"?\\abfnrtv])

%x COMMENT

%%

"break"      { fprintf(token_fp, "Line %d: <KEYWORD, break>\n", line); }
"default"    { fprintf(token_fp, "Line %d: <KEYWORD, default>\n", line); }
"return"     { fprintf(token_fp, "Line %d: <KEYWORD, return>\n", line); }
"void"       { fprintf(token_fp, "Line %d: <KEYWORD, void>\n", line); }
"case"       { fprintf(token_fp, "Line %d: <KEYWORD, case>\n", line); }
"float"      { fprintf(token_fp, "Line %d: <KEYWORD, float>\n", line); }
"short"      { fprintf(token_fp, "Line %d: <KEYWORD, short>\n", line); }
"double"     { fprintf(token_fp, "Line %d: <KEYWORD, double>\n", line); }
"char"       { fprintf(token_fp, "Line %d: <KEYWORD, char>\n", line); }
"for"        { fprintf(token_fp, "Line %d: <KEYWORD, for>\n", line); }
"signed"     { fprintf(token_fp, "Line %d: <KEYWORD, signed>\n", line); }
"while"      { fprintf(token_fp, "Line %d: <KEYWORD, while>\n", line); }
"else"       { fprintf(token_fp, "Line %d: <KEYWORD, else>\n", line); }
"unsigned"   { fprintf(token_fp, "Line %d: <KEYWORD, unsigned>\n", line); }
"long"       { fprintf(token_fp, "Line %d: <KEYWORD, long>\n", line); }
"_Bool"       { fprintf(token_fp, "Line %d: <KEYWORD, _Bool>\n", line); }
"continue"   { fprintf(token_fp, "Line %d: <KEYWORD, continue>\n", line); }
"if"         { fprintf(token_fp, "Line %d: <KEYWORD, if>\n", line); }
"static"     { fprintf(token_fp, "Line %d: <KEYWORD, static>\n", line); }
"do"         { fprintf(token_fp, "Line %d: <KEYWORD, do>\n", line); }
"int"        { fprintf(token_fp, "Line %d: <KEYWORD, int>\n", line); }


\"([^\\\"\n]|\\.)*\n {
    fprintf(token_fp, "Line %d: <ERROR, unterminated string>\n", line);
    line++;
}

[0-9]+{LETTER}+ {
    fprintf(token_fp, "Line %d: <ERROR, invalid identifier %s>\n", line, yytext);
}

"@"{ID} {
    fprintf(token_fp, "Line %d: <ERROR, invalid identifier %s>\n", line, yytext);
}


{ID} {
    fprintf(token_fp, "Line %d: <IDENTIFIER, %s>\n", line, yytext);
    if (!exists(yytext)) {
            if (symcount < MAX_SYMBOLS) {
                symtab[symcount++] = dup_identifier(yytext);
                fprintf(st_fp, "%s\n", yytext);
            } else {
                fprintf(stderr, "Symbol table capacity reached\n");
            }
    }
}

0{DIGIT}+ {
    fprintf(token_fp, "Line %d: <ERROR, invalid integer literal %s>\n", line, yytext);
}


''                                { fprintf(token_fp, "Line %d: <ERROR, empty character constant>\n", line); }
\'({CCHAR})({CCHAR})+\'           { fprintf(token_fp, "Line %d: <ERROR, multi-character constant %s>\n", line, yytext); }
\'({CCHAR})\'                     { fprintf(token_fp, "Line %d: <CHAR_CONST, %s>\n", line, yytext); }
{INTEGER_CONST}                    { fprintf(token_fp, "Line %d: <INTEGER_CONST, %s>\n", line, yytext); }
\"({SCHAR})*\"                    { fprintf(token_fp, "Line %d: <STRING_LITERAL, %s>\n", line, yytext); }


"/*"                              { BEGIN(COMMENT); }
<COMMENT>"*/"                     { BEGIN(INITIAL); }
<COMMENT>\n                       { line++; }
<COMMENT>.                         { /* ignore comment text */ }
<COMMENT><<EOF>>                   { fprintf(token_fp, "Line %d: <ERROR, unterminated comment>\n", line); BEGIN(INITIAL); }
"//".*                             { /* ignore single-line comment */ }


"..."                               { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"->"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"++"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"--"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"<<="                               { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
">>="                               { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"<="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
">="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"=="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"!="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"&&"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"||"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"*="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"/="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"%="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"+="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"-="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"&="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"^="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"|="                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"<<"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
">>"                                { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"["                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"]"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"("                                 { fprintf(token_fp, "Line %d: <LPAREN>\n", line); }
")"                                 { fprintf(token_fp, "Line %d: <RPAREN>\n", line); }
"{"                                 { fprintf(token_fp, "Line %d: <LBRACE>\n", line); }
"}"                                 { fprintf(token_fp, "Line %d: <RBRACE>\n", line); }
"."                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"&"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"*"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"+"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"-"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"~"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"!"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"/"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"%"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"<"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
">"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"^"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"|"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"?"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
":"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
";"                                 { fprintf(token_fp, "Line %d: <SEMICOLON>\n", line); }
","                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"#"                                 { fprintf(token_fp, "Line %d: <PUNCTUATOR, %s>\n", line, yytext); }
"="                                 { fprintf(token_fp, "Line %d: <ASSIGN>\n", line); }


[ \t\r]+                           { /* ignore */ }

\n                                  { line++; }

.                                   { fprintf(token_fp, "Line %d: <ERROR, %s>\n", line, yytext); }

%%

int yywrap()
{
    return 1;
}

int main()
{
    token_fp = fopen("a3_230101085_token.txt", "w");
    st_fp = fopen("a3_230101085_st.txt", "w");

    if(token_fp == NULL || st_fp == NULL)
    {
        fprintf(stderr, "Error opening output files\n");
        return 1;
    }

    yylex();

    fclose(token_fp);
    fclose(st_fp);
    return 0;
}
