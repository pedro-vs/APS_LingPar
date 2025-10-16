#include "coffee_vm.h"

void vm_init(CoffeeVM* vm){
  vm->WATER_ml = 0;
  vm->BEANS_g  = 0;
  vm->cup_ml   = 0;
  vm->BREW_WATER = 200;
  vm->BREW_BEANS = 15;
  vm->halted = false;
}

void vm_fill(CoffeeVM* vm, int ml){
  if(ml > 0) vm->WATER_ml += ml;
}

void vm_grind(CoffeeVM* vm, int g){
  if(g > 0) vm->BEANS_g += g;
}

void vm_brew(CoffeeVM* vm){
  if(vm->WATER_ml >= vm->BREW_WATER && vm->BEANS_g >= vm->BREW_BEANS){
    vm->WATER_ml -= vm->BREW_WATER;
    vm->BEANS_g  -= vm->BREW_BEANS;
    vm->cup_ml    = vm->BREW_WATER;
  } else {
    /* falta recurso: não altera estado (poderia sinalizar erro) */
  }
}

void vm_serve(CoffeeVM* vm){
  /* saída: aqui apenas zera a xícara; em projetos futuros, imprime volume */
  vm->cup_ml = 0;
}

void vm_clean(CoffeeVM* vm){
  vm->cup_ml = 0;
}

void vm_halt(CoffeeVM* vm){
  vm->halted = true;
}
