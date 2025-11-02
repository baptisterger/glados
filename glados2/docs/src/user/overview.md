# Présentation du Langage Cédric

Le langage **Cédric** est un langage de programmation conçu pour allier la **clarté syntaxique** des langages impératifs (inspiré du C) à la **robustesse** et à la **portabilité** d'une architecture de compilation moderne.

Le Cédric est un langage compilé, **typé statiquement** et conçu pour être sûr.

---

## 1. Philosophie et Objectifs

La conception du Cédric repose sur trois piliers fondamentaux :

* **Clarté Syntactique :** Nous avons abandonné la complexité des S-expressions de la partie précédente pour adopter une syntaxe familière, lisible et non orientée ligne (inspirée du C).
* **Robustesse et Sécurité :** En interdisant l'accès direct à la mémoire (pointeurs) et en imposant un **typage statique fort**, le Cédric élimine les failles de sécurité courantes des langages de bas niveau.
* **Performance et Portabilité :** Grâce à la compilation vers le bytecode **WebAssembly (WASM)**, le Cédric offre une vitesse d'exécution proche du natif tout en garantissant une portabilité universelle.

---

## 2. Architecture de Compilation

L'exécution du code Cédric passe par un pipeline de compilation rigoureux :

1.  **Code Source (.cedric) :** Votre programme écrit dans la syntaxe Cédric.
2.  **Compilateur (`glados2`) :** Construit en Haskell, il vérifie le typage, l'intégrité du code, et traduit l'AST vers le bytecode WASM.
3.  **Bytecode WASM (.wasm) :** Le format binaire intermédiaire, idéal pour sa sécurité (*sandboxing*) et sa vitesse.
4.  **Machine Virtuelle (`virtualmachine`) :** Notre interpréteur WASM, construit en Haskell, qui exécute le bytecode dans un environnement sécurisé (*stack-based*).

---

## 3. Premiers Pas

Voici un aperçu du Cédric. Notez l'utilisation du mot-clé **`skibidi`** pour la déclaration des fonctions et le retour **explicite** de la valeur via `return`.

```cedric
skibidi main() {
  // Déclaration de variables avec typage statique
  float a = 3.14;
  int b = 2;
  float c = a * b + 1.0;

  bool ok = true;
  
  if (ok == true) {
    return 1;
  } else {
    return (-1);
  }
}
```

Pour commencer à coder, consultez la section [Installation](installation.md) et explorez les règles détaillées de la [Syntaxe](syntax.md) du Cédric.