# GLaDOS - Generative Language and Distributed Operating System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![Documentation](https://img.shields.io/badge/docs-complete-success.svg)](docs/)

GLaDOS is a statically-typed programming language that compiles to WebAssembly. It features a clear, C-like syntax with modern safety features including memory safety, type safety, and sandboxed execution.

## Features

- 🔒 **Type Safety**: Static typing with explicit type declarations
- 🛡️ **Memory Safety**: No manual memory management, WASM bounds checking
- 📦 **WebAssembly Target**: Portable, fast, and secure execution
- 🎯 **Simple Syntax**: Clear, readable, and easy to learn
- ♿ **Accessible**: Designed with accessibility in mind
- 🧪 **Secure by Design**: Sandboxed execution, no code injection

## Quick Start

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd glados2

# Build with Stack
stack build

# Install
stack install
```

### Your First Program

Create `hello.cedric`:

```glados
skibidi main() {
  int x = 42;
  print(x);
}
```

Compile and run:

```bash
glados2 hello.cedric
wasmtime hello.wat
```

## Example Programs

### Simple Arithmetic

```glados
skibidi main() {
  int a = 10;
  int b = 20;
  int sum = a + b;
  print(sum);  // Outputs: 30
}
```

### Conditional Logic

```glados
skibidi main() {
  bool isReady = true;
  
  if (isReady == true) {
    print(1);  // Go!
  } else {
    print(0);  // Wait
  }
}
```

### Float Operations

```glados
skibidi main() {
  float pi = 3.14;
  float radius = 2.0;
  float area = pi * radius * radius;
  print(area);  // Outputs: 12.56
}
```

## Documentation

Comprehensive documentation is available in the `docs/` directory:

### 📚 Core Documentation

- **[User Manual](docs/USER_MANUAL.md)** - Complete guide to using GLaDOS
  - Installation and setup
  - Language features and syntax
  - Practical examples
  - Running programs
  
- **[Formal Grammar](docs/GRAMMAR.md)** - BNF grammar specification
  - Complete language syntax
  - Token definitions
  - Grammar validation examples
  
- **[Compilation Process](docs/COMPILATION.md)** - How the compiler works
  - Compilation pipeline
  - Each compilation phase explained
  - AST structure
  - WASM generation

### 🔐 Security & Quality

- **[Security Review](docs/SECURITY.md)** - Security features and analysis
  - Review of inspiration languages (C, JavaScript, Rust, Python, WASM)
  - Security features implemented
  - Threat model
  - Best practices
  
- **[Accessibility](docs/ACCESSIBILITY.md)** - Accessibility features
  - Documentation accessibility
  - Language design for accessibility
  - Assistive technology compatibility
  - Inclusive design principles

### 👨‍💻 Development

- **[Developer Manual](docs/DEVELOPER_MANUAL.md)** - Extending GLaDOS
  - Architecture overview
  - Adding new features
  - Testing guidelines
  - Contributing

## Project Structure

```
glados2/
├── app/
│   └── Main.hs              # Entry point
├── src/
│   ├── Ast.hs               # AST definitions
│   ├── Compiler.hs          # Code generation
│   ├── Lib.hs               # Library interface
│   ├── Wasm.hs              # WASM IR
│   └── WasmGenerator.hs     # WASM output
├── docs/
│   ├── USER_MANUAL.md       # User documentation
│   ├── GRAMMAR.md           # Language grammar
│   ├── COMPILATION.md       # Compilation details
│   ├── SECURITY.md          # Security analysis
│   ├── ACCESSIBILITY.md     # Accessibility guide
│   └── DEVELOPER_MANUAL.md  # Developer guide
├── test/
│   ├── *.cedric             # Test programs
│   └── Spec.hs              # Test suite
└── grammar.w3c.ebnf         # EBNF grammar
```

## Language Syntax Highlights

### Types
- `int` - 32-bit integers
- `float` - 32-bit floating point
- `bool` - Boolean values (`true` or `false`)

### Operators
- Arithmetic: `+`, `-`, `*`, `/`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Assignment: `=`

### Control Flow
- `if (condition) { ... }`
- `if (condition) { ... } else { ... }`

### Functions
- Declared with `skibidi` keyword
- Must have a `main()` function

## Building and Testing

```bash
# Build the project
stack build

# Run tests
stack test

# Run with a file
stack exec glados2 -- program.cedric

# Interactive mode (read from stdin)
stack exec glados2

# Clean build
stack clean
```

## Requirements

- **GHC**: 8.10 or higher
- **Stack**: Latest version
- **WASM Runtime**: wasmtime, wasmer, or Node.js

## Contributing

We welcome contributions! See the [Developer Manual](docs/DEVELOPER_MANUAL.md) for:

- Setting up your development environment
- Understanding the codebase
- Adding new features
- Testing guidelines
- Code style guide

## Security

GLaDOS takes security seriously. See [SECURITY.md](docs/SECURITY.md) for:

- Security features
- Threat model
- Reporting vulnerabilities
- Security best practices

## Accessibility

GLaDOS is designed to be accessible to all users. See [ACCESSIBILITY.md](docs/ACCESSIBILITY.md) for:

- Documentation accessibility
- Language design for accessibility
- Assistive technology support
- Reporting accessibility issues

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Inspiration

GLaDOS draws inspiration from several languages while prioritizing safety:

- **C**: Syntax and control flow structures
- **Rust**: Type safety and memory safety
- **WebAssembly**: Security model and portability
- **Python**: Readability and simplicity

## Roadmap

### Current (v0.1.0)
- ✅ Basic types (int, float, bool)
- ✅ Arithmetic and comparison operators
- ✅ If-else statements
- ✅ Function declarations
- ✅ WASM compilation
- ✅ Return values

### Planned (v0.2.0)
- ⏳ While loops
- ⏳ String support
- ⏳ Function parameters
- ⏳ Arrays

### Future (v1.0.0)
- 🔮 Structs
- 🔮 Modules
- 🔮 Standard library
- 🔮 Package manager
- 🔮 IDE integration

## Authors

- GLaDOS Development Team

## Acknowledgments

- The Haskell community
- WebAssembly working group
- All contributors and testers
- Accessibility consultants

## Support

- **Documentation**: See `docs/` directory
- **Issues**: Open a GitHub issue
- **Discussions**: Use GitHub Discussions

---

**Made with ♿ accessibility in mind**  
**Built with ❤️ by the GLaDOS team**
