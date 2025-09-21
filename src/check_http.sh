#!/bin/bash

# verificar HTTP codes
check_http() {
    local url=$1
    local expected_code=${2:-200}

    log "HTTP" "INFO" "HTTP Check: $url"

    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    local curl_exit=$?

    if [ $curl_exit -ne 0 ]; then
        log "HTTP" "ERROR" "HTTP: Conexión fallida - $url"
        return 1
    fi

    if [ "$response_code" = "$expected_code" ]; then
        log "HTTP" "SUCCESS" "HTTP: $url ($response_code)"
        return 0
    else
        log "HTTP" "WARNING" "HTTP: $url esperado[$expected_code] recibido[$response_code]"
        return 1
    fi
}

show_help() {
    cat << 'EOF'
Verificación HTTP de una url especÍfica

Uso: ./check_http.sh [URL] [CODE]

Parámetros:
  URL               - URL a verificar (requerido)
  CODE              - Código HTTP esperado (defecto: 200)

Variables de entorno:
  Ninguna específica para este script

Ejemplos:
  ./check_http.sh https://www.google.com 
  ./check_http.sh https://httpbin.org/status/404 404
  ./check_http.sh https://github.com 200
EOF
}

main() {
    case "${1:-help}" in
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            [ -z "$1" ] && { log "HTTP" "ERROR" "URL requerida"; exit 1; }
            check_http "$1" "$2"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi