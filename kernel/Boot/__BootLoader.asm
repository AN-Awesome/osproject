[ORG 0]
[BITS 16]

SECTION .text
jmp 0x07C0:START

START:
    mov ax, 0x07C0
    mov ds, ax

    mov ax, 0xb800
    mov es, ax

mov si, 0

CLEARSCREEN:
    mov byte[es:si], 0
    mov byte[es:si+1], 0x0A

    add si, 2

    cmp si, 80 * 25 * 2
    jl CLEARSCREEN

jmp $

times 510 - ($ - $$) db 0
db 0x55, 0xAA