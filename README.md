# APS_LingPar

## Entrega #1 – Linguagem estruturada segundo a EBNF  

### Máquina-alvo escolhida: **Codepresso ☕**

A **Codepresso** simula uma máquina de café com poucos registradores e instruções, servindo como alvo de compilação.  
É uma metáfora concreta, simples e didática (sem ser a do micro-ondas).

---

## Codepresso – Modelo

### Registradores
- `WATER` – quantidade de água no reservatório (ml).  
- `BEANS` – quantidade de grãos/pó (g).  
- `CUP` – volume atual na xícara (ml).  

### Instruções primitivas
- `FILL n` — adiciona `n` ml de água no `WATER`.  
- `GRIND n` — adiciona `n` g de pó no `BEANS`.  
- `BREW` — transfere água + grãos → `CUP`.  
- `SERVE` — despeja conteúdo da `CUP` (saída).  
- `CLEAN` — limpa a xícara.  
- `HALT` — encerra a execução.  

---

## Codepresso – Gramática em EBNF

> Notação conforme [Wikipédia: EBNF](https://pt.wikipedia.org/wiki/Formalismo_de_Backus-Naur_Estendido).

```ebnf
(* ========================= *)
(*  PROGRAMA                 *)
(* ========================= *)

programa        = { comando } ;

(* ========================= *)
(*  COMANDOS                 *)
(* ========================= *)

comando         = abastecer ";"
                | preparar ";"
                | servir ";"
                | limpar ";"
                | condicional
                | laco_while
                ;

abastecer       = "fill", "(", inteiro, ")"       (* ml de água *)
                | "grind", "(", inteiro, ")" ;   (* g de grãos *)

preparar        = "brew" ;
servir          = "serve" ;
limpar          = "clean" ;

condicional     = "if", "(", expr_bool, ")", "{", { comando }, "}",
                  [ "else", "{", { comando }, "}" ] ;

laco_while      = "while", "(", expr_bool, ")", "{", { comando }, "}" ;

(* ========================= *)
(*  EXPRESSÕES               *)
(* ========================= *)

expr_bool       = identificador, op_cmp, inteiro ;
op_cmp          = "==" | "!=" | "<" | "<=" | ">" | ">=" ;

(* ========================= *)
(*  TOKENS                   *)
(* ========================= *)

identificador   = "WATER" | "BEANS" | "CUP" ;
inteiro         = digito, { digito } ;

digito          = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```
---
### Exemplo de exercício:
```
fill(600);       // Abastece água suficiente para até 3 xícaras (3 × 200 ml)
grind(30);       // Começa com 30 g de pó (não dá para 3 xícaras -> veremos o if/else)

if (CUP > 0) {   // CUP começa vazia (0), então cai no else (apenas para demonstrar o else)
  clean;
} else {
  serve;         // 'serve' com CUP vazia não produz saída visível, mas usa o comando
}

while (WATER >= 200) {           // Enquanto houver água suficiente para mais uma xícara
  if (BEANS < 15) {              // Se faltar pó para a próxima extração...
    grind(15);                   // ...reabastece 15 g
  } else {
    clean;                       // Caso contrário, garante que a xícara esteja limpa
  }

  brew;                          // Prepara 1 xícara (200 ml, consome 15 g)
  serve;                         // Serve a xícara (saída)
  clean;                         // Limpa a xícara para a próxima iteração
}

```

---

## Explicação do exercício de exemplo

O programa demonstra **todos os comandos** da Codepresso:

1. **Abastecimento inicial**  
   - `fill(600);` coloca 600 ml de água no reservatório.  
   - `grind(30);` adiciona 30 g de pó de café.  

2. **Primeiro `if/else`**  
   - Testa `if (CUP > 0)`. Como a xícara começa vazia, executa o `else` → `serve;`.  
   - Esse passo mostra o uso explícito do `else`, mesmo sem efeito prático.  

3. **Laço `while (WATER >= 200)`**  
   - Enquanto houver ao menos 200 ml de água, continua preparando café.  
   - Dentro do `while` há outro `if/else`:  
     - Se não houver pó suficiente (`BEANS < 15`), executa `grind(15);`.  
     - Caso contrário, executa `clean;`.  
   - Em seguida sempre:  
     - `brew;` prepara uma xícara (consome 200 ml de água e 15 g de pó).  
     - `serve;` despeja a xícara (saída).  
     - `clean;` limpa a xícara.  

4. **Execução completa**  
   - São servidas 3 xícaras ao todo, pois havia água para 3 extrações de 200 ml.  
   - Em uma das iterações o `if` reabastece pó de café, mostrando o uso do ramo `then`.  
   - Assim, o exemplo cobre todos os comandos: `fill`, `grind`, `brew`, `serve`, `clean`, `if/else` e `while`.

---

## Possíveis usos da Codepresso

Embora seja uma linguagem **didática**, a Codepresso ilustra conceitos importantes de programação e compiladores:

- **Ensino de gramáticas e EBNF**  
  - Serve como exemplo claro de como definir a sintaxe de uma linguagem de programação.  

- **Tradução para máquinas virtuais simples**  
  - Mostra como comandos de alto nível (`if`, `while`) podem ser traduzidos em instruções básicas (`JMP`, `JZ`, manipulação de registradores).  

- **Simulação de processos do mundo real**  
  - Pode modelar o funcionamento de dispositivos simples, como cafeteiras, impressoras ou lavadoras.  

- **Laboratório de compiladores**  
  - Excelente ponto de partida para trabalhos de análise léxica, sintática e geração de código.  
  - Pode ser expandida com novos tipos de comandos (ex.: `sugar`, `milk`) para exercitar extensibilidade.  

- **Exercícios de lógica de programação**  
  - Estudantes podem praticar estruturas condicionais e de repetição em um contexto divertido e concreto (preparar café).  




