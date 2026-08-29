# Compiler Lab (IPLL)

A collection of laboratory assignments completed as part of the **Implementation of Programming Languages Laboratory (CS348)**. This repository covers core concepts in programming language implementation, beginning with assembly language programming and progressing through assembler design, lexical analysis, and syntax analysis for a subset of the C programming language called **nanoC**.

## Repository Overview

The repository contains four major assignments:

| Week   | Topic                      | Technologies             |
| ------ | -------------------------- | ------------------------ |
| Week 1 | x86 Assembly Programming   | NASM, Linux System Calls |
| Week 2 | Assembler Design           | C                        |
| Week 3 | Lexical Analyzer for nanoC | Flex (Lex)               |
| Week 4 | Parser for nanoC           | Flex + Bison (Yacc)      |

The assignments gradually build the foundations of a compiler by moving through the early phases of language processing:

1. Assembly Programming
2. Assembler Construction
3. Lexical Analysis
4. Syntax Analysis

---

# Directory Structure

```text
IPLL/
│
├── Week1_IPLL/
│   ├── 230101085_seta11.asm
│   ├── 230101085_setb4.asm
│   ├── 230101085_setb6.asm
│   └── Readme.txt
│
├── Week2_IPLL/
│   ├── 230101085_onepass.c
│   ├── 230101085_twopass.c
│   ├── input.txt
│   └── Readme.txt
│
├── Week3_IPLL/
│   ├── a3_230101085.l
│   ├── a3_230101085_test.nc
│   ├── Assignment.md
│   ├── Makefile
│   └── Readme.txt
│
└── Week4_IPLL/
    ├── a4_230101085.l
    ├── a4_230101085.y
    ├── Makefile
    ├── README.md
    ├── test files
    └── generated parser files
```

---

# Week 1 – x86 Assembly Programming

This assignment focuses on low-level programming using NASM assembly language and Linux system calls.

## Programs Implemented

### 1. Character Frequency Counter

Reads an input document and computes the frequency of each character appearing in the input.

#### Features

* Reads arbitrary text input.
* Counts occurrences of every character.
* Displays frequencies sorted by ASCII value.
* Demonstrates array manipulation and character processing in assembly.

---

### 2. Document Transformation Program

Processes textual input according to assignment specifications.

#### Concepts Used

* String processing
* Character manipulation
* Conditional branching
* Memory addressing

---

### 3. Matrix Transposition

Reads an `n × n` matrix and prints its transpose.

#### Features

* Dynamic matrix size input.
* Matrix traversal using nested loops.
* Demonstrates multidimensional data handling in assembly.

#### Example

Input:

```text
3
1 2 3
4 5 6
7 8 9
```

Output:

```text
1 4 7
2 5 8
3 6 9
```

---

## Building Week 1 Programs

Example:

```bash
nasm -f elf32 230101085_seta11.asm -o program.o
ld -m elf_i386 -o program program.o
./program
```

---

# Week 2 – Assembler Design

This assignment implements both a **One-Pass Assembler** and a **Two-Pass Assembler** in C.

## One-Pass Assembler

A one-pass assembler processes source code in a single scan.

### Responsibilities

* Symbol table generation
* Address assignment
* Object code generation
* Handling forward references

### Concepts Demonstrated

* Symbol table management
* Opcode processing
* Address resolution
* Intermediate code generation

---

## Two-Pass Assembler

The assembler performs two scans over the source program.

### Pass 1

* Builds the symbol table.
* Assigns addresses.
* Calculates location counters.

### Pass 2

* Resolves symbols.
* Generates final machine/object code.
* Produces executable representation.

### Advantages

* Easier symbol resolution.
* Better handling of forward references.
* Cleaner implementation.

---

## Running

### Two-Pass Assembler

```bash
gcc 230101085_twopass.c -o twopass
./twopass
```

### One-Pass Assembler

```bash
gcc 230101085_onepass.c -o onepass
./onepass
```

### Assumption

Input is read from:

```text
input.txt
```

located in the same directory.

---

# Week 3 – Lexical Analyzer for nanoC

This assignment implements a lexer for **nanoC**, a subset of the C programming language.

## Objective

Convert source code into a stream of tokens while simultaneously building a symbol table and reporting lexical errors.

---

## Technologies

* Flex (Lex)
* C
* Make

---

## Tokens Recognized

### Keywords

Examples:

```c
int
float
char
while
for
if
return
static
```

### Identifiers

```c
count
temp
_result
```

### Constants

```c
10
45
3.14
'a'
```

### String Literals

```c
"Hello World"
```

### Operators

```c
+
-
*
/
==
!=
<=
>=
&&
||
```

### Punctuators

```c
;
,
(
)
{
}
[
]
```

---

## Symbol Table Generation

The lexer stores unique identifiers encountered during scanning.

Typical information recorded:

* Identifier name
* First occurrence
* Symbol table index

---

## Error Detection

The lexer detects and reports:

* Invalid identifiers
* Unterminated strings
* Invalid character constants
* Illegal symbols
* Unterminated comments

---

## Build and Run

```bash
make
make run
```

### Cleaning

```bash
make clean
```

---

## Outputs Generated

### Token Stream

```text
a3_230101085_token.txt
```

Contains token type and line information.

### Symbol Table

```text
a3_230101085_st.txt
```

Contains discovered identifiers.

---

# Week 4 – Parser for nanoC

This assignment extends the compiler front-end by implementing a parser for nanoC using Bison.

## Objective

Validate whether a token stream conforms to the grammar of nanoC.

---

## Technologies

* Flex
* Bison (Yacc)
* GCC
* Make

---

## Supported Language Constructs

### Declarations

```c
int x;
float y;
```

### Function Definitions

```c
int add(int a, int b)
{
    return a + b;
}
```

### Control Flow

```c
if
else
while
do-while
for
```

### Arrays

```c
int arr[10];
```

### Expressions

* Arithmetic
* Relational
* Logical
* Assignment

### Initializers

```c
int x = 5;
int arr[] = {1,2,3};
```

---

## Grammar Features

The parser supports:

* Translation units
* Declarations
* Function definitions
* Declarators
* Initializers
* Parameter lists
* Expressions
* Statements
* Compound statements

The grammar closely follows the nanoC specification derived from ISO C.

---

## Build

```bash
make clean
make
```

Generated files:

```text
lex.yy.c
y.tab.c
y.tab.h
parser
```

---

## Run

### Valid Program

```bash
make run
```

Expected:

```text
Parsing successful
```

### Lexer Error Test

```bash
make run-lexer-error
```

### Parser Error Test

```bash
make run-parser-error
```

---

## Generated Outputs

### Token File

```text
a4_230101085_token.txt
```

### Symbol Table

```text
a4_230101085_st.txt
```

---

# Concepts Covered

This repository demonstrates several important compiler construction concepts:

## Assembly Language

* Registers
* Memory addressing
* System calls
* String processing
* Matrix manipulation

## Assembler Design

* One-pass assembly
* Two-pass assembly
* Symbol tables
* Location counters
* Object code generation

## Lexical Analysis

* Regular expressions
* Tokenization
* Lexical errors
* Symbol table creation

## Syntax Analysis

* Context-free grammars
* Parsing
* Recursive grammar structures
* Error reporting
* Compiler front-end construction

---

# Prerequisites

For Linux/WSL:

```bash
sudo apt-get update
sudo apt-get install -y gcc make flex bison nasm
```

---

# Learning Outcomes

By completing these assignments, the following compiler construction topics are explored:

* Assembly language programming
* Assembler implementation
* Token generation
* Symbol table management
* Lexical analysis using Flex
* Syntax analysis using Bison
* Compiler front-end design
* Language grammar implementation

---

# Author

**Ritvij Gopal**

Implementation of Programming Languages Laboratory (CS348)

Department of Computer Science and Engineering

Indian Institute of Technology Guwahati
