# Makefile para Builder de Scripts de Monitoreo

-include .env

RELEASE ?= 1.0.0

.PHONY: tools build test run pack clean help

tools: ## Verificación de herramientas necesarias
	@echo "Verificando herramientas..."
	@which curl >/dev/null || (echo "Error: curl no encontrado" && exit 1)
	@which dig >/dev/null || (echo "Error: dig no encontrado" && exit 1)
	@which nc >/dev/null || (echo "Error: nc no encontrado" && exit 1)
	@which bats >/dev/null || (echo "Error: bats no encontrado" && exit 1)
	@echo "Todas las herramientas están disponibles"

build: tools ## Construcción de artefactos
	@mkdir -p out
	@echo "Construyendo scripts de monitoreo"
	@cat src/monitor.sh > out/monitor.sh
	@chmod +x out/monitor.sh
	@echo "Build completado en out/monitor.sh"

test: build ## Ejecución de pruebas
	@echo "Ejecutando suite de pruebas..."
	@bats tests/*.bats

run: build ## Ejecución del monitoreo
	@echo "Iniciando el monitoreo..."
	@./out/monitor.sh

pack: test ## Empaquetación final del código
	@mkdir -p dist
	@tar czf dist/monitor-$(RELEASE).tar.gz out/ src/ docs/
	@echo "Paquete creado: dist/monitor-$(RELEASE).tar.gz"

clean: ## Limpiar artefactos
	@echo "Limpiando artefactos..."
	@rm -rf out/ dist/

help: ## Muestra de comandos de ayuda
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
