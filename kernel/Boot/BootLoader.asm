[ORG 0]
[BITS 16]

SECTION .text
jmp 0x07C0:START

START:
    mov ax, cs
    mov ds, ax

    mov ax, 0xB800
    mov es, ax
    mov di, 0

    ; Configure Stack
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFE
    mov bp, 0xFFFE

CLEAR_DISPLAY:
    mov byte[es:di], 0
    mov byte[es:di + 1], 0x0A   ; 00001010
    add di, 2                   ; di += 2
    cmp di, 80 * 25 * 2         ; if (di < 80 * 25 * 2) goto CLEAR_DISPLAY
    jl CLEAR_DISPLAY            ; . . .

PRINT_INIT_TEXT:
    push CAPTION        ; PRINTSTRING(X, Y, STRING)
    push 0      ; Y(0)
    push 0      ; X(0)
    call PRINTSTRING

PRINTSTRING:
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cs
    push dx

    ; Setup Video Memory(0xB8000)
    mov ax, 0xB800
    mov es, ax

    ; Calculate character position [ di = ? ]
    ; Y Position(Line)
    mov ax, word[bp + 6]
    mov si, 2
    mul si
    mov di, ax

    ; X Position
    mov ax, word[bp + 4]
    mov si, 2
    mul si
    add di, ax

    ; String data
    mov si, word[bp + 8]
    PRINT_TEXT:
        mov cl, byte[si]
        cmp cl, 0           ; End of string :: 0
        je END_PRINT_TEXT   ; . . .

        mov byte[es:di], cl ; Print char[si]
        add si, 1
        add di, 2
        jmp PRINT_TEXT

    END_PRINT_TEXT:
        pop dx
        pop cx
        pop ax
        pop di
        pop si
        pop es
        pop bp
        ret 6

CAPTION: db 'Hello, World', 0

times 510 - ($ - $$) db 0x00
db 0x55, 0xAA