#!/bin/bash

TARGETS=${TARGETS:-"https://www.google.com https://github.com"}
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
DNS_SERVER=${DNS_SERVER:-"8.8.8.8"}

log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
}

# verificar HTTP codes
check_http() {
    local url=$1
    local expected_code=${2:-200}
    
    log "INFO" "HTTP Check: $url"
    
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    local curl_exit=$?
    
    if [ $curl_exit -ne 0 ]; then
        log "ERROR" "HTTP: Conexión fallida - $url"
        return 1
    fi
    
    if [ "$response_code" = "$expected_code" ]; then
        log "SUCCESS" "HTTP: $url ($response_code)"
        return 0
    else
        log "WARNING" "HTTP: $url esperado[$expected_code] recibido[$response_code]"
        return 1
    fi
}

# verificar DNS
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

# Vverificar TLS
check_tls() {
    local url=$1
    local domain=$(echo "$url" | sed 's|^https\?://||' | cut -d'/' -f1 | cut -d':' -f1)
    
    if [[ ! "$url" =~ ^https:// ]]; then
        log "SKIP" "TLS: $url no es HTTPS"
        return 0
    fi
    
    log "INFO" "TLS Check: $domain"
    
    local cert_info=$(echo | timeout 10 openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$cert_info" ]; then
        local expiry=$(echo "$cert_info" | cut -d= -f2)
        log "SUCCESS" "TLS: $domain expira $expiry"
        return 0
    else
        log "ERROR" "TLS: $domain certificado inválido o inaccesible"
        return 1
    fi
}

# monitoreo completo de un target
monitor_target() {
    local target=$1
    local http_ok=0
    local dns_ok=0
    local tls_ok=0
    
    log "INFO" "=== Monitoreando: $target ==="
    
    check_dns "$target" && dns_ok=1
    check_http "$target" && http_ok=1
    check_tls "$target" && tls_ok=1
    
    local total=$((dns_ok + http_ok + tls_ok))
    log "INFO" "=== Resultado: $total/3 checks exitosos ==="
    echo
    
    return $((3 - total))
}

show_help() {
    cat << EOF
Monitor de sitios web - HTTP/DNS/TLS

Uso: $0 [COMANDO] [ARGUMENTOS]

Comandos:
  monitor URL              - Verificar HTTP+DNS+TLS de una URL
  check-http URL [CODE]    - Solo verificación HTTP (defecto: 200)
  check-dns URL            - Solo verificación DNS  
  check-tls URL            - Solo verificación TLS
  help                     - Mostrar esta ayuda

Ejemplos:
  $0 monitor https://www.google.com
  $0 check-http https://httpbin.org/status/404 404
  $0 check-dns https://github.com
  $0 check-tls https://www.google.com
EOF
}

# monitoreo
main() {
    case "${1:-}" in
        "monitor")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            monitor_target "$2"
            ;;
        "check-http")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_http "$2" "$3"
            ;;
        "check-dns")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_dns "$2"
            ;;
        "check-tls")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_tls "$2"
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

main "$@"