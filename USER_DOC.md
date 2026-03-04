# User Documentation

## What services are running?

This project runs a complete web infrastructure made of several Docker containers:

| Service | Description | Access |
|---|---|---|
| **NGINX** | Web server, entry point of the infrastructure | `https://aledos-s.42.fr` |
| **WordPress** | The main website with PHP | `https://aledos-s.42.fr` |
| **MariaDB** | Database storing all WordPress content | Internal only |
| **Redis** | Cache system to speed up WordPress | Internal only |
| **Adminer** | Web interface to browse the database | `https://aledos-s.42.fr/adminer` |
| **FTP** | File transfer server for WordPress files | Port `21` |
| **Static site** | Simple HTML portfolio page | `https://aledos-s.42.fr/static` |
| **Prometheus** | Collects metrics from all containers | Internal only |
| **Grafana** | Displays monitoring dashboards | `https://aledos-s.42.fr/grafana/` |
| **cAdvisor** | Exposes Docker container metrics | Internal only |

---

## Start and stop the project

**Start everything:**
```bash
make
```

**Stop containers (data is kept):**
```bash
make down
```

**Stop and remove containers + images (data is kept):**
```bash
make clean
```

**Full reset — removes everything including data:**
```bash
make fclean
```

---

## Access the website and administration panel

> Your browser will show a security warning because the SSL certificate is self-signed. Click "Advanced" then "Accept the risk" to continue.

| What | URL |
|---|---|
| WordPress site | `https://aledos-s.42.fr` |
| WordPress admin panel | `https://aledos-s.42.fr/wp-admin` |
| Database interface (Adminer) | `https://aledos-s.42.fr/adminer` |
| Monitoring dashboard (Grafana) | `https://aledos-s.42.fr/grafana/` |
| Static portfolio page | `https://aledos-s.42.fr/static` |

**WordPress admin login:**
- Username and password are defined in `srcs/.env` (`WP_ADMIN_USER`) and `secrets/admin_password.txt`

**Grafana login:**
- Username: `admin`
- Password: defined in `srcs/.env` (`GF_ADMIN_PASSWORD`)

**Adminer login:**
- Server: `mariadb`
- Username and database are defined in `srcs/.env` (`MYSQL_USER`, `MYSQL_DATABASE`)
- Password is in `secrets/db_password.txt`

---

## Locate and manage credentials

All sensitive passwords are stored in the `secrets/` folder at the root of the project:

```
secrets/
├── admin_password.txt      ← WordPress admin password
├── user2_password.txt      ← WordPress second user password
├── db_password.txt         ← MariaDB user password
├── db_root_password.txt    ← MariaDB root password
└── ftp_password.txt        ← FTP user password
```

Non-sensitive variables (usernames, domain, etc.) are in `srcs/.env`.

> ⚠️ Never commit the `secrets/` folder or the `.env` file to Git.

---

## Check that services are running correctly

**See the status of all containers:**
```bash
make ps
```

All containers should show `Up` in the status column.

**See the logs of all services:**
```bash
make logs
```

**See the logs of one specific service:**
```bash
docker compose -f srcs/docker-compose.yml logs -f wordpress
```

Replace `wordpress` with any service name: `nginx`, `mariadb`, `redis`, `grafana`, etc.