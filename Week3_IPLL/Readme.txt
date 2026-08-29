Instructions to run the file:

make
make run

For cleaning outputs generated:
make clean

Assumptions considered while implementing the lexer:

The primary assumption is that i have printed the lexicall errors also in the token file itself.


Rest of assumptions are as follows:
1. **Input character set**: Source programs are provided in standard ASCII (no Unicode identifiers or literals). Any byte outside this range is treated as an unknown token.
2. **Keywords subset**: Only the 20 keywords listed in the assignment brief are reserved; everything else that matches the identifier regex is treated as an identifier.
3. **Identifiers**: Identifiers must start with a letter or underscore and may contain digits afterwards. Identifiers that start with digits (e.g., `123abc`) or are prefixed with `@` are reported as lexical errors and do not enter the symbol table.
4. **Integer constants**: Only non-zero-leading decimal integers (and the single literal `0`) are accepted; literals like `0123` are flagged as invalid to match the provided grammar fragment.
5. **Floating constants**: Fractional constants follow the `digit-sequenceopt . digit-sequence | digit-sequence .` forms. Exponential notation or suffixes are outside scope and will be tokenized as errors.
6. **Character constants**: Only single characters or escape sequences between single quotes are valid. Empty (`''`) or multi-character (`'ab'`) literals are explicitly reported as errors.
7. **String literals**: Strings must terminate on the same line. Encountering a newline before the closing quote produces an “unterminated string” error and increments the line counter once for that newline.
8. **Comments**: `/* ... */` comments do not nest. Unterminated block comments are reported as errors. `//` comments extend to the newline and are ignored.
9. **Symbol table**: The symbol table stores the first occurrence of each distinct identifier (maximum 1000 unique identifiers). If the limit is exceeded, an error is printed to stderr but scanning continues.
10. **File outputs**: Token and symbol-table outputs are regenerated on every lexer run. Subsequent runs overwrite the previous `a3_230101085_token.txt` and `a3_230101085_st.txt` files.

