.code16
.globl _start
_start:
    jmp main    # Saltamos por encima del área que la BIOS va a sobreescribir (BPB)
    nop         # Usualmente se requiere un NOP después del JMP corto por compatibilidad

    .org 0x5A   # Rellenamos con ceros hasta la dirección 0x5A (fin del BPB)
main:
    # Inicializamos los segmentos de datos a 0
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    # Inicializamos la pila (stack) a 0
    movw %ax, %ss
    movw $0x7C00, %sp
    # Limpiamos el direction flag (nos asegura que lodsb incremente %si en lugar de decrementar)
    cld
    # Codigo para imprimir
    movw $msg, %si
    movb $0x0e, %ah
loop:
    lodsb
    orb %al, %al
    jz halt
    int $0x10
    jmp loop
halt:
    hlt
    jmp halt
msg:
    .asciz "Hello World! Aqui el bootloader del team MergeNoConflict en modo real mediante BIOS!"