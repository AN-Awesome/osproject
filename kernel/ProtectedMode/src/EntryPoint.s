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

    jmp dword 0x08: (PROTECTED_MODE - $$ + 0x10000)

; ENTER PROTECTED MODE
[BITS 32]
PROTECTED_MODE:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Configure Stack
    mov ss, ax
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    ; Print Text
    push (MODE_SWITCH_COMPLETE - $$ + 0x10000)
    push 3
    push 0
    call PRINTSTRING

    jmp dword 0x08: 0x10200

PRINTSTRING:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push edx

    ; Calculate character position [ di = ? ]
    ; Y Position(Line)
    mov eax, dword[ebp + 12]    ; [bp + 6] = Y position
    mov esi, 160
    mul esi
    mov edi, eax

    ; X Position
    mov eax, dword[ebp + 8]    ; [bp + 4] = X position
    mov esi, 2
    mul esi
    add edi, eax

    ; String data
    mov esi, dword[ebp + 16]    ; [bp + 8] = String

    PRINT_TEXT:
        mov cl, byte[esi]
        cmp cl, 0x0E           ; End of string :: 0
        je END_PRINT_TEXT   ; . . .

        mov byte[edi + 0xB8000], cl ; Print char[si]

        add esi, 1
        add edi, 2
        jmp PRINT_TEXT

    END_PRINT_TEXT:
        pop edx
        pop ecx
        pop eax
        pop edi
        pop esi
        pop ebp
        ret 12

align 8, db 0
dw 0x0000

GDTR:
    dw GDTEND - GDT - 1
    dd (GDT - $$ + 0x10000)

GDT:
    NullDescriptor:
        dw 0x0000, 0x0000
        db 0x00, 0x00, 0x00, 0x00

    CodeDescriptor:
        dw 0xFFFF, 0x0000
        db 0x00, 0x9A, 0xCF, 0x00

    DataDescriptor:
        dw 0xFFFF, 0x0000
        db 0x00, 0x92, 0xCF, 0x00

GDTEND:

STRING_DAT:
    MODE_SWITCH_COMPLETE: db 'Mode switch process completed', 0

times 512 - ($ - $$) db 0