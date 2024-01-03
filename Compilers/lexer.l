%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "y.tab.h"
#include"node.h"
int countn=1;
%}


DIGIT [0-9]
LETTER [a-zA-Z]
IDENTIFIER [a-zA-Z_$]+[a-zA-Z_$0-9]*{0,31}
STRING  \".*?\"
INTEGER ([[:space:]]-)?{DIGIT}+
FLOAT [0-9]*\.?[0-9]*([dD][-+]?[0-9]+)?
COMMENT \/\/[^\r\n]*

%%
[ \t]             {;}
{COMMENT}         {;}
"do"              {strcpy(yylval.nd_obj.name,(yytext)); return K_DO; }
"double"          {strcpy(yylval.nd_obj.name,(yytext)); return K_DOUBLE; }
"else"            {strcpy(yylval.nd_obj.name,(yytext)); return K_ELSE; }
"exit"            {strcpy(yylval.nd_obj.name,(yytext)); return K_EXIT; }
"function"        {strcpy(yylval.nd_obj.name,(yytext)); return K_FUNCTION; }
"if"              {strcpy(yylval.nd_obj.name,(yytext)); return K_IF; }
"integer"         {strcpy(yylval.nd_obj.name,(yytext)); return K_INTEGER; }
"print_double"    {strcpy(yylval.nd_obj.name,(yytext)); return K_PRINT_DOUBLE; }
"print_integer"   {strcpy(yylval.nd_obj.name,(yytext)); return K_PRINT_INTEGER; }
"print_string"    {strcpy(yylval.nd_obj.name,(yytext)); return K_PRINT_STRING; }
"procedure"       {strcpy(yylval.nd_obj.name,(yytext)); return K_PROCEDURE; }
"program"         {strcpy(yylval.nd_obj.name,(yytext)); return K_PROGRAM; }
"read_double"     {strcpy(yylval.nd_obj.name,(yytext)); return K_READ_DOUBLE; }
"read_integer"    {strcpy(yylval.nd_obj.name,(yytext)); return K_READ_INTEGER; }
"read_string"     {strcpy(yylval.nd_obj.name,(yytext)); return K_READ_STRING; }
"return"          {strcpy(yylval.nd_obj.name,(yytext)); return K_RETURN; }
"string"          {strcpy(yylval.nd_obj.name,(yytext)); return K_STRING; }
"then"            {strcpy(yylval.nd_obj.name,(yytext)); return K_THEN; }
"while"           {strcpy(yylval.nd_obj.name,(yytext)); return K_WHILE; }
":="              {strcpy(yylval.nd_obj.name,(yytext));return ASSIGN; }
"+="              {strcpy(yylval.nd_obj.name,(yytext)); return ASSIGN_PLUS; }
"-="              {strcpy(yylval.nd_obj.name,(yytext)); return ASSIGN_MINUS; }
"*="              {strcpy(yylval.nd_obj.name,(yytext)); return ASSIGN_MULTIPLY; }
"/="              {strcpy(yylval.nd_obj.name,(yytext)); return ASSIGN_DIVIDE; }
"%="              {strcpy(yylval.nd_obj.name,(yytext)); return ASSIGN_MOD; }
","               {strcpy(yylval.nd_obj.name,(yytext)); return COMMA; }
"&&"              {strcpy(yylval.nd_obj.name,(yytext)); return DAND; }
"/"               {strcpy(yylval.nd_obj.name,(yytext)); return DIVIDE; }
"||"              {strcpy(yylval.nd_obj.name,(yytext)); return DOR; }
"=="              {strcpy(yylval.nd_obj.name,(yytext)); return DEQ; }
">="              {strcpy(yylval.nd_obj.name,(yytext)); return GEQ; }
">"               {strcpy(yylval.nd_obj.name,(yytext)); return GT; }
"["               {strcpy(yylval.nd_obj.name,(yytext)); return LBRACKET; }
"<="              {strcpy(yylval.nd_obj.name,(yytext)); return LEQ; }
"{"               {strcpy(yylval.nd_obj.name,(yytext)); return LCURLY; }
"("               {strcpy(yylval.nd_obj.name,(yytext)); return LPAREN; }
"<"               {strcpy(yylval.nd_obj.name,(yytext)); return LT; }
"-"               {strcpy(yylval.nd_obj.name,(yytext)); return MINUS; }
"--"              {strcpy(yylval.nd_obj.name,(yytext)); return DECREMENT; }
"%"               {strcpy(yylval.nd_obj.name,(yytext)); return MOD; }
"*"               {strcpy(yylval.nd_obj.name,(yytext)); return MULTIPLY; }
"!="              {strcpy(yylval.nd_obj.name,(yytext)); return NE; }
"!"               {strcpy(yylval.nd_obj.name,(yytext)); return NOT; }
"."               {strcpy(yylval.nd_obj.name,(yytext)); return PERIOD; }
"+"               {strcpy(yylval.nd_obj.name,(yytext)); return PLUS; }
"++"              {strcpy(yylval.nd_obj.name,(yytext)); return INCREMENT; }
"]"               {strcpy(yylval.nd_obj.name,(yytext)); return RBRACKET; }
"}"               {strcpy(yylval.nd_obj.name,(yytext)); return RCURLY; }
")"               {strcpy(yylval.nd_obj.name,(yytext)); return RPAREN; }
";"               {strcpy(yylval.nd_obj.name,(yytext)); return SEMI; }
{INTEGER}         {strcpy(yylval.nd_obj.id,(yytext)); return ICONSTANT; }
{STRING}          {strcpy(yylval.nd_obj.id, yytext); return SCONSTANT; }
{FLOAT}           {strcpy(yylval.nd_obj.id,(yytext)); return DCONSTANT; }
{IDENTIFIER}      {strcpy(yylval.nd_obj.id, (yytext)); return IDENTIFIER; }
[ \n]             {countn++;}
.                 { fprintf(stderr, "Error: Unrecognized character sequence: %s\n", yytext); exit(1); }


%%


