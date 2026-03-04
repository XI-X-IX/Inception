LOGIN		= aledos-s
DATA_PATH	= /home/$(LOGIN)/data
COMPOSE		= docker compose -f srcs/docker-compose.yml

# Dossiers de données persistantes sur le host
DATA_DIRS	= $(DATA_PATH)/wordpress \
			  $(DATA_PATH)/mariadb \
			  $(DATA_PATH)/prometheus \
			  $(DATA_PATH)/grafana

.PHONY: all up down clean fclean re logs ps

# Lance tout : crée les dossiers, build les images, démarre les containers
all: $(DATA_DIRS)
	$(COMPOSE) up -d --build

# Crée les dossiers de données si manquants
$(DATA_DIRS):
	mkdir -p $@

# Arrête les containers sans supprimer les données
down:
	$(COMPOSE) down

# Supprime les containers et les images
clean: down
	$(COMPOSE) down --rmi all

# Supprime tout : containers, images, volumes ET données sur le host
fclean: clean
	$(COMPOSE) down -v
	sudo rm -rf $(DATA_PATH)
	docker system prune -af

# Repart de zéro
re: fclean all

# Affiche les logs de tous les services
logs:
	$(COMPOSE) logs -f

# Affiche l'état des containers
ps:
	$(COMPOSE) ps