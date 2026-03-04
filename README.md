*This project has been created as part of the 42 curriculum by aledos-s.*

# Inception

## Description

Inception is a system administration project from 42 school. The goal is to set up a small but complete web infrastructure using **Docker** and **Docker Compose**, running inside a Virtual Machine.

Each service runs in its own dedicated container, built from scratch using custom Dockerfiles based on `debian:bullseye`. No pre-built images from DockerHub are used (except the base Debian image).

### Services included

**Mandatory:**
- **NGINX** — Web server, the only entry point via port 443 (TLSv1.2/TLSv1.3)
- **WordPress + PHP-FPM** — The main website
- **MariaDB** — Database for WordPress

**Bonus:**
- **Redis** — Cache layer for WordPress
- **Adminer** — Web UI to manage the database
- **FTP server** — File access to the WordPress volume
- **Static website** — Simple HTML portfolio page
- **Prometheus** — Metrics collection
- **cAdvisor** — Docker container metrics exporter
- **Grafana** — Monitoring dashboards

---

## Project Description

### Use of Docker

Docker allows us to package each service with its dependencies into an isolated container. Each container is built from a `Dockerfile` that describes exactly what to install and how to configure the service. `docker-compose.yml` then orchestrates all containers together — defining their network, volumes, dependencies, and restart policies.

### Design choices

- All images are based on `debian:bullseye` for consistency
- Passwords are never written in Dockerfiles or the `.env` file — they use Docker secrets (plain text files mounted read-only into containers)
- All containers restart automatically on crash (`restart: always`)
- WordPress is fully configured at first startup using WP-CLI (no manual setup needed)
- Redis cache is automatically activated at WordPress first boot

### Virtual Machines vs Docker

| | Virtual Machine | Docker Container |
|---|---|---|
| **Isolates** | Full OS + kernel | Just the process and its dependencies |
| **Size** | Several GB | A few MB to a few hundred MB |
| **Boot time** | Minutes | Seconds |
| **Use case** | Full OS isolation | Isolated, reproducible services |

A VM virtualizes hardware and runs a full OS. Docker containers share the host kernel and only isolate the process — they are much lighter and faster to start, but provide less isolation than a VM. In this project, Docker runs **inside** a VM, combining both approaches.

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| **Stored in** | Files on disk, mounted read-only | `.env` file or `environment:` block |
| **Visible in** | Only inside the container at runtime | `docker inspect`, process list |
| **Used for** | Passwords, API keys | Usernames, URLs, config values |

Environment variables are convenient but can be exposed accidentally (e.g. via `docker inspect`). Secrets are mounted as files inside the container at `/run/secrets/` and are never passed through the environment, making them safer for sensitive data like passwords.

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| **Isolation** | Containers are isolated from the host | Container shares the host's network stack |
| **Communication** | By service name (DNS resolution) | By localhost |
| **Security** | Better — ports must be explicitly exposed | Weaker — all host ports accessible |
| **Required by subject** | ✅ Yes | ❌ Forbidden |

In this project, all containers communicate through a custom bridge network called `inception`. Containers reach each other by name (e.g. `wordpress` connects to `mariadb` by using the hostname `mariadb`). Only NGINX exposes a port to the outside (443).

### Docker Volumes vs Bind Mounts

| | Named Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker | You (host path) |
| **Host path** | Automatic (or configurable) | Explicit path required |
| **Portability** | Better | Tied to the host filesystem |
| **Allowed by subject** | ✅ Yes | ❌ Forbidden for main data |

This project uses named volumes with a fixed host path (`/home/aledos-s/data/`) configured via `driver_opts`. This satisfies the subject requirement of using named volumes while storing data at a predictable location on the host.

---

## Instructions

### Prerequisites

- A Linux Virtual Machine
- Docker and Docker Compose installed
- `make` installed
- Your user added to the `docker` group: `sudo usermod -aG docker $USER`

### Setup

**1. Clone the repository:**
```bash
git clone <your-repo-url>
cd Inception
```

**2. Create the `.env` file:**
```bash
cp srcs/.env.example srcs/.env
# Edit srcs/.env and fill in your values
```

**3. Create the secrets:**
```bash
mkdir -p secrets
echo "your_db_password"    > secrets/db_password.txt
echo "your_root_password"  > secrets/db_root_password.txt
echo "your_admin_password" > secrets/admin_password.txt
echo "your_user2_password" > secrets/user2_password.txt
echo "your_ftp_password"   > secrets/ftp_password.txt
```

**4. Add the domain to `/etc/hosts`:**
```bash
echo "127.0.0.1 aledos-s.42.fr" | sudo tee -a /etc/hosts
```

**5. Build and start:**
```bash
make
```

### Access

| Service | URL |
|---|---|
| WordPress | `https://aledos-s.42.fr` |
| WordPress admin | `https://aledos-s.42.fr/wp-admin` |
| Adminer | `https://aledos-s.42.fr/adminer` |
| Grafana | `https://aledos-s.42.fr/grafana/` |
| Static site | `https://aledos-s.42.fr/static` |

> Your browser will warn about the self-signed SSL certificate — click "Advanced" and accept to continue.

### Makefile commands

| Command | Description |
|---|---|
| `make` | Build and start all containers |
| `make down` | Stop containers (data preserved) |
| `make clean` | Stop containers and remove images |
| `make fclean` | Remove everything including data |
| `make re` | Full rebuild from scratch |
| `make logs` | Follow all container logs |
| `make ps` | Show container status |

---

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [Redis documentation](https://redis.io/docs/)
- [Prometheus documentation](https://prometheus.io/docs/)
- [Grafana documentation](https://grafana.com/docs/)
- [cAdvisor GitHub](https://github.com/google/cadvisor)

### Articles and tutorials
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [PID 1 problem in containers](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Docker secrets explained](https://docs.docker.com/engine/swarm/secrets/)
- [Understanding Docker networking](https://docs.docker.com/network/)

### How AI was used in this project

AI (Claude by Anthropic) was used as a learning and productivity tool throughout the project:

- **Debugging** — Understanding error messages from Docker builds and container logs
- **Dockerfile structure** — Getting explanations on best practices (PID 1, exec form, layer caching)
- **Configuration files** — Generating initial versions of nginx.conf, vsftpd.conf, prometheus.yml and grafana.ini, which were then reviewed, tested and adjusted manually
- **Documentation** — Helping structure and write this README, USER_DOC.md and DEV_DOC.md

All AI-generated content was reviewed, understood, and tested before being included in the project.