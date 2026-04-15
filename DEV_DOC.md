# Developer Documentation

This document describes how a developer can set up, build, and manage the **Inception** project from scratch — a Docker-based infrastructure composed of **NGINX**, **WordPress**, and **MariaDB**.

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| `docker` | Container runtime |
| `docker compose` (v2) | Multi-container orchestration |
| `make` | Build automation via Makefile |
| `sudo` | Required for managing volume directories under `/home` |

---

## Project Structure

```
.
├── Makefile
├── .gitignore
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
├── secrets/                          # Sensitive credentials (not committed)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_pwd_admin.txt
│   └── wp_pwd_editor.txt
└── srcs/
    ├── .env                          # Environment variables (not committed)
    ├── docker-compose.yml            # Service definitions
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb_server.cnf
        │   └── tools/
        │       └── entrypoint_db.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   ├── nginx.conf
        │   │   └── nginx.conf.template
        │   └── tools/
        │       └── generate_ssl.sh
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── entrypoint_wp.sh
```

---

## Environment Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd inception
```

### 2. Create the `.env` file

Create `srcs/.env` with the following content:

```env
MYSQL_DATABASE=wpress_database
MYSQL_USER=wpress_user
WP_ADMIN_USER=masterUser
WP_EDITOR_USER=user
EDITOR_EMAIL=ole@editor.com
ADMIN_EMAIL=ola@admin.com
```

### 3. Populate the `secrets/` folder

The `secrets/` directory already exists in the repository. Fill in each file with the appropriate password:

```bash
echo "your_db_password"       > secrets/db_password.txt
echo "your_db_root_password"  > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_pwd_admin.txt
echo "your_wp_editor_password"> secrets/wp_pwd_editor.txt
```

These files are read by the container entrypoint scripts at startup and injected as environment variables inside each container. They must never be committed — they are already listed in `.gitignore`.

---

## Building and Launching the Project

```bash
# Build images and start all services (recommended first run)
make

# Build images only (also creates host data directories)
make build

# Start already-built services in detached mode
make up
```

Internally, `make build` does two things:
1. Creates persistent data directories at `/home/<your-user>/data/mariadb` and `/home/<your-user>/data/wordpress`
2. Runs `docker compose -f srcs/docker-compose.yml build` with `LOGIN` set to the current user

The `LOGIN` variable is detected automatically using `whoami` (or `logname` if running as root).

---

## Managing Containers and Volumes

```bash
# Stop all running services
make down

# Stop, remove containers and images, and prune Docker system
make clean

# Full reset: removes containers, images, volumes, and local data directories
make fclean

# Rebuild everything from scratch
make re
```

### Useful raw Docker commands

```bash
# List running containers
docker ps

# Enter a running container interactively
docker exec -it ngx_inception sh
docker exec -it wp_inception sh
docker exec -it mdb_inception sh

# Inspect a container's environment variables
docker inspect <container-name>

# List all Docker volumes
docker volume ls

# Remove a specific volume
docker volume rm <volume-name>
```

---

## Data Persistence

All persistent data is stored on the **host machine** and bind-mounted into the containers.

| Data | Host path | Container mount |
|------|-----------|-----------------|
| MariaDB database files | `/home/<yourUser>/data/mariadb` | `/var/lib/mysql` |
| WordPress files & uploads | `/home/<yourUser>/data/wordpress` | `/var/www/html` |

These directories are created automatically by `make build`. They survive `make down` and `make clean`, but are **permanently deleted by `make fclean`**.

---

## Rebuilding After Changes

After modifying a Dockerfile, entrypoint script, or config file:

```bash
# Full rebuild from scratch
make re

# Or rebuild a single service manually
LOGIN=$(whoami) docker compose -f srcs/docker-compose.yml build <service-name>
# service names: mdb_inception | wp_inception | ngx_inception
```

---

## Viewing Logs

```bash
# Follow logs for all services
make logs

# Follow logs for a specific service
make log-nginx    # srcs/requirements/nginx
make log-wp       # srcs/requirements/wordpress
make log-db       # srcs/requirements/mariadb
```