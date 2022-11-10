[ORG 0]
[BITS 16]

jmp 0x07C0:START

CONFIGURE_DISK:
    TOTALSECTORNUMBER: dw 1024
    TRACKNUMBER: db 0x00
    SECTORNUMBER: db 0x02
    HEADNUMBER: db 0x00

START:
    mov ax, cs ; cs = 0x07C0
    mov ds, ax

    mov ax, 0xb800
    mov es, ax
    mov di, 0       ; INIT di

    ; CONFIG STACK
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFE
    mov bp, 0xFFFE

CLEAR_DISPLAY:
    mov byte[es:di], 0
    inc di
    mov byte[es:di], 0x0A
    inc di

    cmp si, 80 * 25 * 2
    jl CLEAR_DISPLAY

PRINT_INIT_TEXT:
    push TXT_CAPTION
    push 0      ; X(0)
    push 0      ; Y(0)
    call TEXT_PRINT
    add sp, 6

    push TXT_IMAGE_LOAD
    push 1      ; X(0)
    push 0      ; Y(0)
    call TEXT_PRINT
    add sp, 6

DISK_RESET:
    ; BIOS SERVICE : DISK RESET
    mov ax, 0x00       ; BIOS SERVICE NO_0(0x00)
    mov dl, 0       ; DRIVE NO_0(FLOPPY)
    int 0x13        ; DISK_IO_INTERRUPT : 0x13
    jc HANDLE_DISK_ERROR

    ; Address to Copy Image of OS: 0x10000(0x1000_Segment * 0x10 + 0x0000_OffSet)
    mov si, 0x1000  ; Segment
    mov es, si      ; . . .
    mov bx, 0       ; OffSet
    mov di, word[TOTALSECTORNUMBER]

DISK_READ:
    ; for (i = 1024; i >= 0; i--) / TOTALSECTORNUMBER--
    cmp di, 0           ; if (di == 0) goto DISK_READ_END
    je DISK_READ_END    ; . . .
    sub di, 1           ; di--

    ; BIOS SERVICE : READ SECTOR
    mov ah, 0x02                ; BIOS SERVICE NO_2(0x02)
    mov al, 1                   ; Count fo Sector to Read
    mov ch, byte[TRACKNUMBER]   ; Track Number to Read(0x00)
    mov cl, byte[SECTORNUMBER]  ; Sector Number to Read(0x02)
    mov dh, byte[HEADNUMBER]    ; Head Number to Read(0x00)
    mov dl, 0                   ; DRIVE NO_0(FLOPPY)
    int 0x13                    ; DISK_IO_INTERRUPT : 0x13
    jc HANDLE_DISK_ERROR

    ; READ(COUNT) DISK
    ; SECTOR NUMBER += 0x200(512 byte)
    add si, 0x0020 ; 0x200 = (Segment)0x20 * 0x10 + (Offset)0x00
    mov es, si

    mov al, byte[SECTORNUMBER]
    add al, 1
    mov byte[SECTORNUMBER], al
    cmp al, 19                  ; if (al < 19) goto DISK_READ
    jl DISK_READ                ; . . .

    ; HEAD COUNT
    xor byte[HEADNUMBER], 0x01      ; 0 -> 1 / 1 -> 0
    mov byte[SECTORNUMBER], 0x01    ; SECTOR_NUMBER = 1(Start from 1)

    cmp byte[HEADNUMBER], 0
    jne DISK_READ

    ; TRACK COUNT
    add byte[TRACKNUMBER], 1
    jmp DISK_READ
    
HANDLE_DISK_ERROR:
    push TXT_DISK_ERROR
    push 1      ; Y(1)
    push 20     ; X(20)
    call TEXT_PRINT
    jmp $

DISK_READ_END:
    push TXT_LOAD_COMPLETE
    push 1      ; X(1)
    push 20     ; Y(20)
    call TEXT_PRINT
    add sp, 6

    jmp 0x1000:0x0000       ; execute OS Image

TEXT_PRINT_FUNCTION:
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cs
    push dx

    ; Setup VMEM(0xB8000)
    mov ax, 0xB800
    mov es, ax

    ; Char_POSITION(X, Y)
    ; Y Position
    mov ax, word[bp + 6]
    mov si, 160
    mul si
    mov di, ax

    ; X Position
    mov ax, word[bp + 4]
    mov si, 2               ; 2 byte per character
    mul si
    add di, ax

    ; TEXT DATA
    mov si, word[bp + 8]

    TEXT_PRINT:
        mov cl, byte[si]
        cmp cl, 0
        je ENDPRINT

        mov byte[es:di], cl
        add si, 1
        add di, 2

        jmp TEXT_PRINT

    ENDPRINT:
        pop dx
        pop cx
        pop ax
        pop di
        pop si
        pop es
        pop bp
        ret

TEXT:
    TXT_CAPTION: db 'TEST OS BOOTLOADER', 0
    TXT_DISK_ERROR: db 'Disk Error', 0
    TXT_IMAGE_LOAD: db 'Image Loading..', 0
    TXT_LOAD_COMPLETE: db 'Complete', 0

times 510 - ($ - $$) db 0
db 0x55, 0xAA