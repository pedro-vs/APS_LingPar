#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    OP_FILL,
    OP_GRIND,
    OP_BREW,
    OP_SERVE,
    OP_CLEAN,
    OP_CMP,
    OP_JZ,
    OP_JMP,
    OP_LABEL,
    OP_HALT,
    OP_INVALID
} OpCode;

typedef enum {
    REG_WATER,
    REG_BEANS,
    REG_CUP
} Reg;

typedef enum {
    CMP_EQ,
    CMP_NE,
    CMP_LT,
    CMP_LE,
    CMP_GT,
    CMP_GE
} CmpOp;

typedef struct {
    OpCode op;
    int arg;          // valor numérico (fill/grind/jump label)
    Reg reg;          // usado em CMP
    CmpOp cmp;        // usado em CMP
    int label_id;     // usado em LABEL/JMP/JZ
} Instr;

#define MAX_PROG 1024
#define MAX_LABELS 256

static Instr prog[MAX_PROG];
static int prog_size = 0;

static int label_to_pc[MAX_LABELS];
static int label_count = 0;

static int WATER = 0;
static int BEANS = 0;
static int CUP   = 0;
static int flag  = 0;   // resultado da última comparação (1 = verdadeiro, 0 = falso)

static Reg parse_reg(const char *s) {
    if (strcmp(s, "WATER") == 0) return REG_WATER;
    if (strcmp(s, "BEANS") == 0) return REG_BEANS;
    if (strcmp(s, "CUP")   == 0) return REG_CUP;
    fprintf(stderr, "VM error: unknown register '%s'\n", s);
    exit(1);
}

static CmpOp parse_cmp(const char *s) {
    if (strcmp(s, "==") == 0) return CMP_EQ;
    if (strcmp(s, "!=") == 0) return CMP_NE;
    if (strcmp(s, "<")  == 0) return CMP_LT;
    if (strcmp(s, "<=") == 0) return CMP_LE;
    if (strcmp(s, ">")  == 0) return CMP_GT;
    if (strcmp(s, ">=") == 0) return CMP_GE;
    fprintf(stderr, "VM error: unknown cmp op '%s'\n", s);
    exit(1);
}

static void load_program(FILE *f) {
    char line[256];

    while (fgets(line, sizeof(line), f)) {
        // ignora linhas em branco
        char *p = line;
        while (*p == ' ' || *p == '\t') p++;
        if (*p == '\0' || *p == '\n') continue;

        Instr ins;
        ins.op = OP_INVALID;
        ins.arg = 0;
        ins.reg = REG_WATER;
        ins.cmp = CMP_EQ;
        ins.label_id = -1;

        if (sscanf(p, "FILL %d", &ins.arg) == 1) {
            ins.op = OP_FILL;
        }
        else if (sscanf(p, "GRIND %d", &ins.arg) == 1) {
            ins.op = OP_GRIND;
        }
        else if (strncmp(p, "BREW", 4) == 0) {
            ins.op = OP_BREW;
        }
        else if (strncmp(p, "SERVE", 5) == 0) {
            ins.op = OP_SERVE;
        }
        else if (strncmp(p, "CLEAN", 5) == 0) {
            ins.op = OP_CLEAN;
        }
        else if (strncmp(p, "HALT", 4) == 0) {
            ins.op = OP_HALT;
        }
        else if (strncmp(p, "CMP", 3) == 0) {
            // formato: CMP REG OP INT
            char reg_s[32], cmp_s[4];
            int value;
            if (sscanf(p, "CMP %31s %3s %d", reg_s, cmp_s, &value) == 3) {
                ins.op = OP_CMP;
                ins.reg = parse_reg(reg_s);
                ins.cmp = parse_cmp(cmp_s);
                ins.arg = value;
            } else {
                fprintf(stderr, "VM error: bad CMP line: %s", line);
                exit(1);
            }
        }
        else if (sscanf(p, "JZ L%d", &ins.label_id) == 1) {
            ins.op = OP_JZ;
        }
        else if (sscanf(p, "JMP L%d", &ins.label_id) == 1) {
            ins.op = OP_JMP;
        }
        else if (sscanf(p, "LABEL L%d", &ins.label_id) == 1) {
            ins.op = OP_LABEL;
        }
        else {
            fprintf(stderr, "VM warning: ignoring unknown line: %s", line);
            continue;
        }

        if (prog_size >= MAX_PROG) {
            fprintf(stderr, "VM error: program too big\n");
            exit(1);
        }
        prog[prog_size++] = ins;
    }

    // primeira passada: mapear LABEL -> pc
    for (int pc = 0; pc < prog_size; pc++) {
        if (prog[pc].op == OP_LABEL) {
            int id = prog[pc].label_id;
            if (id < 0 || id >= MAX_LABELS) {
                fprintf(stderr, "VM error: label out of range L%d\n", id);
                exit(1);
            }
            label_to_pc[id] = pc;
            if (id+1 > label_count) label_count = id+1;
        }
    }
}

static int get_reg(Reg r) {
    switch (r) {
        case REG_WATER: return WATER;
        case REG_BEANS: return BEANS;
        case REG_CUP:   return CUP;
    }
    return 0;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s arquivo.asm\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("fopen");
        return 1;
    }

    load_program(f);
    fclose(f);

    int pc = 0;
    while (pc >= 0 && pc < prog_size) {
        Instr ins = prog[pc];

        switch (ins.op) {
            case OP_FILL:
                WATER += ins.arg;
                pc++;
                break;

            case OP_GRIND:
                BEANS += ins.arg;
                pc++;
                break;

            case OP_BREW:
                if (WATER >= 200 && BEANS >= 15) {
                    WATER -= 200;
                    BEANS -= 15;
                    CUP = 200;
                } else {
                    CUP = 0; // falha no preparo
                }
                pc++;
                break;

            case OP_SERVE:
                printf("Serving %d ml of coffee\n", CUP);
                CUP = 0;
                pc++;
                break;

            case OP_CLEAN:
                CUP = 0;
                pc++;
                break;

            case OP_CMP: {
                int reg_val = get_reg(ins.reg);
                int v = ins.arg;
                int res = 0;
                switch (ins.cmp) {
                    case CMP_EQ: res = (reg_val == v); break;
                    case CMP_NE: res = (reg_val != v); break;
                    case CMP_LT: res = (reg_val <  v); break;
                    case CMP_LE: res = (reg_val <= v); break;
                    case CMP_GT: res = (reg_val >  v); break;
                    case CMP_GE: res = (reg_val >= v); break;
                }
                flag = res;
                pc++;
                break;
            }

            case OP_JZ:
                if (!flag) {
                    if (ins.label_id < 0 || ins.label_id >= label_count) {
                        fprintf(stderr, "VM error: unknown label L%d\n", ins.label_id);
                        return 1;
                    }
                    pc = label_to_pc[ins.label_id];
                } else {
                    pc++;
                }
                break;

            case OP_JMP:
                if (ins.label_id < 0 || ins.label_id >= label_count) {
                    fprintf(stderr, "VM error: unknown label L%d\n", ins.label_id);
                    return 1;
                }
                pc = label_to_pc[ins.label_id];
                break;

            case OP_LABEL:
                pc++; // apenas um marcador
                break;

            case OP_HALT:
                return 0;

            default:
                fprintf(stderr, "VM error: invalid opcode at pc=%d\n", pc);
                return 1;
        }
    }

    return 0;
}
