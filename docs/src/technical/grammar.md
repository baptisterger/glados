# Grammaire du Langage Cédric

Le langage **Cédric** suit une grammaire formelle définie en **W3C EBNF**, inspirée du C mais simplifiée pour faciliter la compilation vers WebAssembly.  
Cette section décrit la structure syntaxique complète du langage.

---

## 1. Vue d’ensemble

Un programme Cédric est composé d’un ensemble de **déclarations globales**, qui peuvent être des **fonctions** ou des **variables globales**.  
Chaque fonction est définie à l’aide du mot-clé `skibidi` (ou `fun` en alias), suivie de son corps entre accolades `{}`.

---

## 2. Grammaire complète (W3C EBNF)

```ebnf
(* Cedric Language Grammar - W3C EBNF *)

(* Program is a list of top-level declarations *)
<program> ::= <top_level_declaration>*

(* Top-level declarations: functions or global variables *)
<top_level_declaration> ::= <function_declaration>
                          | <global_variable_declaration>

(* Function declaration with optional parameters *)
<function_declaration> ::= ("skibidi" | "fun")? <identifier> "(" <parameter_list>? ")" <block>

<parameter_list> ::= <parameter> ("," <parameter>)*

<parameter> ::= <type> <identifier>

(* Global variable declaration *)
<global_variable_declaration> ::= <type> <identifier> "=" <expression> ";"

(* Block is a sequence of statements enclosed in braces *)
<block> ::= "{" <statement>* "}"

(* Statements *)
<statement> ::= <variable_declaration>
              | <expression_statement>
              | <if_statement>
              | <while_statement>
              | <return_statement>

<variable_declaration> ::= <type> <identifier> "=" <expression> ";"

<expression_statement> ::= <expression> ";"

<if_statement> ::= "if" "(" <expression> ")" <block> ("else" <block>)?

<while_statement> ::= "while" "(" <expression> ")" <block>

<return_statement> ::= "return" <expression>? ";"

(* Expressions with operator precedence *)
<expression> ::= <assignment_expression>

<assignment_expression> ::= <comparison_expression>
                          | <identifier> "=" <assignment_expression>

<comparison_expression> ::= <additive_expression> (<comparison_operator> <additive_expression>)?

<additive_expression> ::= <multiplicative_expression> (("+" | "-") <multiplicative_expression>)*

<multiplicative_expression> ::= <primary_expression> (("*" | "/") <primary_expression>)*

<primary_expression> ::= <integer_literal>
                      | <float_literal>
                      | <boolean_literal>
                      | <identifier>
                      | <function_call>
                      | "(" <expression> ")"

(* Function call *)
<function_call> ::= <identifier> "(" <argument_list>? ")"

<argument_list> ::= <expression> ("," <expression>)*

(* Types *)
<type> ::= "int" | "float" | "bool"

(* Operators *)
<comparison_operator> ::= "==" | "!=" | "<" | ">" | "<=" | ">="

(* Literals *)
<boolean_literal> ::= "true" | "false"

<integer_literal> ::= "-"? <digit>+

<float_literal> ::= "-"? <digit>+ "." <digit>+

(* Identifiers *)
<identifier> ::= (<letter> | "_") (<letter> | <digit> | "_")*

(* Basic tokens *)
<digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"

<letter> ::= "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" 
           | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" 
           | "u" | "v" | "w" | "x" | "y" | "z" 
           | "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" 
           | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" 
           | "U" | "V" | "W" | "X" | "Y" | "Z"

(* Comments *)
(* Line comments: // ... \n *)
(* Comments are handled by the lexer and not part of the syntax tree *)

(* Reserved words *)
(* "skibidi", "fun", "if", "else", "while", "return", *)
(* "int", "float", "bool", "true", "false" *)
```

---

## 3. Exemple de code valide

```cedric
skibidi add(int a, int b) {
  return a + b;
}

int mainValue = 0;

skibidi main() {
  int result = add(2, 3);
  if (result > 4) {
    return true;
  } else {
    return false;
  }
}
```

---

## 4. Particularités du langage

- Mot-clé skibidi : sert à déclarer une fonction (équivalent de void ou func).
- Pas de typage implicite : tout doit être typé (int, float, bool).
- Expressions à priorité C-like : multiplicatif > additif > comparatif.
- Retour facultatif : un return; sans expression est accepté.
- Pas de structures ni de pointeurs (langage volontairement minimaliste).

## 5. Extensions possibles

Des extensions futures du langage pourraient inclure :

- des types composites (struct, array),
- un système de modules/imports,
- un système de typage dynamique optionnel.
---

## Ressources

- [EBNF Specification](https://www.w3.org/TR/REC-xml/#sec-notation)
