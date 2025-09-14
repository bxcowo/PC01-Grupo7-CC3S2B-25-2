#!/bin/bash

TARGETS=${TARGETS:-"https://google.com https://github.com"}
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
DNS_SERVER=${DNS_SERVER:-"8.8.8.8"}

log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
}

# verificar http
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

show_help() {
    cat << EOF
Monitor de sitios web - HTTP

Uso: $0 [COMANDO] [ARGUMENTOS]

Comandos:
  check-http URL [CODE]    - Verificación HTTP (defecto: 200)
  help                     - Mostrar esta ayuda

Ejemplos:
  $0 check-http https://google.com
  $0 check-http https://httpbin.org/status/404 404
EOF
}

# monitoreo
main() {
    case "${1:-}" in
        "check-http")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_http "$2" "$3"
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