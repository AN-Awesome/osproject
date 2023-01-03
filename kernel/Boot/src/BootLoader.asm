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

INIT_SCREEN:
    mov byte[es:di], 0
    mov byte[es:di + 1], 0x0A   ; BLINK: 0 / BACKGROUND: 000 / BRIGHTNESS: 1 / TEXTCOLOR: 010
    add di, 2                   ; di += 2
    cmp di, 80 * 25 * 2         ; if (si < 80 * 25 * 2) goto CLEAR_DISPLAY
    jl INIT_SCREEN              ; . . .

    PRINT_INIT_TEXT:
        push CAPTION        ; String
        push 0              ; Y(0)
        push 0              ; X(0)
        call PRINTSTRING    ; PRINTSTRING(X, Y, String)

SETUP_DISK:
    PRINT_IMAGE_LOAD_TEXT:
        push OSIMAGELOADINGMESSAGE  ; String
        push 1                      ; Y(0)
        push 0                      ; X(0)
        call PRINTSTRING            ; PRINTSTRING(X, Y, String)

    CONFIG:
        TOTALSECTORCOUNT: dw 0x02 ;프로텍티드모드 전환후 수정 1024 -> 0x02
        SECTORNUMBER: db 0x02
        HEADNUMBER: db 0x00
        TRACKNUMBER: db 0x00

    DISK_RESET:
        mov ax, 0   ; BIOS SERVICE_0(RESET)
        mov dl, 0   ; DRIVE NUMBER_0(FLOPPY)
        int 0x13    ; GENERATE DISK IO INTERRUPT(0x13)
        jc HANDLE_DISK_IO_ERROR

    ; Address to copy OS Image: 0x10000(0x1000 * 0x10 + 0x0000)
    mov si, 0x1000
    mov es, si
    mov bx, 0x0000
    mov di, 1024

    DISK_READ:
        cmp di, 0           ; if (di == 0) goto DISK_READ_END
        je DISK_READ_END    ; . . .
        sub di, 1           ; for (i = 1024_SECTOR; i > 0; i--)

        mov ah, 0x02                ; BIOS SERVICE_2(READ SECTOR)
        mov al, 1                   ; COUNT OF SECTOR TO READ_1
        mov ch, byte[TRACKNUMBER]   ; NUMBER OF TRACK TO READ_0x00
        mov cl, byte[SECTORNUMBER]  ; NUMBER OF SECTOR TO READ_0x02
        mov dh, byte[HEADNUMBER]    ; NUMBER OF HEAD TO READ_0x00
        mov dl, 0                   ; DRIVE NUMBER_0(FLOPPY)
        int 0x13                    ; GENERATE DISK IO INTERRUPT(0x13)
        jc HANDLE_DISK_IO_ERROR

        add si, 0x20    ; next part of sector(+= 512 byte(Segment_0x200))
        mov es, si

        ; SECTOR COUNT
        mov al, byte[SECTORNUMBER]
        add al, 1
        mov byte[SECTORNUMBER], al
        cmp al, 19
        jl DISK_READ

        ; HEAD COUNT(TOGGLE/ 0->1, 1->0)
        xor byte[HEADNUMBER], 0x01
        mov byte[SECTORNUMBER], 0x01    ; RESET SECTOR NUMBER_1

        cmp byte[HEADNUMBER], 0x00
        jne DISK_READ

        ; TRACK COUNT
        add byte[TRACKNUMBER], 0x01
        jmp DISK_READ

    DISK_READ_END:
        push OSIMAGELOADCOMPLETEMESSAGE     ; String
        push 2                              ; Y(0)
        push 0                              ; X(0)
        call PRINTSTRING                    ; PRINTSTRING(X, Y, String)

        ; Jump to OS Image(0x10000)
        jmp 0x1000:0x0000
        hlt

    HANDLE_DISK_IO_ERROR:
        push OSIMAGELOADERRORMESSAGE        ; String
        push 2                              ; Y(0)
        push 0                              ; X(0)
        call PRINTSTRING                    ; PRINTSTRING(X, Y, String)

        jmp $       

PRINTSTRING:
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cx
    push dx

    ; Setup Video Memory(0xB8000)
    mov ax, 0xB800
    mov es, ax

    ; Calculate character position [ di = ? ]
    ; Y Position(Line)
    mov ax, word[bp + 6]    ; [bp + 6] = Y position
    mov si, 160
    mul si
    mov di, ax

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

STRING_DAT:
    CAPTION: db 'TSAW OS', 0
    OSIMAGELOADINGMESSAGE: db 'Image Loading..', 0
    OSIMAGELOADCOMPLETEMESSAGE: db 'Load Complete..', 0
    OSIMAGELOADERRORMESSAGE: db 'Error', 0

times 510 - ($ - $$) db 0x00
db 0x55, 0xAA

; times 1474560-($-$$) db 0