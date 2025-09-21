# Makefile para Builder de Scripts de Monitoreo

-include .env

# Variables de configuracion
RELEASE ?= 1.0.0
URL ?= https://github.com
SRC_DIR := src
OUT_DIR := out
DIST_DIR := dist
TESTS_DIR := tests

# Fuentes y objetivos para reglas patron
CHECK_SCRIPTS := $(wildcard $(SRC_DIR)/check_*.sh)
BUILDER_SCRIPT := $(SRC_DIR)/builder.sh
MONITOR_SCRIPT := $(OUT_DIR)/monitor.sh
TESTS_SCRIPT := $(wildcard $(TESTS_DIR)/*.bats)

# Definición de Empaquetación
DIST_PACK := $(DIST_DIR)/monitor-$(RELEASE).tar.gz

# Herramientas necesarias
NEED_TOOLS := curl dig nc bats

# Crear directorios necesarios
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

.PHONY: tools build test run run-complete run-targets pack clean help

tools: ## Verificación de herramientas necesarias
	@echo "Verificando herramientas..."
	@for tool in $(NEED_TOOLS); do \
        which $$tool >/dev/null || (echo "Error: $$tool no encontrado" && exit 1); \
	done
	@echo "Todas las herramientas están disponibles"

build: tools $(OUT_DIR) ## Construcción de artefactos
	@echo "Construyendo scripts de monitoreo"
	@bash $(BUILDER_SCRIPT) > $(MONITOR_SCRIPT)
	@chmod +x $(MONITOR_SCRIPT)
	@echo "Build completado en $(MONITOR_SCRIPT)"

test: build ## Ejecución de pruebas
	@echo "Ejecutando suite de pruebas..."
	@bats $(TESTS_SCRIPT)

run: build ## Ejecución del monitoreo
	@echo "Iniciando el monitoreo completo..."
	@./$(MONITOR_SCRIPT) monitor $(URL)

run-complete: build ## Ejecución del monitoreo con resultados más detallados
	@echo "Iniciando el monitoreo completo..."
	@./$(MONITOR_SCRIPT) monitor-complete $(URL)

run-targets: build ## Ejecución del montireo en base a targets
	@echo "Iniciando el monitoreo de los targets..."
	@./$(MONITOR_SCRIPT) run-all

pack: test $(DIST_DIR) ## Empaquetación final del código
	@tar czf $(DIST_PACK) $(OUT_DIR)
	@echo "Paquete creado: $(DIST_PACK)"

clean: ## Limpiar artefactos
	@echo "Limpiando artefactos..."
	@rm -rf $(OUT_DIR) $(DIST_DIR)

help: ## Muestra de comandos de ayuda
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
