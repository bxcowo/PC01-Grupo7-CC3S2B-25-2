#!/bin/bash

cat << 'EOF'
#!/bin/bash

if [ -f ".env" ]; then
    source .env
fi

TARGETS=${TARGETS:-"https://www.google.com https://github.com"}
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
DNS_SERVER=${DNS_SERVER:-"8.8.8.8"}
RETRIES=${RETRIES:-5}
WAIT_SECONDS=${WAIT_SECONDS:-3}
TIMEOUT_NC=${TIMEOUT_NC:-5}

EOF

# Extrae la función de log
sed -n '/^log()/,/^}/p' src/utils.sh
echo ""

# Extrae las funciones asociadas al análisis de HTTP
sed -n '/^check_http()/,/^}/p' src/check_http.sh
echo ""

# Extrae las funciones asociadas al análisis de DNS
sed -n '/^check_dns()/,/^}/p' src/check_dns.sh
echo ""
sed -n '/^complete_check_dns()/,/^}/p' src/check_dns.sh
echo ""

# Extrae las funciones asociadas al análisis de TLS
sed -n '/^check_tls()/,/^}/p' src/check_tls.sh
echo ""
sed -n '/^check_tls_detailed()/,/^}/p' src/check_tls.sh
echo ""

# Extrae las funciones asociadas al health check
sed -n '/^run_check()/,/^}/p' src/health_check.sh
echo ""

cat << 'EOF'
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

monitor_target_complete() {
    local target=$1
    local http_ok=0
    local dns_ok=0
    local tls_ok=0

    log "INFO" "=== Monitoreando COMPLETO: $target ==="

    complete_check_dns "$target" && dns_ok=1
    check_http "$target" && http_ok=1
    check_tls_detailed "$target" && tls_ok=1

    local total=$((dns_ok + http_ok + tls_ok))
    log "INFO" "=== Resultado COMPLETO: $total/3 checks exitosos ==="
    echo

    return $((3 - total))
}

show_help() {
    cat << 'HELP_EOF'
Monitor de sitios web - HTTP/DNS/TLS/Health Check

Uso: monitor.sh [COMANDO] [ARGUMENTOS]

Comandos:
  monitor URL              - Verificar HTTP+DNS+TLS de una URL
  monitor-complete URL     - Verificar HTTP+DNS+TLS completo de una URL
  check-http URL [CODE]    - Solo verificación HTTP (defecto: 200)
  check-dns URL            - Solo verificación DNS
  complete-dns URL         - DNS completo con registros A y CNAME
  check-tls URL            - Solo verificación TLS
  detailed-tls URL         - Verificación TLS detallada
  health-check HOST PORT   - Verificar conexión TCP a host:puerto
  run-all                  - Monitorear todos los targets configurados
  help                     - Mostrar esta ayuda

Variables de entorno:
  TARGETS, CHECK_INTERVAL, DNS_SERVER, RETRIES, WAIT_SECONDS

Ejemplos:
  ./monitor.sh monitor https://www.google.com
  ./monitor.sh check-http https://httpbin.org/status/404 404
  ./monitor.sh health-check localhost 8080
  ./monitor.sh run-all
HELP_EOF
}

main() {
    mkdir -p out

    case "${1:-run-all}" in
        "monitor")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            monitor_target "$2"
            ;;
        "monitor-complete")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            monitor_target_complete "$2"
            ;;
        "check-http")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_http "$2" "$3"
            ;;
        "check-dns")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_dns "$2"
            ;;
        "complete-dns")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            complete_check_dns "$2"
            ;;
        "check-tls")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_tls "$2"
            ;;
        "detailed-tls")
            [ -z "$2" ] && { log "ERROR" "URL requerida"; exit 1; }
            check_tls_detailed "$2"
            ;;
        "health-check")
            [ -z "$2" ] || [ -z "$3" ] && { log "ERROR" "HOST y PORT requeridos"; exit 1; }
            HOST="$2" PORT="$3" run_check
            ;;
        "run-all")
            log "INFO" "Iniciando monitoreo de targets: $TARGETS"
            local failed=0
            for target in $TARGETS; do
                monitor_target "$target" || ((failed++))
            done
            log "INFO" "Monitoreo completado. Fallos: $failed"
            exit $failed
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
EOF
