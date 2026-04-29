<div align="center">

![Inception](./inception-banner.png)

#  Inception — Dockerized Web Infrastructure

### *A complete multi-service web stack built from scratch — NGINX, WordPress, MariaDB, Redis, Grafana & more — all in custom Docker containers.*

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Compose](https://img.shields.io/badge/Docker%20Compose-2496ED?style=flat&logo=docker&logoColor=white)
![Debian](https://img.shields.io/badge/Base-debian%3Abullseye-A81D33?style=flat&logo=debian&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=flat&logo=nginx&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=flat&logo=wordpress&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat&logo=mariadb&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat&logo=redis&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)
![42](https://img.shields.io/badge/42-Lausanne-000?style=flat&logo=42&logoColor=white)

</div>

---

*This project has been created as part of the 42 curriculum by aledos-s.*


---

##  Overview

**Inception** is a system-administration project from 42 school. The goal: build a **complete, production-style web infrastructure** using **Docker** and **Docker Compose**, running inside a Virtual Machine.

Every service ships in its own dedicated container — built from scratch using **custom Dockerfiles based on `debian:bullseye`**. No pre-built images from DockerHub are used (except the Debian base).

**What makes it interesting:**

-  **From-scratch** Dockerfiles — no pulling `wordpress:latest`, everything compiled/configured by hand
-  **Docker secrets** instead of environment variables for passwords
-  **Custom bridge network** — containers talk by service name
-  **Auto-configured** WordPress via WP-CLI on first boot
-  **Full observability** (bonus): Prometheus + cAdvisor + Grafana

---

##  Demo

<!-- TODO: add a screenshot of the WordPress site + a Grafana dashboard -->

**Stack at a glance:**

```
           port 443 (TLS 1.2/1.3) 
                                
                           
                             NGINX    ← only entry point
                           
                                  (inception bridge network)
         
                                                   
          
    WordPress Static   Adminer    Grafana    FTP  
     + PHP     site      
                        
                                          
                
     MariaDB    Redis    Prometheus cAdvisor 
                
```

**Services:**

 Type  Service  Role
---------------------
  Mandatory  **NGINX**  Web server, sole entry point (port 443, TLS 1.2/1.3)
  Mandatory  **WordPress + PHP-FPM**  Main website
  Mandatory  **MariaDB**  WordPress database
  Bonus  **Redis**  Cache layer for WordPress
  Bonus  **Adminer**  Web UI to manage the database
  Bonus  **vsftpd**  FTP access to the WordPress volume
  Bonus  **Static site**  Plain HTML portfolio page
  Bonus  **Prometheus**  Metrics collection
  Bonus  **cAdvisor**  Per-container metrics exporter
  Bonus  **Grafana**  Monitoring dashboards

---

##  Quick Start

### Prerequisites

- Linux Virtual Machine
- Docker & Docker Compose installed
- `make`
- User added to the `docker` group: `sudo usermod -aG docker $USER`

### Setup

```bash
# 1. Clone
git clone git@github.com:XI-X-IX/Inception.git
cd Inception

# 2. Environment
cp srcs/.env.example srcs/.env
# → edit srcs/.env with your values

# 3. Secrets (never committed)
mkdir -p secrets
echo "your_db_password"    > secrets/db_password.txt
echo "your_root_password"  > secrets/db_root_password.txt
echo "your_admin_password" > secrets/admin_password.txt
echo "your_user2_password" > secrets/user2_password.txt
echo "your_ftp_password"   > secrets/ftp_password.txt

# 4. Local DNS
echo "127.0.0.1 aledos-s.42.fr"  sudo tee -a /etc/hosts

# 5. Launch
make
```

### Access

 Service  URL
--------------
 WordPress  `https://aledos-s.42.fr`
 WordPress admin  `https://aledos-s.42.fr/wp-admin`
 Adminer  `https://aledos-s.42.fr/adminer`
 Grafana  `https://aledos-s.42.fr/grafana/`
 Static site  `https://aledos-s.42.fr/static`

> Your browser will warn about the self-signed SSL certificate — click **Advanced** → **Accept** to continue.

### Makefile commands

 Command  Description
----------------------
 `make`  Build and start all containers
 `make down`  Stop containers (data preserved)
 `make clean`  Stop containers and remove images
 `make fclean`  Remove everything including data
 `make re`  Full rebuild from scratch
 `make logs`  Follow all container logs
 `make ps`  Show container status

---

##