# Références Techniques

Cette page regroupe les principales ressources utilisées pour la conception, la documentation et l’implémentation du langage Cédric.
Elles couvrent la construction de l’AST, le processus de compilation vers WebAssembly, la définition grammaticale du langage, ainsi que le fonctionnement de la machine virtuelle.

---

## AST (Arbre Syntaxique Abstrait)

L’AST représente la structure hiérarchique du code source. Ces ressources expliquent comment le concevoir et le générer à partir d’une grammaire formelle.

- [Conception d'un AST](https://craftinginterpreters.com/representing-code.html)
- [Création d’un AST à partir d’une grammaire EBNF](https://ruslanspivak.com/lsbasi-part7/)

---

## Compilation

La compilation transforme le code source du langage Cédric en bytecode WebAssembly.
Ces ressources décrivent la spécification du format WASM, son encodage et la représentation binaire.

- [Spécification WebAssembly](https://webassembly.github.io/spec/)
- [Format binaire](https://webassembly.github.io/spec/core/binary/index.html)
- [LEB128 encoding](https://en.wikipedia.org/wiki/LEB128)


---

## Grammaire du Langage

La grammaire définit la structure syntaxique du langage Cédric à l’aide de la notation EBNF (Extended Backus–Naur Form).

- [EBNF Specification](https://www.w3.org/TR/REC-xml/#sec-notation)

---

## Machine Virtuelle (VM)

La VM Cédric est une machine à pile (stack-based) capable d’exécuter le bytecode généré.
Elle suit le modèle d’exécution de WebAssembly.

- [WASM Execution Model](https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Concepts)

---

## WebAssembly (WASM)

Le backend du compilateur Cédric produit du code WASM, exécutable sur navigateur ou en environnement natif.
Ces outils et ressources permettent d’explorer, convertir et déboguer le bytecode généré.

- [WABT WebAssembly Binary Toolkit](https://github.com/WebAssembly/wabt)


---

*Dernière mise à jour : Novembre 2025*