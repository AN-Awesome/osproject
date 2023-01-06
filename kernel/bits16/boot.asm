[ORG 0x00]
[BITS 16]

SECTION .text
jmp 0x07C0:ENTRY

TOTALSECTORCOUNT:   dw 0x2

ENTRY:
    ; Entry Point Segment(DS)
    mov ax, 0x07C0
    mov ds, ax

    ; Video Memory Segment(FS)
    mov ax, 0xB800
    mov es, ax

    ; STACK POINTER(SS)
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFE  ; Stack Point
    mov bp, 0xFFFE  ; Base Point

CLEARSCREEN:
    mov si, 0
    LOOP_CLEARSCREEN:
        mov byte[es:si], 0
        mov byte[es:si+1], 0x0A
        add si, 2
        cmp si, 80 * 25 * 2
        jl LOOP_CLEARSCREEN

PRINT_CAPTION:
    push MSG1           ; STRING
    push 1              ; Y
    push 1              ; X
    call PRINT_TEXT
    add sp, 6

DISK_READ:
    ; [AH] 0x02(READ), 0x03(WRITE), 0x04(VERIFY), 0x0C(SEEK), 0x00(RESET)
    ; [AL] SECTOR COUNT FOR PROCESSING(ABLE TO PROCESS SEQUENTIAL SECTOR)
    ; [CH] CYLINDER NUMBER & 0xFF
    ; [CL] SECTOR NUMBER(BIT 0~5) | (CYNLINDER NUMBER & 0x300) >> 2
    ; [DH] HEAD NUMBER
    ; [DL] DRIVE NUMBER
    ; [ES:BX] BUFFER ADDRESS(IF IN VERYFING OR SEEKING, ISN'T REFER TO THIS VALUE)
    ; [FLAGS.CF] IF 0: NO ERROR(AH == 0)/ IF 1: ERROR. AH==$(ERROR_CODE == RESET)
    DISKRESET:
        mov ah, 0x00    ; BIOS function(AH=0x00(RESET))
        mov dl, 0       ; DRIVE NUMBER(0=Floppy)
        int 0x13        ; BIOS SERVICE: Disk I/O Service
        jc PROCESS_DISKERROR

        ; [ES:BX] = [0x1000:0x0000]
        mov ax, 0x1000
        mov es, ax
        mov bx, 0

        push MSG2           ; STRING
        push 3              ; Y
        push 1              ; X
        call PRINT_TEXT
        add sp, 6

        DISKREAD_CONFIG:
            mov di, word[TOTALSECTORCOUNT]

            push MSG4           ; STRING
            push 4              ; Y
            push 1              ; X
            call PRINT_TEXT
            add sp, 6

        PROCESS_DISK_READ:
        cmp di, 0
        je ENDPOINT_DISK_READ
        sub di, 1

        mov ah, 0x02    ; BIOS function(AH=0x02(READ))
        mov al, 1       ; SECTOR COUNT FOR PROCESSING(AL=1)
        mov ch, byte[TRACKNUMBER]   ; CYLINDER(TRACK) NUMBER
        mov cl, byte[SECTORNUMBER]  ; SECTOR NUMBER
        mov dh, byte[HEADNUMBER]    ; HEAD NUMBER
        mov dl, 0                   ; DRIVE NUMBER(0=Floppy)
        int 0x13        ; BIOS SERVICE: Disk I/O Service
        jc PROCESS_DISKERROR
            
        NEXT_SECTOR:
            add si, 0x0020    ; PER SECTOR(512MB = 0x200 --> Segment)
            mov es, si

            mov al, byte[SECTORNUMBER]
            add al, 0x01
            mov byte[SECTORNUMBER], al
            cmp al, 19
            jl PROCESS_DISK_READ

        HEAD_CONTROL:
            xor byte[HEADNUMBER], 0x0
            mov byte[SECTORNUMBER], 0x01

            cmp byte[HEADNUMBER], 0x00
            jne PROCESS_DISK_READ
            
        TRACK_CONTROL:
            add byte[TRACKNUMBER], 0x01
        jmp PROCESS_DISK_READ

    ENDPOINT_DISK_READ:
        push MSG5           ; STRING
        push 5              ; Y
        push 1              ; X
        call PRINT_TEXT
        add sp, 6

        jmp 0x1000:0x0000    

    PROCESS_DISKERROR:
        push MSG3           ; STRING
        push 4              ; Y
        push 1              ; X
        call PRINT_TEXT
        add sp, 6

        jmp $

PRINT_TEXT:
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

    CALCULATE_POSISION_X:
        mov ax, word[bp + 6]    ; [bp + 6] : Y Posision(Parameter_2)
        mov si, 160
        mul si
        mov di, ax

    CALCULATE_POSISION_Y:
        mov ax, word[bp + 4]    ; [bp + 4] : X Posision(Parameter_1)
        mov si, 2
        mul si
        add di, ax

    PROCESS_STRING_DATA:
        mov si, word[bp + 8]    ; [bp + 8] : String Data(Parameter_3)

    PROCESS_PRINT_TEXT:
        mov cl, byte[si]
        cmp cl, 0
        je ENDPOINT_PRINT_TEXT

        mov byte[es:di], cl
        add si, 1
        add di, 2
        jmp PROCESS_PRINT_TEXT
    
    ENDPOINT_PRINT_TEXT:
        pop dx
        pop cx
        pop ax
        pop di
        pop si
        pop es
        pop bp
        ret 

MSG1: db 'FIRE-EGG Operating System', 0
MSG2: db 'Disk initialize complete.', 0
MSG3: db 'Error', 0
MSG4: db 'Configuration information set complete..', 0
MSG5: db 'Disk read complete.', 0

SECTORNUMBER: db  0x02
HEADNUMBER: db  0x00
TRACKNUMBER: db  0x00

times 510 - ( $ - $$ ) db 0x00
db 0x55, 0xAA