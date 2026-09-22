bits 16
org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    mov si, loading_msg
    call print_string

    mov dl, [boot_drive]
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13
    jc disk_error
    cmp bx, 0xAA55
    jne disk_error
    test cx, 1
    jz disk_error

    mov si, dap
    mov dl, [boot_drive]
    mov ah, 0x42
    int 0x13
    jc disk_error

    jmp 0x1000:0x0000

disk_error:
    mov si, error_msg
    call print_string
.hang:
    cli
    hlt
    jmp .hang

print_string:
.next:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .next
.done:
    ret

boot_drive db 0
loading_msg db "Loading S-AOS...",13,10,0
error_msg db "S-AOS BOOT ERROR",13,10,0

align 4
dap:
    db 0x10
    db 0
    dw 16
    dw 0
    dw 0x1000
    dq 1

times 510-($-$$) db 0
dw 0xAA55
