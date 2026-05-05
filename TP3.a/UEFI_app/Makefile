# Variables para los compiladores y herramientas
CC = gcc
LD = ld
OBJCOPY = objcopy

# Flags de compilación (los que usaste en gcc)
CFLAGS = -I/usr/include/efi -I/usr/include/efi/x86_64 -I/usr/include/efi/protocol -fpic -ffreestanding -fno-stack-protector -fno-strict-aliasing -fshort-wchar -mno-red-zone -maccumulate-outgoing-args -Wall

# Flags de enlazado (los que usaste en ld)
LDFLAGS = -shared -Bsymbolic -L/usr/lib -L/usr/lib/efi -T /usr/lib/elf_x86_64_efi.lds /usr/lib/crt0-efi-x86_64.o
LIBS = -lefi -lgnuefi

# Flags para objcopy
OBJCOPY_FLAGS = -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target=efi-app-x86_64

# Regla por defecto (la que se ejecuta al escribir solo "make")
all: aplicacion.efi

# Paso 3: Convertir a .efi
aplicacion.efi: aplicacion.so
	$(OBJCOPY) $(OBJCOPY_FLAGS) aplicacion.so aplicacion.efi

# Paso 2: Linkear para crear el .so
aplicacion.so: aplicacion.o
	$(LD) $(LDFLAGS) aplicacion.o -o aplicacion.so $(LIBS)

# Paso 1: Compilar el .c a .o
aplicacion.o: aplicacion.c
	$(CC) $(CFLAGS) -c -o aplicacion.o aplicacion.c

# Regla para limpiar los archivos generados
clean:
	rm -f aplicacion.o aplicacion.so aplicacion.efi

# Le decimos a make que "all" y "clean" no son nombres de archivos
.PHONY: all clean