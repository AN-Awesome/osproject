[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0: START
START:
    mov ax, 0x07C0
    mov ds, ax

    mov ax, 0xB800
    mov es, ax

mov si, 0

CLEAR_SCREEN:
    mov byte[es:si], 0

    add si, 2
    cmp si, 80 * 25 * 2
    jl CLEAR_SCREEN

mov si, 0
mov byte[es:si], 'H'
add si, 2
mov byte[es:si], 'i'

jmp $
times 510 - ($ - $$) db 0x00
db 0x55, 0xAA