# Génération WebAssembly

Le compilateur Cédric produit du code **WebAssembly (WASM)** lisible et exécutable dans un navigateur ou une VM.

---

## 1. Principe

Chaque fonction, variable et expression du code Cédric est traduite en instructions WASM équivalentes.

---

## 2. Exemple

Code source :
```cedric
skibidi main() {
  int a = 5;
  int b = 2;
  return a * b + 1;
}
```

Généré en WebAssembly :

```WASM
(func $main (result i32)
  (local $a i32)
  (local $b i32)
  i32.const 5
  set_local $a
  i32.const 2
  set_local $b
  get_local $a
  get_local $b
  i32.mul
  i32.const 1
  i32.add
  return
)
```

---

## 3. Exécution

Exécution possible avec la VM Haskell :

```bash
./virtualmachine test.wasm
```

Ou avec la VM python :

```bash
python wm.py test.wasm
```

---

## 4. Objectif futur

- Support complet des fonctions natives
- Ajout des structures (struct)
- Compatibilité avec WebAssembly System Interface (WASI)

---

## Ressources

- [WABT WebAssembly Binary Toolkit](https://github.com/WebAssembly/wabt)
