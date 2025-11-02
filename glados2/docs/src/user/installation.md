# Installation du Langage Cédric

Ce guide détaille toutes les étapes nécessaires pour **installer, compiler et exécuter** le projet **Cédric**, un langage compilé vers **WebAssembly** avec une **machine virtuelle Haskell**.

---

## 1. Prérequis système

Le projet a été testé sur :

- **Ubuntu / Debian / Arch Linux / Fedora Asahi**

### Outils nécessaires

| Outil | Version recommandée | Rôle |
|-------|----------------------|------|
| **GHC** | ≥ 9.0 | Compilateur Haskell |
| **Stack** | ≥ 2.9 | Gestionnaire de build |
| **make** | ≥ 4.0 | Automatisation des builds |
| **mdBook** | ≥ 0.4 | Génération de documentation |
| **git** | ≥ 2.30 | Gestion du code source |

---

## 2. Installation de Haskell et Stack

### Linux

```bash
curl -sSL https://get.haskellstack.org/ | sh
```

Si **curl** n'est pas installé :

```bash
sudo apt install curl
```

Pour vérifier l'installation :

```bash
stack --version
ghc --version
```

---

## 3. Cloner le dépôt

```bash
git clone git@github.com:EpitechPGE3-2025/G-FUN-500-TLS-5-1-glados-8.git
cd glados2
```

---

## 4. Compilation du projet

### Utiliser le Makefile

Le projet fournit un Makefile pratique :

```bash
make
```

ou séparément:

```bash
make glados2        # Compile le compilateur Cédric
make virtualmachine # Compile la VM
```

### Structure des exécutables

| Binaire | Rôle |
|---    |:-:    |
| ./glados2 | Transforme un fichier .cedric en .wasm|
| ./virtualmachine| Exécute un binaire .wasm sur la VM Cédric|

---

## 5. Exécution d'un programme Cédric

### Exemple simple

```bash
./glados2 test.cedric
./virtualmachine cedric.wasm
```

Résultat attendu :

```bash
0
```

---

## 6. Générer la documentation (mdBook)

### Installation de mdBook sur Linux

```bash
cargo install mdbook
```

Si cargo n'est pas installé :

```bash
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
```

Vérification :

```bash
mdbook --version
```

Générer le livre

```bash
cd docs
mdbook build
```

Les fichiers HTML seront générés dans **docs/book**.

Pour consulter la documentation localement :

```bash
mdbook serve
```

Puis ouvrez http://localhost:3000 dans votre navigateur.

---

## 7. Mise à jour

Pour récupérer les dernières versions :

```bash
git pull origin main
stack build
```
