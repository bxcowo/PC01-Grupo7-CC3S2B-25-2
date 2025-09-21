#!/usr/bin/env bats

# Pruebas HTTP expandidas - Sprint 2

setup() {
    export TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_OUTPUT="$TEST_TEMP_DIR/test_output.log"

    # Trap para limpieza automática
    trap cleanup EXIT
}

cleanup() {
    [ -d "$TEST_TEMP_DIR" ] && rm -rf "$TEST_TEMP_DIR"
    [ -f "out/cleanup.done" ] && rm -f "out/cleanup.done"
}

@test "HTTP: Verificar código 200" {
    run ./out/monitor.sh check-http https://httpbin.org/status/200
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "200" ]]
}

@test "HTTP: Verificar código 404" {
    run ./out/monitor.sh check-http https://httpbin.org/status/404 404
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "404" ]]
}

@test "HTTP: Verificar código 500" {
    run ./out/monitor.sh check-http https://httpbin.org/status/500 500
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "500" ]]
}

@test "HTTP: Fallo de conexión" {
    run ./out/monitor.sh check-http http://ejemplo-que-no-existe-12345.com
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR" ]]
    [[ "$output" =~ "Conexión fallida" ]]
}

@test "HTTP: Código inesperado" {
    run ./out/monitor.sh check-http https://httpbin.org/status/404 200
    [ "$status" -eq 1 ]
    [[ "$output" =~ "WARNING" ]]
    [[ "$output" =~ "esperado\[200\] recibido\[404\]" ]]
}

@test "HTTP: URL sin parámetros debe fallar" {
    run ./out/monitor.sh check-http
    [ "$status" -eq 1 ]
    [[ "$output" =~ "URL requerida" ]]
}

@test "HTTP: Validar timeout en URL lenta" {
    skip "Test de timeout - demasiado lento para CI"
    run timeout 15 ./out/monitor.sh check-http https://httpbin.org/delay/10
    [ "$status" -ne 0 ] || [[ "$output" =~ "SUCCESS\|ERROR" ]]
}

@test "HTTP: Verificar redirección" {
    run ./out/monitor.sh check-http https://httpbin.org/redirect/1 200
    [ "$status" -eq 0 ]
    [[ "$output" =~ "200" ]]
}