/* coffee.y — sintaxe CoffeeLang (ENTREGA #2) — versão compatível com Bison 2.x
   - Sem %code / %define (não existem no 2.x)
   - Usa %pure-parser e %error-verbose
   - Não usa %locations (mensagem usa yylineno do Flex)
*/

%{
  #include <stdio.h>
  #include <stdlib.h>

  int yylex(void);        /* <-- sem argumentos */
  extern int yylineno;

  static void yyerror(const char* msg) {
    fprintf(stderr, "[PARSE] Erro de sintaxe na linha %d: %s\n", yylineno, msg);
  }
%}

%define parse.error verbose   /* mensagens de erro detalhadas */
/* (NÃO usar %pure-parser aqui) */

%union {
  int ival;
}

/* --------- Tokens --------- */
%token KW_FILL KW_GRIND KW_BREW KW_SERVE KW_CLEAN
%token KW_IF KW_ELSE KW_WHILE
%token T_WATER T_BEANS T_CUP
%token <ival> NUMBER
%token EQEQ NEQ LT LE GT GE
%token LPAREN RPAREN LBRACE RBRACE SEMI

/* Precedência para comparadores (opcional) */
%left EQEQ NEQ LT LE GT GE

%start programa

%%

/* =========================
 *   PROGRAMA / LISTA DE STMT
 * ========================= */

programa
  : stmts                 { puts("OK: código sintaticamente correto."); }
  ;

stmts
  : /* vazio */
  | stmts stmt
  ;

/* =========================
 *   STATEMENTS
 * ========================= */

stmt
  : abastecer SEMI
  | preparar SEMI
  | servir SEMI
  | limpar SEMI
  | condicional
  | laco_while
  | bloco
  | SEMI                 /* statement vazio */
  ;

bloco
  : LBRACE stmts RBRACE
  ;

abastecer
  : KW_FILL  LPAREN NUMBER RPAREN
  | KW_GRIND LPAREN NUMBER RPAREN
  ;

preparar  : KW_BREW  ;
servir    : KW_SERVE ;
limpar    : KW_CLEAN ;

condicional
  : KW_IF LPAREN expr_bool RPAREN stmt
  | KW_IF LPAREN expr_bool RPAREN stmt KW_ELSE stmt
  ;

laco_while
  : KW_WHILE LPAREN expr_bool RPAREN stmt
  ;

/* =========================
 *   EXPRESSÃO BOOLEANA
 *   (estado/sensor op NUMBER)
 * ========================= */

expr_bool
  : estado op_cmp NUMBER
  ;

estado
  : T_WATER
  | T_BEANS
  | T_CUP       /* sensor CUP: só leitura (semântica virá depois) */
  ;

op_cmp
  : EQEQ | NEQ | LT | LE | GT | GE
  ;

%%


