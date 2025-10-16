#ifndef COFFEE_VM_H
#define COFFEE_VM_H

#include <stddef.h>
#include <stdbool.h>

/* CoffeeVM — simulador simples
   - WATER, BEANS: estados (registradores)
   - CUP: sensor (somente leitura)
   - Consumo de uma extração (parametrizável)
*/
typedef struct {
  int WATER_ml;     /* registrador */
  int BEANS_g;      /* registrador */
  int cup_ml;       /* armazenamento interno; exposto via sensor */
  int BREW_WATER;   /* default: 200 ml por brew */
  int BREW_BEANS;   /* default: 15 g  por brew */
  bool halted;
} CoffeeVM;

void vm_init(CoffeeVM* vm);
void vm_fill(CoffeeVM* vm, int ml);
void vm_grind(CoffeeVM* vm, int g);
void vm_brew(CoffeeVM* vm);
void vm_serve(CoffeeVM* vm);
void vm_clean(CoffeeVM* vm);
void vm_halt(CoffeeVM* vm);

/* SENSOR: CUP (somente leitura) */
static inline int vm_sensor_CUP(const CoffeeVM* vm){ return vm->cup_ml; }

#endif
