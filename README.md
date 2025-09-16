# Proyecto 8: Builder de scripts robustos para monitoreo

## Descripción general
Este proyecto implementa un **builder con Makefile** para construir y ejecutar **scripts de monitoreo** orientados a:
- Validación de **códigos HTTP** (200/404/500 según escenario).
- Verificación de **DNS** (resolución A y/o CNAME, parseo de TTL).
- Análisis de **TLS** (comparación entre HTTP vs HTTPS).
- Automatización de pruebas con **Bats**.

El enfoque sigue principios **12-Factor App** y la filosofía **You Build It, You Run It**, promoviendo que los mismos desarrolladores se encarguen de construcción, despliegue y monitoreo.

### Tecnologías y herramientas
- **Bash scripting avanzado** (heredocs, arrays).
- **Toolkit**: `sed`, `sort`, `tee`.
- **Redes**: `nc`, `rsync`.
- **Automatización y testing**: `Makefile`, `bats`.

---

## Estructura del proyecto
```text
PC01-Grupo7-CC3S2B-25-2/
├── Makefile                    # Reglas de construcción y ejecución
├── README.md                   # Documentación del proyecto
├── src/
│   └── monitor.sh             # Script principal de monitoreo
├── test/
│   └── monitor_tests.bats 8    # Pruebas automatizadas
└── out/
    └── monitor.sh             # Script compilado/generado por el builder
```

## Bitácora del Sprint 1

### Objetivo
Sentar las bases con **Makefile básico** y primeros scripts Bash.

### Logros
- Crear builder con here-docs en Bash.
- Configurar comandos iniciales de red (nc).
- Validar estructura mínima del proyecto.

### Dificultades
- Aprendizaje de reglas patrón en Makefile.
- Integración con CLI y globbing.

---

## Guía de ejecución (Sprint 1)

### Requisitos previos
- Linux/Mac con **bash**.
- Dependencias: `make`, `nc`.

### Pasos
1. **Clonar repositorio**
   ```bash
   git clone https://github.com/bxcowo/PC01-Grupo7-CC3S2B-25-2.git
   cd PC01-Grupo7-CC3S2B-25-2
   ```
2. **Construir scripts**
    ```bash
    make build
    ```

3. **Ejecutar monitoreo básico**
    ```bash
    ./monitor.sh <URL_o_HOST>
    ```

## Links de videos de los Sprints
**Sprint 1:**: https://drive.google.com/file/d/1qC4WKTOaIcJOuRhj3oYYUSobf3hbZLZs/view?usp=sharing
