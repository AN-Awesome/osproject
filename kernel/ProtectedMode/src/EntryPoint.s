[ORG 0]
[BITS 16]

SECTION .text
START:
    mov ax, 0x1000      ; Start Address Segment(0x10000)
    mov ds, ax          ; ds, es = ax
    mov es, ax          ; . . .

    cli                 ; Disable interrupt(Clear Interrupt Flag)
    lgdt [GDTR]         ; Set the GDTR & load GDT Table

    ; Enter the Protected Mode
    ; PG[0]/CD[1]/NW[0]/RESERVED_AREA[0/0000/0000/0]/AM[0]/RESERVED_AREA[0]/WP[0]/RESERVED_AREA[0000/0000/00]/NE[1]/ET[1]/TS[1]/EM[0]/MP[1]/PE[1]
    mov eax, 0x4000003B 
    mov cr0, eax        ; CR0_Control Register = SETTED FLAGS & SWITCH MODE

    jmp dword dx08: (PROTECTEDMODE - $$ + 0x10000)

; ENTER PROTECTED MODE
[BITS 32]
PROTECTEDMODE:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fx, ax
    mov gs, ax

    ; Configure Stack
    mov ss, ax
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    ; Complete Message

    jmp $

    PRINTSTRING:
    push ebp
    mov ebp, esp

    ; Calculate character position [ di = ? ]
    ; Y Position(Line)
    mov eax, word[ebp + 6]    ; [bp + 6] = Y position
    mov esi, 160
    mul esi
    mov edi, eax

    ; X Position
    mov ax, word[bp + 4]    ; [bp + 4] = X position
    mov si, 2
    mul si
    add di, ax

    ; String data
    mov si, word[bp + 8]    ; [bp + 8] = String

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
        ret 8