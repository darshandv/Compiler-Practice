%{
    #include "y.tab.h"

%}

%option yylineno

num [0-9]
alpha [a-zA-Z]
und [_]
ide    {alpha}({alpha}|{num}|[_])*
space [ ]
%x co

%%
"//"[^\n]*   { return SINGLE;}
"/*"      {BEGIN co;}
<co>.|[ ]     ;
<co>"*/"      {BEGIN INITIAL; return MULTI;}
<co><<EOF>>   {printf("Error at line no %d\n",yylineno); exit(0);}

[ \n\t] {}

#include{space}*<{ide}*\.?{ide}+>  {return INCLUDE;}
#include{space}\"{ide}*\.?{ide}+\"  {return INCLUDE;}
#define{space}*({num}|{ide})* {return DEF;}

"int"   {return INT;}
"float" {return FLOAT;}
"char"  {return CHAR;}
"break" {return BREAK;}
"continue" {return CONTINUE;}
"if"   {return IF;}
"else" {return ELSE;}
"{"   {return OB;}
"}"   {return CB;} 
"("   {return OP;}
")"   {return CP;}
"++"  {return INC;}
"--"  {return DEC;}
"+="  {return PLE;}
"-="  {return MIE;}
"*="  {return MUE;}
"%="  {return MOE;}
"/="  {return DIE;}
"||"  {return OR;}
"&&"  {return AND;}

{num}+  {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str,yytext);return INTEGER;}
{num}*\.{num}+  {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str,yytext);return FLOATING;}


{ide}   {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str,yytext);return IDE;}

\"([^\\\"]|[\\.])*\" {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str,yytext);return STRING;}
\'([^\\\"]|[\\.])*\' {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str,yytext);return STRING;}

.     {return *yytext;}
%%


int yywrap(){
    return 1;
}