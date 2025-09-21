#!/bin/bash

check_tls() {
    local url=$1
    local domain=$(echo "$url" | sed 's|^https\?://||' | cut -d'/' -f1 | cut -d':' -f1)

    if [[ ! "$url" =~ ^https:// ]]; then
        log "TLS" "SKIP" "TLS: $url no es HTTPS"
        return 0
    fi

    log "TLS" "INFO" "TLS Check: $domain"

    local cert_info=$(echo | timeout 10 openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$cert_info" ]; then
        local expiry=$(echo "$cert_info" | cut -d= -f2)
        log "TLS" "SUCCESS" "TLS: $domain expira $expiry"

        # se guarda información del certificado
        echo "$cert_info" | sed 's/^/CERT: /' | tee -a "out/tls_${domain}.log" > /dev/null

        return 0
    else
        log "TLS" "ERROR" "TLS: $domain certificado inválido o inaccesible"
        return 1
    fi
}

check_tls_detailed() {
    local url=$1
    local domain=$(echo "$url" | sed 's|^https\?://||' | cut -d'/' -f1 | cut -d':' -f1)

    if [[ ! "$url" =~ ^https:// ]]; then
        log "TLS" "SKIP" "TLS: $url no es HTTPS"
        return 0
    fi

    log "TLS" "INFO" "TLS Check detallado: $domain"

    local -a tls_info=()

    # here-doc para configuración temporal
    cat <<EOF > /tmp/tls_config_$$.tmp
DOMAIN=$domain
URL=$url
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
CHECK_TYPE=detailed
EOF

    # obtener información completa del certificado
    local full_cert_info=$(echo | timeout 15 openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$full_cert_info" ]; then
        local subject=$(echo "$full_cert_info" | openssl x509 -noout -subject 2>/dev/null)
        local issuer=$(echo "$full_cert_info" | openssl x509 -noout -issuer 2>/dev/null)
        local dates=$(echo "$full_cert_info" | openssl x509 -noout -dates 2>/dev/null)

        if [ -n "$subject" ]; then
            log "TLS" "SUCCESS" "TLS Subject: $subject"
            tls_info+=("subject:$subject")
        fi

        if [ -n "$issuer" ]; then
            log "TLS" "SUCCESS" "TLS Issuer: $issuer"
            tls_info+=("issuer:$issuer")
        fi

        if [ -n "$dates" ]; then
            log "TLS" "SUCCESS" "TLS Dates: $dates"
            tls_info+=("dates:$dates")
        fi

        # se guarda información del certificado
        printf '%s\n' "${tls_info[@]}" | sed 's/^/TLS_DETAIL: /' | tee "out/tls_detailed_${domain}.log" > /dev/null

        log "TLS" "SUCCESS" "TLS: Verificación detallada completada para $domain"
    else
        log "TLS" "ERROR" "TLS: No se pudo obtener información del certificado para $domain"
        rm -f "/tmp/tls_config_$$.tmp"
        return 1
    fi

    rm -f "/tmp/tls_config_$$.tmp"
    return 0
}

show_help() {
    cat << 'EOF'
Verificación TLS de una url especÍfica

Uso: ./check_tls.sh [COMANDO] [URL]

Comandos:
  basic URL            - Verificación TLS básica
  detailed URL         - Verificación TLS detallada

Ejemplos:
  ./check_tls.sh basic https://www.google.com
  ./check_tls.sh detailed https://github.com
EOF
}

main() {
    mkdir -p out

    case "${1:-help}" in
        "basic")
            [ -z "$2" ] && { log "TLS" "ERROR" "URL requerida"; exit 1; }
            check_tls "$2"
            ;; 
        "detailed")
            [ -z "$2" ] && { log "TLS" "ERROR" "URL requerida"; exit 1; }
            check_tls_detailed "$2"
            ;; 
        "help"|"--help"|"-h")
            show_help
            ;; 
        *)
            if [ -n "$1" ] && [[ "$1" =~ ^https:// ]]; then
                check_tls "$1"
            else
                log "TLS" "ERROR" "Comando desconocido: $1"
                show_help
                exit 1
            fi
            ;; 
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi