[ORG 0x00]              ; 코드의 시작 어드레스 0x00으로 설정
[BITS 16]               ; 16비트로 작성

SECTION .text           ; text섹션 정의
START:
    mov ax, 0x1000      ; Start Address Segment(0x10000)
    mov ds, ax          ; ds, es = ax
    mov es, ax          ; . . .

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A20 게이트 활성화
;BIOS를 이용한 전환이 실패했을 때 시스템 컨트롤 포트로 전환 시도
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BIOS 서비스를 사용해서 A20 게이트를 활성화
mov ax, 0x2401          ; A20 게이트 활성화 서비스 설정
int 0x15                ; BIOS 인터럽트 서비스 호출

jc .A20_GATE_ERROR      ; A20 게이트 활성화 성공여부 확인
jmp .A20_GATE_SUCCESS

.A20_GATE_ERROR:
    ;에러 발생 시, 시스템 컨트롤 포트로 전환 시도
    in al, 0x92         ; 시스템 컨트롤 포트(0x92)에서 1 바이트를 읽어 AL 레지스터에 저장
    or al, 0x02         ; 읽은 값에 A20 게이트 비트(비트 1)를 1로 설정
    and al, 0xFE        ; 시스템 리셋 방지를 위해 0xFE와 AND 연산하여 비트 0을 0으로 설정
    out 0x92, al        ; 시스템 컨트롤 포트(0x92)에 변경된 값을 1 바이트 설정

.A20_GATE_SUCCESS:

    cli                 ; Disable interrupt(Clear Interrupt Flag)
    lgdt [GDTR]         ; Set the GDTR & load GDT Table

    ; Enter the Protected Mode
    ; PG[0]/CD[1]/NW[0]/RESERVED_AREA[0/0000/0000/0]/AM[0]/RESERVED_AREA[0]/WP[0]/RESERVED_AREA[0000/0000/00]/NE[1]/ET[1]/TS[1]/EM[0]/MP[1]/PE[1]
    mov eax, 0x4000003B 
    mov cr0, eax        ; CR0_Control Register = SETTED FLAGS & SWITCH MODE
    
    ; 커널 코드 세그먼트 0x00을 기준으로 하는 것으로 교체하고 EIP의 값을 0x00을 기준으로 재설정
    jmp dword 0x18: (PROTECTED_MODE - $$ + 0x10000)     ; 280p 보호 모드용 코드 세그먼트 디스크립터 0x08 → IA-32e 모드용 코드 0x18

; ENTER PROTECTED MODE
[BITS 32]
PROTECTED_MODE:
    mov ax, 0x20        ; 280p 보호 모드용 데이터 세그먼트 디스크립터 0x10 → IA-32e 모드용 코드 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Configure Stack
    mov ss, ax
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    ; Print Text
    push (MODE_SWITCH_COMPLETE - $$ + 0x10000)
    push 3
    push 0
    call PRINTSTRING

    jmp dword 0x18: 0x10200         ; 280p

PRINTSTRING:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push edx

    ; Calculate character position [ di = ? ]
    ; Y Position(Line)
    mov eax, dword[ebp + 12]    ; [bp + 6] = Y position
    mov esi, 160
    mul esi
    mov edi, eax

    ; X Position
    mov eax, dword[ebp + 8]    ; [bp + 4] = X position
    mov esi, 2
    mul esi
    add edi, eax

    ; String data
    mov esi, dword[ebp + 16]    ; [bp + 16] = String

    PRINT_TEXT:
        mov cl, byte[esi]
        cmp cl, 0           ; End of string :: 0
        je END_PRINT_TEXT   ; . . .

        mov byte[edi + 0xB8000], cl ; Print char[si]
        mov byte[edi + 1 + 0xB8000], 0x0E ; Print char[si]

        add esi, 1
        add edi, 2
        jmp PRINT_TEXT

    END_PRINT_TEXT:
        pop edx
        pop ecx
        pop eax
        pop edi
        pop esi
        pop ebp
        ret 12

align 8, db 0
dw 0x0000

GDTR:
    dw GDTEND - GDT - 1
    dd (GDT - $$ + 0x10000)

GDT:
    NullDescriptor:
        dw 0x0000, 0x0000
        db 0x00, 0x00, 0x00, 0x00

    ; IA-32e 모드 커널용 코드 세그먼트 디스크립터
    IA_32eCODEDESCRIPTOR:
        dw 0xFFFF       ; Limit [15:0]
        dw 0x0000       ; Base  [15:0]
        db 0x00         ; Base  [23:16]
        db 0x9A         ; P=1, DPL=0, Code Segment, Execute/Read
        db 0xAF         ; G=1, D=0, L=1, Limit[19:16]
        db 0x00         ; Base  [31:24]

    ; IA-32e 모드 커널용 데이터 세그먼트 디스크립터
    IA_32eDATADESCRIPTOR:
        dw 0xFFFF       ; Limit [15:0]
        dw 0x0000       ; Base  [15:0]
        db 0x00         ; Base  [23:16]
        db 0x92         ; P=1, DPL=0, Data Segment, Read/Write
        db 0xAF         ; G=1, D=0, L=1, Limit[19:16]
        db 0x00         ; Base  [31:24]

    ; 보호 모드 커널용 코드 세그먼트 디스크립터
    CodeDescriptor:
        dw 0xFFFF, 0x0000
        db 0x00, 0x9A, 0xCF, 0x00

    ; 보호 모드 커널용 데이터 세그먼트 디스크립터
    DataDescriptor:
        dw 0xFFFF, 0x0000
        db 0x00, 0x92, 0xCF, 0x00

GDTEND:

STRING_DAT:
    MODE_SWITCH_COMPLETE: db 'Mode switch process completed', 0

times 512 - ($ - $$) db 0