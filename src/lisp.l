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

[\(\)] {return yytext[0];}

{bool_val}  {
                switch (yytext[1]) {
                    case 't':
                        yylval.AST_NODE = new_node(new_object(boolean, NULL, 0, true), NULL, NULL);
                        break;
                    case 'f':
                        yylval.AST_NODE = new_node(new_object(boolean, NULL, 0, false), NULL, NULL);
                        break;
                }
                return BOOL;
            }
{number}    {
                yylval.AST_NODE = new_node(new_object(integer, NULL, atoi(yytext), false), NULL, NULL);
                return NUM;
            }
{id}        {}
{separator} {}
.           {}

%%
