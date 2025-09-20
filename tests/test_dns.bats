#!/usr/bin/env bats

# Pruebas DNS expandidas - Sprint 2

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export DNS_SERVER="8.8.8.8"
    
    # Crear directorio out si no existe
    mkdir -p out

    # Trap para limpieza automática
    trap cleanup EXIT
}

cleanup() {
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
    # Limpiar archivos de log DNS
    rm -f out/dns_*.log 2>/dev/null || true
}

@test "DNS: Verificar resolución básica de dominio válido" {
    run ./out/monitor.sh check-dns google.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "resuelve correctamente" ]]
}

@test "DNS: Verificar resolución de URL completa" {
    run ./out/monitor.sh check-dns https://github.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "resuelve correctamente" ]]
}

@test "DNS: Verificar análisis completo con registros A" {
    run ./out/monitor.sh complete-dns google.com
    # Debe completar sin error crítico
    [[ "$output" =~ "DNS Check completo" ]]
}

@test "DNS: Verificar análisis completo con registros CNAME" {
    run ./out/monitor.sh complete-dns www.github.com
    # Debe completar sin error crítico
    [[ "$output" =~ "DNS Check completo" ]]
}

@test "DNS: Fallo con dominio inexistente" {
    # Usar un dominio con caracteres inválidos que dig rechazará inmediatamente
    run timeout 3 ./out/monitor.sh check-dns "invalid..domain"
    # El test debe fallar debido a formato inválido
    [ "$status" -ne 0 ]
}

@test "DNS: Verificar generación de logs" {
    ./out/monitor.sh complete-dns google.com > /dev/null 2>&1
    # Verificar que se creó algún archivo de log
    if ls out/dns_*.log > /dev/null 2>&1; then
        true
    elif [ -f "out/dns_google.com.log" ]; then
        true
    else
        false
    fi
}

@test "DNS: Verificar formato de salida con sed/tee" {
    run ./out/monitor.sh complete-dns cloudflare.com
    [ "$status" -eq 0 ]
    # Verificar que se usaron las herramientas Unix (sed, tee)
    [[ "$output" =~ "DNS Check completo" ]]
}

@test "DNS: URL sin parámetros debe fallar" {
    run ./out/monitor.sh check-dns
    [ "$status" -eq 1 ]
    [[ "$output" =~ "URL requerida" ]]
}

@test "DNS: Verificar extracción correcta de dominio" {
    run ./out/monitor.sh check-dns https://subdomain.example.com/path?query=1
    # Debe extraer solo subdomain.example.com
    [[ "$output" =~ "subdomain.example.com" ]]
}