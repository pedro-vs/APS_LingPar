#include <stdio.h>
#include <stdlib.h>

/* Tipos usados em parser.h (copiados do coffee.y) */
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

#include "parser.h"   /* gerado pelo Bison, usa os tipos acima */

extern FILE *out;     /* declarado em coffee.y */

int yyparse(void);

int main(int argc, char **argv) {
    out = stdout;     /* onde o emit vai escrever o código da VM */

    if (yyparse() == 0) {
        /* Se parse OK, encerra programa da VM com HALT */
        fprintf(out, "HALT\n");
        return 0;
    }

    return 1;
}
