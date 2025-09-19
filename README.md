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
├── builder.sh                  # Script builder principal (Sprint 2)
├── src/
│   ├── monitor.sh             # Script principal de monitoreo
│   ├── check_http.sh          # Módulo verificación HTTP (Sprint 2)
│   ├── check_dns.sh           # Módulo verificación DNS (Sprint 2)
│   └── check_tls.sh           # Módulo verificación TLS (Sprint 2)
├── test/
│   ├── monitor_tests.bats     # Pruebas automatizadas originales
│   ├── test_http.bats         # Pruebas HTTP expandidas (Sprint 2)
│   ├── test_dns.bats          # Pruebas DNS expandidas (Sprint 2)
│   └── test_tls.bats          # Pruebas TLS expandidas (Sprint 2)
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
#### Toolkit y Unix Tools
- Implementación de herramientas Unix avanzadas: `sed`, `tee`, `cut`, `dig`
- Uso de **here-docs** para configuraciones temporales
- Manejo de **arrays** en Bash para almacenar resultados DNS/TLS
- Pipeline de procesamiento con `sed` y `tee` para logs

#### Administración y robustez
- Sistema de **trap** y limpieza automática de recursos temporales
- Manejo de **timeouts** en conexiones TLS (10-15 segundos)
- Generación automática de logs estructurados en directorio `out/`
- Variables de entorno configurables (`DNS_SERVER`, `TARGETS`)

#### Modularización del código
- **Refactorización de monitor.sh**: Extracción de funcionalidades HTTP y TLS en scripts independientes
- **Script de construcción principal**: `builder.sh` que integra y consolida funciones de subscripts
- Separación en módulos especializados:
  - `check_http.sh`: Extracción directa de check_http de monitor.sh + CLI independiente
  - `check_dns.sh`: Módulo especializado para análisis y verificación de DNS completa
  - `check_tls.sh`: Verificación TLS básica y detallada con persistencia automática
  - `builder.sh`: Extracción y consolidación de funciones principales de subscripts

#### Testing expandido
- **Suite de pruebas Bats** comprehensiva (26+ tests):
  - `test_http.bats`: Validación de códigos 200/404/500, manejo de errores
  - `test_dns.bats`: Resolución de dominios, registros A/CNAME, generación de logs
  - `test_tls.bats`: Certificados válidos/inválidos, análisis detallado

#### Funcionalidades avanzadas
- **DNS completo**: Consulta de registros A y CNAME con `dig`
- **TLS detallado**: Análisis de subject, issuer, fechas de expiración
- **Monitoreo integral**: Comandos `monitor` y `monitor-complete`

### Dificultades
#### Técnicas
- Integración de múltiples herramientas Unix en pipelines complejos
- Manejo de timeouts y conexiones lentas en verificaciones TLS
- Parsing correcto de URLs y extracción de dominios con `sed`

#### Administración de recursos
- Prevención de memory leaks con archivos temporales
- Coordinación de traps para limpieza automática
- Balance entre robustez y performance en verificaciones

---

### Imágenes de prueba de funcionalidad

#### Verificación HTTP:
<img width="1270" height="136" alt="captura-http" src="https://github.com/user-attachments/assets/c84d33a5-405e-4b7d-b0c0-67041ffc0626" />

#### Verificación TLS:
<img width="1278" height="221" alt="captura-tls" src="https://github.com/user-attachments/assets/baac7a51-5bb6-4906-9b59-a2d79496019c" />

#### Script de construcción (builder.sh):
<img width="915" height="218" alt="captura-builder" src="https://github.com/user-attachments/assets/012151f8-e761-43f8-94c5-6ac8625fbb70" />

---

## Guía de ejecución (Sprint 2)

### Requisitos previos
- Linux/Mac con **bash 4.0+**
- Dependencias: `make`, `nc`, `curl`, `dig`, `openssl`, `bats`

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
    ./out/monitor.sh monitor https://google.com
    ```

4. **Ejecutar monitoreo completo**
    ```bash
    ./out/monitor.sh monitor-complete https://github.com
    ```

5. **Verificaciones específicas**
    ```bash
    # HTTP con código esperado
    ./out/monitor.sh check-http https://httpbin.org/status/404 404
    
    # DNS completo con registros A y CNAME
    ./out/monitor.sh complete-dns github.com
    
    # TLS detallado con certificado
    ./out/monitor.sh detailed-tls https://cloudflare.com
    ```

6. **Ejecutar todas las pruebas**
    ```bash
    make test
    # o individualmente
    bats test/test_http.bats
    bats test/test_dns.bats
    bats test/test_tls.bats
    ```

7. **Monitoreo automatizado**
    ```bash
    export TARGETS="https://google.com https://github.com"
    ./out/monitor.sh run-all
    ```

### Variables de entorno (Sprint 2)
```bash
# Configuración DNS
export DNS_SERVER="1.1.1.1"  # Servidor DNS (defecto: 8.8.8.8)

# Targets de monitoreo
export TARGETS="https://site1.com https://site2.com"
```

### Logs generados
- `out/dns_[dominio].log`: Resultados de verificación DNS
- `out/tls_[dominio].log`: Información básica TLS
- `out/tls_detailed_[dominio].log`: Análisis TLS completo

## Links de videos de los Sprints
**Sprint 1**: https://drive.google.com/file/d/1qC4WKTOaIcJOuRhj3oYYUSobf3hbZLZs/view?usp=sharing

