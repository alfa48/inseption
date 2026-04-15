*The very first line must be italicized and read: This project has been created as part of the 42 curriculum by manandre.*

#  Description

Inception consists of building a complete web services infrastructure using Docker and Docker Compose, following best practices for isolation and configuration. The main idea is to create a small, fully containerized __ecosystem of servers__.”

The goal is to configure multiple services that work together, such as a web server __Nginx__, a database __MariaDB__, and a content management system __WordPress__, all running in separate containers but interconnected to form a complete and functional application.


# Project description
## Use of Docker

Docker is used to containerize each service, ensuring isolation, reproducibility, and consistency across environments. Instead of relying on pre-built images, this project emphasizes building custom images tailored to the specific needs of each service.

Key aspects:

- Each service runs in its own container
- Services communicate through a dedicated Docker network
- Persistent data is stored using volumes
- Configuration is handled via environment variables and/or secrets
- Docker Compose orchestrates the entire setup
*The very first line must be italicized and read: This project has been created as part of the 42 curriculum by manandre.*

#  Description

Inception consists of building a complete web services infrastructure using Docker and Docker Compose, following best practices for isolation and configuration. The main idea is to create a small, fully containerized __ecosystem of servers__.”

The goal is to configure multiple services that work together, such as a web server __Nginx__, a database __MariaDB__, and a content management system __WordPress__, all running in separate containers but interconnected to form a complete and functional application.


# Project description
## Use of Docker

Docker is used to containerize each service, ensuring isolation, reproducibility, and consistency across environments. Instead of relying on pre-built images, this project emphasizes building custom images tailored to the specific needs of each service.

Key aspects:

- Each service runs in its own container
- Services communicate through a dedicated Docker network
- Persistent data is stored using volumes
- Configuration is handled via environment variables and/or secrets
- Docker Compose orchestrates the entire setup

## Design Choices

- Separation of concerns: Each service (Nginx, MariaDB, WordPress) is isolated in its own container
- Security: Sensitive data is not hardcoded and is managed through environment variables or secrets
- Persistence: Data is preserved using Docker volumes
- Custom configuration: Services are built using custom Dockerfiles rather than relying on ready-made images
- Networking: Containers communicate over an internal network rather than exposing unnecessary ports

## Comparisons
### Virtual Machines vs Docker

|    Virtual Machines       |           Docker          |  
|---------------------------|---------------------------|
| Full OS per instance 	    | Shares host OS kernel     |
| Heavier, slower startup	| Lightweight, fast startup |
| More resource consumption	| Efficient resource usage  |
| Strong isolation	        | Process-level isolation   |

## Secrets vs Environment Variables

| Secrets                                  | Environment Variablesme           |
|------------------------------------------|-----------------------------------|
| More secure (not exposed in plain text)  | Easier to use                     |
| Stored separately from code              | Often stored in config files      |
| Ideal for passwords, keys                | Suitable for non-sensitive configs|
| Harder to manage locally                 | Simple and widely supported       |

## Docker Network vs Host Network
| Docker Network	                | Host Network                       |
|-----------------------------------|------------------------------------|
| Isolated container communication  | Shares host network directly       |
| Safer and more controlled	        | Less secure                        |
| Custom internal DNS	            | No isolation                       |
| Default for multi-container apps  | Used for performance-critical cases|

## Docker Volumes vs Bind Mounts
| Docker Volumes	         | Bind Mounts                   |
|----------------------------|-------------------------------|
| Managed by Docker	         | Linked to host filesystem     |
| Better portability	     | Depends on host structure     |
| Safer and easier to backup | More flexible for development |
| Recommended for production | Common in development         |

# Instructions


# Resources
## Design Choices

- Separation of concerns: Each service (Nginx, MariaDB, WordPress) is isolated in its own container
- Security: Sensitive data is not hardcoded and is managed through environment variables or secrets
- Persistence: Data is preserved using Docker volumes
- Custom configuration: Services are built using custom Dockerfiles rather than relying on ready-made images
- Networking: Containers communicate over an internal network rather than exposing unnecessary ports

## Comparisons
### Virtual Machines vs Docker

|    Virtual Machines       |           Docker          |  
|---------------------------|---------------------------|
| Full OS per instance 	    | Shares host OS kernel     |
| Heavier, slower startup	| Lightweight, fast startup |
| More resource consumption	| Efficient resource usage  |
| Strong isolation	        | Process-level isolation   |

## Secrets vs Environment Variables

| Secrets                                  | Environment Variablesme           |
|------------------------------------------|-----------------------------------|
| More secure (not exposed in plain text)  | Easier to use                     |
| Stored separately from code              | Often stored in config files      |
| Ideal for passwords, keys                | Suitable for non-sensitive configs|
| Harder to manage locally                 | Simple and widely supported       |

## Docker Network vs Host Network
| Docker Network	                | Host Network                       |
|-----------------------------------|------------------------------------|
| Isolated container communication  | Shares host network directly       |
| Safer and more controlled	        | Less secure                        |
| Custom internal DNS	            | No isolation                       |
| Default for multi-container apps  | Used for performance-critical cases|

## Docker Volumes vs Bind Mounts
| Docker Volumes	         | Bind Mounts                   |
|----------------------------|-------------------------------|
| Managed by Docker	         | Linked to host filesystem     |
| Better portability	     | Depends on host structure     |
| Safer and easier to backup | More flexible for development |
| Recommended for production | Common in development         |

# Instructions

## Prerequisites

- Docker and Docker Compose installed
- `sudo` available for volume operations
- Access to the domain `manandre.42.fr` (port `443` — HTTPS)

---

## Required Structure

Before starting, make sure you have the following files and folders created at the root of the project:

### 1. `.env` File
Create the file `srcs/.env` with the following environment variables:

```env
MYSQL_DATABASE=wpress_database
MYSQL_USER=wpress_user
WP_ADMIN_USER=masterUser
WP_EDITOR_USER=user
EDITOR_EMAIL=ole@editor.com
ADMIN_EMAIL=ola@admin.com
```

### 2. `secrets/` Folder
Create a `secrets/` folder at the **root of the project** containing the sensitive credential files (passwords, etc.) required by the services.

---

## Available Commands

| Command          | Description                                                         |
|------------------|---------------------------------------------------------------------|
| `make`           | Builds the images and starts all services                           |
| `make build`     | Creates the data folders and builds the Docker images               |
| `make up`        | Starts the services in *detached* mode                              |
| `make down`      | Stops the services                                                  |
| `make clean`     | Stops services, removes containers, images, and runs a system prune |
| `make fclean`    | Deep clean — removes everything, including volumes and local data   |
| `make re`        | Runs `fclean` followed by `all` (full rebuild)                      |
| `make logs`      | Shows logs for all services in real time                            |
| `make log-db`    | Logs for the MariaDB service only                                   |
| `make log-wp`    | Logs for the WordPress service only                                 |
| `make log-nginx` | Logs for the NGINX service only                                     |

---

### How to Start the Project

```bash
# 1. Clone the repository
git clone <repository-url>
cd <project-name>

# 2. Create the environment variables file
cp srcs/.env.example srcs/.env  # or create it manually as shown above

# 3. Create the secrets folder with the required credentials
mkdir -p secrets

# 4. Build and start the services
make
```

Once running, access the project at:

```
https://manandre.42.fr
```

>  The application is available **only via HTTPS on port 443**. Make sure the domain `manandre.42.fr` resolves to your host — you may need to add an entry to `/etc/hosts` if running locally.

# Resources

## Session Resource
- [Docker Official Documentation](https://docs.docker.com/)
- [WordPress Official Documentation](https://pt-ao.wordpress.org/)
- [Nginx Official Documenatation](https://nginx.org/)
- [Inception Guide](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)

## AI Usage

AI was used in specific parts of this project to support development and learning — not to replace understanding of the concepts involved.

---

### Tasks where AI was used

| Area | Task |
|------|------|
| **Docker & Compose** | Helped debug `docker-compose.yml` configuration and understand service dependencies (`depends_on`, healthchecks) |
| **NGINX** | Assisted in writing the NGINX config for TLS (SSL certificate setup, HTTPS-only on port 443, reverse proxy to WordPress) |
| **MariaDB** | Helped structure the database initialization scripts and troubleshoot connection issues between WordPress and MariaDB |
| **WordPress** | Supported the `wp-config.php` setup and WP-CLI automation for installing WordPress non-interactively via entrypoint scripts |
| **Secrets management** | Advised on how to handle sensitive credentials using Docker secrets and environment variable separation |
| **Debugging** | Used to interpret Docker error logs and diagnose container startup failures |
---

### Disclaimer

- Every AI suggestion was **manually reviewed, tested, and validated** before being used
- AI was only used for tasks I already had enough context to **critically evaluate the output**
- Whenever AI produced something I didn't fully understand, I researched it independently or discussed it with peers before accepting it
- No AI-generated code or configuration was included without being able to **explain and justify** every part of it
- The final understanding of the infrastructure, all architectural decisions, and responsibility for the project remain entirely with the author