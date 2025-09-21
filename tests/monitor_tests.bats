#!/usr/bin/env bats
# Pruebas para verificación HTTP del monitor.sh

@test "Verificar código HTTP 200" {
    run ./out/monitor.sh check-http https://httpbin.org/status/200
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "200" ]]
}

@test "Verificar código HTTP 404 esperado" {
    run ./out/monitor.sh check-http https://httpbin.org/status/404 404
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "404" ]]
}

@test "Verificar DNS check" {
    run ./out/monitor.sh check-dns https://google.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "resuelve correctamente" ]]
}

@test "Verificar TLS check" {
    run ./out/monitor.sh check-tls https://google.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS" ]]
    [[ "$output" =~ "expira" ]]
}

@test "Verificar monitoreo completo" {
    run ./out/monitor.sh monitor https://google.com
    [ "$status" -ge 0 ]
    [[ "$output" =~ "=== Monitoreando" ]]
    [[ "$output" =~ "checks exitosos" ]]
}

@test "Verificar help" {
    run ./out/monitor.sh help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Uso:" ]]
    [[ "$output" =~ "check-http" ]]
}

@test "Verificar comando inválido" {
    run ./out/monitor.sh comando-inexistente
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Comando desconocido" ]]
}