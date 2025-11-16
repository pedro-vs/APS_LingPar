%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

/* Protótipos de funções geradas pelo Flex */
int yylex(void);
void yyerror(const char *s);

/* Registradores da máquina Codepresso */
typedef enum {
    REG_WATER,
    REG_BEANS,
    REG_CUP
} reg_t;

/* Operadores de comparação */
typedef enum {
    OP_EQ,
    OP_NE,
    OP_LT,
    OP_LE,
    OP_GT,
    OP_GE
} cmp_op_t;

/* Estrutura que representa uma condição: REG OP INT */
typedef struct {
    reg_t   reg;
    cmp_op_t op;
    int     value;
} condition_t;

/* Saída do compilador: por padrão stdout */
FILE *out = NULL; 

/* Gerador de rótulos numéricos: L0, L1, L2, ... */
static int label_counter = 0;
static int new_label(void) { return label_counter++; }

/* Pequeno "printf" helper para a saída */
static void emit(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vfprintf(out, fmt, ap);
    va_end(ap);
}

/* Converte enums em strings para o assembly da VM */
static const char *reg_to_str(reg_t r) {
    switch (r) {
        case REG_WATER: return "WATER";
        case REG_BEANS: return "BEANS";
        case REG_CUP:   return "CUP";
        default:        return "UNKNOWN";
    }
}

static const char *op_to_str(cmp_op_t op) {
    switch (op) {
        case OP_EQ: return "==";
        case OP_NE: return "!=";
        case OP_LT: return "<";
        case OP_LE: return "<=";
        case OP_GT: return ">";
        case OP_GE: return ">=";
        default:    return "??";
    }
}

/* Emite um CMP + JZ L<label> para "pular se condição for falsa" */
static void emit_condition_jump_false(condition_t cond, int label) {
    emit("CMP %s %s %d\n", reg_to_str(cond.reg),
                           op_to_str(cond.op),
                           cond.value);
    emit("JZ L%d\n", label);
}

/* Pilhas para controlar rótulos de if/else/while */
#define MAX_NESTING 128

/* if sem else */
static int if_end_stack[MAX_NESTING];
static int if_top = 0;

/* if-else */
static int if_else_else_stack[MAX_NESTING];
static int if_else_end_stack[MAX_NESTING];
static int if_else_top = 0;

/* while */
static int while_start_stack[MAX_NESTING];
static int while_end_stack[MAX_NESTING];
static int while_top = 0;

/* Helpers para if */
static void begin_if(condition_t cond) {
    if (if_top >= MAX_NESTING) {
        fprintf(stderr, "Erro: profundidade máxima de if atingida\n");
        exit(1);
    }
    int l_end = new_label();
    if_end_stack[if_top++] = l_end;

    emit_condition_jump_false(cond, l_end);
}

static void end_if(void) {
    if (if_top <= 0) {
        fprintf(stderr, "Erro: pilha de if vazia em end_if\n");
        exit(1);
    }
    int l_end = if_end_stack[--if_top];
    emit("LABEL L%d\n", l_end);
}

/* Helpers para if-else */
static void begin_if_else(condition_t cond) {
    if (if_else_top >= MAX_NESTING) {
        fprintf(stderr, "Erro: profundidade máxima de if-else atingida\n");
        exit(1);
    }
    int l_else = new_label();
    int l_end  = new_label();
    if_else_else_stack[if_else_top] = l_else;
    if_else_end_stack [if_else_top] = l_end;
    if_else_top++;

    emit_condition_jump_false(cond, l_else);
}

/* Chamado na palavra-chave "else" */
static void emit_else(void) {
    if (if_else_top <= 0) {
        fprintf(stderr, "Erro: pilha de if-else vazia em emit_else\n");
        exit(1);
    }
    int idx   = if_else_top - 1;
    int l_else = if_else_else_stack[idx];
    int l_end  = if_else_end_stack[idx];

    emit("JMP L%d\n", l_end);
    emit("LABEL L%d\n", l_else);
}

/* Chamado após o bloco do else */
static void end_if_else(void) {
    if (if_else_top <= 0) {
        fprintf(stderr, "Erro: pilha de if-else vazia em end_if_else\n");
        exit(1);
    }
    int l_end = if_else_end_stack[--if_else_top];
    emit("LABEL L%d\n", l_end);
}

/* Helpers para while */
static void begin_while(condition_t cond) {
    if (while_top >= MAX_NESTING) {
        fprintf(stderr, "Erro: profundidade máxima de while atingida\n");
        exit(1);
    }
    int l_start = new_label();
    int l_end   = new_label();
    while_start_stack[while_top] = l_start;
    while_end_stack  [while_top] = l_end;
    while_top++;

    emit("LABEL L%d\n", l_start);
    emit_condition_jump_false(cond, l_end);
}

static void end_while(void) {
    if (while_top <= 0) {
        fprintf(stderr, "Erro: pilha de while vazia em end_while\n");
        exit(1);
    }
    int idx    = --while_top;
    int l_start = while_start_stack[idx];
    int l_end   = while_end_stack[idx];

    emit("JMP L%d\n", l_start);
    emit("LABEL L%d\n", l_end);
}

%}

/* Definição dos tipos do yylval */
%union {
    int        ival;   /* inteiros literais */
    reg_t      reg;    /* registradores */
    cmp_op_t   op;     /* operadores de comparação */
    condition_t cond;  /* condição completa */
}

/* Tokens (com tipo) */
%token FILL GRIND BREW SERVE CLEAN
%token IF ELSE WHILE

%token <reg> WATER BEANS CUP
%token EQ NE LT LE GT GE
%token <ival> INT_LITERAL

%type  <reg>  reg_name
%type  <op>   cmp_op
%type  <cond> condition

%start program

%%

program
    : /* vazio */
    | program stmt
    ;

stmt
    : FILL '(' INT_LITERAL ')' ';'
        { emit("FILL %d\n", $3); }
    | GRIND '(' INT_LITERAL ')' ';'
        { emit("GRIND %d\n", $3); }
    | BREW ';'
        { emit("BREW\n"); }
    | SERVE ';'
        { emit("SERVE\n"); }
    | CLEAN ';'
        { emit("CLEAN\n"); }
    | if_stmt
    | while_stmt
    ;

/* IF sem ELSE e IF-ELSE */
if_stmt
    : IF '(' condition ')'
        { begin_if($3); }
      block
        { end_if(); }
    | IF '(' condition ')'
        { begin_if_else($3); }
      block
      ELSE
        { emit_else(); }
      block
        { end_if_else(); }
    ;

while_stmt
    : WHILE '(' condition ')'
        { begin_while($3); }
      block
        { end_while(); }
    ;

block
    : '{' stmts '}'
    ;

stmts
    : /* vazio */
    | stmts stmt
    ;

/* WATER / BEANS / CUP */
reg_name
    : WATER { $$ = $1; }
    | BEANS { $$ = $1; }
    | CUP   { $$ = $1; }
    ;

/* Operadores de comparação -> enum OP_* */
cmp_op
    : EQ { $$ = OP_EQ; }
    | NE { $$ = OP_NE; }
    | LT { $$ = OP_LT; }
    | LE { $$ = OP_LE; }
    | GT { $$ = OP_GT; }
    | GE { $$ = OP_GE; }
    ;

/* condição: REG OP INT */
condition
    : reg_name cmp_op INT_LITERAL
      {
          $$.reg   = $1;
          $$.op    = $2;
          $$.value = $3;
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}
