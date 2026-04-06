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


# Resources

## Session Resource
- [Docker Official Documentation](https://docs.docker.com/)
- [Inception Guide 42 Project Part I](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)
- [Inception 42 Project Part II](https://medium.com/@ssterdev/inception-42-project-part-ii-19a06962cf3b)
- [Docker Nginx WordPress MariaDB Tutorial Inception42](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)