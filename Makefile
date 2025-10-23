
all:
	docker compose -f srcs/docker-compose.yml up --build -d
# all __ 				cible par defaut
# docker compose __ 	lance docker compose
# -f srcs/....yml __ 	indique le chemin du fichier docker-compose.yml
# up --build __			lance les services et (re)construit les images dock si besoin
# -d __ 				exec les conteneurs en arriere plan


down:
	docker compose -f srcs/docker-compose.yml down
# down __ 				stop et supprime les conteneurs, reseaux etc..
# 						permet d'eteindre proprement le projet

clean:
	docker system prune -af
# clean __ 				nettoie tout ce que docker n'utilise plus
# -a -f __ 				a: supprime les images non utilise. f: force


fclean: down clean
re: fclean all
