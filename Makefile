# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

all: build up

# Create data directories
$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

# construir as imagens
build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

# Inciar serviços
up:
	docker compose -f $(COMPOSE_FILE) up -d

# Parar serviços
down:
	docker compose -f $(COMPOSE_FILE) down

# Parar e remover containers and imagens
clean:
	docker compose -f $(COMPOSE_FILE) down
	docker system prune -af

# Limpeza profunda incluindo volumes e dados
fclean: clean
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

# Rebuild everything
re: fclean all

.PHONY: all build up down clean fclean re