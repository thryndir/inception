DC = docker compose -f srcs/docker-compose.yml

all: up

up:
	sh srcs/create_directory.sh
	$(DC) up --build -d

down:
	$(DC) down

logs:
	$(DC) logs -f

clean:
	$(DC) down --rmi all

fclean:
	docker system prune -a

re: clean all

.PHONY: all up down clean re logs
