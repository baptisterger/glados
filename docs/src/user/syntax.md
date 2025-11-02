# Syntaxe du Langage Cédric

Le Cédric adopte une syntaxe inspirée du C, tout en conservant la rigueur d'un langage de haut niveau.

---

## 1. Structure de Base

### Déclaration de Fonction
Toutes les fonctions sont déclarées à l'aide du mot-clé **`skibidi`**. Les blocs de code sont délimités par des **accolades `{}`**.

```cedric
skibidi add() {
  int a = 5;
  int b = 5;
  c = a + b;
  return c;
}
```

---

## 2. Types de Données

Cédric supporte trois types de base :

| Type | Description | Exemple |
|---    |:-:    |:-:    |
| int | Entiers | int x = 42; |
| float | Nomnres à virgule flottante | float pi = 3.14; |
| bool | Booléens | bool ok = true; |

---

## 3. Variables et Affectation

Déclaration d'une variable type :

```cedric
int a = 10;
float b = 3.14;
bool ok = true;
```

Affectation :

```cedric
a = 5;
b = b + 1.0;
ok = false;
```

Les variables doivent être déclarées avant usage.

---

## 4. Opérateurs

### Arithmétiques

```cedric
+  -  *  /  %
```

### Comparaison

```cedric
<  >  <=  >=
```

### Affectation

```cedric
=
```

Les opérateurs respectent les priorités standards (comme en C).

---

## 5. Conditions

La structure conditionnelle est simple et lisible :

```cedric
skibidi main() {
  bool ok = true;

  if (ok == true) {
    return 1;
  } else {
    return 0;
  }
}
```

- if **(condition) { ... } else { ... }**
- L’**else** est optionnel.
- Les conditions doivent toujours retourner un booléen.

Le langage Cédric est conçu pour être simple, lisible et sûr tout en gardant des fonctionnalités proches du C moderne.