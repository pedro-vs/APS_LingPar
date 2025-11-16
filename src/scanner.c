#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

/* Mesmos tipos do coffee.y */
typedef enum {
    REG_WATER,
    REG_BEANS,
    REG_CUP
} reg_t;

typedef enum {
    OP_EQ,
    OP_NE,
    OP_LT,
    OP_LE,
    OP_GT,
    OP_GE
} cmp_op_t;

typedef struct {
    reg_t    reg;
    cmp_op_t op;
    int      value;
} condition_t;

#include "parser.h"   /* traz yylval, tokens, etc. */

/* Scanner manual substituindo o Flex */
int yylex(void) {
    int c;

    /* Ignora espaços em branco */
    while ((c = getchar()) != EOF && isspace(c))
        ;

    if (c == EOF) {
        return 0; /* fim de entrada */
    }

    /* Números inteiros -> INT_LITERAL */
    if (isdigit(c)) {
        char buf[64];
        int  i = 0;

        buf[i++] = c;
        while ((c = getchar()) != EOF && isdigit(c)) {
            if (i < (int)sizeof(buf) - 1) {
                buf[i++] = c;
            }
        }
        buf[i] = '\0';
        if (c != EOF) {
            ungetc(c, stdin);
        }

        yylval.ival = atoi(buf);
        return INT_LITERAL;
    }

    /* Identificadores / palavras-chave */
    if (isalpha(c)) {
        char buf[64];
        int  i = 0;

        buf[i++] = c;
        while ((c = getchar()) != EOF && isalpha(c)) {
            if (i < (int)sizeof(buf) - 1) {
                buf[i++] = c;
            }
        }
        buf[i] = '\0';
        if (c != EOF) {
            ungetc(c, stdin);
        }

        /* Comandos */
        if (strcmp(buf, "fill")  == 0) return FILL;
        if (strcmp(buf, "grind") == 0) return GRIND;
        if (strcmp(buf, "brew")  == 0) return BREW;
        if (strcmp(buf, "serve") == 0) return SERVE;
        if (strcmp(buf, "clean") == 0) return CLEAN;

        /* Controle de fluxo */
        if (strcmp(buf, "if")    == 0) return IF;
        if (strcmp(buf, "else")  == 0) return ELSE;
        if (strcmp(buf, "while") == 0) return WHILE;

        /* Registradores */
        if (strcmp(buf, "WATER") == 0) {
            yylval.reg = REG_WATER;
            return WATER;
        }
        if (strcmp(buf, "BEANS") == 0) {
            yylval.reg = REG_BEANS;
            return BEANS;
        }
        if (strcmp(buf, "CUP") == 0) {
            yylval.reg = REG_CUP;
            return CUP;
        }

        /* Palavra desconhecida: devolve primeiro caractere */
        return buf[0];
    }

    /* Operadores de comparação de 2 caracteres */
    if (c == '=') {
        int d = getchar();
        if (d == '=') return EQ;
        if (d != EOF) ungetc(d, stdin);
    }
    if (c == '!') {
        int d = getchar();
        if (d == '=') return NE;
        if (d != EOF) ungetc(d, stdin);
    }
    if (c == '<') {
        int d = getchar();
        if (d == '=') { return LE; }
        if (d != EOF) ungetc(d, stdin);
        return LT;
    }
    if (c == '>') {
        int d = getchar();
        if (d == '=') { return GE; }
        if (d != EOF) ungetc(d, stdin);
        return GT;
    }

    /* Símbolos simples */
    if (c == ';' || c == '(' || c == ')' || c == '{' || c == '}') {
        return c;
    }

    /* Qualquer outra coisa: devolve o próprio caractere */
    return c;
}
