# GLaDOS - LISP Interpreter in Haskell

## Part 1: Lots of Irritating Superfluous Parentheses (LISP)

For this first part of the project you must implement a minimalist LISP interpreter. To be more precise, when not specified otherwise in this document, your language must behave just like Chez-Scheme. It will be evaluated during the first Defense of this project.

In the rare occasion of you being one of those humans who think he's faster than everyone else, and you are already at part 2 before even the first defense, you MUST still have the LISP clone code available (on a separate branch of your git, or as an option of your latest build).

**Failure to do so will result in you not having cake at your first defense, nor points nor credits either.**

Also, be sure to read the following warning. Repetition is key.

**Part 0 is absolutely mandatory for every defense**
**Failure to comply will result in an 'unsatisfactory' mark on your official testing record.**

## Syntax

Being a LISP, this first language must be represented by Symbolic-Expressions. At the bare minimum your parser must be able to handle:

**3 Atoms:**
- Signed Integers in base 10
- Symbols (any string which is not a number)

**3 Lists:**
- started by an open parenthesis, ended by a close parenthesis
- contains zero, one or any number of sub-expressions separated by spaces, tabs, carriage returns or parenthesis.

Examples of valid S-Expressions:
```scheme
foo
42
(1 2 3)
(( foo bar baz )
(1 2 3) ()
((((1(2) 3) )))
)
```

## Invocation and error handling

Your program must be able to read your language code from standard input. You are free to add more and fancier way to invoke it (from files given as arguments, with a full featured REPL, etc.).

```bash
$> cat foo.scm
(define foo 21)
(* foo 2)
$> ./glados < foo.scm
42
```

You must stop the execution as soon as an error occurs and return a 84 status code. You're free to display any meaningful information on the standard output or error output.

```bash
$> cat error.scm
(* foo 2)
$> ./glados < error.scm
*** ERROR : variable foo is not bound.
$> echo $?
84
```

## Core concepts

At the bare minimum your program must handle the following concepts:

### Types

**3 You language must support 64 bit integers and boolean values.**
**3 Boolean values must be represented by the "#t" and "#f" symbols, for True and False respectively.**
**3 As a consequence of being a functional language, it must also support a procedure type (more information about that bellow)**

Optionally, you are free to implement more types (for example: lists).

### Bindings

You must implement a way to define an association (binding) between a symbol and a value (which can be seen as having variables, to be able to store them and reuse them afterwards). When a symbol is bound to a value, it evaluates to this value. Trying to evaluate an unbound symbol produces an error.

The define notation is a special form which binds an expression to a symbol:
```scheme
(define <SYMBOL> <EXPRESSION>)
```

**Example:**
```bash
> foo
*** ERROR : variable foo is not bound.
> (define foo 42)
> foo
42
```

### User defined functions and lambda

You must define a way to represent (and call) functions, being anonymous ones (lambdas) or named ones. Functions must be able to take parameters (or none).

A function call (application) is simply a list with the callee (the operator) placed in first place, the other elements of the list being the arguments (the operands). This is the default behavior when a list doesn't match with a special form.

**Example:**
```bash
$> cat call.scm
(div 10 2)
$> ./glados call.scm
5
```

#### Lambdas

A lambda is a special form composed of a (possibly empty) list of parameters and a body.
The body is an expression, which will be evaluated when the lambda is called, within a context where the parameters will take the values of the arguments provided during invocation.

A lambda has the following form:
```scheme
(lambda (<ARG1> <ARG2> ... <ARGN>) <BODY>)
```

**Examples:**
```bash
$> cat lambda1.scm
(lambda (a b) (+ a b))
$> ./glados < lambda1.scm
#<procedure>

$> cat lambda2.scm
((lambda (a b) (+ a b)) 1 2)
$> ./glados < lambda2.scm
3

$> cat lambda3.scm
(define add
  (lambda (a b)
    (+ a b)))
(add 3 4)
$> ./glados < lambda3.scm
7
```

#### Named functions

In this language named functions are just syntactic sugar added to the define notation. The following example produces the same result as "lambda3.scm" above:

```scheme
(define (<FUNC_NAME> <ARG1> <ARG2> ... <ARGN>) <BODY>)
```

**Example:**
```bash
$> cat function1.scm
(define (add a b)
  (+ a b))
(add 3 4)
$> ./glados < function1.scm
7
```

Named functions must be capable to call themselves, to allow recursion.

### Conditional expressions

You must define a way to represent conditions using a if notation, which contains a conditional expression followed by two more expressions. The first of these expressions is evaluated and returned if the condition is true, otherwise the second is evaluated and returned.

It must have the form:
```scheme
(if <CONDITION> <THEN> <ELSE>)
```

Where CONDITION, THEN and ELSE are three arbitrarily complex sub-expressions.

**Examples:**
```bash
$> cat if1.scm
(if #t 1 2)
$> ./glados < if1.scm
1

$> cat if2.scm
(if #f 1 2)
$> ./glados < if2.scm
2

$> cat if3.scm
(define foo 42)
(if (< foo 10)
    (* foo 3)
    (div foo 2))
$> ./glados < if3.scm
21
```

You are free to implement the cond notation too but it's not mandatory.

### Builtin functions

You've seen some of them already in the examples, but in order to make your language (barelly) usable, you must implement some functions which will be hardcoded in your interpreter:

**3 Predicates, which take two arguments and evaluates to a boolean value:**
- "eq?" (returns true if its two arguments are equal, false otherwise)
- "<" (returns true if the first argument is strictly lower than the second, false otherwise)

**3 Aritmethic operators, which take two arguments and return an integer:**
- "+", "-", "*"
- "div" (division) and "mod" (modulo)

Even if they are represented by a single special character, they are just symbols bound to a function and behave like any user defined functions.

**Examples:**
```bash
$> cat builtins1.scm
(+ (* 2 3) (div 10 2))
$> ./glados < builtins1.scm
11

$> cat builtins2.scm
(eq? (* 2 5) (- 11 1))
$> ./glados < builtins2.scm
#t

$> cat builtins3.scm
(< 1 (mod 10 3))
$> ./glados < builtins3.scm
#f
```

## Examples

Given all the rules above, Your lisp interpreter should be able, for example, to process the following programs:

```bash
$> cat superior.scm
(define (> a b)
  (if (eq? a b)
      #f
      (if (< a b)
          #f
          #t)))
(> 10 -2)
$> ./glados < superior.scm
#t
```

```bash
$> cat factorial.scm
(define (fact x)
  (if (eq? x 1)
      1
      (* x (fact (- x 1)))))
(fact 10)
$> ./glados < factorial.scm
3628800
```

Think about your code structure, and data structure. You will probably reuse some parts of your code for the Part2

---

## Implementation Details

### Project Architecture

#### `/app/Main.hs`
**Main entry point** of the application.
- Handles command line arguments
- Reads Scheme files or standard input
- Parses source code with the parser
- Evaluates expressions sequentially
- Displays results or errors
- Handles output with appropriate error codes (84 for errors)

**Main functions:**
- `main :: IO ()`: Main function that orchestrates execution
- `runEval :: Env -> LispVal -> IO ()`: Evaluates an expression and displays the result
- `evalSeq :: Env -> [LispVal] -> IO ()`: Evaluates a sequence of expressions
- `printResult :: LispVal -> IO ()`: Formats and displays LISP values

#### `/src/Types.hs`
**Central type definitions** for the interpreter.

**Main types:**
- `LispVal`: Represents all possible LISP values
  - `Atom String`: Symbols and variables
  - `Number Integer`: Integer numbers
  - `Bool Bool`: Boolean values (#t/#f)
  - `List [LispVal]`: LISP lists
  - `Proc Procedure`: User-defined procedures
  - `Builtin ([LispVal] -> EvalM LispVal)`: Built-in functions

- `Procedure`: Structure for user functions
  - Parameters, function body, and closure environment

- `LispError`: Possible error types
  - `UnboundVar String`: Undefined variable
  - `TypeError String`: Type error
  - `NumArgs Int [LispVal]`: Incorrect number of arguments

- `Env`: Environment type (`Map String LispVal`)
- `EvalM`: Evaluation monad (`ExceptT LispError (ReaderT Env IO)`)

#### `/src/Parser.hs`
**Syntactic analysis** of LISP code.

**Parser functions:**
- `parseExpr :: Parser LispVal`: Main parser for S-expressions
- `parseBool :: Parser LispVal`: Parses `#t` and `#f` literals
- `parseNumber :: Parser LispVal`: Parses signed integers
- `parseAtom :: Parser LispVal`: Parses symbols and attempts number parsing
- `parseList :: Parser LispVal`: Parses lists `(expr1 expr2 ...)`

**Features:**
- Handles whitespace (spaces, tabs, newlines)
- Supports nested lists
- Properly parses symbols and numbers
- Error handling for malformed expressions

#### `/src/Eval.hs`
**Expression evaluation** engine.

**Evaluation functions:**
- `eval :: LispVal -> EvalM LispVal`: Main evaluation function
- `initialEnv :: Env`: Initial environment with built-in functions

**Built-in functions:**
- Arithmetic: `+`, `-`, `*`, `div`, `mod`
- Predicates: `<`, `eq?`

**Special forms:**
- `define`: Variable and function definition
- `lambda`: Anonymous function creation
- `if`: Conditional expressions

**Features:**
- Lexical scoping with closures
- Recursion support for named functions
- Proper error handling and reporting
- Environment management for variable bindings

### Building and Running

#### Prerequisites
- GHC (Glasgow Haskell Compiler)
- Stack (Haskell Tool Stack)

#### Build
```bash
stack build
```

#### Run
```bash
# From file
./glados < program.scm

# From stdin (interactive)
echo "(+ 1 2)" | ./glados

# With file argument
./glados program.scm
```

### Testing

The `test/` directory contains various test files:
- `builtins*.scm`: Built-in function tests
- `call.scm`: Function calling test
- `error.scm`: Error handling test
- `factorial.scm`: Recursive function test
- `foo.scm`: Basic variable test
- `function*.scm`: Named function tests
- `if*.scm`: Conditional expression tests
- `lambda*.scm`: Anonymous function tests
- `superior.scm`: Complex function definition test

## Development Notes

The implementation uses monadic error handling with `ExceptT` and `ReaderT` to manage evaluation context and error propagation. The parser is built using Parsec, providing robust error messages and composable parsing logic.

Key design decisions:
- Immutable data structures for safety
- Monadic composition for clean error handling
- Separate parsing and evaluation phases
- Extensible built-in function system
- Support for closures and lexical scoping

#### `/src/Parser.hs`
**Analyseur syntaxique** qui transforme le texte en structures de données.

Utilise la bibliothèque Parsec pour implémenter :
- `parseBool` : Parse les booléens (#t, #f)
- `parseNumber` : Parse les entiers (avec support des nombres négatifs)
- `parseAtom` : Parse les symboles et identifiants
- `parseList` : Parse les listes entre parenthèses
- `parseExpr` : Point d'entrée principal du parseur

**Caractéristiques :**
- Gestion des espaces blancs
- Support de la syntaxe Scheme standard
- Gestion des caractères spéciaux dans les identifiants

#### `/src/Eval.hs`
**Évaluateur** qui exécute les expressions Scheme parsées.

**Fonctions built-in supportées :**
- Arithmétiques : `+`, `-`, `*`, `div`, `mod`
- Comparaison : `<`, `eq?`

**Constructions du langage :**
- `define` : Définition de variables et fonctions
- `lambda` : Création de fonctions anonymes
- `if` : Expressions conditionnelles
- Appels de fonctions

**Fonctionnalités avancées :**
- Support de la récursion (avec `fix` pour les fonctions récursives)
- Gestion des environnements avec clôtures lexicales
- Évaluation paresseuse appropriée

### `/test/`
**Fichiers de test** contenant des exemples de code Scheme :

- `factorial.scm` : Implémentation récursive de la factorielle
- `lambda*.scm` : Tests des fonctions lambda
- `if*.scm` : Tests des expressions conditionnelles  
- `function*.scm` : Tests de définition de fonctions
- `builtins*.scm` : Tests des fonctions built-in
- `call.scm`, `error.scm` : Tests d'appels et gestion d'erreurs

## Utilisation

### Compilation
```bash
stack build
```

### Exécution

**Avec un fichier :**
```bash
stack exec Glados test/factorial.scm
```

**Avec l'entrée standard :**
```bash
echo "(+ 1 2)" | stack exec Glados
```

### Exemples

**Définition et appel de fonction :**
```scheme
(define (square x) (* x x))
(square 5)
```

**Fonction récursive :**
```scheme
(define (fact n)
  (if (eq? n 1)
      1
      (* n (fact (- n 1)))))
(fact 5)
```

**Fonctions lambda :**
```scheme
((lambda (x y) (+ x y)) 3 4)
```

## Fonctionnalités Supportées

- ✅ Types de base : entiers, booléens, symboles, listes
- ✅ Opérations arithmétiques et de comparaison
- ✅ Définition de variables et fonctions
- ✅ Fonctions lambda
- ✅ Expressions conditionnelles (if)
- ✅ Récursion
- ✅ Environnements lexicaux (closures)
- ✅ Gestion d'erreurs robuste

## Technologies Utilisées

- **Haskell** : Langage de programmation principal
- **Parsec** : Bibliothèque de parsing
- **Stack** : Outil de build et gestion de dépendances
- **Monades** : ExceptT et ReaderT pour la gestion d'état et d'erreurs
- **Data.Map** : Structures de données efficaces pour les environnements

Ce projet démontre l'élégance de Haskell pour implémenter des interpréteurs grâce à son système de types expressif et ses abstractions puissantes comme les monades.
