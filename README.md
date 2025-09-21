# Proyecto 8: Builder de scripts robustos para monitoreo

## Descripción general
Este proyecto implementa un **builder con Makefile** para construir y ejecutar **scripts de monitoreo** orientados a:
- Validación de **códigos HTTP** (200/404/500 según escenario).
- Verificación de **DNS** (resolución A y/o CNAME, parseo de TTL).
- Análisis de **TLS** (comparación entre HTTP vs HTTPS).
- **Health check** de puertos TCP con reintentos configurables.
- Automatización de pruebas con **Bats**.

El enfoque sigue principios **12-Factor App** y la filosofía **You Build It, You Run It**, promoviendo que los mismos desarrolladores se encarguen de construcción, despliegue y monitoreo.

### Tecnologías y herramientas
- **Bash scripting avanzado** (heredocs, arrays, trap).
- **Toolkit**: `sed`, `sort`, `tee`, `cut`.
- **Redes**: `nc`, `dig`, `curl`, `openssl`.
- **Automatización y testing**: `Makefile`, `bats`.

---

## Estructura del proyecto
```text
PC01-Grupo7-CC3S2B-25-2/
├── Makefile                    # Reglas de construcción y ejecución
├── README.md                   # Documentación del proyecto
├── src/
│   ├── builder.sh             # Script builder principal
│   ├── check_http.sh          # Módulo verificación HTTP
│   ├── check_dns.sh           # Módulo verificación DNS
│   ├── check_tls.sh           # Módulo verificación TLS
│   ├── health_check.sh        # Verificación de puertos TCP (Sprint 3)
│   └── utils.sh               # Funciones de logging compartidas (Sprint 3)
├── tests/
│   ├── test_dns.bats          # Pruebas DNS expandidas
│   ├── test_http.bats         # Pruebas HTTP expandidas
│   ├── test_tls.bats          # Pruebas TLS expandidas
│   └── test_idempotency.bats  # Pruebas de idempotencia (Sprint 3)
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

## Bitácora del Sprint 2

### Objetivo
Expandir la funcionalidad con **toolkit avanzado**, **administración robusta** y **testing comprehensivo**.

### Logros
- Implementación de herramientas Unix avanzadas: `sed`, `tee`, `cut`, `dig`.
- Sistema de **trap** y limpieza automática de recursos temporales.
- **Refactorización de monitor.sh** y separación en módulos especializados.
- **Suite de pruebas Bats** comprehensiva (27 tests).

### Dificultades
- Integración de múltiples herramientas Unix en pipelines complejos.
- Manejo de timeouts y conexiones lentas en verificaciones TLS.
- Parsing correcto de URLs y extracción de dominios con `sed`.

---

## Bitácora del Sprint 3

### Objetivo
**Finalización del proyecto** con optimización de scripts, refactorización para mejorar la mantenibilidad y nuevas capacidades de monitoreo empresarial.

### Logros
- Última refactorización de scripts dentro de `src/` mediante `utils.sh`
- Agregación de script de verificación de estado de red usando `nc (netcat)` dentro del script `health_check.sh`
- Documentación completa dentro de un `.env.example` sobre las variables de entorno disponibles.
- Nueva suite `test_idempotency.bats` para validar reproducibilidad del build.

### Dificultades
- Obtener un resolución y correcto manejo de los tests definidos para garantizar pruebas significativas y extensas.
- La revisión de los scripts existentes para la obtención variables de entorno signficativas dentro del proyecto.

---

## Guía de ejecución (Sprint 3)

### Requisitos previos
- Linux/Mac con **bash 4.0+**
- Dependencias: `make`, `nc`, `curl`, `dig`, `openssl`, `bats`

### Verificación de herramientas
```bash
make tools
```

### Construcción y ejecución

1. **Construir scripts**
   ```bash
   make build
   ```

2. **Monitoreo básico**
   ```bash
   export URL="https://github.com"
   make run
   ```

3. **Monitoreo completo (análisis detallado)**
   ```bash
   export URL="https://cloudflare.com"
   make run-complete
   ```

4. **Monitorear múltiples targets**
   ```bash
   export TARGETS="https://google.com https://github.com"
   make run-targets
   ```

5. **Health Check de servicios**
   ```bash
   export HEALTH_HOST="localhost"
   export HEALTH_PORT=8080
   make health-check
   ```

6. **Ejecutar todas las pruebas**
   ```bash
   make test
   # Resultado esperado: 27 tests, 0 failures, 0 not run
   ```

7. **Empaquetado para distribución**
   ```bash
   make pack
   # Genera dist/monitor-1.0.0.tar.gz
   ```

### Variables de configuración
Crea un archivo `.env` para personalizar el comportamiento basandose en el archivo `.env.example`:
```bash
TARGETS="https://github.com https://google.com https://cloudflare.com"
CHECK_INTERVAL=60
DNS_SERVER=8.8.8.8
RETRIES=5
WAIT_SECONDS=3
```

### Comandos disponibles del monitor
```bash
# Ver ayuda completa
./out/monitor.sh help

# Comandos individuales
./out/monitor.sh check-http https://httpbin.org/status/404 404
./out/monitor.sh check-dns github.com
./out/monitor.sh complete-dns github.com
./out/monitor.sh check-tls https://github.com
./out/monitor.sh detailed-tls https://github.com
```

## Resultados del Sprint 3

- [x] **27/27 tests ejecutándose exitosamente**
- [x] **Sistema de logging centralizado y consistente**
- [x] **Health check empresarial con reintentos configurables**
- [x] **Build determinista e idempotente**
- [x] **Makefile avanzado con targets especializados**
- [x] **Eliminación completa de dependencias externas problemáticas**

## Links de videos de los Sprints

**Sprint 1**: https://drive.google.com/file/d/1qC4WKTOaIcJOuRhj3oYYUSobf3hbZLZs/view?usp=sharing

**Sprint 2**: https://drive.google.com/file/d/1dywVJG72JM3UY7ZNKYSpRjHW5o9iNRIs/view?usp=sharing

**Sprint 3**: https://drive.google.com/file/d/1m-zxw6u2o_-7FiEGNg4xx_CRO2_ELHkL/view?usp=sharing
