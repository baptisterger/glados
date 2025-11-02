# Gestion des Erreurs

La gestion des erreurs dans le compilateur Cédric vise à fournir des **messages clairs et localisés** pour aider à la correction rapide du code.

---

## 1. Types d’erreurs

### Erreurs lexicales

Caractère inconnu ou invalide.
```text
Erreur : caractère inattendu '@' à la ligne 3
```

### Erreurs syntaxiques

Structure du code invalide.

```text
Erreur : parenthèse fermante manquante à la ligne 8
```

### Erreurs sémantiques

Erreur de type ou d’usage de variable.

```text
Erreur : variable 'x' utilisée avant déclaration
```

## 2. Gestion dans le code

En Haskell, les erreurs sont propagées via le monade Either :

```haskell
parse :: String -> Either Error AST
```

## 3. Exemple

```cedric
int x = true;
```

```text
Erreur : impossible d’affecter un booléen à une variable de type int (ligne 1)
```

