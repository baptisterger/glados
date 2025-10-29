# GLaDOS - Projet de Compilation

Projet académique implémentant deux langages de programmation en Haskell :
1. **GLaDOS Part 1** : Interpréteur Scheme (LISP)
2. **GLaDOS Part 2** : Compilateur vers WebAssembly

## 📁 Structure du Projet

```
glados/
├── glados1/          # Part 1 : Interpréteur LISP/Scheme
└── glados2/          # Part 2 : Compilateur WebAssembly
```

---

## 🔧 Part 1 : Interpréteur LISP (glados1/)

### Description
Interpréteur minimaliste de Scheme écrit en Haskell. Supporte les fonctionnalités de base du langage LISP.

### Fonctionnalités
- **Types** : Entiers 64-bit, booléens (`#t`/`#f`), fonctions
- **Définitions** : `(define var val)`, `(define (func args) body)`
- **Fonctions lambda** : `(lambda (args) body)`
- **Conditionnelles** : `(if cond then else)`
- **Built-ins** : `+`, `-`, `*`, `div`, `mod`, `<`, `eq?`
- **Récursion** et closures lexicales

### Utilisation
```bash
cd glados1/
stack build
echo "(+ 1 2)" | stack exec Glados
stack exec Glados test/factorial.scm
```

### Exemple
```scheme
(define (fact n)
  (if (eq? n 1)
      1
      (* n (fact (- n 1)))))
(fact 10)  # => 3628800
```

---

## 🚀 Part 2 : Compilateur WebAssembly (glados2/)

### Description
Langage de programmation statiquement typé qui compile vers WebAssembly. Syntaxe inspirée du C avec des garanties de sécurité modernes.

### Fonctionnalités
- **Types** : `int`, `float`, `bool`
- **Opérateurs** : Arithmétiques (`+`, `-`, `*`, `/`) et comparaison (`==`, `!=`, `<`, `>`, `<=`, `>=`)
- **Structures de contrôle** : `if/else`
- **Fonctions** : Déclarations avec `skibidi`, support de `return`
- **Compilation** : Génère du WebAssembly (.wat)
- **Sécurité** : Type safety, memory safety, sandboxing WASM

### Utilisation
```bash
cd glados2/
stack build
stack exec glados2 -- program.cedric  # Génère program.wat
wasmtime program.wat                   # Exécute le WASM
```

### Exemple
```glados
skibidi main() {
  int x = 10;
  int y = 20;
  if (x < y) {
    return 1;
  } else {
    return 0;
  }
}
```

---

## 🛠️ Installation et Prérequis

### Dépendances
- **GHC** 8.10+
- **Stack** (gestionnaire de build Haskell)
- **wasmtime** ou **wasmer** (pour exécuter le WASM, Part 2 uniquement)

### Installation
```bash
git clone <repo-url>
cd glados/

# Part 1
cd glados1 && stack build

# Part 2
cd ../glados2 && stack build
```

---

## 📚 Documentation

### GLaDOS Part 2
Documentation complète dans `glados2/docs/` :
- **USER_MANUAL.md** : Guide utilisateur complet
- **GRAMMAR.md** : Grammaire formelle BNF
- **COMPILATION.md** : Pipeline de compilation
- **SECURITY.md** : Analyse de sécurité
- **ACCESSIBILITY.md** : Fonctionnalités d'accessibilité

---

## ✅ Tests

Chaque partie contient des tests dans son répertoire `test/` :
- **glados1/test/** : Tests Scheme (.scm)
- **glados2/test/** : Tests Cedric (.cedric)

```bash
# Part 1
cd glados1 && stack test

# Part 2
cd glados2 && stack test
```

---

## 📄 Licence

MIT License - Voir fichiers LICENSE respectifs dans chaque sous-projet.
