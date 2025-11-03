# Overview of the Cédric Language

The **Cédric language** is a programming language designed to combine the **syntactic clarity** of imperative languages (inspired by C) with the **robustness** and **portability** of a modern compilation architecture.

Cédric is a **compiled**, **statically typed**, and **safe** language.

---

## 1. Philosophy and Goals

The design of Cédric is based on three core principles:

* **Syntactic Clarity:** We moved away from the complexity of S-expressions used in earlier stages to adopt a familiar, readable, and line-independent syntax (inspired by C).
* **Robustness and Safety:** By forbidding direct memory access (pointers) and enforcing **strong static typing**, Cédric eliminates many common security flaws found in low-level languages.
* **Performance and Portability:** By compiling to **WebAssembly (WASM)** bytecode, Cédric achieves near-native performance while maintaining universal portability.

---

## 2. Compilation Architecture

Cédric code execution follows a rigorous compilation pipeline:

1. **Source Code (.cedric):** Your program written in the Cédric syntax.  
2. **Compiler (`glados2`):** Built in Haskell, it performs type checking, code validation, and translates the AST into WASM bytecode.  
3. **WASM Bytecode (.wasm):** An intermediate binary format chosen for its safety (*sandboxing*) and speed.  
4. **Virtual Machine (`virtualmachine`):** Our Haskell-based WASM interpreter that executes bytecode in a secure, stack-based environment.

---

## 3. Getting Started

Here’s a simple example written in Cédric.  
Notice the use of the **`skibidi`** keyword for function declarations and the **explicit** return statement.

```cedric
skibidi main() {
  // Variable declarations with static typing
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

To start coding, check the [Installation](installation.md) section and explore the delaited [Syntax](syntax.md) rules of the Cedric language.
