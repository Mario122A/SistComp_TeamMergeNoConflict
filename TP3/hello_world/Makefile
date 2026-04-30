BUILD = build

all: $(BUILD)/main.img

# Crea la carpeta build si no existe
$(BUILD):
	mkdir -p $(BUILD)

# Ensambla main.S y genera main.o dentro de build/
$(BUILD)/main.o: main.S | $(BUILD)
	as --32 -g -o $@ $<

# Linkea main.o y genera main.img dentro de build/
$(BUILD)/main.img: $(BUILD)/main.o link.ld
	ld -m elf_i386 --oformat binary -o $@ -T link.ld $<

# Ejecuta QEMU
run: $(BUILD)/main.img
	qemu-system-i386 -hda $<

# Ejecuta QEMU pausado para GDB
debug: $(BUILD)/main.img
	qemu-system-i386 -hda $< -s -S

# Limpia los binarios generados
clean:
	rm -rf $(BUILD)

.PHONY: all run debug clean