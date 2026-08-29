section .data
msg db "ENTER DOCUMENT: ", 10
len equ $ - msg
 
section .bss
buffer resb 1000
tmp resb 1
 
section .text
	global _start
 
_start:
    Print:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len
    int 0x80
    Take_Input:
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1000
    int 0x80
    mov esi, buffer
    mov edx, eax
    Loop_start:
    cmp edx, 0
    je Exit
    push ecx
    push edx
    mov al, [esi]
    cmp al, 'Z'
	je ZZ
    cmp al, 'z'
    je zz
    cmp al, 'A'
    jb Special
    cmp al, 'Z'
    jb Do
    cmp al, 'z'
    jg Special
    cmp al, 'a'
    jge Do
    
    Lo:
    mov [tmp], al
    mov eax, 4
    mov ebx, 1
    mov ecx, tmp
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    inc esi
    dec edx
    jmp Loop_start
    ; Output:
    ; mov edx, eax
    ; mov eax, 4
    ; mov ebx, 1
    ; int 0x80
    Special:
    jmp Lo
    Do:
    inc al
    jmp Lo
    ZZ: 
    mov al, 'a'
    jmp Lo
    zz:
    mov al, 'A'
    jmp Lo
    Exit:
    mov eax ,1
    mov ebx, 0
    int 0x80