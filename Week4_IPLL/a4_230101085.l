%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int line = 1;
FILE *token_fp = NULL;
FILE *st_fp = NULL;

#define MAX_SYMBOLS 1000

static char *symtab[MAX_SYMBOLS];
static int symcount = 0;

static void ensure_outputs(void)
{
    if (token_fp == NULL) {
        token_fp = fopen("a4_230101085_token.txt", "w");
        if (token_fp == NULL) {
            fprintf(stderr, "Error opening token output file\n");
            exit(EXIT_FAILURE);
        }
    }

    if (st_fp == NULL) {
        st_fp = fopen("a4_230101085_st.txt", "w");
        if (st_fp == NULL) {
            fprintf(stderr, "Error opening symbol table output file\n");
            exit(EXIT_FAILURE);
        }
    }
}

static char *dup_identifier(const char *src)
{
    size_t len = strlen(src) + 1;
    char *copy = (char *)malloc(len);
    if (copy == NULL) {
        fprintf(stderr, "Out of memory while storing identifier\n");
        exit(EXIT_FAILURE);
    }
    memcpy(copy, src, len);
    return copy;
}

static int exists(const char *s)
{
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i], s) == 0) {
            return 1;
        }
    }
    return 0;
}

static void add_symbol(const char *s)
{
    if (exists(s)) {
        return;
    }

    if (symcount >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table capacity reached\n");
        return;
    }

    ensure_outputs();
    symtab[symcount++] = dup_identifier(s);
    fprintf(st_fp, "%s\n", s);
}

static void log_simple(const char *kind)
{
    ensure_outputs();
    fprintf(token_fp, "Line %d: <%s>\n", line, kind);
}

static void log_lexeme(const char *kind, const char *lexeme)
{
    ensure_outputs();
    fprintf(token_fp, "Line %d: <%s, %s>\n", line, kind, lexeme);
}
%}

%option noyywrap nodefault

%x COMMENT

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTCONST    {DIGIT}+
EXP         ([eE][+-]?{DIGIT}+)
FLOATCONST  (({DIGIT}+\.{DIGIT}*|\.{DIGIT}+)({EXP})?|{DIGIT}+{EXP})

%%

"/*"                              { ensure_outputs(); BEGIN(COMMENT); }
<COMMENT>"*/"                     { BEGIN(INITIAL); }
<COMMENT>\n                       { line++; }
<COMMENT>.                         { /* ignore comment text */ }
<COMMENT><<EOF>>                   { log_simple("ERROR, unterminated comment"); BEGIN(INITIAL); return 0; }
"//".*                             { /* ignore single-line comment */ }

[ \t\r]+                           { /* ignore whitespace */ }
\n                                  { line++; }

"break"                            { log_lexeme("KEYWORD", yytext); return BREAK; }
"default"                          { log_lexeme("KEYWORD", yytext); return DEFAULT; }
"return"                           { log_lexeme("KEYWORD", yytext); return RETURN; }
"void"                             { log_lexeme("KEYWORD", yytext); return VOID; }
"case"                             { log_lexeme("KEYWORD", yytext); return CASE; }
"float"                            { log_lexeme("KEYWORD", yytext); return FLOAT; }
"short"                            { log_lexeme("KEYWORD", yytext); return SHORT; }
"double"                           { log_lexeme("KEYWORD", yytext); return DOUBLE; }
"char"                             { log_lexeme("KEYWORD", yytext); return CHAR; }
"for"                              { log_lexeme("KEYWORD", yytext); return FOR; }
"signed"                           { log_lexeme("KEYWORD", yytext); return SIGNED; }
"while"                            { log_lexeme("KEYWORD", yytext); return WHILE; }
"else"                             { log_lexeme("KEYWORD", yytext); return ELSE; }
"unsigned"                         { log_lexeme("KEYWORD", yytext); return UNSIGNED; }
"long"                             { log_lexeme("KEYWORD", yytext); return LONG; }
"_Bool"                            { log_lexeme("KEYWORD", yytext); return BOOL; }
"Bool"                             { log_lexeme("KEYWORD", yytext); return BOOL; }
"continue"                         { log_lexeme("KEYWORD", yytext); return CONTINUE; }
"if"                               { log_lexeme("KEYWORD", yytext); return IF; }
"static"                           { log_lexeme("KEYWORD", yytext); return STATIC; }
"do"                               { log_lexeme("KEYWORD", yytext); return DO; }
"int"                              { log_lexeme("KEYWORD", yytext); return INT; }

"..."                              { log_lexeme("PUNCTUATOR", yytext); return ELLIPSIS; }
"<<="                              { log_lexeme("PUNCTUATOR", yytext); return SHL_ASSIGN; }
">>="                              { log_lexeme("PUNCTUATOR", yytext); return SHR_ASSIGN; }
"++"                               { log_lexeme("PUNCTUATOR", yytext); return INC; }
"--"                               { log_lexeme("PUNCTUATOR", yytext); return DEC; }
"<="                               { log_lexeme("PUNCTUATOR", yytext); return LE; }
">="                               { log_lexeme("PUNCTUATOR", yytext); return GE; }
"=="                               { log_lexeme("PUNCTUATOR", yytext); return EQ; }
"!="                               { log_lexeme("PUNCTUATOR", yytext); return NE; }
"&&"                               { log_lexeme("PUNCTUATOR", yytext); return LAND; }
"||"                               { log_lexeme("PUNCTUATOR", yytext); return LOR; }
"*="                               { log_lexeme("PUNCTUATOR", yytext); return MUL_ASSIGN; }
"/="                               { log_lexeme("PUNCTUATOR", yytext); return DIV_ASSIGN; }
"%="                               { log_lexeme("PUNCTUATOR", yytext); return MOD_ASSIGN; }
"+="                               { log_lexeme("PUNCTUATOR", yytext); return ADD_ASSIGN; }
"-="                               { log_lexeme("PUNCTUATOR", yytext); return SUB_ASSIGN; }
"&="                               { log_lexeme("PUNCTUATOR", yytext); return AND_ASSIGN; }
"^="                               { log_lexeme("PUNCTUATOR", yytext); return XOR_ASSIGN; }
"|="                               { log_lexeme("PUNCTUATOR", yytext); return OR_ASSIGN; }
"<<"                               { log_lexeme("PUNCTUATOR", yytext); return SHL; }
">>"                               { log_lexeme("PUNCTUATOR", yytext); return SHR; }

\"([^\"\n\\]|\\.)*\"            { log_lexeme("STRING_LITERAL", yytext); yylval.str = dup_identifier(yytext); return STRING_LITERAL; }
\"([^\"\n\\]|\\.)*\n            { log_simple("ERROR, unterminated string"); line++; }

\'([^\'\n\\]|\\.)\'               { log_lexeme("CONSTANT", yytext); yylval.str = dup_identifier(yytext); return CONSTANT; }
\'([^\'\n\\]|\\.){2,}\'           { log_lexeme("ERROR, multi-character constant", yytext); }
\'([^\'\n\\]|\\.)*\n               { log_simple("ERROR, unterminated character constant"); line++; }
''                                 { log_simple("ERROR, empty character constant"); }

{DIGIT}+{ID}                        { log_lexeme("ERROR, invalid identifier", yytext); }
{FLOATCONST}                        { log_lexeme("CONSTANT", yytext); yylval.str = dup_identifier(yytext); return CONSTANT; }
{INTCONST}                          { log_lexeme("CONSTANT", yytext); yylval.str = dup_identifier(yytext); return CONSTANT; }

{ID}                                {
                                        log_lexeme("IDENTIFIER", yytext);
                                        add_symbol(yytext);
                                        yylval.str = dup_identifier(yytext);
                                        return IDENTIFIER;
                                    }

"("                                { log_lexeme("PUNCTUATOR", yytext); return '('; }
")"                                { log_lexeme("PUNCTUATOR", yytext); return ')'; }
"{"                                { log_lexeme("PUNCTUATOR", yytext); return '{'; }
"}"                                { log_lexeme("PUNCTUATOR", yytext); return '}'; }
"["                                { log_lexeme("PUNCTUATOR", yytext); return '['; }
"]"                                { log_lexeme("PUNCTUATOR", yytext); return ']'; }
";"                                { log_simple("SEMICOLON"); return ';'; }
","                                { log_lexeme("PUNCTUATOR", yytext); return ','; }
":"                                { log_lexeme("PUNCTUATOR", yytext); return ':'; }
"?"                                { log_lexeme("PUNCTUATOR", yytext); return '?'; }
"="                                { log_simple("ASSIGN"); return '='; }
"&"                                { log_lexeme("PUNCTUATOR", yytext); return '&'; }
"*"                                { log_lexeme("PUNCTUATOR", yytext); return '*'; }
"+"                                { log_lexeme("PUNCTUATOR", yytext); return '+'; }
"-"                                { log_lexeme("PUNCTUATOR", yytext); return '-'; }
"~"                                { log_lexeme("PUNCTUATOR", yytext); return '~'; }
"!"                                { log_lexeme("PUNCTUATOR", yytext); return '!'; }
"/"                                { log_lexeme("PUNCTUATOR", yytext); return '/'; }
"%"                                { log_lexeme("PUNCTUATOR", yytext); return '%'; }
"<"                                { log_lexeme("PUNCTUATOR", yytext); return '<'; }
">"                                { log_lexeme("PUNCTUATOR", yytext); return '>'; }
"^"                                { log_lexeme("PUNCTUATOR", yytext); return '^'; }
"|"                                { log_lexeme("PUNCTUATOR", yytext); return '|'; }
"."                                { log_lexeme("PUNCTUATOR", yytext); return '.'; }
"#"                                { log_lexeme("PUNCTUATOR", yytext); return '#'; }

.                                   { log_lexeme("ERROR", yytext); }

%%
