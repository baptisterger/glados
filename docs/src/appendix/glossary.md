# Glossaire du Langage Cédric

Ce glossaire rassemble les principaux termes techniques utilisés dans la documentation du langage Cédric.
Il permet de mieux comprendre les concepts de compilation, d’exécution et de conception du langage.

---

## Concepts Syntaxiques

***AST (Abstract Syntax Tree)***

Arbre Syntaxique Abstrait représentant la structure logique du code source.
Chaque nœud correspond à une instruction ou une expression (ex : une opération, une déclaration, un appel de fonction).
L’AST est produit par l’analyse syntaxique (parsing) et sert de base à la génération du bytecode.

***EBNF (Extended Backus–Naur Form)***

Notation formelle utilisée pour décrire la syntaxe d’un langage de programmation.
Elle définit les règles de grammaire à l’aide de symboles (::=, |, *, +, etc.) permettant de générer un parseur.

***Token***

Unité lexicale produite par le lexer (analyse lexicale).
Exemples : int, =, 123, if, skibidi.

## Compilation

***Bytecode***

Représentation intermédiaire du code source, souvent plus compacte et plus proche de la machine.
Le langage Cédric compile vers du bytecode WebAssembly (WASM).

***Compiler***

Programme qui traduit le code source (écrit en Cédric) en un autre langage cible (ici WebAssembly).
Il suit généralement les étapes : lexing → parsing → AST → codegen.

***LEB128***

Encodage binaire utilisé dans WebAssembly pour représenter efficacement les entiers signés et non signés.
C’est un format à longueur variable, optimisé pour les petits nombres.

## Machine Virtuelle

***Stack-Based VM***

Machine virtuelle fonctionnant sur une pile :
les opérations (addition, multiplication, comparaison, etc.) manipulent les valeurs en les empilant et en les dépilant.
C’est le modèle d’exécution utilisé par la VM Cédric et par WebAssembly.

***Opcode***

Instruction élémentaire exécutée par la machine virtuelle.
Chaque opcode (comme add, sub, load, store, return) indique une opération à effectuer sur la pile.

***Runtime***

Environnement d’exécution du programme compilé.
Il gère la mémoire, les appels de fonction et l’interprétation du bytecode.

## WebAssembly

***WASM (WebAssembly)***

Format binaire portable destiné à être exécuté dans les navigateurs ou dans des environnements natifs.
C’est la cible de compilation du langage Cédric.

***WAT (WebAssembly Text Format)***

Version textuelle lisible du bytecode .wasm.
Elle permet de déboguer ou d’analyser le code généré par le compilateur.

***WABT***

(WebAssembly Binary Toolkit) — Ensemble d’outils officiels pour manipuler, convertir et vérifier les fichiers .wasm.
Exemples : wat2wasm, wasm2wat, wasm-validate.

## Langage Cédric

***skibidi***

Mot-clé utilisé pour déclarer une fonction dans le langage Cédric.
Exemple :

```cedric
skibidi main() {
  return 0;
}
```

***Bloc ({ })***

Section de code délimitée par des accolades.
Elle regroupe plusieurs instructions (par exemple dans une fonction ou une condition).

***Type***

Définit la nature d’une variable ou d’une valeur.
Types de base supportés :

- int — entier
- float — nombre à virgule
- bool — valeur booléenne (true / false)

---

*Dernière mise à jour : Novembre 2025*