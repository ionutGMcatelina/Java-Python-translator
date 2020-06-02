%{
#include <stdlib.h>
// #include "types.h"
#include "y.tab.h"
%}

alpha [A-Za-z]
digit [0-9]
%%

if      return IF;  // keywords pentru instructiuni
else    return ELSE;
while   return WHILE;
for     return FOR;

new     return NEW;
"ArrayList"   return ARRAYLIST;
"LinkedList"  return LINKEDLIST;

"List"        return LIST_INTERFACE;

"<="    return LE;  // operatori conditionali
">="    return GE;
"=="    return EQ;
"!="    return NE;
"&&"    return AND;
"||"    return OR;

int         |               // tipuri de primitive
short       return INT;

float       |
double      return FLOAT;

void        return VOID;    // void si return pentru metode
return      return RETURN;

"System.out.print"  |
"System.out.println"    return PRINT;

{digit}+[.]{digit}+ {yylval.flt = strdup(yytext); return FLOATNUM;} // numar real

{digit}+        {yylval.num = strdup(yytext); return INTNUM;}       // numar intreg

{alpha}({alpha}|{digit})*   {yylval.string = strdup(yytext); return NAME;} // denumire de variabila
\".*\"     {yylval.comment = strdup(yytext); return ANYTHING;} // orice string care este intre ghilimele

[{]         |   // caractere de care este nevoie
[}]         |
[=]         |
[;]         |
[:]         |
[+]         |
[-]         |
[*]         |
[/]         |
[<]         |
[>]         |
[&]         |
[(]         |
[)]         |
[,]         |
[|]         return yytext[0];
[\n]        ;   // ignor spatiul si orice altceva
.           ;
%%
