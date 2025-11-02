# Machine Virtuelle (VM)

La **VM Cédric** est une machine à pile (*stack-based virtual machine*) qui exécute le bytecode WebAssembly généré par le compilateur.

---

## 1. Fonctionnement

Chaque opération manipule une **pile d’exécution**.  
Exemple :  

```ASM
PUSH 3
PUSH 2
ADD
```

Résultat → `5` sur la pile.

---

## 2. Registres et pile

- **Pile (stack)** : stocke les valeurs intermédiaires  
- **Mémoire** : segment réservé pour les variables locales  
- **Compteur d’instructions (PC)** : index de l’instruction actuelle

---

## 3. Exemple d’exécution

Code source :
```cedric
return 2 + 3;
```

Bytecode simplifié :

```ASM
PUSH 2
PUSH 3
ADD
RET
```

Execution :

```bash
./virtualmachine test.wasm
```

---

## 4. VM Bonus Python

Une version bonus en Python permet d’exécuter directement les fichiers .wasm :

```bash
python vm.py test.wasm
```

Cette VM lit le binaire WebAssembly, décode les instructions et les exécute séquentiellement.

---

## Ressources

- [WASM Execution Model](https://developer.mozilla.org/en-US/docs/WebAssembly/Guides/Concepts)
