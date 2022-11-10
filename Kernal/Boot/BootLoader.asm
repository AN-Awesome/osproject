[ORG 0]
[BITS 16]

jmp 0x07C0:START
START:
    mov ax, cs
    mov ds, ax

    mov ax, 0xb800
    mov es, ax
    mov di, 0

    mov byte [es:di], 'O'
    inc di

    mov byte [es:di], 0x06
    inc di

    mov byte [es:di], 'S'
    inc di

    mov byte [es:di], 0x06
    inc di

    mov byte [es:di], '!'
    inc di

    mov byte [es:di], 0x06
    inc di

END:
    hlt         ; Kill
    jmp END

times 510 - ($ - $$) db 0
db 0x55, 0xAA