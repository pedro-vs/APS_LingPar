%option noyywrap
%option yylineno
%option nounput noinput
%{
  #include "parser.h"
  #include <stdlib.h>
  static int to_int(const char *s){ return (int)strtol(s, NULL, 10); }
%}
%%
[ \t\r\f\v]+           { /* ignore */ }
\n                     { /* keep line count */ }
"//".*                 { /* line comment */ }
"fill"                 { return KW_FILL; }
"grind"                { return KW_GRIND; }
"brew"                 { return KW_BREW; }
"serve"                { return KW_SERVE; }
"clean"                { return KW_CLEAN; }
"if"                   { return KW_IF; }
"else"                 { return KW_ELSE; }
"while"                { return KW_WHILE; }
"WATER"                { return T_WATER; }
"BEANS"                { return T_BEANS; }
"CUP"                  { return T_CUP; }
[0-9]+                 { yylval.ival = to_int(yytext); return NUMBER; }
"=="                   { return EQEQ; }
"!="                   { return NEQ; }
"<="                   { return LE; }
">="                   { return GE; }
"<"                    { return LT; }
">"                    { return GT; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }
"{"                    { return LBRACE; }
"}"                    { return RBRACE; }
";"                    { return SEMI; }
.                      { return yytext[0]; }
%%
