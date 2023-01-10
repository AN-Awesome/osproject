[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:ENTRY

TOTALSECTORCOUNT : dw 0x02

ENTRY:
    ; Entry Point Segment(DS)
    mov ax, 0x07C0
    mov ds, ax

    ; Video Memory Segment(ES)
    mov ax, 0xB800
    mov es, ax
    
    ; STACK POINTER(SS)
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFE
    mov bp, 0xFFFE

CLEARSCREEN:
    mov si, 0

    LOOP_SCREENCLEARLOOP:
        mov byte [es:si], 0
        mov byte [es:si+1], 0x0F
        add si, 2

        cmp si, 80 * 25 * 2
        jl LOOP_SCREENCLEARLOOP

PRINT_CAPTION:
    push MSG1           ; STRING
    push 1              ; Y
    push 1              ; X
    call PRINTMESSAGE
    add sp, 6

    push MSG2           ; STRING
    push 3              ; Y
    push 1              ; X
    call PRINTMESSAGE
    add sp, 6

DISKREAD:
    ; [AH] 0x02(READ), 0x03(WRITE), 0x04(VERIFY), 0x0C(SEEK), 0x00(RESET)
    ; [AL] SECTOR COUNT FOR PROCESSING(ABLE TO PROCESS SEQUENTIAL SECTOR)
    ; [CH] CYLINDER NUMBER & 0xFF
    ; [CL] SECTOR NUMBER(BIT 0~5) | (CYNLINDER NUMBER & 0x300) >> 2
    ; [DH] HEAD NUMBER
    ; [DL] DRIVE NUMBER
    ; [ES:BX] BUFFER ADDRESS(IF IN VERYFING OR SEEKING, ISN'T REFER TO THIS VALUE)
    ; [FLAGS.CF] IF 0: NO ERROR(AH == 0)/ IF 1: ERROR. AH==$(ERROR_CODE == RESET)
    INIT_DISK:
        mov ah, 0x00            ; BIOS function(AH=0x00(RESET))
        mov dl, 0               ; DRIVE NUMBER(0=Floppy)
        int 0x13                ; BIOS SERVICE: Disk I/O Service
        jc HANDLEDISKERROR

        push MSG3               ; STRING
        push 4                  ; Y
        push 1                  ; X
        call PRINTMESSAGE
        add sp, 6

    ; [ES:BX] = [0x1000:0x0000]
    mov si, 0x1000
    mov es, si
    mov bx, 0x0000

    mov di, word [TOTALSECTORCOUNT]

    push MSG4           ; STRING
    push 5              ; Y
    push 1              ; X
    call PRINTMESSAGE
    add sp, 6

    DISK_READ:
        cmp di, 0
        je ENDPOINT_DISK_READ
        sub di, 0x1
        
        mov ah, 0x02                    ; BIOS function(AH=0x02(READ))
        mov al, 0x1                     ; SECTOR COUNT FOR PROCESSING(AL=1)
        mov ch, byte [TRACKNUMBER]      ; CYLINDER(TRACK) NUMBER
        mov cl, byte [SECTORNUMBER]     ; SECTOR NUMBER
        mov dh, byte [HEADNUMBER]       ; HEAD NUMBER
        mov dl, 0                       ; DRIVE NUMBER(0=Floppy)
        int 0x13                        ; BIOS SERVICE: Disk I/O Service
        jc HANDLEDISKERROR
        
        NEXT_SECTOR:
            add si, 0x0020                  ; PER SECTOR(512MB = 0x200 --> Segment)
            mov es, si

            mov al, byte [SECTORNUMBER]
            add al, 0x01
            mov byte [SECTORNUMBER], al
            cmp al, 37
            jl DISK_READ

        HEAD_CONTROL:
            xor byte [HEADNUMBER], 0x01
            mov byte [SECTORNUMBER], 0x01

            cmp byte [HEADNUMBER], 0x00
            jne DISK_READ

        TRACK_CONTROL:
            add byte [TRACKNUMBER], 0x01

        jmp DISK_READ        
    ENDPOINT_DISK_READ:
        push MSG5
        push 5
        push 24
        call PRINTMESSAGE
        add sp, 6

        jmp 0x1000:0x0000
    HANDLEDISKERROR:
        jmp $

PRINTMESSAGE:
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cx
    push dx

    mov ax, 0xB800
    mov es, ax

    CALCULATE_CHAR_AXIS:
        mov ax, word [bp + 6]   ; [bp + 6] : Y Posision(Parameter_2)
        mov si, 160
        mul si
        mov di, ax

        mov ax, word [bp + 4]   ; [bp + 4] : X Posision(Parameter_1)
        mov si, 2
        mul si
        add di, ax

    mov si, word [bp + 8]       ; [bp + 8] : String Data(Parameter_3)

    LOOP_PRINT_CHAR:
        mov cl, byte [si]

        cmp cl, 0
        je ENDPOINT_PRINT

        mov byte [es:di], cl
        
        add si, 1
        add di, 1

        jmp LOOP_PRINT_CHAR

    ENDPOINT_PRINT:
        pop dx
        pop cx
        pop ax
        pop di
        pop si
        pop es
        pop bp
        ret

MSG1: db 'A', 0x0B, 'W', 0x0B, 'E', 0x0B, 'S', 0x0B, 'O', 0x0B, 'M', 0x0B, 'E', 0x0B, ' ', 0x0B, 'O', 0x0B, 'S', 0x0B, 0
MSG2: db 'B', 0x0F, 'o', 0x0F, 'o', 0x0F, 't', 0x0F, ' ', 0x0F, 'S', 0x0F, 'y', 0x0F, 's', 0x0F, 't', 0x0F, 'e', 0x0F, 'm', 0x0F, ' ', 0x0F, 'L', 0x0F, 'o', 0x0F, 'a', 0x0F, 'd', 0x0F, ' ', 0x0F, 'C', 0x0F, 'o', 0x0F, 'm', 0x0F, 'p', 0x0F, 'l', 0x0F, 'e', 0x0F, 't', 0x0F, 'e', 0x0F, '.', 0x0F, 0
MSG3: db 'D', 0x0F, 'i', 0x0F, 's', 0x0F, 'k', 0x0F, ' ', 0x0F, 'I', 0x0F, 'n', 0x0F, 'i', 0x0F, 't', 0x0F, ' ', 0x0F, 'C', 0x0F, 'o', 0x0F, 'm', 0x0F, 'p', 0x0F, 'l', 0x0F, 'e', 0x0F, 't', 0x0F, 'e', 0x0F, '.', 0x0F, 0
MSG4: db 'D', 0x0D, 'i', 0x0D, 's', 0x0D, 'k', 0x0D, ' ', 0x0D, 'R', 0x0D, 'e', 0x0D, 'a', 0x0D, 'd', 0x0D, ' ', 0x0D, 'P', 0x0D, 'r', 0x0D, 'o', 0x0D, 'c', 0x0D, 'e', 0x0D, 's', 0x0D, 's', 0x0D, 'i', 0x0D, 'n', 0x0D, 'g', 0x0D, '.', 0x0D, 0
MSG5: db '>', 0x0A, '>', 0x0A, ' ', 0x0A, 'C', 0x0A, 'O', 0x0A, 'M', 0x0A, 'P', 0x0A, 'L', 0x0A, 'E', 0x0A, 'T', 0x0A, 'E', 0x0A, ' ', 0x0A, '<', 0x0A, '<', 0x0A, 0

SECTORNUMBER:   db 0x02
HEADNUMBER:     db 0x00
TRACKNUMBER:    db 0x00

times 510 - ( $ - $$ ) db 0x00

db 0x55, 0xAA