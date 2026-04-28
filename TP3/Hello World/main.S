.code16
    mov $msg, %si
    mov $0x0E, %ah
loop:
    lodsb
    or %al, %al
    jz halt
    int $0x10
    jmp loop
halt:
    hlt
msg:
    .asciz "Hello World"
