# Cédric Language Syntax

Cédric adopts a syntax inspired by C while maintaining the rigor of a high-level language.

---

## 1. Basic Structure

### Function Declaration
All functions are declared using the **`skibidi`** keyword.  
Code blocks are enclosed in **curly braces `{}`**.

```cedric
skibidi add() {
  int a = 5;
  int b = 5;
  c = a + b;
  return c;
}
```

## 2. Data types

Cédric supports three basic types:

| Type | Description | Example |
|---    |:-:    |:-:    |
| int | Integers | int x = 42; |
| float | Floating-point numbers | float pi = 3.14; |
| bool | Boolean values | bool ok = true; |


---

## 3. Variables and Assignment

Declaring typed variables:


```cedric
int a = 10;
float b = 3.14;
bool ok = true;
```

Assigning values :

```cedric
a = 5;
b = b + 1.0;
ok = false;
```

All variables must be declared before use.

---

## 4. Operators

### Arithmetics

```cedric
+  -  *  /  %
```

### Comparison

```cedric
<  >  <=  >=
```

### Assignment

```cedric
=
```

Operators follow standard precedence rules (similar to C).

---

## 5. Conditionals

Conditional structures are simple and readable:

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
- The **else** block is optionnal.
- Conditions must always evaluate to a boolean value.

The Cédric language is designed to be simple, readable, and safe, while preserving the familiar expressiveness of modern C-style programming.
