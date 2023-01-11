[BITS 16]

SECTION .text
jmp 0x07C0:ENTRY

ENTRY:
    mov ax, 0x07C0
    mov ds, ax

times 510 ($ - $$) db 0x00
db 0x55, 0xAA