#!/bin/bash

# Funciones de utilidad compartidas

# Función de logging unificada.
# Uso: log "MODULO" "NIVEL" "Mensaje..."
log() {
    local module=$1
    local level=$2
    shift 2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$module-$level] $*"
}