## Rendimiento de procesadores — Compilación del Kernel de Linux

Para evaluar el rendimiento real de diferentes procesadores, utilizamos el benchmark **Build Linux Kernel 1.15.0** disponible en [OpenBenchmarking.org](https://openbenchmarking.org/test/pts/build-linux-kernel-1.15.0), que mide el tiempo necesario para compilar el kernel de Linux desde el código fuente. Esta tarea es intensiva en CPU y hace uso eficiente de todos los núcleos disponibles, por lo que es un excelente indicador de rendimiento en compilación y desarrollo de software.

### Procesadores comparados

- **Intel Core i5-13600K**
- **AMD Ryzen 9 5900X 12-Core**
- **AMD Ryzen 9 7950X 16-Core** *(referencia de aceleración)*

### Cálculo de Speedup y Rendimiento

Tomamos como referencia el procesador **Intel Core i5-13600K** para calcular el speedup de los demás. El speedup se define como:

$$Speedup = \frac{Tiempo_{referencia}}{Tiempo_{procesador}}$$

Y el rendimiento (throughput) como:

$$Rendimiento = \frac{1}{Tiempo}$$

De la tabla de resultados obtenemos:

| Procesador | Núcleos | Tiempo (s) | Speedup | Rendimiento |
|------------|---------|------------|---------|-------------|
| Intel Core i5-13600K | 14 | 72 | 1.00 | 0.0139 |
| AMD Ryzen 9 5900X | 12 | 76 | 0.94 | 0.0132 |
| AMD Ryzen 9 7950X | 16 | 50 | **1.44** | **0.0200** |

### Análisis de resultados

- El **Intel Core i5-13600K** es nuestra referencia con un tiempo de 72 segundos. A pesar de tener 14 núcleos, su arquitectura híbrida (núcleos de rendimiento + eficiencia) y su alta frecuencia base le dan una ventaja notable.

- El **AMD Ryzen 9 5900X** con 12 núcleos tardó 76 segundos, resultando en un speedup de 0.94 respecto al i5-13600K. Si bien es un procesador potente de generación anterior (Zen 3), en este benchmark específico queda ligeramente por debajo del Intel de referencia. Sin embargo, tiene un costo inferior al i5-13600K en muchos mercados.

- El **AMD Ryzen 9 7950X** con 16 núcleos completó la tarea en solo 50 segundos, logrando un speedup de **1.44x** respecto al i5-13600K. Esto representa una aceleración significativa gracias a su mayor cantidad de núcleos, arquitectura Zen 4 y mayor ancho de banda de memoria. Sin embargo, su costo es considerablemente más alto que los otros dos procesadores.

### Conclusiones

El AMD Ryzen 9 7950X es la opción más rápida en términos absolutos para compilación del kernel, con una aceleración del 44% respecto al Intel de referencia. No obstante, la elección del procesador dependerá siempre de la relación **rendimiento/costo** según el caso de uso:

- Para un entorno de **desarrollo profesional intensivo** donde el tiempo de compilación impacta directamente la productividad, el 7950X justifica su costo superior.
- Para un **uso general o presupuesto moderado**, el i5-13600K ofrece la mejor relación rendimiento/precio entre los tres.
- El **Ryzen 9 5900X** sigue siendo una opción válida si se consigue a buen precio en el mercado de segunda mano.

---

*Datos de referencia obtenidos de: [https://openbenchmarking.org/test/pts/build-linux-kernel-1.15.0](https://openbenchmarking.org/test/pts/build-linux-kernel-1.15.0)*