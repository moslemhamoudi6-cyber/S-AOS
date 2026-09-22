bits 16
org 0x0000

start:
    cli
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE
    sti

    mov ax, 0x0003
    int 0x10

    mov si, title
    call print_string
    call newline

main_loop:
    mov si, prompt
    call print_string
    call read_line
    call execute_command
    jmp main_loop

execute_command:
    mov si, buffer
    mov di, cmd_help
    call strcmp
    test al, al
    jnz .help

    mov si, buffer
    mov di, cmd_cls
    call strcmp
    test al, al
    jnz .cls

    mov si, buffer
    mov di, cmd_time
    call strcmp
    test al, al
    jnz .time

    mov si, buffer
    mov di, cmd_date
    call strcmp
    test al, al
    jnz .date

    mov si, buffer
    cmp byte [si], 0
    je .empty

    mov si, unknown
    call print_string
    call newline
    ret

.empty:
    ret

.help:

.help:
    mov si, help_text
    call print_string
    ret

.cls:
    mov ax, 0x0003
    int 0x10
    ret

.time:
    mov si, time_label
    call print_string

    mov al, 0x04
    out 0x70, al
    in al, 0x71
    call print_bcd

    mov al, ':'
    call print_char

    mov al, 0x02
    out 0x70, al
    in al, 0x71
    call print_bcd

    mov al, ':'
    call print_char

    mov al, 0x00
    out 0x70, al
    in al, 0x71
    call print_bcd

    call newline
    ret

.date:
    mov si, date_label
    call print_string

    mov al, 0x07
    out 0x70, al
    in al, 0x71
    call print_bcd

    mov al, '/'
    call print_char

    mov al, 0x08
    out 0x70, al
    in al, 0x71
    call print_bcd

    mov al, '/'
    call print_char

    mov si, year_prefix
    call print_string

    mov al, 0x09
    out 0x70, al
    in al, 0x71
    call print_bcd

    call newline
    ret

read_line:
    mov di, buffer

.read:
    xor ah, ah
    int 0x16

    cmp al, 13
    je .enter

    cmp al, 8
    je .backspace

    cmp al, 0
    je .read

    cmp di, buffer + 63
    jae .read

    mov [di], al
    inc di
    call print_char
    jmp .read

.backspace:
    cmp di, buffer
    je .read
    dec di
    mov al, 8
    call print_char
    mov al, ' '
    call print_char
    mov al, 8
    call print_char
    jmp .read

.enter:
    mov byte [di], 0
    call newline
    ret

strcmp:
.next:
    mov al, [si]
    cmp al, [di]
    jne .no
    cmp al, 0
    je .yes
    inc si
    inc di
    jmp .next

.yes:
    mov al, 1
    ret

.no:
    xor al, al
    ret

print_string:
.next:
    lodsb
    test al, al
    jz .done
    call print_char
    jmp .next
.done:
    ret

print_char:
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    ret

newline:
    mov al, 13
    call print_char
    mov al, 10
    call print_char
    ret

print_bcd:
    push ax
    mov ah, al
    and al, 0xF0
    shr al, 1
    shr al, 1
    shr al, 1
    shr al, 1
    add al, '0'
    call print_char
    pop ax
    and al, 0x0F
    add al, '0'
    call print_char
    ret

title db "S-AOS",0
prompt db "ICLSCO > ",0

help_text db "help       - show commands",13,10
           db "cls        - clear screen",13,10
           db "shw time   - show time",13,10
           db "shw date   - show date",13,10,0

time_label db "Time : ",0
date_label db "Date : ",0
year_prefix db "20",0
unknown db "Unknown command",13,10,0

cmd_help db "help",0
cmd_cls db "cls",0
cmd_time db "shw time",0
cmd_date db "shw date",0

buffer times 64 db 0

times 8192-($-$$) db 0
