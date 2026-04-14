# Variáveis
LOGIN = $(shell whoami)
ifeq ($(LOGIN), root)
	LOGIN = $(shell logname)
endif

COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(LOGIN)/data

all: build up

# Create data directories
$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

# construir as imagens
build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) build

# Inciar serviços
up:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) up -d --remove-orphans

# Parar serviços
down:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) down

# Parar e remover containers and imagens
clean:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af

# Limpeza profunda incluindo volumes e dados
fclean: clean
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	sudo rm -rf $(DATA_DIR)
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@chmod 777 $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

# Rebuild everything
re: fclean all

# Logs
logs:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f

log-db:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f mdb_inception

log-wp:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f wp_inception

log-nginx:
	LOGIN=$(LOGIN) docker compose -f $(COMPOSE_FILE) logs -f ngx_inception

.PHONY: all build up down clean fclean re logs log-db log-wp log-nginx