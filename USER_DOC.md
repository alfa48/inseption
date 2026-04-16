# User Documentation

This document explains how an end user or administrator can interact with the **Inception** stack — a containerized web infrastructure running **NGINX**, **WordPress**, and **MariaDB**.

---

## What Services Are Provided?

| Service | Description |
|---------|-------------|
| **NGINX** | Web server and reverse proxy. Handles all incoming HTTPS traffic on port `443` and forwards it to WordPress. |
| **WordPress** | Content management system (CMS). This is the website users and administrators interact with. |
| **MariaDB** | Relational database. Stores all WordPress content, users, and settings. Not directly accessible from outside the stack. |

---

## Starting and Stopping the Project

Open a terminal at the root of the project and run:

```bash
# Start all services (builds if needed)
make

# Stop all services (containers are stopped but data is preserved)
make down

# Stop and remove containers and images (data is preserved)
make clean

# Full reset — removes everything including volumes and stored data
make fclean
```

> `make fclean` will **delete all stored data**, including the database and uploaded files. Use with caution.

---

## Accessing the Website

Once the services are running, open your browser and go to:

```
https://manandre.42.fr
```

> The site is only accessible via **HTTPS on port 443**. If you are running this locally, make sure `manandre.42.fr` resolves to your machine by adding it to `/etc/hosts`:
> ```
> 127.0.0.1   manandre.42.fr
> ```

---

## Accessing the Administration Panel

The WordPress admin panel is available at:

```
https://manandre.42.fr/wp-admin
```

Log in with the admin credentials:

| Field    | Source                            |
|----------|-----------------------------------|
| Username | `WP_ADMIN_USER` in `srcs/.env`    |
| Password | `secrets/wp_pwd_admin.txt`        |
| Email    | `ADMIN_EMAIL` in `srcs/.env`      |

---

## Locating and Managing Credentials

Credentials are split across two locations:

### `srcs/.env`
Contains non-sensitive configuration values:
```env
MYSQL_DATABASE=wpress_database
MYSQL_USER=wpress_user
WP_ADMIN_USER=masterUser
WP_EDITOR_USER=user
EDITOR_EMAIL=ole@editor.com
ADMIN_EMAIL=ola@admin.com
```

### `secrets/` folder (project root)
Contains sensitive passwords as plain text files:

```
secrets/
├── db_password.txt        # MariaDB user password
├── db_root_password.txt   # MariaDB root password
├── wp_pwd_admin.txt       # WordPress admin user password
└── wp_pwd_editor.txt      # WordPress editor user password
```

> Never commit the `secrets/` folder or `srcs/.env` to version control. Both are already covered by `.gitignore`.

---

## Checking That Services Are Running

```bash
# View status of all containers
docker ps

# View real-time logs for all services
make logs

# View logs for a specific service
make log-nginx    # NGINX logs
make log-wp       # WordPress logs
make log-db       # MariaDB logs
```

A healthy output from `docker ps` should show three containers running:

| Container name  | Status |
|-----------------|--------|
| `ngx_inception` | `Up`   |
| `wp_inception`  | `Up`   |
| `mdb_inception` | `Up`   |