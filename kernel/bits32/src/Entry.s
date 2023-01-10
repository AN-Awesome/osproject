[ORG 0x00]
[BITS 16]

SECTION .text

ENTRY:
    mov ax, 0x1000  ; ENTRY SEGMENT(0x10000) -> AX, ES
    mov ds, ax
    mov es, ax

    ; Activate Gate A20
    mov ax, 0x2401  ; 0x2401: Activate Gate A20
                    ; if SUCCESS :: EFLAGS.CF(BIT) = 0, AH = 0
                    ;    FAIL    :: EFLAGS.CF(BIT) = 1, AH = 0x80 or 0x86
    int 0x15        ; BIOS SERVICE: MEMORY SIZE FUNCTIONS

    jc GATE_A20_ERROR       ; IF ERROR:: GOTO GATE_A20_ERROR
    jmp GATE_A20_PROCESS    ; IF NOT:: GOTO GATE_A20_PROCESS

    GATE_A20_ERROR:         ; When an error occurs, try switching to the system control port
        in al, 0x92     ; Read 1 byte from the system control port (0x92) and store it in the AL register.
        or al, 0x02     ; Set the A20 gate bit (bit 1) to 1 on the read value.
        and al, 0xFE    ; Set bit 0 to 0 by ANDing with 0xFE to prevent system reset.
        out 0x92, al    ; Set the changed value to the system control port (0x92) as 1 byte.

    GATE_A20_PROCESS:
        cli             ; Disable interrupts
        lgdt [GDTR]     ; Load the GDT table by setting the GDTR data structure to the processor.

        ; ENTER TO 32 BIT MODE(PROTECTED MODE)
        ; DISABLE PAGING, DISABLE CACHE
        ; INTERNAL FPU
        ; DISABLE ALIGN CHECK
        ; ENABLE PROTECT MODE(32 BIT)
        mov eax, 0x4000003B     ; FLAG SETUP
                                ; PG: 0, CD: 1, NW: 0, AM: 0, WP: 0, NE: 1, ET: 1, TS: 1, EM: 0, MP: 1, PE: 1
        mov cr0, eax            ; SWITCH MODE

        ; 32BIT KERNEL CODE DESCRIPTOR(0x18) :: TO ENTRY32 LABEL
        ; CS SEGMENT SELECTOR :: EIP(Reset based on 0x00)
        jmp dword 0x18: (ENTRY32 - $$ + 0x10000)

[BITS 32]
ENTRY32:
    mov ax, 0x20    ; DATA SEGMENT DESCRIPTOR FOR 32 BIT MODE(0x20) -> DS, ES, FS, GS
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; STACK POINTER(SS)
    mov ss, ax
    mov esp, 0xFFFE     ; SIZE:: ~ FFFF
    mov ebp, 0xFFFE     ; SIZE:: ~ FFFF

    push (MSG1 - $$ + 0x10000)
    push 7
    push 1
    call PRINTMESSAGE
    add esp, 12

    ; Move to address 0x10200(32 Bit C Object Bin. Point)
    jmp dword 0x18: 0x10200

PRINTMESSAGE:
    push ebp
    mov ebp, esp

    push esi
    push edi
    push eax
    push ecx
    push edx

    CALCULATE_CHAR_AXIS:
        mov eax, dword [ebp + 12]   ; [bp + 12] : Y Posision(Parameter_2)
        mov esi, 160
        mul esi
        mov edi, eax

        mov eax, dword [ebp + 8]     ; [bp + 8] : X Posision(Parameter_1)
        mov esi, 2
        mul esi
        add edi, eax

    mov esi, dword [ebp + 16]       ; [bp + 16] : String Data(Parameter_3)

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

; Align the following data according to 8 bytes.
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

    IA32E_CODEDESCRIPTOR:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 0x9A
        db 0xAF
        db 0x00

    IA32E_DATADESCRIPTOR:
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 0x92
        db 0xAF
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

MSG1: db '3', 0x0E, '2', 0x0E, ' ', 0x0E, 'K', 0x0E, 'e', 0x0E, 'r', 0x0E, 'n', 0x0E, 'e', 0x0E, 'l', 0x0E, ' ', 0x0E, 'M', 0x0E, 'o', 0x0E, 'd', 0x0E, 'e', 0x0E, ' ', 0x0E, 'S', 0x0E, 'w', 0x0E, 'i', 0x0E, 't', 0x0E, 'c', 0x0E, 'h', 0x0E, ' ', 0x0E, 'C', 0x0E, 'o', 0x0E, 'm', 0x0E, 'p', 0x0E, 'l', 0x0E, 'e', 0x0E, 't', 0x0E, 'e', 0x0E, 0

times 512 - ( $ - $$ ) db 0x00 