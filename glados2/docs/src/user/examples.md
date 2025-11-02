# Exemples de programmes en Cédric

Cette section présente plusieurs exemples simples et commentés en **langage Cédric**, pour vous aider à comprendre la syntaxe, la structure et les comportements fondamentaux du langage.

---

## Exemple 1 : Programme minimal

Le point d’entrée d’un programme Cédric est toujours la fonction `main()`.

```cedric
skibidi main() {
  return 0;
}
```

---

## Exemple 2 : Variables et opérations arithmétiques

Voici un programme complet qui déclare des variables, effectue des calculs et utilise un if :

```cedric
skibidi main() {
  float a = 3.14;
  int b = 2;
  float c = a * b + 1.0;

  bool ok = true;
  bool fail = false;

  if (ok == true) {
    return 1;
  } else {
    return (-1);
  }

  return 0;
}
```

# Explication

- **float a = 3.14;** déclare un nombre à virgule flottante.

- **int b = 2;** déclare un entier.

- **float c = a * b + 1.0;** effectue un calcul arithmétique standard.

- **bool ok = true;** et bool fail = false; définissent des booléens.

- La structure conditionnelle **if (...) { ... } else { ... }** choisit un bloc selon la valeur de ok.

---

## Exemple 3 : Erreurs de typage

Le langage Cédric est statiquement typé : une variable ne peut pas changer de type.

```cedric
skibidi main() {
  int a = 3;
  a = true;   // Erreur : bool assigné à un int
  return a;
}
```

---

## Exemple 4 : Erreurs de typage

| Opérateur | Description | Exemple | Résultat |
|---    |:-:    |:-:    |:-:    |
| + | Addition | 3 + 4 | 7 |
| - | Soustraction | 10 - 2 | 8 |
| * | Multiplication | 5 * 6 | 30 |
| / | Division | 8 / 2 | 4 |
| = | Égalité | x = 5 | 5 |
| <, >, <=, >= | Comparaisons | a < b| Booléen |

