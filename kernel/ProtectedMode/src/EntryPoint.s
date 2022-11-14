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