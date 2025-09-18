#!/bin/bash

# Script de análisis DNS mejorado para Sprint 2
# Implementa verificación de registros A y CNAME con dig

if [ -f ".env" ]; then
    source .env
fi

# Variables de entorno
DNS_SERVER=${DNS_SERVER:-"8.8.8.8"}

log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DNS-$level] $*"
}

# Función DNS básica original (compatible con monitor.sh)
check_dns() {
    local domain=$(echo "$1" | sed 's|^https\?://||' | cut -d'/' -f1 | cut -d':' -f1)

    log "INFO" "DNS Check: $domain"

    if dig +short @$DNS_SERVER "$domain" > /dev/null 2>&1; then
        log "SUCCESS" "DNS: $domain resuelve correctamente"
        return 0
    else
        log "ERROR" "DNS: $domain no resuelve"
        return 1
    fi
}

# Función DNS completa con registros A y CNAME (Sprint 2)
complete_check_dns() {
    local domain=$(echo "$1" | sed 's|^https\?://||' | cut -d'/' -f1 | cut -d':' -f1)
    local status=0

    log "INFO" "DNS Check completo: $domain"

    # Array para almacenar resultados
    local -a dns_results=()

    # Here-doc para configuración temporal
    cat <<EOF > /tmp/dns_config_$$.tmp
DOMAIN=$domain
DNS_SERVER=$DNS_SERVER
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
EOF

    # Consultar registros A
    local a_records=$(dig +short @$DNS_SERVER A "$domain" 2>/dev/null)
    if [ -n "$a_records" ]; then
        echo "$a_records" | head -1 | while read -r ip; do
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                log "SUCCESS" "DNS A: $domain -> $ip"
                dns_results+=("A:$ip")
            fi
        done
        # Usar tee para guardar resultados
        echo "$a_records" | sed 's/^/A: /' | tee -a "out/dns_${domain}.log" > /dev/null
    else
        log "WARNING" "DNS: No se encontraron registros A para $domain"
        status=1
    fi

    # Consultar registros CNAME
    local cname_records=$(dig +short @$DNS_SERVER CNAME "$domain" 2>/dev/null)
    if [ -n "$cname_records" ]; then
        echo "$cname_records" | while read -r cname; do
            log "SUCCESS" "DNS CNAME: $domain -> $cname"
            dns_results+=("CNAME:$cname")
        done
        # Usar sed y tee para procesar y guardar
        echo "$cname_records" | sed 's/^/CNAME: /' | tee -a "out/dns_${domain}.log" > /dev/null
    else
        log "INFO" "DNS: No se encontraron registros CNAME para $domain"
    fi

    # Limpiar archivos temporales
    rm -f "/tmp/dns_config_$$.tmp"

    # Verificar si al menos resuelve básicamente
    if [ -z "$a_records" ] && [ -z "$cname_records" ]; then
        log "ERROR" "DNS: $domain no resuelve"
        return 1
    else
        log "SUCCESS" "DNS: $domain resuelve correctamente"
        return $status
    fi
}

show_help() {
    cat << 'EOF'
Script DNS mejorado - Sprint 2

Uso: check_dns.sh [COMANDO] [DOMINIO]

Comandos:
  basic DOMINIO          - Verificación DNS básica (compatible con monitor.sh)
  complete DOMINIO       - Análisis DNS completo con registros A y CNAME
  help                   - Mostrar esta ayuda

Descripción:
  - basic: Verificación simple de resolución DNS
  - complete: Análisis completo con dig, here-docs, arrays y Unix tools (sed, tee)

Variables de entorno:
  DNS_SERVER     - Servidor DNS (defecto: 8.8.8.8)

Ejemplos:
  ./check_dns.sh basic google.com
  ./check_dns.sh complete https://github.com
EOF
}

main() {
    # Crear directorio de salida
    mkdir -p out

    case "${1:-help}" in
        "basic")
            [ -z "$2" ] && { log "ERROR" "Dominio requerido"; exit 1; }
            check_dns "$2"
            ;;
        "complete")
            [ -z "$2" ] && { log "ERROR" "Dominio requerido"; exit 1; }
            complete_check_dns "$2"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log "ERROR" "Comando desconocido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar main si el script se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
