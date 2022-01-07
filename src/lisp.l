%{
    #include "lisp.tab.h"
%}

separator   [\t\n\r\ ]
letter      [a-z]
digit       [0-9]

number      0|[1-9]{digit}*|'-'[1-9]{digit}*
id          {letter}({letter}|{digit}|'-')*
bool_val    (#t)|(#f)

%%

"print-num" {return PRINT_N;}
"print-bool" {return PRINT_B;}
"+" {return PLS;}
"-" {return MIN;}
"*" {return MUL;}
"/" {return DIV;}
"mod" {return MOD;}
">" {return GREATER;}
"<" {return SMALLER;}
"=" {return EQUAL;}

"not" {return NOT;}
"or" {return OR;}
"and" {return AND;}

"if" {return IF;}
"define" {return DEF;}

[\(\)] {return yytext[0];}

{bool_val}  {
                switch (yytext[1]) {
                    case 't':
                        yylval.AST_NODE = new_bool(true, NULL, NULL);
                        break;
                    case 'f':
                        yylval.AST_NODE = new_bool(false, NULL, NULL);
                        break;
                }
                return BOOL;
            }
{number}    {
                yylval.AST_NODE = new_num(atoi(yytext), NULL, NULL);
                return NUM;
            }
{id}        {
                yylval.AST_NODE = new_id(strdup(yytext), NULL, NULL);
                return ID;
            }
{separator} {}
.           {}

%%
