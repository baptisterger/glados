# Représentation de l’AST (Abstract Syntax Tree)

L’**AST (Abstract Syntax Tree)** est une représentation arborescente du programme Cédric.  
Il capture la structure logique du code après l’analyse syntaxique (parsing) mais avant la compilation vers WebAssembly.

---

## 1. Objectif de l’AST

L’AST permet :
- d’isoler la **structure logique** du programme (fonctions, expressions, conditions, etc.),
- d’effectuer des **analyses sémantiques** (vérification des types, portée des variables…),
- de faciliter la **traduction vers WebAssembly** ou tout autre backend.

---

## 2. Structure générale

Chaque nœud de l’arbre hérite d’un type générique `Node`.  
Exemple en Haskell :

```haskell
data Node
  = Program [Node]
  | FunctionDecl String [Node] Node
  | VariableDecl String Node
  | BinaryOp String Node Node
  | If Node Node Node
  | Return Node
  | Literal Value
  deriving (Show, Eq)
```

---

## 3. Exemple d'AST

Code source Cédric :

```cedric
skibidi add() {
  int a = 2;
  int b = 3;
  return a + b;
}
```

AST correspondant :

```less
Program
 └── FunctionDecl("add")
     ├── VariableDecl("a", Literal(2))
     ├── VariableDecl("b", Literal(3))
     └── Return(
           BinaryOp("+", Identifier("a"), Identifier("b"))
         )
```

---

## 4. Conversion en WASM

Le compilateur parcourt récursivement cet AST pour produire le code WebAssembly équivalent.
Chaque type de nœud (BinaryOp, If, FunctionDecl) possède sa logique de génération.

---

## Ressources

- [Conception d'un AST](https://craftinginterpreters.com/representing-code.html)
- [Création d’un AST à partir d’une grammaire EBNF](https://ruslanspivak.com/lsbasi-part7/)

