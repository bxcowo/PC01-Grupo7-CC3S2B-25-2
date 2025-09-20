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

#### Refactorización de Logging y Arquitectura
- **Centralización completa del logging**: Se creó `src/utils.sh` con función `log()` unificada para todos los scripts.
- **Eliminación de código duplicado**: Se removió logging redundante de `check_http.sh`, `check_dns.sh` y `check_tls.sh`.
- **Builder mejorado**: El `builder.sh` inyecta automáticamente la función de log, siguiendo el principio DRY (Don't Repeat Yourself).

#### Nueva Capacidad Empresarial: Health Check
- **Script standalone `health_check.sh`**: Verificación de disponibilidad de puertos TCP usando `nc`.
- **Reintentos configurables**: Variables `RETRIES` y `WAIT_SECONDS` para escenarios de CI/CD donde los servicios tardan en arrancar.
- **Control de timeouts**: Ajuste fino de tiempos de espera para optimizar el rendimiento.
- **Integración Makefile**: Nuevo target `health-check` para facilidad de uso.

#### Optimización y Estabilidad
- **Determinismo en DNS**: Se añadió `sort` en `check_dns.sh` para salida consistente de registros DNS.
- **Suite de pruebas robusta**: 27 tests ejecutándose exitosamente (100% de cobertura).
- **Test de idempotencia**: Nueva suite `test_idempotency.bats` para validar la reproducibilidad del build.
- **Makefile avanzado**: Variables configurables y targets especializados (`run-complete`, `run-targets`, `tools`).

#### Estabilización de Tests BATS
- **Eliminación de dependencias externas**: Se removieron `bats-support` y `bats-assert` problemáticas.
- **Tests deterministas**: Corrección de fallos intermitentes usando timeouts y verificaciones robustas.
- **Cobertura completa**: 27/27 tests ejecutándose exitosamente sin dependencias de servicios externos.

### Dificultades Superadas

- **Coordinación del Refactor**: Verificación exhaustiva de que todos los scripts funcionaran tras centralizar la función `log()`.
- **Estabilidad de Tests**: Resolución de 10 tests intermitentes que dependían de servicios externos impredecibles.
- **Arquitectura de Decisión**: Mantener `health_check.sh` como utilidad separada para no sobrecargar el propósito del `monitor.sh` principal.

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
   ./out/monitor.sh monitor https://github.com
   ```

3. **Monitoreo completo (análisis detallado)**
   ```bash
   ./out/monitor.sh monitor-complete https://github.com
   # O usando el Makefile
   make run-complete URL=https://cloudflare.com
   ```

4. **Monitorear múltiples targets**
   ```bash
   make run-targets
   # Usa variable TARGETS del .env o valores por defecto
   ```

5. **Health Check de servicios**
   ```bash
   # Verificar puerto probablemente cerrado
   ./src/health_check.sh localhost 8080
   
   # Verificar puerto probablemente abierto
   ./src/health_check.sh google.com 443
   
   # Con variables de entorno
   RETRIES=10 WAIT_SECONDS=2 ./src/health_check.sh localhost 3000
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
Crea un archivo `.env` para personalizar el comportamiento:
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

- **✅ 27/27 tests ejecutándose exitosamente**
- **✅ Sistema de logging centralizado y consistente** 
- **✅ Health check empresarial con reintentos configurables**
- **✅ Build determinista e idempotente**
- **✅ Makefile avanzado con targets especializados**
- **✅ Eliminación completa de dependencias externas problemáticas**

El proyecto está **listo para producción** con arquitectura robusta, testing comprehensivo y herramientas de monitoreo empresarial.