.code16
.global _start

_start:
    cli

    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %ss
    mov $0x7C00, %sp

    lgdt gdt_descriptor

    # Activación modo protegido
    mov %cr0, %eax
    orl $0x1, %eax
    mov %eax, %cr0

    ljmp $0x08, $protected_mode

#----------------------------
#----------------------------
#           GDT
#----------------------------
#----------------------------

gdt_start:
gdt_null:
    .long 0x00000000
    .long 0x00000000

gdt_code:
    .word 0xffff
    .word 0x0000
    .byte 0x00
    .byte 0b10011010
    .byte 0b11001111
    .byte 0x00

gdt_data:
    .word 0xffff
    .word 0x0000
    .byte 0x00
    .byte 0b10010010
    .byte 0b11001111
    .byte 0x00

gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1
    .long gdt_start

#----------------------------
#----------------------------
#       MODO PROTEGIDO
#----------------------------
#----------------------------

.code32
protected_mode:
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    mov $0x9000, %esp

    # Dirección de VGA
    mov $0xB8000, %edi

    mov $msg, %esi

    # En este caso se consideran las iniciales mayúscula para especificar los colores por simplicidad

    mov $0x0C, %bl    # color inicial rojo

print_loop:
    lodsb
    test %al, %al
    jz hang

    cmp $'M', %al
    jne check_N
    mov $0x0A, %bl   # verde
check_N:
    cmp $'N', %al
    jne check_C
    mov $0x09, %bl   # azul
check_C:
    cmp $'C', %al
    jne print_char
    mov $0x0E, %bl   # amarillo

print_char:
    movb %al, (%edi)
    movb %bl, 1(%edi)

    add $2, %edi
    jmp print_loop

hang:
    jmp hang

#--------------------
#--------------------
#       MENSAJE
#--------------------
#--------------------

msg:
    .asciz "TeamMergeNoConflict"
