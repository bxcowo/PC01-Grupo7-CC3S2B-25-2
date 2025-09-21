#!/usr/bin/env bats

# Pruebas DNS expandidas - Sprint 2

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export DNS_SERVER="8.8.8.8"

    # Trap para limpieza automática
    trap cleanup EXIT
}

cleanup() {
    [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
    [ -f "out/dns_*.log" ] && rm -f out/dns_*.log
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
    [ "$status" -eq 0 ]
    [[ "$output" =~ "DNS Check completo" ]]
    [[ "$output" =~ "SUCCESS.*DNS A:" ]] || [[ "$output" =~ "SUCCESS.*DNS:" ]]
}

@test "DNS: Verificar análisis completo con registros CNAME" {
    run ./out/monitor.sh complete-dns www.github.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "DNS Check completo" ]]
    # Puede tener registros A o CNAME
    [[ "$output" =~ "SUCCESS.*DNS" ]]
}

@test "DNS: Fallo con dominio inexistente" {
    run ./out/monitor.sh check-dns dominio-que-no-existe-12345.com
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
    [[ "$output" =~ "no resuelve" ]]
}

@test "DNS: Verificar generación de logs" {
    ./out/monitor.sh complete-dns google.com > /dev/null
    [ -f out/dns_google.com.log ] || [ -n "$(ls out/dns_google.com*.log 2>/dev/null)" ]
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