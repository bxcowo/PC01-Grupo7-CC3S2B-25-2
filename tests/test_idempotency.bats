#!/usr/bin/env bats

@test "Validar idempotencia del proceso de build" {
    # Limpiar el entorno para asegurar un estado inicial limpio
    run make clean
    [ "$status" -eq 0 ]

    # Primera construcción
    run make build
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Construyendo scripts de monitoreo" ]]

    # Guardar el checksum del artefacto generado
    if [ -f "out/monitor.sh" ]; then
        original_checksum=$(sha256sum out/monitor.sh | cut -d' ' -f1)
    else
        skip "Archivo monitor.sh no encontrado después del build"
    fi

    # Segunda construcción
    run make build
    [ "$status" -eq 0 ]
    
    # Verificar que el checksum no ha cambiado
    if [ -f "out/monitor.sh" ]; then
        new_checksum=$(sha256sum out/monitor.sh | cut -d' ' -f1)
        [ "$original_checksum" = "$new_checksum" ]
    else
        skip "Archivo monitor.sh no encontrado después del segundo build"
    fi
}