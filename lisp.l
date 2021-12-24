%{
    // #include "lisp.tab.h"
%}

separator [\t\n\r\ ]
letter [a-z]
digit [0-9]

number 0|[1-9]{digit}*|'-'[1-9]{digit}*
id {letter}({letter}|{digit}|'-')*
bool-val (#t)|(#f)


%%

{separator} {}
{bool-val} {printf ("bool-val\n");}
{number} {printf ("number\n");}
{id} {printf ("id\n");}
. {}

%%
int main () {
    yylex ();
    return (0);
}