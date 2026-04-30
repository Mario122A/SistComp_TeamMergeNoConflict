.code16
.globl _start

_start:
    # deshabilitamos las interrupciones para evitar problemas durante la transición
    cli

    # iniciamos los segmentos de datos y de pila a 0 para evitar problemas con segmentos no inicializados
    xorw %ax, %ax           # AX en 0
    movw %ax, %ds           # DS en 0
    movw %ax, %es           # ES en 0
    movw %ax, %ss           # SS en 0      
    movw $0x7C00, %sp       # ponemos el stack pointer en 0x7C00, que es donde se carga el código

    # cargamos la GDT con el descriptor que hemos definido
    lgdt gdt_descriptor     

    # activamos el modo protegido estableciendo el bit PE (Protection Enable) en CR0
    movl %cr0, %eax
    orl $0x1, %eax
    movl %eax, %cr0

    # salto largo para limpiar el pipeline y entrar en modo protegido
    ljmp $0x08, $protected_mode

# GDT (Global Descriptor Table) rústica con solo los descriptores necesarios para el modo protegido

.align 8
gdt_start:
    # descriptor nulo (Offset 0x00) - siempre debe ser el primer descriptor y no se usa
    .quad 0x0000000000000000

    # descriptor de código (Offset 0x08)
    # base: 0x00000000, límite: 0xFFFFF
    .word 0xFFFF            # límite bajo (bits 0-15)
    .word 0x0000            # base baja (bits 0-15)
    .byte 0x00              # base media (bits 16-23)
    .byte 0x9A              # atributos: presente, ring 0, ejecutable/lectura
    .byte 0xCF              # granularidad (4KB) + límite alto (bits 16-19)
    .byte 0x00              # base alta (bits 24-31)

    # descriptor de datos (Offset 0x10)
    # espacios diferenciados: base 0x00010000 (empieza más adelante que el código)
    .word 0xFFFF            # límite bajo
    .word 0x0000            # base baja
    .byte 0x01              # base media (0x01 hace que la base real sea 0x00010000)
    .byte 0x90              # atributos: presente, ring 0, *SOLO LECTURA* (read-only)
    .byte 0xCF              # granularidad (4KB) + límite alto
    .byte 0x00              # base alta
gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1   # límite de la tabla GDT
    .long gdt_start                 # dirección base donde empieza la tabla

.code32
protected_mode:
    # configuramos los segmentos de datos para que apunten al descriptor de datos (offset 0x10)
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    # movw %ax, %ss

    # ahora intentamos escribir en la memoria usando el segmento de datos de solo lectura.
    # el segmento de datos apuntará a la dirección base 0x00010000, pero el descriptor está marcado como solo lectura.
    # intentamos escribir 0xFF en la dirección 0x00000001, que está dentro del rango del descriptor de datos pero debería causar una violación de protección.
    movb $0xFF, (0x00000000)

halt:
    hlt
    jmp halt