# Assignment 4 (nanoC Parser) - Quick Run Guide

## Files
- `a4_230101085.l`: Flex lexer specification
- `a4_230101085.y`: Bison parser specification
- `Makefile`: build automation
- `a4_230101085_test.nc`: comprehensive valid test file
- `a4_230101085_lexer_error_test.nc`: lexer error handling test file
- `a4_230101085_parser_error_test.nc`: parser syntax error handling test file

## One-time setup in WSL (Ubuntu)
```bash
sudo apt-get update
sudo apt-get install -y flex bison gcc make poppler-utils
```

## Build
```bash
make clean
make
```

This generates:
- `y.tab.c`, `y.tab.h`
- `lex.yy.c`
- `parser`

## Run parser on comprehensive test
```bash
make run
```
Expected: prints `Parsing successful`.

## Run lexer error test
```bash
make run-lexer-error
```
Expected: syntax error on stderr and non-zero make exit status.

## Run parser error test
```bash
make run-parser-error
```
Expected: syntax error on stderr and non-zero make exit status.

## View generated outputs
```bash
make show-token
make show-st
```

## Output files produced by lexer
- `a4_230101085_token.txt`: token stream with line numbers
- `a4_230101085_st.txt`: unique identifier symbol table

## Optional: read assignment PDF text in terminal
```bash
pdftotext Assignment4.pdf - | less
```

## Equivalent manual commands (without Makefile)
```bash
flex -o lex.yy.c a4_230101085.l
yacc -d -o y.tab.c a4_230101085.y
gcc -o parser y.tab.c lex.yy.c
./parser < a4_230101085_test.nc
./parser < a4_230101085_lexer_error_test.nc
./parser < a4_230101085_parser_error_test.nc
cat a4_230101085_token.txt
cat a4_230101085_st.txt
```
