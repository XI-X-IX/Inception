
# Inception

Plateforme WordPress auto-hébergée composée de trois conteneurs Docker (Nginx, PHP-FPM/WordPress et MariaDB), orchestrés via `docker compose` dans le cadre du projet Inception (42).

## Architecture

```
Client HTTPS 443
        │
        ▼
┌───────────────┐      FastCGI 9000       ┌───────────────┐      MySQL 3306      ┌───────────────┐
│    nginx      │ ───────────────────────▶│  wordpress    │ ─────────────────────▶│   mariadb     │
│ TLS termination│                        │ PHP-FPM + WP  │                        │   database    │
└───────────────┘                         └───────────────┘                         └───────────────┘

Volumes
  wordpress_files  →  /var/www/wordpress  (partagé nginx ↔ wordpress)
  wordpress_db     →  /var/lib/mysql      (données MariaDB persistées)

Secrets montés
  wordpress : /run/secrets/db_password, /run/secrets/user2_password, /run/secrets/admin_password
  mariadb   : /run/secrets/db_root_password, /run/secrets/db_password, /run/secrets/credentials

Réseau Docker bridge : `inception`
```

## Démarrage rapide

1. Vérifier la présence de `.env` et des secrets attendus dans `./secrets/`.
2. Construire et lancer toute la stack :
   ```bash
   make all
   ```
3. Accéder à WordPress : https://aledos-s.42.fr (certificat autosigné).

## Cycle de vie des services

- Le conteneur **MariaDB** initialise la base si nécessaire et lit les secrets via `/run/secrets/*` (suffixe `.txt` facultatif).
- **WordPress** attend que la base réponde avant de lancer `wp-cli` pour configurer le site, créer l’administrateur et un second utilisateur.
- **Nginx** termine la connexion TLS et relaie les requêtes FastCGI vers PHP-FPM (port 9000).

En cas de modification sur les scripts d’init ou la configuration, relancer la stack avec `make re` garantit que toutes les images sont reconstruites et que les conteneurs repartent propres.

## Commandes utiles

### Makefile
- `<make all>` : construire les images et lancer les services en arrière-plan.
- `<make down>` : arrêter la stack et supprimer conteneurs, réseaux et volumes anonymes.
- `<make clean>` : purger les images/volumes inutilisés (`docker system prune -af`).
- `<make fclean>` : exécuter `make down` puis `make clean`.
- `<make re>` : reconstruire intégralement la stack (`make fclean` + `make all`).

### Docker Compose
- `<docker compose -f srcs/docker-compose.yml up -d>` : lancer ou rafraîchir la stack en arrière-plan.
- `<docker compose -f srcs/docker-compose.yml up --build -d mariadb>` : reconstruire uniquement MariaDB.
- `<docker compose -f srcs/docker-compose.yml restart nginx>` : redémarrer Nginx (utile après un redeploiement de WordPress/PHP-FPM).
- `<docker compose -f srcs/docker-compose.yml ps>` : afficher l’état des services.
- `<docker compose -f srcs/docker-compose.yml logs -f --tail 20 wordpress>` : suivre les logs WordPress.

### Docker (général)
- `<docker image ls>` : lister les images disponibles.
- `<docker rmi <image_id>>` : supprimer une image.
- `<docker ps>` : lister les conteneurs actifs.
- `<docker ps -a>` : inclure les conteneurs stoppés.
- `<docker exec -it mariadb bash>` : ouvrir un shell dans MariaDB.
- `<docker exec mariadb mysql -uroot -p$DB_ROOT_PASSWORD>` : accéder au client MySQL (variables issues des secrets).

### Gestion des volumes et réseaux
- `<docker volume ls>` : lister les volumes Docker.
- `<docker volume rm <nom_volume>>` : supprimer un volume (⚠️ destructif).
- `<docker network ls>` : lister les réseaux Docker.
- `<docker network rm <nom_network>>` : supprimer un réseau personnalisé.

### SSL autosigné (généré dans l’entrypoint Nginx)
- `<openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=CH/ST=VD/L=Lausanne/O=42/OU=42/CN=${DOMAIN_NAME}">` : créer le certificat et la clé utilisés par Nginx.

### Nettoyage complet (attention ⚠️)
- `<docker stop $(docker ps -qa)>` : stopper tous les conteneurs.
- `<docker rm $(docker ps -qa)>` : supprimer tous les conteneurs.
- `<docker rmi -f $(docker images -qa)>` : supprimer toutes les images.
- `<docker volume rm $(docker volume ls -q)>` : supprimer tous les volumes.
- `<docker network rm $(docker network ls -q)>` : supprimer tous les réseaux personnalisés.

## Dépannage rapide

- 502 Bad Gateway après un rebuild : redémarrer Nginx (`<docker compose -f srcs/docker-compose.yml restart nginx>`) afin qu’il se reconnecte au port FastCGI correct.
- WordPress bloqué sur “waiting for mariadb…” : vérifier que les secrets `db_root_password` et `db_password` sont présents et montés ; re-démarrer MariaDB avec `make re`.
- Accès SSH (VM) : `<ssh -p 2222 axds@127.0.0.1>`.

## Ressources

- Admin WordPress : https://aledos-s.42.fr/wp-login.php
- Documentation Docker Compose : https://docs.docker.com/compose/
- Documentation WP-CLI : https://developer.wordpress.org/cli/commands/
