# Compilador y banderas
CC      = gcc
CFLAGS  = -Wall -Wextra -O2

# Rutas de instalación (estándar en Linux)
PREFIX  = /usr/local
BINDIR  = $(PREFIX)/bin

# Variable opcional pero recomendada para empaquetado
DESTDIR =

all: hola

hola: hola.c
	$(CC) $(CFLAGS) -o $@ $<

install: hola
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 hola $(DESTDIR)$(BINDIR)/hola

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/hola

clean:
	rm -f hola

.PHONY: all install uninstall clean