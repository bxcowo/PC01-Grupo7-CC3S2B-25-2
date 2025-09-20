#!/bin/bash

# Script para verificar la disponibilidad de un puerto en un host, con reintentos.

# --- Dependencias ---
# Cargar el script de utilidades para la función de log
if [ -f "src/utils.sh" ]; then
    source "src/utils.sh"
else
    # Fallback a una función de log simple si no se encuentra utils.sh
    log() {
        local module=$1
        local level=$2
        shift 2
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$module-$level] $*"
    }
fi

# --- Variables Configurables ---
HOST=${1}                     # Host a verificar, primer argumento
PORT=${2}                      # Puerto a verificar, segundo argumento
RETRIES=${RETRIES:-5}          # Número de reintentos (configurable por variable de entorno)
WAIT_SECONDS=${WAIT_SECONDS:-3}  # Segundos de espera entre reintentos
TIMEOUT_NC=5                   # Timeout para la conexión de netcat en segundos

# --- Funciones ---

run_check() {
    log "HEALTH" "INFO" "Iniciando health-check para $HOST:$PORT..."

    local attempt=1
    while [ $attempt -le $RETRIES ]; do
        log "HEALTH" "INFO" "Intento $attempt/$RETRIES: Verificando conexión a $HOST:$PORT..."

        if nc -z -w $TIMEOUT_NC $HOST $PORT; then
            log "HEALTH" "SUCCESS" "Conexión exitosa. El puerto $PORT está abierto en $HOST."
            return 0
        fi

        if [ $attempt -lt $RETRIES ]; then
            log "HEALTH" "WARNING" "Fallo en el intento $attempt. Reintentando en $WAIT_SECONDS segundos..."
            sleep $WAIT_SECONDS
        fi

        ((attempt++))
    done

    log "HEALTH" "ERROR" "No se pudo establecer conexión con $HOST:$PORT después de $RETRIES intentos."
    return 1
}

show_help() {
    cat << 'EOF'
Script de Health Check con Netcat

Verifica si un puerto TCP está abierto en un host, con reintentos.

Uso: ./health_check.sh [HOST] [PUERTO]

Parámetros:
  HOST              - Host o IP a verificar (requerido).
  PUERTO            - Puerto TCP a verificar (requerido).

Variables de entorno:
  RETRIES           - Número de reintentos (defecto: 5).
  WAIT_SECONDS      - Segundos de espera entre reintentos (defecto: 3).

Ejemplos:
  ./health_check.sh localhost 8080
  RETRIES=10 WAIT_SECONDS=5 ./health_check.sh mi-servicio.local 443
EOF
}

# --- Lógica Principal ---
main() {
    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ -z "$1" ] || [ -z "$2" ]; then
        show_help
        exit 1
    fi

    run_check
}

# Ejecutar main si el script se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
