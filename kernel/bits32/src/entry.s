[ORG 0X00]  ; 시작주소 0X00
[BITS 16]   ; 16비트 코드로 작성

SECTION .text   ; text 섹션

START:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    cli
    lgdt [ GDTR ]

    mov eax, 0x4000003B
    mov cr0, eax

    jmp dword 0x08: (ENTRY32 - $$ + 0x10000)

[BITS 32]
ENTRY32:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ss, ax
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    push ( SWITCHSUCCESSMESSAGE - $$ + 0x10000 )
    push 7
    push 1
    call PRINTMESSAGE
    add esp, 12

    jmp dword 0x08: 0x10200

PRINTMESSAGE:
    push ebp
    mov ebp, esp

    push esi
    push edi
    push eax
    push ecx
    push edx

    CALCULATE_CHAR_AXIS:
        mov eax, dword [ebp + 12]   ; [bp + 6] : Y Posision(Parameter_2)
        mov esi, 160
        mul esi
        mov edi, eax

        mov eax, dword [ebp + 8]     ; [bp + 4] : X Posision(Parameter_1)
        mov esi, 2
        mul esi
        add edi, eax

    mov esi, dword [ebp + 16]       ; [bp + 8] : String Data(Parameter_3)

    LOOP_PRINT_CHAR:
        mov cl, byte [esi]

        cmp cl, 0
        je ENDPOINT_PRINT

        mov byte [edi + 0xB8000], cl
        
        add esi, 1
        add edi, 1

        jmp LOOP_PRINT_CHAR

    ENDPOINT_PRINT:
        pop edx
        pop ecx
        pop eax
        pop edi
        pop esi
        pop ebp
        ret

align 8, db 0
dw 0x0000

GDTR:
    dw GDTEND - GDT - 1
    dd ( GDT - $$ + 0X10000 )

GDT:
    NULLDescriptor:
        dw 0x0000
        dw 0x0000
        db 0x00
        db 0x00
        db 0x00
        db 0x00

    CODEDESCRIPTOR:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 0x9A
        db 0xCF
        db 0x00

    DATADESCRIPTOR:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 0x92
        db 0xCF
        db 0x00
GDTEND:

SWITCHSUCCESSMESSAGE: db '3', 0x0E, '2', 0x0E, ' ', 0x0E, 'K', 0x0E, 'e', 0x0E, 'r', 0x0E, 'n', 0x0E, 'e', 0x0E, 'l', 0x0E, ' ', 0x0E, 'M', 0x0E, 'o', 0x0E, 'd', 0x0E, 'e', 0x0E, ' ', 0x0E, 'S', 0x0E, 'w', 0x0E, 'i', 0x0E, 't', 0x0E, 'c', 0x0E, 'h', 0x0E, ' ', 0x0E, 'C', 0x0E, 'o', 0x0E, 'm', 0x0E, 'p', 0x0E, 'l', 0x0E, 'e', 0x0E, 't', 0x0E, 'e', 0x0E, 0

times 512 - ( $ - $$ ) db 0x00 