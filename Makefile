# variaveis
LOGIN = $(shell whoami)
ifeq ($(LOGIN), root)
	LOGIN = $(shell logname)
endif

COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(LOGIN)/data

all: build up ## Construir as imagens e iniciar os containers

# cirar pastas de dados, para o banco de dados e para o wordpress
$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress ## Construir as imagens
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) build


up: ## Inciar containers
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) up -d --remove-orphans


down: ## Parar containers
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) down


clean: ## Parar e remover containers e as imagens
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af


fclean: clean ## Parar os containers e remover as imagens e os volumees de dados
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	sudo rm -rf $(DATA_DIR)
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@chmod 777 $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

re: fclean all ## Reconstruir tudo


logs: ## Mostrar logs de todos os containers
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f

log-db: ## Mostrar logs do container do banco de dados
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f mdb_inception

log-wp: ## Mostrar logs do container do wordpress
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f wp_inception

log-nginx: ## Mostrar logs do container do nginx
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f ngx_inception

help: ## Mostrar ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

.PHONY: all build up down clean fclean re logs log-db log-wp log-nginx help

print:
	@echo $(MAKEFILE_LIST)