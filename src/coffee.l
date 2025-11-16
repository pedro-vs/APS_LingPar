%{
#include "parser.h"
%}

%%

"fill"        { return FILL; }
"grind"       { return GRIND; }
"brew"        { return BREW; }
"serve"       { return SERVE; }
"clean"       { return CLEAN; }

"if"          { return IF; }
"else"        { return ELSE; }
"while"       { return WHILE; }

"WATER"       { return WATER; }
"BEANS"       { return BEANS; }
"CUP"         { return CUP; }

"=="          { return EQ; }
"!="          { return NE; }
"<="          { return LE; }
">="          { return GE; }
"<"           { return LT; }
">"           { return GT; }

[0-9]+        { return INT; }

/* espaços em branco: ignorar */
[ \t\r\n]+    { /* ignore */ }

/* comentário // até o fim da linha: ignorar */
"//".*        { /* ignore */ }

/* símbolos simples */
";"           { return ';'; }
"("           { return '('; }
")"           { return ')'; }
"{"           { return '{'; }
"}"           { return '}'; }

/* qualquer outro caractere: retorna ele mesmo */
.             { return *yytext; }

%%

int yywrap(void) {
    return 1;
}
