# Compilation du Langage Cédric

Le compilateur Cédric traduit le code source `.cedric` en bytecode WebAssembly `.wasm`. Module d'encodage de structures WebAssembly en format binaire .wasm. Transforme des AST Haskell en bytecode WebAssembly valide.

---

## 1. Pipeline de Compilation

```text
Code source (.cedric)
        ↓
Analyse lexicale → Analyse syntaxique → AST
        ↓
Analyse sémantique (types, symboles)
        ↓
Génération de code (WASM)
```

---

## 2. Constantes

**wasmMagic** et **wasmVersion**

```WASM
wasmMagic = [0x00, 0x61, 0x73, 0x6D]    -- "\0asm"
wasmVersion = [0x01, 0x00, 0x00, 0x00]  -- Version 1
```

En-tête obligatoire de tout fichier WebAssembly. Les 4 premiers octets identifient le format (\0asm), les 4 suivants indiquent la version du format (version 1 actuellement).

---

## 3. Fonctions d'encodage de base

```haskell
encodeULEB128 :: Int -> [Word8]
```

Encode un entier non signé en format ULEB128 (encodage compact à longueur variable). Les petits nombres (< 128) utilisent 1 octet, les plus grands utilisent plusieurs octets.
Exemples : 42 → [0x2A], 128 → [0x80, 0x01]

```haskell
encodeSLEB128 :: Int -> [Word8]
```

Encode un entier signé en format SLEB128 (version signée de ULEB128). Gère les nombres négatifs avec extension de signe. 
Exemples : 42 → [0x2A], -42 → [0x56]

```haskell
encodeString :: String -> [Word8]
```

Encode une chaîne en format WebAssembly : longueur (ULEB128) + octets UTF-8. 
Exemple : "main" → [0x04, 0x6D, 0x61, 0x69, 0x6E]

---

## 4. Encodage de types et instructions

```haskell
encodeType :: WasmType -> Word8
```

Convertit un type WebAssembly en son opcode : I32 → 0x7F, F32 → 0x7D.

```haskell
encodeInstr :: WasmInstr -> [Word8]
```

Encode une instruction WebAssembly en octets (opcode + opérandes). Exemples : I32Const 42 → [0x41, 0x2A], I32Add → [0x6A], LocalGet 0 → [0x20, 0x00] Supporte : constantes, variables locales, opérations arithmétiques, contrôle de flux (if/else), appels.

```haskell
encodeFuncType :: [WasmType] -> Maybe WasmType -> [Word8]
```

Encode la signature d'une fonction : 0x60 + nombre_params + types_params + nombre_results + type_result. Exemple : (i32, i32) → i32 devient [0x60, 0x02, 0x7F, 0x7F, 0x01, 0x7F]

--- 

## 5. Encodage de structures complexes

```haskell
encodeLocals :: [WasmType] -> [Word8]
```

Encode les variables locales en les regroupant par type pour optimiser la taille. Utilise groupConsecutive pour compacter : [I32, I32, F32] → [(2, I32), (1, F32)]

```haskell
groupConsecutive :: Eq a => [a] -> [(Int, a)]
```

Utilitaire qui regroupe les éléments identiques consécutifs avec leur compte. Utilise span pour séparer puis récurse sur le reste.
Exemple : [I32, I32, F32, F32, I32] → [(2, I32), (2, F32), (1, I32)]

```haskell
encodeFuncBody :: WasmFunc -> [Word8]
```

Encode le corps d'une fonction : taille + variables_locales + instructions + 0x0B (end). Format : [taille] [locals] [instrs...] [0x0B]

---

## 6. Sections et module

```haskell
encodeSection :: Word8 -> [Word8] -> [Word8]
```

Encapsule une section : [section_id] [taille_ULEB128] [contenu]. IDs principaux : 0x01 (Type), 0x03 (Function), 0x07 (Export), 0x0A (Code).

```haskell
encodeWasmModule :: WasmModule -> BS.ByteString
```

Assemble le module complet : magic + version + sections (Type, Function, Export, Code). Génère les 4 sections principales avec toutes les fonctions du module. Convertit le résultat en ByteString avec BS.pack pour l'écriture efficace.

```haskell
generateWasmFile :: WasmModule -> FilePath -> IO ()
```

Point d'entrée principal : encode le module et l'écrit dans un fichier .wasm. Affiche un message de confirmation après génération. Exemple : generateWasmFile myModule "output.wasm"

---

## 7. Opcodes de référence

### Types

**i32 → 0x7F, f32 → 0x7D**

### Instructions principales

- Contrôle : if → 0x04, else → 0x05, end → 0x0B, return → 0x0F, call → 0x10
- Variables : local.get → 0x20, local.set → 0x21
- Constantes : i32.const → 0x41, f32.const → 0x43
- Arithmétique : i32.add → 0x6A, i32.mul → 0x6C, i32.eq → 0x46
- Pile : drop → 0x1A

---

## 8. Structure d'un fichier .wasm

```text
[0x00 0x61 0x73 0x6D]  ← Magic "\0asm"
[0x01 0x00 0x00 0x00]  ← Version 1
[Section Type]          ← Signatures de fonctions
[Section Function]      ← Indices des types
[Section Export]        ← Exports ("main")
[Section Code]          ← Corps des fonctions
```

---

## 9. Exemple d'utilisation

```haskell
-- Fonction qui retourne 42
let func = WasmFunc 
  { funcParams = [], funcResult = Just I32
  , funcLocals = [], funcBody = [I32Const 42, Return] }

let module = WasmModule { wasmFunctions = [func] }

generateWasmFile module "output.wasm"
-- Génère: "WASM binary generated: output.wasm"
```

---

## 10. Dépendances

```haskell
Data.Word           -- Types Word8 pour octets
Data.Bits           -- Opérations bit à bit
Data.ByteString     -- Manipulation efficace de données binaires
Data.Binary.Put     -- Sérialisation binaire (floats)
Wasm                -- Types WebAssembly (WasmModule, WasmFunc, etc.)
```

---

## Ressources

- [Spécification WebAssembly](https://webassembly.github.io/spec/)
- [Format binaire](https://webassembly.github.io/spec/core/binary/index.html)
- [LEB128 encoding](https://en.wikipedia.org/wiki/LEB128)
