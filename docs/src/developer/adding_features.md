# Ajouter de nouvelles fonctionnalités

Cette section explique comment étendre le langage **Cédric** en ajoutant de nouvelles fonctionnalités, qu’il s’agisse de nouvelles instructions, opérateurs ou structures syntaxiques.

---

## 1. Comprendre la structure du compilateur

Le compilateur de Cédric est organisé en plusieurs modules principaux :

- **Lexer** : découpe le code source en *tokens*.
- **Parser** : convertit les tokens en arbre syntaxique (AST).
- **Semantic Analyzer** : vérifie la cohérence des types et des identificateurs.
- **Code Generator (WASM)** : traduit l’AST en instructions WebAssembly.
- **Runtime** : gère les fonctions intégrées, la mémoire et l’exécution.

Avant d’ajouter une nouvelle fonctionnalité, il est essentiel de comprendre où elle s’insère dans cette chaîne.

---

## 2. Étapes pour ajouter une fonctionnalité

1. **Mettre à jour le lexer**
   - Ajouter les nouveaux mots-clés ou symboles dans la table des tokens.
   - Exemple :
     ```rust
     Token::NewKeyword => "newkw"
     ```

2. **Modifier le parser**
   - Ajouter la nouvelle règle grammaticale correspondante.
   - Exemple :
     ```rust
     Expr::NewFeature(node) => parse_new_feature(tokens)
     ```

3. **Vérifier la sémantique**
   - Implémenter les vérifications de type et de portée.

4. **Étendre la génération de code**
   - Ajouter les instructions WASM ou l’équivalent dans le générateur.

5. **Mettre à jour la documentation et les tests**
   - Ajouter des exemples dans `/examples`.
   - Mettre à jour les pages du manuel utilisateur.

---

## 3. Exemple : ajout d’un opérateur `**` (puissance)

```c
// Exemple de code Cédric
var x = 2 ** 8; // 256
```
- Lexer : ajouter Token::Power.
- Parser : gérer la précédence entre * et **.
- CodeGen : générer une boucle ou un appel à pow.

---

## 4. Tester votre ajout

Utilisez :

```bash
cargo test
```

ou, si vous travaillez dans le répertoire du compilateur :

```bash
cargo run -- examples/power_test.cd
```

---

## 5. Faire une Pull Request

- Forkez le dépôt.
- Créez une branche nommée feature/nom-fonctionnalité.
- Ajoutez un test minimal.
- Décrivez clairement la modification dans le message de commit.