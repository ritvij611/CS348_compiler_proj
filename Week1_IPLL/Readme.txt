
How to Run
Build the executables: Run the following command to compile the assembly files and create executables:

For Assignment A Q11
Commands to be run:
nasm -f elf32 230101085_seta11.asm -o 230101085_seta11.o
ld -m elf_i386 -o 230101085_seta11 230101085_seta11.o
./230101085_seta11

Sample Input and Output (After Pressing Enter at last)


Enter Document:
abcffgg4455$$$%^&&%^%UUGUK

 1	NOTE: My comment wont appear in output(1 newline thats why empty line)
$ 3
% 3
& 2
4 2
5 2
G 1
K 1
U 3
^ 2
a 1
b 1
c 1
f 2
g 2

In output, frequency of characters and their occurences arranged in increasing ascii values.

For Assignment B Q4
Commands to be run:
nasm -f elf32 230101085_setb4.asm -o 230101085_setb4.o
ld -m elf_i386 -o 230101085_setb4 230101085_setb4.o
./230101085_setb4



Sample Input and Output(Enter input string in a single line and then press Enter):


ENTER DOCUMENT: 
ABHI&**(YVCDFGgvvasahzzzZZZ
BCIJ&**(ZWDEGHhwwbtbiAAAaaa



For Assignment B Q6
Commands to be run:
nasm -f elf32 230101085_setb6.asm -o 230101085_setb6.o
ld -m elf_i386 -o 230101085_setb6 230101085_setb6.o
./230101085_setb6

Sample Input and Output Format( Whole input matrix size and then all n* n elements should be entered into a single line starting with first row then second row and so on there should be a space separating 2 successive matrix elements)



Enter Matrix size, and elements in a single line first [0][0] then [0][1] then [0][2] and so on till [n-1][n-1]
3 1 2 3 4 5 6 7 8 9
1 4 7
2 5 8
3 6 9


