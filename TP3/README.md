# Informe: Trabajo Práctico #3 - Modo Protegido

**Asignatura:** Sistemas de Computación  
**Institución:** Facultad de Ciencias Exactas, Físicas y Naturales (FCEFyN) – UNC  
**Docente:** Javier Alejandro Jorge  

## Datos del Grupo y Repositorio

* **Integrantes:** 
  - Macarena Vanina González 
  - Marcos Nieto 
  - Mario Pampiglione
* **Repositorio:** [https://github.com/Maca040/SistComp_TeamMergeNoConflict.git](https://github.com/Maca040/SistComp_TeamMergeNoConflict.git)

---

## 1. Introducción

En este trabajo práctico abordamos el arranque a bajo nivel y la transición de modo real a modo protegido en arquitectura x86. Se desarrollaron dos programas en ensamblador: uno que actúa como *bootloader* simple para imprimir un mensaje usando BIOS (`TP3/hello_world/main.S`), y otro que configura una GDT mínima y habilita el modo protegido, forzando un acceso ilegal a un segmento marcado como solo lectura (`TP3/modo_protegido/main.S`) para analizar el comportamiento del procesador.

---

## 2. Estructura del TP3

La implementación está separada en dos desafíos prácticos:

- **hello_world/**: bootloader mínimo en modo real que imprime por BIOS.  
  - Código: `TP3/hello_world/main.S`  
  - Script de linker: `TP3/hello_world/link.ld`  
  - Compilación: `TP3/hello_world/Makefile`

- **modo_protegido/**: código que habilita modo protegido, define GDT y prueba violación de protección.  
  - Código: `TP3/modo_protegido/main.S`  
  - Script de linker: `TP3/modo_protegido/link.ld`  
  - Compilación: `TP3/modo_protegido/Makefile`

---

## 3. Desafío: UEFI y coreboot (teoría)

### ¿Qué es UEFI y cómo puede usarse?
UEFI es la especificación que define la interfaz entre el sistema operativo y el firmware, reemplazando al BIOS tradicional. A diferencia del BIOS (modo real 16 bits), UEFI opera en 32/64 bits, permitiendo direccionar más memoria y usar controladores complejos.  
Se utiliza escribiendo aplicaciones `.efi` que se ejecutan desde la EFI System Partition (ESP), accediendo a servicios a través de tablas de punteros provistas por el firmware.

### Servicios UEFI y función de ejemplo
UEFI expone dos tipos de servicios:

- **EFI Boot Services**: disponibles durante el arranque. Dejan de existir cuando el SO llama a `ExitBootServices()`.  
- **EFI Runtime Services**: persisten después de `ExitBootServices()` y se pueden usar durante la ejecución del SO.

**Ejemplo de función:** `GetVariable`  
Permite leer variables NVRAM (como el estado de Secure Boot u orden de arranque) a través de la tabla `EFI_RUNTIME_SERVICES`.

### Vulnerabilidades y bugs explotables
UEFI es un objetivo crítico por su alto privilegio y su presencia previa al SO. Esto habilita ataques de persistencia *pre-boot*. Ejemplos conocidos:

- **LogoFAIL (2023–2024)**: vulnerabilidades en librerías de parsing de imágenes usadas para mostrar el logo del fabricante durante el boot. Un atacante puede reemplazar el logo por una imagen maliciosa y ejecutar código antes de que cargue el SO.

- **BlackLotus**: bootkit que evade Secure Boot explotando una vulnerabilidad (CVE-2022-21894) en el cargador de Windows. Permite instalar un payload persistente con privilegios máximos sin ser detectado por el sistema operativo.

- **CosmicStrand**: rootkit en firmware de algunas placas base que inyecta código en el kernel durante la transición del boot (alrededor de `ExitBootServices()`), permaneciendo invisible para antivirus tradicionales.

Estos casos muestran que un compromiso en UEFI puede persistir incluso tras reinstalar el sistema operativo o formatear el disco.

### CSME e Intel MEBx
**CSME (Converged Security and Management Engine)** es un subsistema embebido dentro del chipset Intel que opera de forma independiente al CPU principal. Corre un firmware propio sobre un microcontrolador dedicado y tiene acceso privilegiado a recursos críticos.  
Sus funciones incluyen **arranque seguro**, **validación de firmas**, **gestión de claves**, **cifrado**, **TPM/firmware TPM (PTT)** y soporte de administración remota (AMT). Esto lo convierte en una pieza central del modelo de seguridad del hardware Intel.

**Intel MEBx (Management Engine BIOS Extension)** es la interfaz de configuración del CSME accesible durante POST (por ejemplo con `Ctrl+P`). Permite habilitar o deshabilitar AMT, definir credenciales, configurar red para administración fuera de banda y políticas de seguridad.  
En términos prácticos, MEBx permite que un administrador gestione un equipo **aunque el sistema operativo no arranque**, ya que la administración ocurre a nivel de firmware.

### Coreboot
Coreboot es firmware open source que reemplaza UEFI/BIOS. Su objetivo es inicializar el hardware lo mínimo indispensable y transferir el control a un *payload* (SeaBIOS, U-Boot, TianoCore o incluso un kernel directo).

**Productos que lo usan:**
- **Chromebooks**: casi todos los modelos de Google usan variantes de coreboot.  
- **System76 y Purism**: fabricantes de laptops con enfoque en Linux y privacidad.  
- **PC Engines y Protectli**: dispositivos de red y firewalls.

**Ventajas principales:**
- **Velocidad de arranque**: reduce el tiempo de boot al evitar inicializaciones innecesarias.  
- **Seguridad y auditoría**: al ser código abierto puede auditarse, reduciendo backdoors ocultos.  
- **Minimalismo**: menor superficie de ataque respecto a firmware propietario.  
- **Personalización**: permite integrar herramientas de recuperación o payloads específicos directamente en el firmware.

---

## 4. Desafío: Linker

El linker combina objetos, resuelve símbolos, asigna secciones y relocaliza direcciones para producir una imagen booteable. En este TP se usa un script de linker para fijar el programa en `0x7C00` (`TP3/hello_world/link.ld`), que es donde la BIOS carga el *boot sector*.

### Dirección en el script del linker
La dirección `0x7C00` funciona como VMA (dirección virtual de carga). El linker usa esta base para ubicar etiquetas y calcular direcciones absolutas. Sin esa base, no puede fijar posiciones correctas.

### Comparación objdump vs hd
- `objdump -D archivo.elf`: muestra el código ensamblado con direcciones lógicas asignadas por el linker.  
- `hd archivo.bin` (o `hexdump -C`): muestra el binario crudo byte a byte, útil para verificar el *boot signature* `0xAA55`.

**Evidencia requerida 1 (objdump vs hd):**  
![evidencia-linker-objdump-hd](./images/evidencia-linker-objdump-hd.png)


En `objdump` se observa que el código inicia en `0x7C00`, que coincide con la dirección de carga del boot sector.  
En el `hexdump` se ve la firma `55 AA` al final del sector, y el string del mensaje dentro del rango del primer sector, confirmando que el programa quedó ubicado correctamente en la imagen booteable.

### Prueba en pendrive real
Se genera la imagen booteable (`TP3/hello_world/Makefile`), se graba en pendrive y se inicia una PC real.

**Evidencia requerida 2 (boot en PC real):**  
![evidencia-linker-usb](./images/evidencia-linker-usb.jpeg)

### ¿Para qué se utiliza `--oformat binary`?
Le indica al linker que genere un binario plano sin cabeceras (no ELF/PE), necesario para un *boot sector* válido.

---

## 5. Desafío final: Modo protegido

El programa (`TP3/modo_protegido/main.S`) realiza:

1. Configuración de segmentos en modo real.  
2. Carga de una GDT mínima.  
3. Activación del bit PE en CR0.  
4. Salto largo para entrar a modo protegido.  
5. Carga de registros de segmento con el selector de datos.  
6. Intento de escritura en un segmento marcado como solo lectura.

### 5.1. Dos descriptores de memoria diferenciados
Se define una GDT con un descriptor de **código** y uno de **datos** con base distinta (en el TP: `0x00000000` y `0x00010000`). Luego se cargan los selectores en `CS` (salto largo) y en `DS/ES/FS/GS`.

### 5.2. Escritura en segmento de solo lectura
El descriptor de datos está marcado como **read-only**. Intentar escribir debería generar una **excepción de protección general (#GP)** y, sin handler, terminar en **triple fault** y reinicio.

**Nota:** QEMU no refleja correctamente la excepción (permite escritura). En hardware real, al bootear desde pendrive, la CPU se reinicia, confirmando el comportamiento esperado.

**Evidencia requerida (GDB / violación de segmento):**  
![evidencia-modo-protegido-gdb](./images/evidencia-modo-protegido-gdb.jpg)

> Si no hay captura de GDB, se puede reemplazar con evidencia del reinicio en hardware real.

### 5.3. ¿Qué valor se carga en los registros de segmento?
Se cargan **selectores** que apuntan a entradas de la GDT. En este caso:
- `0x08` para **código**  
- `0x10` para **datos**  
Esto se debe a que cada descriptor ocupa 8 bytes en la GDT.

---

## 6. Compilación y ejecución

Cada carpeta cuenta con su `Makefile`:

### hello_world (`TP3/hello_world/Makefile`)
- `make` genera `build/main.img`
- `make run` ejecuta en QEMU
- `make debug` ejecuta QEMU pausado para GDB

### modo_protegido (`TP3/modo_protegido/Makefile`)
- `make` genera `build/main.elf` y `build/main.img`
- `make run` ejecuta en QEMU
- `make debug` ejecuta QEMU pausado para GDB

---

## 7. Conclusiones

En este TP se logró implementar un bootloader mínimo y la transición a modo protegido con GDT propia, comprendiendo el rol del linker, las restricciones del arranque y el comportamiento de protección del procesador.
Además se evidenció la diferencia entre emulación (QEMU) y hardware real: mientras QEMU funcionaba correctamente, al bootear desde pendrive en una PC real el código en hello_world solo mostraba “Hello” y no continuaba. El problema fue el BPB (BIOS Parameter Block): muchas BIOS, al detectar un dispositivo FAT, sobrescriben en RAM el rango 0x03–0x3E (o 0x5A en FAT32) con datos reales de geometría. En nuestro caso, eso inyectó un 0x00 dentro del string, convirtiendo “Hello World” en “Hello\0World”, lo que hizo que el loop terminara antes de tiempo.
La solución fue respetar la convención de dejar libre el área del BPB: se agregó un salto inicial y se desplazó el código y los datos a partir de un offset seguro (por ejemplo, después de 0x5A). Con eso el bootloader funcionó correctamente en hardware real.
Este percance demuestra que el firmware puede modificar regiones “reservadas” del sector de arranque, algo que no siempre se reproduce en emuladores, por lo que la validación en máquina física es indispensable.
Evidencia del problema (solo imprime “Hello”):
![evidencia-hello-solo](./images/evidencia-hello-solo.jpeg)
