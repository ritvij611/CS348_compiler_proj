section .data
command db "Enter Document:", 10
length equ $ - command
 
section .bss
buffer resb 500
freq   resd 256
 
section .text
global _start
 
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, command
    mov edx, length
    int 0x80
 
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 500
    int 0x80
 
    mov esi, buffer
    mov edx, eax
 
cnt:
    cmp edx, 0
    je pr
 
    mov al, [esi]
    mov bl, al
    push esi
    mov esi, freq
 
inner:
    cmp bl, 0
    je done
    add esi, 4
    dec bl
    jmp inner
 
done:
    inc dword [esi]
    pop esi
    inc esi
    dec edx
    jmp cnt
 
pr:
    mov ecx, 0
 
loop:
    cmp ecx, 256
    jge exit
 
    mov eax, [freq + ecx*4]
    cmp eax, 0
    jle next
 
    mov [buffer], cl
    mov byte [buffer+1], ' '
 
    push ecx
 
    mov esi, buffer+2
    mov edi, 0
    mov ebx, 10
    cmp eax, 0
    jne digloop
 
    mov byte [esi], '0'
    mov edi, 1
    jmp fin
 
 digloop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi+edi], dl
    inc edi
    cmp eax, 0
    jne digloop
 
fin:
    mov ecx, edi
    shr ecx, 1
    mov edx, 0
 
inloop:
    cmp edx, ecx
    jge finale
 
    mov eax, edi
    dec eax
    sub eax, edx
 
    mov bl, [esi+eax]
    mov al, [esi+edx]
    mov [esi+edx], bl
    mov [esi+eax], al
 
    inc edx
    jmp inloop
 
finale:
    mov byte [buffer+2+edi], 10
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, edi
    add edx, 3
    int 0x80
 
    pop ecx
 
next:
    inc ecx
    jmp loop
 
exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

