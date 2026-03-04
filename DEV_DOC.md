# Developer Documentation

## Prerequisites

- A Linux Virtual Machine (Debian or Ubuntu recommended)
- Docker and Docker Compose installed
- `make` installed
- Your login added to the `docker` group (to run docker without sudo):
```bash
sudo usermod -aG docker $USER
# Log out and back in for the change to take effect
```

---

## Set up the environment from scratch

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd Inception
```

### 2. Create the `.env` file
```bash
cp srcs/.env.example srcs/.env
```
Then edit `srcs/.env` and fill in your values. The file looks like this:
```env
DOMAIN_NAME=aledos-s.42.fr
WP_URL=https://aledos-s.42.fr
WP_TITLE=Inception
WP_ADMIN_USER=aledos
WP_ADMIN_EMAIL=aledos-s@student.42.fr
WP_SECOND_USER=student
WP_SECOND_EMAIL=student@student.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
FTP_USER=ftpuser
GF_ADMIN_PASSWORD=changeme
```

### 3. Create the secrets files
Each file contains only the password, with no extra spaces or newlines.
```bash
mkdir -p secrets
echo "your_db_password"      > secrets/db_password.txt
echo "your_root_password"    > secrets/db_root_password.txt
echo "your_admin_password"   > secrets/admin_password.txt
echo "your_user2_password"   > secrets/user2_password.txt
echo "your_ftp_password"     > secrets/ftp_password.txt
```

### 4. Add the domain to `/etc/hosts`
```bash
echo "127.0.0.1 aledos-s.42.fr" | sudo tee -a /etc/hosts
```

---

## Build and launch the project

```bash
make
```

This single command will:
1. Create the data directories on the host (`/home/aledos-s/data/`)
2. Build all Docker images from their Dockerfiles
3. Start all containers in detached mode

---

## Useful commands to manage containers and volumes

| Command | Description |
|---|---|
| `make` | Build images and start all containers |
| `make down` | Stop all containers (data is preserved) |
| `make clean` | Stop containers and remove images |
| `make fclean` | Remove everything including volumes and host data |
| `make re` | Full rebuild from scratch |
| `make logs` | Follow logs of all containers |
| `make ps` | Show status of all containers |

**Enter a running container:**
```bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx bash
```

**Check Redis is caching WordPress:**
```bash
docker exec -it redis redis-cli ping
# Should return: PONG

docker exec -it redis redis-cli info stats | grep keyspace_hits
# Should show increasing hits after browsing WordPress
```

**Check MariaDB manually:**
```bash
docker exec -it mariadb mariadb -u root -p
# Enter the root password from secrets/db_root_password.txt
```

**Rebuild a single service without restarting everything:**
```bash
docker compose -f srcs/docker-compose.yml up -d --build wordpress
```

---

## Where data is stored and how it persists

Data is stored on the host machine inside `/home/aledos-s/data/` and mounted into the containers as Docker named volumes.

```
/home/aledos-s/data/
├── wordpress/    ← WordPress PHP files (mounted in nginx + wordpress containers)
├── mariadb/      ← MariaDB database files
├── prometheus/   ← Prometheus metrics history
└── grafana/      ← Grafana dashboards and settings
```

This means that if you run `make down` and then `make`, your WordPress content and database are still there. Only `make fclean` deletes this data.

**How volumes are declared in `docker-compose.yml`:**
```yaml
volumes:
  wordpress_files:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/aledos-s/data/wordpress
```
The `driver: local` with `type: none` and `o: bind` is how Docker named volumes are bound to a specific host path — this satisfies the project requirement of using named volumes stored in `/home/login/data`.