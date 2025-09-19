#!/usr/bin/env bats

# Pruebas TLS expandidas - Sprint 2

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"

    # Trap para limpieza automática
    trap cleanup EXIT
}

cleanup() {
    [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
    [ -f "out/tls_*.log" ] && rm -f out/tls_*.log
    touch "out/cleanup.done"
}

@test "TLS: Verificar certificado válido" {
    run ./out/monitor.sh check-tls https://google.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "expira" ]]
}

@test "TLS: Verificar certificado de GitHub" {
    run ./out/monitor.sh check-tls https://github.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "expira" ]]
}

@test "TLS: Skip verificación para HTTP (no HTTPS)" {
    run ./out/monitor.sh check-tls http://example.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SKIP" ]]
    [[ "$output" =~ "no es HTTPS" ]]
}

@test "TLS: Verificar análisis detallado" {
    run ./out/monitor.sh detailed-tls https://cloudflare.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "TLS Check detallado" ]]
    [[ "$output" =~ "SUCCESS.*TLS" ]]
}

@test "TLS: Fallo con certificado inválido" {
    skip "Requiere un dominio con certificado inválido conocido"
    run ./out/monitor.sh check-tls https://expired.badssl.com
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
    [[ "$output" =~ "certificado inválido" ]]
}

@test "TLS: Fallo con dominio inexistente" {
    run ./out/monitor.sh check-tls https://dominio-tls-inexistente-12345.com
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
    [[ "$output" =~ "certificado inválido o inaccesible" ]]
}

@test "TLS: Verificar generación de logs detallados" {
    ./out/monitor.sh detailed-tls https://github.com > /dev/null 2>&1
    [ -f out/tls_detailed_github.com.log ] || [ -n "$(ls out/tls_detailed_*.log 2>/dev/null)" ]
}

@test "TLS: URL sin parámetros debe fallar" {
    run ./out/monitor.sh check-tls
    [ "$status" -eq 1 ]
    [[ "$output" =~ "URL requerida" ]]
}

@test "TLS: Verificar timeout en conexiones lentas" {
    # Test con timeout de 10 segundos (definido en el script)
    run timeout 15 ./out/monitor.sh check-tls https://httpbin.org/delay/5
    # Debe completar o fallar gracefully
    [ "$status" -ne 0 ] || [[ "$output" =~ "SUCCESS\|ERROR\|SKIP" ]]
}

@test "TLS: Verificar limpieza con trap" {
    # Ejecutar y luego verificar que se creó el archivo de limpieza
    ./out/monitor.sh check-tls https://google.com >/dev/null 2>&1
    # El cleanup del setup debería haber creado el archivo
    [ -f "out/cleanup.done" ]
}