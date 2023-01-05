[ORG 0x00]
[BITS 16]

SECTION .text
START:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    
    cli
    lgdt [GDTR]

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

    push (MSG1 - $$ + 0x10000)
    push 7
    push 1
    call PRINT_TEXT
    add esp, 12

    jmp 0x08: 0x10200

PRINT_TEXT:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push edx

    CALCULATE_POSISION_X:
        mov eax, dword[ebp + 12]    ; [bp + 6] : Y Posision(Parameter_2)
        mov esi, 160
        mul esi
        mov edi, eax

    CALCULATE_POSISION_Y:
        mov eax, dword[ebp + 8]    ; [bp + 4] : X Posision(Parameter_1)
        mov esi, 2
        mul esi
        add edi, eax

    PROCESS_STRING_DATA:
        mov esi, dword[ebp + 16]    ; [bp + 8] : String Data(Parameter_3)

    PROCESS_PRINT_TEXT:
        mov cl, byte[esi]
        cmp cl, 0
        je ENDPOINT_PRINT_TEXT

        mov byte[edi + 0xB8000], cl
        add esi, 1
        add edi, 2
        jmp PROCESS_PRINT_TEXT
    
    ENDPOINT_PRINT_TEXT:
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
    dd ( GDT - $$ + 0x10000 )

; GDT 테이블 정의
GDT:
    NULLDescriptor:
        dw 0x0000
        dw 0x0000
        db 0x00
        db 0x00
        db 0x00
        db 0x00

    CODEDESCRIPTOR:     
        dw 0xFFFF       ; Limit [15:0]
        dw 0x0000       ; Base [15:0]
        db 0x00         ; Base [23:16]
        db 0x9A         ; P=1, DPL=0, Code Segment, Execute/Read
        db 0xCF         ; G=1, D=1, L=0, Limit[19:16]
        db 0x00         ; Base [31:24]  
        
    DATADESCRIPTOR:
        dw 0xFFFF       ; Limit [15:0]
        dw 0x0000       ; Base [15:0]
        db 0x00         ; Base [23:16]
        db 0x92         ; P=1, DPL=0, Data Segment, Read/Write
        db 0xCF         ; G=1, D=1, L=0, Limit[19:16]
        db 0x00         ; Base [31:24]
GDTEND:

MSG1: db 'Mode switch complete', 0
times 512 - ( $ - $$ ) db 0x00