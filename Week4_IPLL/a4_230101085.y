%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex(void);
extern int line;
extern FILE *token_fp;
extern FILE *st_fp;

void yyerror(const char *s);
%}

%union {
    char *str;
}

%token <str> IDENTIFIER CONSTANT STRING_LITERAL
%token STATIC VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED BOOL
%token IF ELSE WHILE DO FOR CONTINUE BREAK RETURN CASE DEFAULT
%token INC DEC
%token LE GE EQ NE LAND LOR SHL SHR
%token MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN
%token SHL_ASSIGN SHR_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token ELLIPSIS


%start translation_unit

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
    : declaration
    | function_definition
    ;

function_definition
    : declaration_specifiers declarator declaration_list_opt compound_statement
    ;

declaration_list_opt
    : /* empty */
    | declaration_list_opt declaration
    ;

declaration
    : declaration_specifiers init_declarator_list_opt ';'
    ;

declaration_specifiers
    : declaration_specifier
    | declaration_specifiers declaration_specifier
    ;

declaration_specifier
    : storage_class_specifier
    | type_specifier
    ;

storage_class_specifier
    : STATIC
    ;

type_specifier
    : VOID
    | CHAR
    | SHORT
    | INT
    | LONG
    | FLOAT
    | DOUBLE
    | SIGNED
    | UNSIGNED
    | BOOL
    ;

init_declarator_list_opt
    : /* empty */
    | init_declarator_list
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator
    : declarator
    | declarator '=' initializer
    ;

declarator
    : direct_declarator
    ;

direct_declarator
    : IDENTIFIER
    | '(' declarator ')'
    | direct_declarator '[' assignment_expression_opt ']'
    | direct_declarator '(' parameter_type_list ')'
    | direct_declarator '(' identifier_list_opt ')'
    ;

assignment_expression_opt
    : /* empty */
    | assignment_expression
    ;

parameter_type_list
    : parameter_list
    | parameter_list ',' ELLIPSIS
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers declarator
    | declaration_specifiers
    ;

identifier_list_opt
    : /* empty */
    | identifier_list
    ;

identifier_list
    : IDENTIFIER
    | identifier_list ',' IDENTIFIER
    ;

initializer
    : assignment_expression
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

initializer_list
    : designation_opt initializer
    | initializer_list ',' designation_opt initializer
    ;

designation_opt
    : /* empty */
    | designation
    ;

designation
    : designator_list '='
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : '[' constant_expression ']'
    ;

statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : IDENTIFIER ':' statement
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

compound_statement
    : '{' block_item_list_opt '}'
    ;

block_item_list_opt
    : /* empty */
    | block_item_list
    ;

block_item_list
    : block_item
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

expression_statement
    : expression_opt ';'
    ;

expression_opt
    : /* empty */
    | expression
    ;

selection_statement
    : IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' expression_opt ';' expression_opt ';' expression_opt ')' statement
    | FOR '(' declaration expression_opt ';' expression_opt ')' statement
    ;

jump_statement
    : CONTINUE ';'
    | BREAK ';'
    | RETURN expression_opt ';'
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : '='
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | SHL_ASSIGN
    | SHR_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

constant_expression
    : conditional_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression LOR logical_and_expression
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression LAND inclusive_or_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ relational_expression
    | equality_expression NE relational_expression
    ;

relational_expression
    : shift_expression
    | relational_expression '<' shift_expression
    | relational_expression '>' shift_expression
    | relational_expression LE shift_expression
    | relational_expression GE shift_expression
    ;

shift_expression
    : additive_expression
    | shift_expression SHL additive_expression
    | shift_expression SHR additive_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

multiplicative_expression
    : unary_expression
    | multiplicative_expression '*' unary_expression
    | multiplicative_expression '/' unary_expression
    | multiplicative_expression '%' unary_expression
    ;

unary_expression
    : postfix_expression
    | INC unary_expression
    | DEC unary_expression
    | unary_operator cast_expression
    ;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

cast_expression
    : unary_expression
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' argument_expression_list_opt ')'
    | postfix_expression INC
    | postfix_expression DEC
    ;

argument_expression_list_opt
    : /* empty */
    | argument_expression_list
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

primary_expression
    : IDENTIFIER
    | CONSTANT
    | STRING_LITERAL
    | '(' expression ')'
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Syntax error at line %d: %s\n", line, s);
}

int main(void)
{
    int result = yyparse();

    if (token_fp) fclose(token_fp);
    if (st_fp) fclose(st_fp);

    if (result == 0) {
        printf("Parsing successful\n");
    }

    return result;
}
