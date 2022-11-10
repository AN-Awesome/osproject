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

CLEAR_DISPLAY:
    mov byte[es:di], 0
    inc di
    mov byte[es:di], 0x0A

    add di, 2
    cmp si, 80 * 25 * 2
    jl CLEAR_DISPLAY

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

DISK_READ_END:


times 510 - ($ - $$) db 0
db 0x55, 0xAA