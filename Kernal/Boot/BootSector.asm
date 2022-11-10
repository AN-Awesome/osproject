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
    mov es, ax ; es SET with di

mov di, 0
CLEAR_DISPLAY:
    mov byte[es:di], 0
    inc di
    mov byte[es:di], 0x0A

    add di, 2
    cmp si, 80 * 25 * 2
    jl CLEAR_DISPLAY

DISK_RESET:
    mov ax, 0
    mov dl, 0
    inc 0x13        ; DISK_IO_INTERRUPT : 0x13

DISK_READ:
    cmp word[TOTALSECTORNUMBER], 0
    je DISK_READ_END
    sub word[TOTALSECTORNUMBER], 1

    ;BIOS

HANDLE_DISK_ERROR:

DISK_READ_END:


times 510 - ($ - $$) db 0
db 0x55, 0xAA