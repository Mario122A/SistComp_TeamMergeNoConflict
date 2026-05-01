BUILD = build

all: $(BUILD)/main.img

# Crea la carpeta build si no existe
$(BUILD):
	mkdir -p $(BUILD)

# Ensambla main.S y genera main.o dentro de build/
$(BUILD)/main.o: main.S | $(BUILD)
	as --32 -g -o $@ $<

# 1. Linkea main.o y genera un archivo ELF con símbolos
$(BUILD)/main.elf: $(BUILD)/main.o link.ld
	ld -m elf_i386 -o $@ -T link.ld $<

# 2. Extrae el binario crudo del ELF para QEMU
$(BUILD)/main.img: $(BUILD)/main.elf
	objcopy -O binary $< $@

# Actualiza las reglas run y debug para que dependan del ELF (y por ende, generen el .img)
run: $(BUILD)/main.img
	qemu-system-i386 -hda $(BUILD)/main.img

debug: $(BUILD)/main.img $(BUILD)/main.elf
	qemu-system-i386 -hda $(BUILD)/main.img -s -S

# Limpia los binarios generados
clean:
	rm -rf $(BUILD)

.PHONY: all run debug clean