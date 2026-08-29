section .data
    msg1 db "Enter Matrix size, and elements in a single line first [0][0] then [0][1] then [0][2] and so on till [n-1][n-1]", 10
    len1 equ $ - msg1

section .bss
    buffer  resb 1024
    buf_len resd 1
    buf_pos resd 1
    arr     resd 1024
    n       resd 1
    outbuf  resb 12

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, len1
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1024
    int 0x80
    mov [buf_len], eax
    mov dword [buf_pos], 0

    call input
    mov [n], eax

    mov ebx, eax
    imul eax, eax
    mov ecx, eax
    mov edi, arr
    

read_elements_loop:
    cmp ecx, 0
    je elements_done

    mov eax, [buf_pos]
    mov edx, [buf_len]
    cmp eax, edx
    jne have_data

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1024
    int 0x80
    mov [buf_len], eax
    mov dword [buf_pos], 0
    cmp eax, 0
    je elements_done

have_data:
    call input
    mov [edi], eax
    add edi, 4
    dec ecx
    jmp read_elements_loop

elements_done:
    mov eax, [n]
    mov ebx, eax
    imul eax, eax
    mov ecx, eax
    mov edi, arr
    xor esi, esi

    mov ebx, [n]
    xor esi, esi

print_outer:
    cmp esi, ebx
    je print_done

    xor ecx, ecx

print_inner:
    cmp ecx, ebx
    je next_row

    mov eax, ecx
    imul eax, ebx
    add eax, esi
    shl eax, 2

    mov edx, eax
    add edx, arr
    mov eax, [edx]

    mov edx, ebx
    dec edx
    cmp ecx, edx
    je print_nl_case

    call print_space
    jmp after_print

print_nl_case:
    call print_nl

after_print:
    inc ecx
    jmp print_inner

next_row:
    inc esi
    jmp print_outer

print_done:
	mov eax, 1
	mov ebx, 0
	int 0x80

input:
    push ebx
    push ecx
    push edx
    push esi

    mov esi, buffer
    mov ebx, [buf_pos]
    add esi, ebx

    xor eax, eax
parse_loop:
    mov bl, [esi]
    cmp bl, '0'
    jb maybe_done
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx
    inc esi
    jmp parse_loop

maybe_done:
skip_delims:
    mov bl, [esi]
    cmp bl, 0
    je update_pos
    cmp bl, 10
    je advance_delim
    cmp bl, 13
    je advance_delim
    cmp bl, ' '
    je advance_delim
    cmp bl, 9
    je advance_delim
    jmp update_pos

advance_delim:
    inc esi
    jmp skip_delims

update_pos:
    mov edx, esi
    mov ebx, buffer
    sub edx, ebx
    mov [buf_pos], edx

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

print_space:
    push ebx
    push ecx
    push edx
    push esi

    mov esi, outbuf
    add esi, 11
    mov byte [esi], ' '
    dec esi

    mov ebx, 10

convert_loop_s:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi], dl
    dec esi
    test eax, eax
    jnz convert_loop_s

    inc esi

    mov ecx, esi
    mov edx, outbuf + 12
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

print_nl:
    push ebx
    push ecx
    push edx
    push esi

    mov esi, outbuf
    add esi, 11
    mov byte [esi], 10
    dec esi

    mov ebx, 10

convert_loop_n:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi], dl
    dec esi
    test eax, eax
    jnz convert_loop_n

    inc esi

    mov ecx, esi
    mov edx, outbuf + 12
    sub edx, ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
